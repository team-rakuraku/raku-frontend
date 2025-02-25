import 'package:fpdart/fpdart.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';

import '../../../types/failure.dart';

final class SocketResponseParser<T> {
  final T Function(Map<String, dynamic>) parse;

  const SocketResponseParser({required this.parse});

  Either<Failure, T> parseFrame(StompFrame frame) {
    try {
      if (frame.body == null || frame.body!.isEmpty) {
        return Left(Failure(
          error: Exception('응답 본문이 비어 있습니다.'),
          stackTrace: StackTrace.current,
          message: '소켓 응답 파싱 실패: 본문이 비어 있습니다.',
        ));
      }

      final Map<String, dynamic> json = jsonDecode(frame.body!);
      final T parsedData = parse(json);

      return Right(parsedData);
    } catch (error, stackTrace) {
      return Left(Failure(
        error: error,
        stackTrace: stackTrace,
        message: '소켓 응답 파싱 중 오류 발생',
      ));
    }
  }
}
