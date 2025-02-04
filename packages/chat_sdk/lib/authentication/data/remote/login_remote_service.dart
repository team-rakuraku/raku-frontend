import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../services/remote/request_builder.dart';
import '../../../services/remote/response_parser.dart';
import '../../../services/remote/http_transport.dart';
import '../../../types/failure.dart';
import '../../domain/data_interfaces/login_repository_interface.dart';
import 'dto/login_dto.dart';
import 'dto/login_response_dto.dart';

final class LoginRemoteService implements ILoginRemoteService {
  final HttpTransport _http;
  final ResponseParser<LoginResponseDto> _parser =
      ResponseParser(parse: LoginResponseDto.fromJson);

  LoginRemoteService(this._http);

  @override
  TaskEither<Failure, LoginResponseDto> login({
    required LoginDto loginDto,
    required String token,
    required String appId,
  }) =>
      _buildRequest(loginDto, token, appId).match(
          (failureFromBuilder) => TaskEither.left(failureFromBuilder),
          (request) => _sendRequest(request));

  // =====================
  // 내부 헬퍼 메서드들
  // =====================

  Either<Failure, Request> _buildRequest(
      LoginDto loginDto, String token, String appId) {
    return RequestBuilder(baseUrl: "http://localhost:8080")
        .setEndpoint("auth/login")
        .setMethod(HttpMethod.post)
        .addHeader("Content-Type", "application/json")
        .addHeader("Authorization", token)
        .addHeader("App-Id", appId)
        .setBody(jsonEncode(loginDto))
        .build()
        .mapLeft((buildErrorMsg) => Failure(
              error: 'RequestBuildError',
              message: buildErrorMsg,
            ));
  }

  TaskEither<Failure, LoginResponseDto> _sendRequest(Request request) {
    return _http
        .sendRequest(request)
        .mapLeft((transportFailure) => transportFailure.copyWith(
              error: '네트워크 에러',
              message: '네트워크 전송 중 오류 발생',
              cause: transportFailure,
            ))
        .flatMap((response) => _parseResponse(response));
  }

  TaskEither<Failure, LoginResponseDto> _parseResponse(Response response) {
    return TaskEither.fromEither(
      _parser
          .parseDioResponse(response)
          .mapLeft((parserFailure) => parserFailure.copyWith(
                error: 'ParsingError',
                message: parserFailure.message,
              ))
          .map((resWrapper) => resWrapper.data),
    );
  }
}
