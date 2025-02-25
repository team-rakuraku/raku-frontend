import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart';

abstract interface class HttpTransportInterface {
  TaskEither<Failure, Response> get(String url, Map<String, String> headers, {String? body});
  TaskEither<Failure, Response> post(String url, Map<String, String> headers, {String? body});
  TaskEither<Failure, Response> put(String url, Map<String, String> headers, {String? body});
  TaskEither<Failure, Response> delete(String url, Map<String, String> headers);
  TaskEither<Failure, Response> patch(String url, Map<String, String> headers, {String? body});
}

final class HttpTransport extends HttpTransportInterface {
  final Dio dio;

  HttpTransport(this.dio) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  @override
  TaskEither<Failure, Response> get(String url, Map<String, String> headers, {String? body}) {
    return _sendRequest(url, headers, (url, options) =>
        dio.get(url, options: options));
  }

  @override
  TaskEither<Failure, Response> post(String url, Map<String, String> headers, {String? body}) {
    return _sendRequest(url, headers, (url, options) =>
        dio.post(url, options: options, data: body));
  }

  @override
  TaskEither<Failure, Response> put(String url, Map<String, String> headers, {String? body}) {
    return _sendRequest(url, headers, (url, options) =>
        dio.put(url, options: options, data: body));
  }

  @override
  TaskEither<Failure, Response> delete(String url, Map<String, String> headers) {
    return _sendRequest(url, headers, (url, options) =>
        dio.delete(url, options: options));
  }

  @override
  TaskEither<Failure, Response> patch(String url, Map<String, String> headers, {String? body}) {
    return _sendRequest(url, headers, (url, options) =>
        dio.patch(url, options: options, data: body));
  }

  TaskEither<Failure, Response> _sendRequest(
      String url,
      Map<String, String> headers,
      Future<Response> Function(String, Options) dioCall,
      ) {
    return TaskEither<Failure, Response>.tryCatch(
          () async {
        final options = Options(
          headers: headers,
        );

        return await dioCall(url, options);
      },
          (error, stackTrace) {
        return error is Failure
            ? error
            : mapDioExceptionToFailure(error, stackTrace, url);
      },
    );
  }

  Failure mapDioExceptionToFailure(Object error, StackTrace stackTrace, String url) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseBody = error.response?.data;

      final message = switch (error.type) {
        DioExceptionType.connectionTimeout => '서버 연결 시간 초과',
        DioExceptionType.sendTimeout => '요청 전송 시간 초과',
        DioExceptionType.receiveTimeout => '서버 응답 시간 초과',
        DioExceptionType.badCertificate => 'SSL 인증서 오류',
        DioExceptionType.cancel => '요청이 취소됨',
        DioExceptionType.connectionError => '네트워크 연결 실패',
        DioExceptionType.badResponse => '서버 오류 (${statusCode ?? "Unknown"})',
        DioExceptionType.unknown => '알 수 없는 오류 발생',
      };

      return Failure(
        error: error,
        stackTrace: stackTrace,
        message: '''$message
        [URL]: $url
        [Status Code]: ${statusCode ?? "N/A"}
        [Response]: ${responseBody ?? "N/A"}
        ''',
      );
    } else {
      return Failure(
        error: error,
        stackTrace: stackTrace,
        message: '알 수 없는 오류 발생',
      );
    }
  }
}
