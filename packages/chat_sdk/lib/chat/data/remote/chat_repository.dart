import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart';

import '../../../services/remote/builder/restapi_request_builder.dart';
import '../../../services/remote/builder/socket_request_builder.dart';
import '../../../services/remote/parser/socket_response_parser.dart';
import '../../domain/data_interfaces/chat_repository_interface.dart';
import '../../domain/entity/chat_message.dart';
import '../../domain/entity/chat_room.dart';

import '../mapper/chat_mappers.dart';
import '../remote/dto/chat_room_create_dto.dart';

import 'package:chat_sdk/services/remote/transport/http_transport.dart';
import 'package:chat_sdk/services/remote/transport/socket_transport.dart';

import 'dto/chat_message_dto.dart';

final class ChatRepositoryImpl implements IChatRepository {
  final HttpTransportInterface _http;
  final SocketTransport _socket;
  final ChatMapper _mapper;

  ChatRepositoryImpl({
    required HttpTransportInterface http,
    required ChatMapper mapper,
    required String socketUrl,
  })  : _http = http,
        _socket = SocketTransport(url: socketUrl),
        _mapper = mapper;

  @override
  TaskEither<Failure, Unit> connect() => _socket.connect();

  @override
  TaskEither<Failure, Unit> disconnect() => _socket.disconnect();

  @override
  TaskEither<Failure, Unit> sendChatMessage({
    required String appId,
    required String roomId,
    required String accessToken,
    required String usersId,
    required String content,
    required String cloudFrontImageURL,
  }) {
    final message = SocketMessageBuilder()
        .appId(appId)
        .roomId(roomId)
        .usersId(usersId)
        .content(content)
        .cloudFrontImageURL(cloudFrontImageURL)
        .type("CHAT")
        .build();

    return _socket.sendMessage(
      destination: "/app/chat.queue.$roomId",
      message: message,
      headers: {"Authorization": accessToken},
    );
  }

  @override
  TaskEither<Failure, Stream<ChatMessage>> subscribeToChatMessages({
    required String roomId,
  }) {
    return _socket.subscribe(destination: "/exchange/chat.exchange/room.$roomId").flatMap(
      (frameStream) {
        final _parser = SocketResponseParser<ChatMessageDto>(
          parse: (json) {
            debugPrint("📨 수신된 원본 메시지: $json");
            return ChatMessageDto.fromJson(json);
          },
        );

        final Stream<ChatMessage> parsedStream = frameStream.asyncMap((frame) async {
          debugPrint("📨 STOMP Frame 수신: ${frame.body}");

          if (frame.body == null) {
            debugPrint("❌ STOMP Frame body가 null입니다.");
            throw Failure(
              error: Exception("STOMP Frame body가 null"),
              message: "STOMP Frame이 올바르지 않음",
              stackTrace: StackTrace.current,
            );
          }

          final parsedResult = _parser.parseFrame(frame);
          return parsedResult.fold(
            (failure) {
              debugPrint("❌ 메시지 구독 실패: ${failure.message}");
              debugPrint("Error: ${failure.error}");
              debugPrint("StackTrace: ${failure.stackTrace}");
              debugPrint("❗ 수신된 JSON: ${frame.body}");
              throw failure;
            },
            (chatMessageDto) async {
              var mappedResult = _mapper.fromChatMessageDto(chatMessageDto);

              return mappedResult.fold(
                (failure) {
                  debugPrint("❌ 메시지 매핑 실패: ${failure.message}");
                  throw failure;
                },
                (chatMessage) {
                  return chatMessage;
                },
              );
            },
          );
        });

        return TaskEither.right(parsedStream);
      },
    );
  }

  @override
  TaskEither<Failure, List<ChatRoom>> requestChatRoomsList(int page, int size) {
    final requestBuilder = RestAPIRequestBuilder(
      baseUrl: 'http://acec93397c45740cd91228806400ad86-1631035604.ap-northeast-2.elb.amazonaws.com:4000',
    ).setEndpoint('chatrooms').addQueryParameter('page', page).addQueryParameter('size', size);

    return _http.get(requestBuilder.getUrl(), requestBuilder.buildHeaders()).flatMap((response) {
      return TaskEither.fromEither(_mapper.fromJsonToChatRoomListDto(response.data))
          .flatMap((dto) => TaskEither.fromEither(_mapper.fromChatRoomListDto(dto)));
    });
  }

  @override
  TaskEither<Failure, ChatRoom> createChatRoom({
    required String appId,
    required String accessToken,
    required String userId,
    required String roomName,
  }) {
    final createDto = ChatRoomCreateDto(userId: userId, name: roomName, type: ChatRoomType.group);

    final requestBuilder = RestAPIRequestBuilder(
      baseUrl: 'http://acec93397c45740cd91228806400ad86-1631035604.ap-northeast-2.elb.amazonaws.com:4000', // 임시 주소
    ).setEndpoint('chatrooms').addHeader('Authorization', accessToken).addHeader('App-Id', appId);

    final requestBody = jsonEncode(createDto.toJson());

    return _http
        .post(
          requestBuilder.getUrl(),
          requestBuilder.buildHeaders(),
          body: requestBody,
        )
        .flatMap((_) => TaskEither.fromEither(_mapper.fromChatRoomCreateDto(createDto)));
  }

  @override
  TaskEither<Failure, ChatRoom> enterChatRoom({
    required String appId,
    required String accessToken,
    required int roomId,
    required String userId,
  }) =>
      TaskEither.left(Failure(error: UnimplementedError()));

  @override
  TaskEither<Failure, ChatRoom> leaveChatRoom({
    required String appId,
    required String accessToken,
    required int roomId,
    required String userId,
  }) =>
      TaskEither.left(Failure(error: UnimplementedError()));

  @override
  TaskEither<Failure, List<ChatRoom>> getUserChatRooms({required String userId}) =>
      TaskEither.left(Failure(error: UnimplementedError()));

  @override
  TaskEither<Failure, String> requestPresignedS3Url({
    required String fileName,
    required String fileType,
  }) {
    final innerJson = jsonEncode({
      "fileName": fileName,
      "fileType": fileType,
    });
    final requestJson = jsonEncode({"body": innerJson});
    final requestBuilder = RestAPIRequestBuilder(
      baseUrl: 'https://0fpx1gw9v5.execute-api.ap-northeast-2.amazonaws.com/prod',
    ).setEndpoint('').addHeader('Content-Type', 'application/json').setBody(requestJson);

    return _http
        .post(
      requestBuilder.getUrl(),
      requestBuilder.buildHeaders(),
      body: requestBuilder.body.getOrElse(() => ""),
    )
        .flatMap((response) {
      debugPrint("📝 raw response data: ${response.data}");

      final decodedResponse = response.data is String ? jsonDecode(response.data) : response.data;

      if (decodedResponse is! Map || !decodedResponse.containsKey('body')) {
        return TaskEither.left(Failure(
          error: Exception("Invalid response format"),
          message: "API 응답이 잘못됨",
        ));
      }

      final innerBody = jsonDecode(decodedResponse['body']);
      if (!innerBody.containsKey('uploadURL')) {
        return TaskEither.left(Failure(
          error: Exception("Missing uploadURL"),
          message: "uploadURL 누락됨",
        ));
      }

      final uploadURL = innerBody['uploadURL'] as String;
      debugPrint("🟢 PreSigned URL: $uploadURL");
      return TaskEither.right(uploadURL);
    });
  }

  @override
  TaskEither<Failure, String> uploadFileToS3({
    required String accessToken,
    required File file,
  }) {
    if (file.path.startsWith("https://")) {
      debugPrint("파일은 이미 업로드된 S3 URL입니다. 반환: ${file.path}");
      return TaskEither.right(file.path);
    }

    final fileName = file.path.split('/').last;
    final fileType = "image/jpeg"; // 필요시 동적 변경

    return requestPresignedS3Url(fileName: fileName, fileType: fileType).flatMap((preSignedUrl) {
      debugPrint("🟢 PreSigned URL: $preSignedUrl");

      return TaskEither<Failure, String>.tryCatch(
        () async {
          final fileBytes = await file.readAsBytes();
          debugPrint("🟢 업로드할 파일 크기: ${fileBytes.length} bytes");
          final dio = Dio();
          final response = await dio.put(
            preSignedUrl,
            data: fileBytes,
            options: Options(
              headers: {
                'Content-Type': fileType,
              },
            ),
          );

          debugPrint("🟢 S3 응답 코드: ${response.statusCode}");
          debugPrint("🟢 S3 응답 데이터: ${response.data}");

          if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
            final s3Url = "https://media-crud.s3.ap-northeast-2.amazonaws.com/uploads/$fileName";
            debugPrint("✅ 업로드 완료: $s3Url");
            return s3Url;
          } else {
            throw Exception("S3 업로드 실패: ${response.statusCode} - ${response.data}");
          }
        },
        (error, stack) {
          debugPrint("❌ S3 업로드 중 예외 발생: $error");
          return Failure(error: error, stackTrace: stack);
        },
      );
    });
  }

  @override
  TaskEither<Failure, List<ChatMessage>> getChatHistory({required String roomId}) {
    final requestBuilder = RestAPIRequestBuilder(
      baseUrl:
          'http://acec93397c45740cd91228806400ad86-1631035604.ap-northeast-2.elb.amazonaws.com:4000/chatrooms/detail/$roomId', // 임시주소
    ).addQueryParameter('page', 0).addQueryParameter('size', 100);

    return _http.get(requestBuilder.getUrl(), requestBuilder.buildHeaders()).flatMap((response) {
      return TaskEither.fromEither(
        _mapper.fromJsonToChatMessageListDto(response.data),
      ).map((chatMessages) {
        return chatMessages.map((msg) {
          return msg;
        }).toList();
      });
    });
  }
}
