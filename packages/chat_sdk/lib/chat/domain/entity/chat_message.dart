import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String messageId;   // 실제 메시지 ID (서버 전송 후 업데이트)
  final String? tempId;     // 옵티미스틱 업데이트 시 임시 ID
  final String senderId;
  final String roomId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  const ChatMessage({
    required this.messageId,
    this.tempId,
    required this.senderId,
    required this.roomId,
    required this.content,
    required this.createdAt,
    this.imageUrl,
  });

  ChatMessage copyWith({
    String? messageId,
    String? tempId,
    String? senderId,
    String? roomId,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      tempId: tempId ?? this.tempId,
      senderId: senderId ?? this.senderId,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [messageId, tempId, senderId, roomId, content, imageUrl, createdAt];
}
