import 'package:json_annotation/json_annotation.dart';

part 'chat_message_dto.g.dart';

@JsonSerializable()
final class ChatMessageDto {
  final String appId;
  final String usersId;
  final String content;
  final String type;

  const ChatMessageDto({
    required this.appId,
    required this.usersId,
    required this.content,
    required this.type,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
