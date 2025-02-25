import 'dart:convert';

import 'package:chat_sdk/chat/data/remote/dto/chat_room_create_dto.dart';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../domain/entity/chat_message.dart';
import '../../domain/entity/chat_room.dart';

import '../../data/remote/dto/chat_room_list_dto.dart';
import '../../data/remote/dto/chat_room_enter_dto.dart';
import '../../data/remote/dto/chat_room_leave_dto.dart';
import '../../data/remote/dto/chat_message_dto.dart';
import '../remote/dto/chat_room_create_response_dto.dart';

final class ChatMapper {
  Either<Failure, List<ChatRoom>> fromChatRoomListDto(ChatRoomListDto dto) {
    try {
      final rooms = dto.content.map((roomDto) => roomDto.toEntity()).toList();
      return Right(rooms);
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatRoomListDto 매핑 실패",
      ));
    }
  }

  Either<Failure, ChatRoom> fromChatRoomEnterDto(ChatRoomEnterDto dto) {
    try {
      final room = ChatRoom(
        id: "entered-room-id",
        name: "EnteredRoom",
        participantIds: [dto.userId],
        createdAt: DateTime.now(),
      );
      return Right(room);
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatRoomEnterDto 매핑 실패",
      ));
    }
  }

  Either<Failure, ChatRoom> fromChatRoomLeaveDto(ChatRoomLeaveDto dto) {
    try {
      final room = ChatRoom(
        id: "left-room-id",
        name: "LeftRoom",
        participantIds: const [],
        createdAt: DateTime.now(),
      );
      return Right(room);
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatRoomLeaveDto 매핑 실패",
      ));
    }
  }

  Either<Failure, ChatMessage> fromChatMessageDto(ChatMessageDto dto) {
    try {
      final msg = ChatMessage(
        messageId: "msg-${DateTime.now().microsecondsSinceEpoch}",
        senderId: dto.userId,
        roomId: dto.roomId,
        content: dto.content,
        createdAt: DateTime.now(),
      );
      return Right(msg);
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatMessageDto 매핑 실패",
      ));
    }
  }

  Either<Failure, ChatMessageDto> toChatMessageDto(ChatMessage msg) {
    try {
      final dto = ChatMessageDto(
        roomId: msg.roomId,
        userId: msg.senderId,
        content: msg.content,
        cloudFrontImageURL: msg.imageUrl,
        type: "TEXT",
      );
      return Right(dto);
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatMessage -> ChatMessageDto 매핑 실패",
      ));
    }
  }

  Either<Failure, ChatMessageDto> fromStompFrame(StompFrame frame) {
    try {
      final decoded = jsonDecode(frame.body!) as Map<String, dynamic>;

      final chatMessageDto = ChatMessageDto(
        roomId: decoded['roomId'] as String? ?? '',
        userId: decoded['userId'] as String? ?? '',
        content: decoded['content'] as String? ?? '',
        cloudFrontImageURL: decoded['cloudFrontImageURL'] as String?,
        type: decoded['type'] as String? ?? 'TEXT',
      );

      return Right(chatMessageDto);
    } catch (error, stackTrace) {
      return Left(Failure(
        error: error,
        stackTrace: stackTrace,
        message: "STOMP Frame 파싱 실패",
      ));
    }
  }

  Either<Failure, ChatRoomListDto> fromJsonToChatRoomListDto(Map<String, dynamic> json) {
    try {
      return Right(ChatRoomListDto.fromJson(json));
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatRoomListDto JSON 변환 실패",
      ));
    }
  }

  Either<Failure, ChatRoomCreateDto> fromJsonToChatRoomCreateDto(Map<String, dynamic> json) {
    try {
      return Right(ChatRoomCreateDto.fromJson(json));
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatRoomCreateDto JSON 변환 실패",
      ));
    }
  }

  Either<Failure, ChatRoom> fromChatRoomCreateDto(ChatRoomCreateDto dto) {
    try {
      final chatRoom = ChatRoom(
        id: "temporary-id-${DateTime.now().millisecondsSinceEpoch}", // 임시 ID
        name: dto.name,
        participantIds: [dto.userId],
        createdAt: DateTime.now(),
      );
      return Right(chatRoom);
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatRoomCreateDto -> ChatRoom 매핑 실패",
      ));
    }
  }

  Either<Failure, ChatRoom> fromChatRoomCreateResponseDto(ChatRoomCreateResponseDto dto) {
    try {
      if (dto.data == null) {
        return Right(ChatRoom(
          id: "unknown",
          name: "Unnamed Room",
          participantIds: [],
          createdAt: DateTime.now(),
        ));
      }

      return Right(ChatRoom(
        id: dto.data?['id'] ?? "unknown",
        name: dto.data?['name'] ?? "Unnamed Room",
        participantIds: List<String>.from(dto.data?['participantIds'] ?? []),
        createdAt: dto.data?['createdAt'] != null
            ? DateTime.parse(dto.data!['createdAt'])
            : DateTime.now(),
      ));
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "ChatRoomCreateResponseDto -> ChatRoom 매핑 실패",
      ));
    }
  }

  Either<Failure, List<ChatMessage>> fromJsonToChatMessageListDto(Map<String, dynamic> json) {
    try {
      final List<dynamic> messagesJson = json['data'] as List<dynamic>;

      final messages = messagesJson.map((message) {
        return ChatMessage(
          messageId: "msg-${DateTime.now().microsecondsSinceEpoch}",
          senderId: message['userId'] as String? ?? '',
          roomId: message['roomId'] as String? ?? '',
          content: message['content'] as String? ?? '',
          createdAt: message['time'] != null
              ? DateTime.parse(message['time'])
              : DateTime.now(),
          imageUrl: message['cloudFrontImageURL'] as String?,
        );
      }).toList();

      return Right(messages);
    } catch (error, stack) {
      return Left(Failure(
        error: error,
        stackTrace: stack,
        message: "채팅 메시지 리스트 변환 실패",
      ));
    }
  }


}
