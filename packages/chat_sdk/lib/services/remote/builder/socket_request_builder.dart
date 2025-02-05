import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../types/failure.dart';

final class SocketResponseWrapper<T> {
  final T data;
  final Map<String, String> headers;

  const SocketResponseWrapper({
    required this.data,
    this.headers = const {},
  });
}

final class SocketResponseParser<T> {
  final T Function(Map<String, dynamic>) parse;
  final Map<String, String> Function(Map<String, dynamic>)? headerParser;

  const SocketResponseParser({
    required this.parse,
    this.headerParser,
  });

  /// StompFrame 의 body를 JSON으로 파싱하여 도메인 모델로 변환
  Either<Failure, SocketResponseWrapper<T>> parseFrame(StompFrame frame) {
    try {
      if (frame.body == null || frame.body!.isEmpty) {
        return Left(buildFailure(
          error: Exception('응답 본문이 비어 있습니다.'),
          stackTrace: StackTrace.current,
          message: '소켓 응답 파싱 실패: 본문이 비어 있습니다.',
        ));
      }

      final Map<String, dynamic> json = jsonDecode(frame.body!);

      final T parsedData = parse(json);

      // 헤더 파싱 (옵션)
      final headers = headerParser?.call(json) ?? frame.headers;

      return Right(SocketResponseWrapper(
        data: parsedData,
        headers: headers,
      ));
    } catch (error, stackTrace) {
      return Left(buildFailure(
        error: error,
        stackTrace: stackTrace,
        message: '소켓 응답 파싱 중 오류 발생',
      ));
    }
  }
}
