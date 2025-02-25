import 'package:equatable/equatable.dart';
import 'package:chat_sdk/chat/domain/entity/chat_message.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class SendMessage extends ChatEvent {
  final ChatMessage message;
  final String accessToken;
  final bool hasImage;


  const SendMessage({
    required this.message,
    required this.accessToken,
    this.hasImage = false,
  });

  @override
  List<Object?> get props => [message, accessToken, hasImage];
}

final class SubscribeToMessages extends ChatEvent {
  final String roomId;

  const SubscribeToMessages({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

final class NewMessageReceived extends ChatEvent {
  final ChatMessage message;

  const NewMessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

final class ConnectToChat extends ChatEvent {}

final class DisconnectFromChat extends ChatEvent {}

final class FetchChatHistory extends ChatEvent {
  final String roomId;
  const FetchChatHistory({required this.roomId});
}

final class ReceiveMessage extends ChatEvent {
  final ChatMessage message;

  const ReceiveMessage({required this.message});

  @override
  List<Object?> get props => [message];
}
