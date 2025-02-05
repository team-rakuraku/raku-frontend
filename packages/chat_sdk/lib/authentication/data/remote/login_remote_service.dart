import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../services/remote/builder/restapi_request_builder.dart';
import '../../../services/remote/parser/restapi_response_parser.dart';
import '../../../services/remote/transport/http_transport.dart';
import '../../../types/failure.dart';
import '../../domain/data_interfaces/login_repository_interface.dart';
import 'dto/login_dto.dart';
import 'dto/login_response_dto.dart';

final class LoginRemoteService implements ILoginRemoteService {
  final HttpTransport _http;
  final RestAPIResponseParser<LoginResponseDto> _parser = RestAPIResponseParser(parse: LoginResponseDto.fromJson);

  LoginRemoteService(this._http);

  @override
  TaskEither<Failure, LoginResponseDto> login({
    required LoginDto loginDto,
    required String token,
    required String appId,
  }) =>
      _buildRequest(loginDto, token, appId)
          .match((failureFromBuilder) => TaskEither.left(failureFromBuilder), (request) => _sendRequest(request));
}

extension LoginRemoteServiceHelper on LoginRemoteService {
  Either<Failure, RestAPIRequest> _buildRequest(LoginDto loginDto, String token, String appId) {
    return RestAPIRequestBuilder(baseUrl: "http://localhost:8080")
        .setEndpoint("auth/login")
        .setMethod(HttpMethod.post)
        .addHeader("Content-Type", "application/json")
        .addHeader("Authorization", token)
        .addHeader("App-Id", appId)
        .setBody(jsonEncode(loginDto))
        .build()
        .mapLeft((buildErrorMsg) => Failure(error: 'RequestBuildError', message: buildErrorMsg));
  }

  TaskEither<Failure, LoginResponseDto> _sendRequest(RestAPIRequest request) {
    return _http
        .sendRequest(request)
        .mapLeft((transportFailure) => transportFailure.copyWith(
            error: transportFailure.error, message: transportFailure.message, cause: transportFailure))
        .flatMap((response) => _parseResponse(response));
  }

  TaskEither<Failure, LoginResponseDto> _parseResponse(Response response) {
    return TaskEither.fromEither(
      _parser
          .parseDioResponse(response)
          .mapLeft((parserFailure) =>
              parserFailure.copyWith(error: parserFailure.error, message: parserFailure.message, cause: parserFailure))
          .map((resWrapper) => resWrapper.data),
    );
  }
}
