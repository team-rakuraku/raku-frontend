import 'package:json_annotation/json_annotation.dart';

part 'chat_room_enter_dto.g.dart';

@JsonSerializable()
final class ChatRoomEnterDto {
  final String userId;

  const ChatRoomEnterDto({required this.userId});

  factory ChatRoomEnterDto.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomEnterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomEnterDtoToJson(this);
}
