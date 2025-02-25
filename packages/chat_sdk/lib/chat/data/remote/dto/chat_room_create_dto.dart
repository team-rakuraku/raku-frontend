import 'package:json_annotation/json_annotation.dart';

part 'chat_room_create_dto.g.dart';

enum ChatRoomType {
  @JsonValue("SINGLE")
  single,

  @JsonValue("GROUP")
  group,
}

@JsonSerializable()
final class ChatRoomCreateDto {
  final String userId;
  final String name;

  @JsonKey(unknownEnumValue: ChatRoomType.single)
  final ChatRoomType type;

  @JsonKey(defaultValue: [])
  final List<String> invitedUserIds;

  const ChatRoomCreateDto({
    required this.userId,
    required this.name,
    required this.type,
    this.invitedUserIds = const [],
  });

  factory ChatRoomCreateDto.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomCreateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomCreateDtoToJson(this);
}
