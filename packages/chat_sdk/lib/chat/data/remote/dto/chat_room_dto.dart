import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entity/chat_room.dart';

part 'chat_room_dto.g.dart';

@JsonSerializable()
class ChatRoomDto {
  final int id;
  final String name;
  final String? createdAt;
  final int? count;

  const ChatRoomDto({
    required this.id,
    required this.name,
    required this.createdAt,
    this.count,
  });

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) => ChatRoomDto(
    id: json['id'] as int,
    name: json['name'] as String? ?? 'No Name',
    createdAt: json['createdAt'] as String?,
    count: json['count'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    "id": id,
    "name": name,
    "createdAt": createdAt,
    "count": count,
  };

  ChatRoom toEntity() {
    return ChatRoom(
      id: id.toString(),
      name: name,
      participantIds: const [],
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
    );
  }
}
