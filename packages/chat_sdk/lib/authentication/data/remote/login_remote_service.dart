import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  }) {
    final requestBuilder = _buildRequest(loginDto, token, appId);

    return requestBuilder.fold(
          (failure) => TaskEither.left(failure),
          (request) => _sendRequest(request),
    );
  }
}

extension LoginRemoteServiceHelper on LoginRemoteService {
  Either<Failure, RestAPIRequestBuilder> _buildRequest(LoginDto loginDto, String token, String appId) {
    return Either.right(
      RestAPIRequestBuilder(baseUrl: "http://acec93397c45740cd91228806400ad86-1631035604.ap-northeast-2.elb.amazonaws.com:4000")
          .setEndpoint("auth/login")
          .addHeader("Content-Type", "application/json")
          .addHeader("Authorization", token)
          .addHeader("App-Id", appId)
          .setBody(jsonEncode(loginDto)),
    );
  }

  TaskEither<Failure, LoginResponseDto> _sendRequest(RestAPIRequestBuilder request) {
    final url = request.getUrl();
    final headers = request.buildHeaders();
    final body = request.body.getOrElse(() => "null");

    return _http.post(url, headers, body: body).flatMap((response) {
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response data: ${response.data}");
      return _parseResponse(response);
    }).mapLeft((failure) => failure.copyWith(message: '로그인 요청 실패: ${failure.message}'));
  }

  TaskEither<Failure, LoginResponseDto> _parseResponse(Response response) {
    return TaskEither.fromEither(
      _parser.parseDioResponse(response).map(
            (resWrapper) => resWrapper.data,
      ),
    );
  }
}
