import 'package:fpdart/fpdart.dart';

import '../../../types/failure.dart';
import '../../data/remote/dto/login_dto.dart';
import '../../data/remote/dto/login_response_dto.dart';
import '../data_interfaces/login_repository_interface.dart';
import '../entity/user_entity.dart';

final class AuthUseCase {
  final ILoginRemoteService _loginRemoteService;

  AuthUseCase({required ILoginRemoteService loginRemoteService})
      : _loginRemoteService = loginRemoteService;

  TaskEither<Failure, User> performLogin(
      User user, String accessToken, String appId) {
    return _createRequest(user)
        .mapLeft(
          (createReqFailure) => buildFailure(
            error: Exception("AuthUseCase: Create request failed"),
            stackTrace: StackTrace.current,
            message: "유저 정보가 비어있습니다",
            cause: createReqFailure,
          ),
        )
        .flatMap(
          (requestDto) => _loginRemoteService
              .login(
                loginDto: requestDto,
                token: accessToken,
                appId: appId,
              )
              .mapLeft(
                (loginFailure) => buildFailure(
                  error: Exception("AuthUseCase: Login failed"),
                  stackTrace: StackTrace.current,
                  message: "로그인 중 오류가 발생했습니다.",
                  cause: loginFailure,
                ),
              ),
        )
        .map(
            (response) => _mapToEntity(response, user.accessToken, user.appId));
  }

  TaskEither<Failure, LoginDto> _createRequest(User user) {
    if (user.userId.isEmpty) {
      return TaskEither.left(
        buildFailure(
          error: Exception("Invalid user ID"),
          stackTrace: StackTrace.current,
          message: "User ID cannot be empty",
        ),
      );
    }
    return TaskEither.right(
      LoginDto(
        userId: user.userId,
        nickname: user.nickname,
        profileImageUrl: user.profileImageUrl,
      ),
    );
  }

  User _mapToEntity(
          LoginResponseDto response, String accessToken, String appId) =>
      User(
        userId: response.userId,
        accessToken: accessToken,
        appId: appId,
        nickname: response.userId,
        profileImageUrl: "testImageUrl",
      );
}
