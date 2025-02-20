import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rakuraku/authentication/data/remote/dto/login_request_dto.dart';
import '../../../types/failure.dart';
import '../../data/remote/dto/login_response_dto.dart';
import '../data_interfaces/login_repository_interface.dart';
import '../entity/user_entity.dart';

final class AuthUseCase {
  final LoginGatewayInterface _loginGateway;

  AuthUseCase({required LoginGatewayInterface loginGateway}) : _loginGateway = loginGateway;

  TaskEither<Failure, User> performLogin({required User user}) => _createRequest(user)
      .flatMap((request) => _loginGateway.login(request))
      .map((response) => _mapToEntity(response, user.accessToken, user.appId))
      .mapLeft((failure) => _enhanceFailure(failure));
}

extension AuthUseCaseHelper on AuthUseCase {
  TaskEither<Failure, LoginRequestDto> _createRequest(User user) => user.userId.isNotEmpty
      ? TaskEither.right(LoginRequestDto(
          accessToken: user.accessToken,
          appId: user.appId,
          userId: user.userId,
          nickname: user.nickname,
          profileImageUrl: user.profileImageUrl,
        ))
      : TaskEither.left(Failure(
          state: FailedState.invalidInput,
          error: "Invalid user ID",
  TaskEither<Failure, User> performLogin(
      User user, String accessToken, String appId) {
    return _createRequest(user)
        .mapLeft(
          (createReqFailure) {
        debugPrint("[AuthUseCase] Request 생성 실패: ${createReqFailure.message}");
        return Failure (
          error: Exception("AuthUseCase: Create request failed"),
          stackTrace: StackTrace.current,
          message: "유저 정보가 비어있습니다",
          cause: createReqFailure,
        );
      },
    )
        .flatMap(
          (requestDto) => _loginRemoteService
          .login(
        loginDto: requestDto,
        token: accessToken,
        appId: appId,
      )
          .mapLeft(
            (loginFailure) {
          debugPrint("[AuthUseCase] 로그인 요청 실패: ${loginFailure.message}");
          return Failure (
            error: Exception("AuthUseCase: Login failed"),
            stackTrace: StackTrace.current,
            message: "로그인 중 오류가 발생했습니다.",
            cause: loginFailure,
          );
        },
      ),
    )
        .map(
            (response) {
          debugPrint("[AuthUseCase] 로그인 성공: userId=${response.userId}");
          return _mapToEntity(response, user.accessToken, user.appId);
        });
  }

  TaskEither<Failure, LoginDto> _createRequest(User user) {
    if (user.userId.isEmpty) {
      return TaskEither.left(
        Failure (
          error: Exception("Invalid user ID"),
          stackTrace: StackTrace.current,
          message: "User ID cannot be empty",
          stackTrace: StackTrace.current,
        ));

  User _mapToEntity(LoginResponseDto response, String accessToken, String appId) => User(
        userId: response.userId,
        accessToken: accessToken,
        appId: appId,
        nickname: response.userId,
        profileImageUrl: "testImageUrl",
      );

  Failure _enhanceFailure(Failure failure) {
    return failure.copyWith(
      message: failure.message ?? "An error occurred during login",
      stackTrace: failure.stackTrace ?? StackTrace.current,
    );
  }
}
