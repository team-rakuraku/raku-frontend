import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final String name;
  final List<String> participantIds;
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.participantIds,
    required this.createdAt,
  });


  ChatRoom copyWith({
    String? id,
    String? name,
    List<String>? participantIds,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, participantIds, createdAt];
}
