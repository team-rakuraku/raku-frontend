import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
final class ChatMessage {
  final String appId;
  final String usersId;
  final String content;
  final String type;

  const ChatMessage({
    required this.appId,
    required this.usersId,
    required this.content,
    required this.type,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
