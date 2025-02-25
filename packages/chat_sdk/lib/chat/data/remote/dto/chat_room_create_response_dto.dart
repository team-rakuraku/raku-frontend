import 'package:json_annotation/json_annotation.dart';

part 'chat_room_create_response_dto.g.dart';

@JsonSerializable()
final class ChatRoomCreateResponseDto {
  final String status;
  final String message;
  final Map<String, dynamic>? data;

  const ChatRoomCreateResponseDto({
    required this.status,
    required this.message,
    this.data,
  });

  factory ChatRoomCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomCreateResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomCreateResponseDtoToJson(this);
}
