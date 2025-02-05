import 'package:fpdart/fpdart.dart';

import '../../../types/failure.dart';
import '../../data/remote/dto/chat_message_dto.dart';

abstract interface class IChatRemoteService {
  TaskEither<Failure, Unit> connect();

  TaskEither<Failure, Unit> disconnect();

  TaskEither<Failure, Unit> sendChatMessage({
    required String roomId,
    required String accessToken,
    required ChatMessageDto message,
  });

  TaskEither<Failure, Stream<ChatMessageDto>> subscribeToChatMessages({
    required String roomId,
  });
}
