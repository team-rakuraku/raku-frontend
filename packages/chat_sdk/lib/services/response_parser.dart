import 'package:fpdart/fpdart.dart';

import '../types/failure.dart';

final class ResponseParser<T> {
  final T Function(Map<String, dynamic>) parse;
  final Map<String, String> Function(Map<String, dynamic>)? headerParser;

  const ResponseParser({required this.parse, this.headerParser});

  Either<Failure, ResponseWrapper<T>> parseResponse(Object? rawData) {
    return _handleException(() {
      if (rawData is! Map<String, dynamic>) {
        return Left(
          buildFailure(
            error: Exception("Invalid format: Expected Map<String, dynamic>."),
            stackTrace: StackTrace.current,
            state: FailedState.invalidData,
          ),
        );
      }
      final data = parse(rawData);
      final headers = _parseHeaders(rawData);
      return Right(ResponseWrapper(data: data, headers: headers));
    });
  }

  Either<Failure, ResponseWrapper<List<T>>> parseListResponse(Object? rawData) {
    return _handleException(() {
      if (rawData is! Map<String, dynamic> || !rawData.containsKey('data')) {
        return Left(
          buildFailure(
            error: Exception("Missing 'data' key in the response."),
            stackTrace: StackTrace.current,
            state: FailedState.invalidData,
          ),
        );
      }

      final rawList = rawData['data'];
      if (rawList is! List) {
        return Left(
          buildFailure(
            error: Exception("Invalid format: Expected List under 'data' key."),
            stackTrace: StackTrace.current,
            state: FailedState.invalidData,
          ),
        );
      }

      final data = rawList.whereType<Map<String, dynamic>>().map(parse).toList();
      final headers = _parseHeaders(rawData);
      return Right(ResponseWrapper(data: data, headers: headers));
    });
  }

  Map<String, String> _parseHeaders(Map<String, dynamic> rawData) {
    return headerParser?.call(rawData) ?? const {};
  }

  Either<Failure, R> _handleException<R>(Either<Failure, R> Function() callback) {
    try {
      return callback();
    } catch (e, stackTrace) {
      return Left(
        buildFailure(
          error: e,
          stackTrace: stackTrace,
          state: FailedState.operationFailed,
        ),
      );
    }
  }
}

final class ResponseWrapper<T> {
  final T data;
  final Map<String, String> headers;

  const ResponseWrapper({required this.data, this.headers = const {}});
}

Failure buildFailure({
  required Object error,
  required StackTrace stackTrace,
  required FailedState state,
  String? customMessage,
}) {
  return Failure(
    state: state,
    error: error,
    message: customMessage,
    stackTrace: stackTrace,
  );
}
