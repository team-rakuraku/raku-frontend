import 'package:json_annotation/json_annotation.dart';
import 'chat_room_dto.dart';

part 'chat_room_list_dto.g.dart';

@JsonSerializable()
class ChatRoomListDto {
  final int page;
  final List<ChatRoomDto> content;

  const ChatRoomListDto({
    required this.page,
    required this.content,
  });

  factory ChatRoomListDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    if (data == null) {
      return const ChatRoomListDto(page: 0, content: []);
    }

    final contentList = data['content'] as List<dynamic>? ?? [];

    final pageNumber = data['number'] as int? ?? 0;

    return ChatRoomListDto(
      page: pageNumber,
      content: contentList
          .map((e) => ChatRoomDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
