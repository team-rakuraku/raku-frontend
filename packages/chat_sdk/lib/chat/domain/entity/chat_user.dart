import 'package:equatable/equatable.dart';

final class ChatUser extends Equatable {
  final String id;
  final String nickname;
  final String avatarUrl;

  const ChatUser({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
  });

  ChatUser copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
  }) {
    return ChatUser(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, nickname, avatarUrl];
}
