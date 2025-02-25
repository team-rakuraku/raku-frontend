import 'package:equatable/equatable.dart';
import 'package:chat_sdk/chat/domain/entity/chat_message.dart';
import 'package:chat_sdk/types/failure.dart';

enum ChatStatus { initial, loading, connected, disconnected, error }

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final ChatStatus status;
  final Failure? error;

  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.initial,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    Failure? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, status, error];
}
