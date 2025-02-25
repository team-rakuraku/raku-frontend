import 'dart:async';
import 'dart:io';
import 'package:chat_sdk/chat/domain/entity/chat_message.dart';
import 'package:chat_sdk/types/failure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_sdk/chat/domain/usecases/chat_usecase.dart';
import 'package:fpdart/fpdart.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase chatUseCase;
  StreamSubscription<ChatMessage>? _messageSubscription;

  ChatBloc({required this.chatUseCase}) : super(const ChatState()) {
    on<ConnectToChat>(_onConnectToChat);
    on<DisconnectFromChat>(_onDisconnectFromChat);
    on<SendMessage>(_onSendMessage);
    on<SubscribeToMessages>(_onSubscribeToMessages);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<FetchChatHistory>(_onFetchChatHistory);
    on<ReceiveMessage>((event, emit) {
      // 현재 메시지 리스트를 가져온 뒤,
      final updatedMessages = List<ChatMessage>.from(state.messages)
        ..add(event.message);

      // 새로운 상태로 emit
      emit(state.copyWith(
        messages: updatedMessages,
      ));
    });


  }

  /// ✅ STOMP 서버 연결
  Future<void> _onConnectToChat(
      ConnectToChat event,
      Emitter<ChatState> emit,
      ) async {
    final either = await chatUseCase.connect().run();
    either.fold(
          (failure) => emit(state.copyWith(status: ChatStatus.error, error: failure)),
          (_) => emit(state.copyWith(status: ChatStatus.connected)),
    );
  }

  /// ✅ STOMP 서버 연결 해제
  Future<void> _onDisconnectFromChat(
      DisconnectFromChat event,
      Emitter<ChatState> emit,
      ) async {
    _messageSubscription?.cancel();
    final either = await chatUseCase.disconnect().run();
    either.fold(
          (failure) => emit(state.copyWith(status: ChatStatus.error, error: failure)),
          (_) => emit(state.copyWith(status: ChatStatus.disconnected)),
    );
  }

  Future<void> _onSendMessage(
      SendMessage event,
      Emitter<ChatState> emit,
      ) async {
    debugPrint("📨 메시지 전송 시작: ${event.message.content}");

    String? finalImageUrl = event.message.imageUrl;
    if (event.hasImage && !(event.message.imageUrl?.startsWith("http") ?? false)) {
      final filePath = event.message.imageUrl!;
      final file = File(filePath);
      final uploadEither = await chatUseCase.uploadFileToS3(
        accessToken: event.accessToken,
        file: file,
      ).run();

      uploadEither.fold(
            (failure) {
          debugPrint("❌ 이미지 업로드 실패: ${failure.message}");
          emit(state.copyWith(status: ChatStatus.error, error: failure));
          return;
        },
            (s3Url) {
          debugPrint("✅ 이미지 업로드 성공: $s3Url");
          if (s3Url.startsWith("https://mybucket.s3.amazonaws.com/")) {
            finalImageUrl = s3Url.replaceFirst(
              "https://mybucket.s3.amazonaws.com/",
              "https://d3example.cloudfront.net/",
            );
          } else {
            finalImageUrl = s3Url;
          }
        },
      );
    }

    final ChatMessage updatedMessage = event.message.copyWith(
      // imageUrl: finalImageUrl,
      imageUrl: finalImageUrl,
    );

    // 여기서 상태에 추가하는 옵티미스틱 업데이트를 제거합니다.
    // 최종 STOMP 전송 결과를 기다려 구독 이벤트로 추가되도록 함.

    final either = await chatUseCase.sendChatMessage(
      message: updatedMessage,
      accessToken: event.accessToken,
    ).run();

    either.fold(
          (failure) {
        debugPrint("❌ 메시지 전송 실패: ${failure.message}");
        emit(state.copyWith(status: ChatStatus.error, error: failure));
      },
          (_) {
        debugPrint("✅ 메시지 전송 성공: ${updatedMessage.content}");
      },
    );
  }


  /// ✅ 메시지 구독 시작
  Future<void> _onSubscribeToMessages(
      SubscribeToMessages event,
      Emitter<ChatState> emit,
      ) async {
    debugPrint("📡 메시지 구독 시작: ${event.roomId}");

    final either = await chatUseCase.subscribeToChatMessages(
      roomId: event.roomId,
    ).run();

    either.fold(
          (failure) {
        debugPrint("❌ 메시지 구독 실패: ${failure.message}");
        debugPrint("Error: ${failure.error}");
        debugPrint("StackTrace: ${failure.stackTrace}");
        emit(state.copyWith(status: ChatStatus.error, error: failure));
      },
          (messageStream) {
        debugPrint("✅ 메시지 구독 성공!");

        _messageSubscription?.cancel();
        _messageSubscription = messageStream.listen(
              (message) {
            debugPrint("📩 새 메시지 수신: ${message.content}");
            add(NewMessageReceived(message: message));
          },
          onError: (error, stackTrace) {
            debugPrint("❌ 메시지 스트림 오류: $error");
            debugPrint("StackTrace: $stackTrace");
          },
          onDone: () {
            debugPrint("✅ 메시지 스트림 종료됨.");
          },
        );
      },
    );
  }

  /// ✅ 새로운 메시지 수신 시 상태 업데이트
  void _onNewMessageReceived(
      NewMessageReceived event,
      Emitter<ChatState> emit,
      ) {
    final received = event.message;

    // 1️⃣ tempId가 같다면 같은 메시지로 간주하고 업데이트
    if (received.tempId != null) {
      final idx = state.messages.indexWhere((m) => m.tempId == received.tempId);
      if (idx != -1) {
        final updatedList = List<ChatMessage>.from(state.messages);
        updatedList[idx] = updatedList[idx].copyWith(
          messageId: received.messageId,
          imageUrl: received.imageUrl, // 최종 S3 URL 적용
          createdAt: received.createdAt,
        );
        emit(state.copyWith(messages: updatedList));
        return;
      }
    }

    // 2️⃣ 기존에 추가되지 않은 메시지라면 UI에 즉시 반영
    if (!state.messages.any((m) => m.messageId == received.messageId)) {
      emit(state.copyWith(messages: [...state.messages, received]));
    }

  }

  Future<void> _onFetchChatHistory(
      FetchChatHistory event,
      Emitter<ChatState> emit,
      ) async {
    debugPrint("📜 채팅 내역 불러오기: ${event.roomId}");

    final either = await chatUseCase.getChatHistory(roomId: event.roomId).run();

    either.fold(
          (failure) {
        debugPrint("❌ 채팅 내역 불러오기 실패: ${failure.message}");
        emit(state.copyWith(status: ChatStatus.error, error: failure));
      },
          (chatMessages) {
        debugPrint("✅ 채팅 내역 로드 완료 (${chatMessages.length}개)");
        emit(state.copyWith(messages: chatMessages));
      },
    );
  }

  TaskEither<Failure, String> requestPresignedS3Url(String fileName, String fileType) {
    return chatUseCase.requestPresignedS3Url(fileName, fileType);
  }

  // ▼ 2) S3 파일 업로드
  TaskEither<Failure, String> uploadFileToS3({
    required String accessToken,
    required File file,
  }) {
    return chatUseCase.uploadFileToS3(accessToken: accessToken, file: file);
  }



}

