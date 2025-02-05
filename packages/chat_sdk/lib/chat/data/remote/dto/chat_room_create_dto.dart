import 'package:json_annotation/json_annotation.dart';

part 'chat_room_create_dto.g.dart';

@JsonSerializable()
final class ChatRoomCreateDto {
  final String userId;
  final String name;
  final String type;
  final List<String> invitedUserIds;

  const ChatRoomCreateDto({
    required this.userId,
    required this.name,
    required this.type,
    required this.invitedUserIds,
  });

  factory ChatRoomCreateDto.fromJson(Map<String, dynamic> json) => _$ChatRoomCreateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomCreateDtoToJson(this);
}
