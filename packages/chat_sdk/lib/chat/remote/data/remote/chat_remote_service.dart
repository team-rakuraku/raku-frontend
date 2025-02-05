import 'dart:async';
import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart';

import '../../../../services/remote/builder/socket_request_builder.dart';
import '../../../../services/remote/transport/socket_transport.dart';
import '../../domain/data_interfaces/chat_room_service_interface.dart';
import 'dto/chat_message.dart';


final class ChatRemoteService implements IChatRemoteService {
  final SocketTransportInterface socketTransport;
  final SocketResponseParser<ChatMessage> messageParser;

  ChatRemoteService({
    required this.socketTransport,
    required this.messageParser,
  });

  @override
  TaskEither<Failure, Unit> connect() => socketTransport.connect();

  @override
  TaskEither<Failure, Unit> disconnect() => socketTransport.disconnect();

  @override
  TaskEither<Failure, Unit> sendChatMessage({
    required String roomId,
    required String accessToken,
    required ChatMessage message,
  }) {
    final messageJson = jsonEncode({
      "appId": message.appId,
      "usersId": message.usersId,
      "content": message.content,
      "type": message.type,
    });
    return socketTransport.sendMessage(
      destination: "/app/$roomId",
      message: messageJson,
      headers: {"Authorization": accessToken},
    );
  }

  @override
  TaskEither<Failure, Stream<ChatMessage>> subscribeToChatMessages({
    required String roomId,
  }) {
    return TaskEither.fromEither(
      socketTransport.subscribe(destination: "/topic/$roomId"),
    ).flatMap((stompFrameStream) {
      final chatMessageStream = stompFrameStream.asyncMap((stompFrame) async {
        final eitherChatMessage = await TaskEither<Failure, ChatMessage>.tryCatch(
          () async {
            final parseResult = messageParser.parseFrame(stompFrame);
            return parseResult.fold(
              (failure) => throw failure,
              (wrapper) => wrapper.data,
            );
          },
          (error, stackTrace) {
            if (error is Failure) {
              return buildFailure(
                error: error.error,
                stackTrace: stackTrace,
                message: 'Error parsing chat message: ${error.message}',
                cause: error,
              );
            } else {
              return buildFailure(
                error: error,
                stackTrace: stackTrace,
                message: 'Error parsing chat message: ${error.toString()}',
              );
            }
          },
        ).run();
        return eitherChatMessage.fold(
          (failure) => throw Exception(failure.fullErrorMessage),
          (data) => data,
        );
      });
      return TaskEither.right(chatMessageStream);
    });
  }
}
