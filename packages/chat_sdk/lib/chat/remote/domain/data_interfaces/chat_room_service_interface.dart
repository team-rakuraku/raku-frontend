import 'package:fpdart/fpdart.dart';

import '../../../../types/failure.dart';
import '../../data/remote/dto/chat_message.dart';

abstract interface class IChatRemoteService {
  TaskEither<Failure, Unit> connect();

  TaskEither<Failure, Unit> disconnect();

  TaskEither<Failure, Unit> sendChatMessage({
    required String roomId,
    required String accessToken,
    required ChatMessage message,
  });

  TaskEither<Failure, Stream<ChatMessage>> subscribeToChatMessages({
    required String roomId,
  });
}
