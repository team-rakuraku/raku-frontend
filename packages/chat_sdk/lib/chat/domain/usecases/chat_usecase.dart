import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart';

import '../data_interfaces/chat_repository_interface.dart';
import '../entity/chat_message.dart';
import '../entity/chat_room.dart';

final class ChatUseCase {
  final IChatRepository _repository;

  ChatUseCase(this._repository);

  TaskEither<Failure, Unit> connect() => _repository.connect();

  TaskEither<Failure, Unit> disconnect() => _repository.disconnect();

  TaskEither<Failure, Unit> sendChatMessage({
    required ChatMessage message,
    required String accessToken,
  }) {
    return _repository.sendChatMessage(
      appId: message.roomId,
      roomId: message.roomId,
      accessToken: accessToken,
      usersId: message.senderId,
      content: message.content,
      cloudFrontImageURL: message.imageUrl ?? "",
    );
  }

  TaskEither<Failure, Stream<ChatMessage>> subscribeToChatMessages({
    required String roomId,
  }) {
    return _repository.subscribeToChatMessages(roomId: roomId);
  }

  TaskEither<Failure, List<ChatRoom>> requestChatRoomsList(int page, int size) {
    return _repository.requestChatRoomsList(page, size);
  }

  TaskEither<Failure, ChatRoom> createChatRoom({
    required String appId,
    required String accessToken,
    required String userId,
    required String roomName,
  }) {
    return _repository.createChatRoom(
      appId: appId,
      accessToken: accessToken,
      userId: userId,
      roomName: roomName,
    );
  }

  TaskEither<Failure, ChatRoom> enterChatRoom({
    required String appId,
    required String accessToken,
    required int roomId,
    required String userId,
  }) {
    return _repository.enterChatRoom(
      appId: appId,
      accessToken: accessToken,
      roomId: roomId,
      userId: userId,
    );
  }

  TaskEither<Failure, ChatRoom> leaveChatRoom({
    required String appId,
    required String accessToken,
    required int roomId,
    required String userId,
  }) {
    return _repository.leaveChatRoom(
      appId: appId,
      accessToken: accessToken,
      roomId: roomId,
      userId: userId,
    );
  }

  TaskEither<Failure, List<ChatRoom>> getUserChatRooms({required String userId}) {
    return _repository.getUserChatRooms(userId: userId);
  }

  TaskEither<Failure, String> requestPresignedS3Url(String fileName, String fileType) {
    return _repository.requestPresignedS3Url(fileName: fileName, fileType: fileType);
  }

  TaskEither<Failure, String> uploadFileToS3({
    required String accessToken,
    required File file,
  }) {
    return _repository.uploadFileToS3(
      accessToken: accessToken,
      file: file,
    );
  }

  TaskEither<Failure, List<ChatMessage>> getChatHistory({required String roomId}) {
    return _repository.getChatHistory(roomId: roomId);
  }
}
