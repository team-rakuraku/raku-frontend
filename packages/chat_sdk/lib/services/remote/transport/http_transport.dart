import 'package:chat_sdk/services/remote/builder/restapi_request_builder.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../types/failure.dart';

abstract interface class HttpTransportInterface {
  TaskEither<Failure, Response> sendRequest(RestAPIRequest request);
}

final class HttpTransport extends HttpTransportInterface {
  final Dio dio;

  HttpTransport(this.dio);

  @override
  TaskEither<Failure, Response> sendRequest(RestAPIRequest request) =>
      TaskEither<Failure, Response>.tryCatch(
        () async => await dio.request(
          request.buildUrl(),
          data: request.body.toNullable(),
          options: Options(
            method: _httpMethodToString(request.method),
            headers: request.headers,
          ),
        ),
        (error, stackTrace) =>
            mapDioExceptionToFailure(error, stackTrace, request),
      );

  String _httpMethodToString(HttpMethod method) => switch (method) {
        HttpMethod.get => 'GET',
        HttpMethod.post => 'POST',
        HttpMethod.put => 'PUT',
        HttpMethod.delete => 'DELETE',
        HttpMethod.patch => 'PATCH',
      };

  Failure mapDioExceptionToFailure(
      Object error, StackTrace stackTrace, RestAPIRequest request) {
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

      return buildFailure(
        error: error,
        stackTrace: stackTrace,
        message: '''$message
        [URL]: ${request.buildUrl()}
        [Method]: ${_httpMethodToString(request.method)}
        ${statusCode != null ? "[Status Code]: $statusCode" : ""}
        ${responseBody != null ? "[Response]: $responseBody" : ""}
        ''',
      );
    } else {
      return buildFailure(
        error: error,
        stackTrace: stackTrace,
        message: '알 수 없는 오류 발생',
      );
    }
  }
}
