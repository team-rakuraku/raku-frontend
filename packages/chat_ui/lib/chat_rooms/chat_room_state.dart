import 'package:chat_sdk/chat/domain/entity/chat_room.dart';
import 'package:equatable/equatable.dart';
import 'package:chat_sdk/types/failure.dart';

enum ChatRoomsStatus { initial, loading, success, failure }

class ChatRoomsState extends Equatable {
  final List<ChatRoom> myRooms;
  final List<ChatRoom> allRooms;
  final ChatRoomsStatus status;
  final Failure? error;
  final bool lastPage;

  const ChatRoomsState({
    this.myRooms = const [],
    this.allRooms = const [],
    this.status = ChatRoomsStatus.initial,
    this.error,
    this.lastPage = false,
  });

  ChatRoomsState copyWith({
    List<ChatRoom>? myRooms,
    List<ChatRoom>? allRooms,
    ChatRoomsStatus? status,
    Failure? error,
    bool? lastPage,
  }) {
    return ChatRoomsState(
      myRooms: myRooms ?? this.myRooms,
      allRooms: allRooms ?? this.allRooms,
      status: status ?? this.status,
      error: error,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  @override
  List<Object?> get props => [myRooms, allRooms, status, error, lastPage];
}
