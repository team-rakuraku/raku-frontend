import 'dart:async';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart';

import '../entity/chat_room.dart';
import '../entity/chat_message.dart';

abstract interface class IChatRepository {
  TaskEither<Failure, List<ChatMessage>> getChatHistory({required String roomId});

  TaskEither<Failure, Unit> connect();

  TaskEither<Failure, Unit> disconnect();

  TaskEither<Failure, Stream<ChatMessage>> subscribeToChatMessages({
    required String roomId,
  });

  TaskEither<Failure, Unit> sendChatMessage({
    required String appId,
    required String roomId,
    required String accessToken,
    required String usersId,
    required String content,
    required String cloudFrontImageURL,
  });

  TaskEither<Failure, List<ChatRoom>> requestChatRoomsList(int page, int size);

  TaskEither<Failure, ChatRoom> createChatRoom({
    required String appId,
    required String accessToken,
    required String userId,
    required String roomName,
  });

  TaskEither<Failure, ChatRoom> enterChatRoom({
    required String appId,
    required String accessToken,
    required int roomId,
    required String userId,
  });

  TaskEither<Failure, ChatRoom> leaveChatRoom({
    required String appId,
    required String accessToken,
    required int roomId,
    required String userId,
  });

  TaskEither<Failure, List<ChatRoom>> getUserChatRooms({
    required String userId,
  });

  TaskEither<Failure, String> requestPresignedS3Url({
    required String fileName,
    required String fileType,
  });

  TaskEither<Failure, String> uploadFileToS3({
    required String accessToken,
    required File file,
  });
}
