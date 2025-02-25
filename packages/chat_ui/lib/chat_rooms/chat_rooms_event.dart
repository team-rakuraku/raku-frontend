import 'package:equatable/equatable.dart';

sealed class ChatRoomsEvent extends Equatable {
  const ChatRoomsEvent();

  @override
  List<Object?> get props => [];
}

final class FetchUserChatRooms extends ChatRoomsEvent {
  final String userId;

  const FetchUserChatRooms(this.userId);

  @override
  List<Object?> get props => [userId];
}

final class FetchAllChatRooms extends ChatRoomsEvent {
  final int page;
  final int size;

  const FetchAllChatRooms(this.page, this.size);

  @override
  List<Object?> get props => [page];
}
