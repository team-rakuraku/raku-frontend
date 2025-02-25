import 'package:json_annotation/json_annotation.dart';

part 'chat_message_dto.g.dart';

@JsonSerializable()
final class ChatMessageDto {
  final String roomId;
  final String userId;
  final String content;
  final String? cloudFrontImageURL;
  final String type;

  const ChatMessageDto({
    required this.roomId,
    required this.userId,
    required this.content,
    required this.type,
    this.cloudFrontImageURL,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      roomId: json['roomId'] as String? ?? '',
      userId: json['usersId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      cloudFrontImageURL: json['cloudFrontImageURL'] as String?,
      type: json['type'] as String? ?? 'TEXT',
    );
  }

  Map<String, dynamic> toJson() => _$ChatMessageDtoToJson(this);
}
