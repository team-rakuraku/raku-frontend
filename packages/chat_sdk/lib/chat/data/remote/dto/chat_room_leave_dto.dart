import 'package:json_annotation/json_annotation.dart';

part 'chat_room_leave_dto.g.dart';

@JsonSerializable()
final class ChatRoomLeaveDto {
  final String userId;

  const ChatRoomLeaveDto({
    required this.userId,
  });

  factory ChatRoomLeaveDto.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomLeaveDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomLeaveDtoToJson(this);
}
