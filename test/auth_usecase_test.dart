import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rakuraku/authentication/data/remote/dto/login_response_dto.dart';
import 'package:rakuraku/authentication/domain/entity/user_entity.dart';
import 'package:rakuraku/authentication/domain/usecases/auth_uscease.dart';
import 'package:rakuraku/types/failure.dart';

import 'mock/mock_login_gateway.dart';

void main() {
  late AuthUseCase useCase;
  late MockLoginGateway mockLoginGateway;

  setUp(() {
    mockLoginGateway = MockLoginGateway();
    useCase = AuthUseCase(loginGateway: mockLoginGateway);
  });

  group('AuthUseCase 단위 테스트', () {
    test('Given 유저 정보가 유효할 때, When 로그인 요청을 수행하면 Then 성공적으로 로그인 응답을 반환한다.', () async {
      // Given
      final user = User(
        userId: '12345',
        accessToken: 'validToken',
        appId: 'appId123',
        nickname: 'testUser',
        profileImageUrl: 'http://example.com/profile.png',
      );
      final loginResponse = LoginResponseDto(
        status: 'success',
        userId: '12345',
        expiresAt: '2025-12-31T23:59:59Z',
      );

      mockLoginGateway.setMockResponse(Right(loginResponse));

      // When
      final result = await useCase.performLogin(user: user).run();

      // Then
      result.match(
        (failure) => fail('Expected success but got failure: $failure'),
        (loggedInUser) {
          expect(loggedInUser.userId, '12345');
          expect(loggedInUser.accessToken, 'validToken');
          expect(loggedInUser.appId, 'appId123');
        },
      );
    });

    test('Given 유저 ID가 없을 때, When 로그인 요청을 수행하면 Then 실패 상태를 반환한다.', () async {
      // Given
      final user = User(
        userId: '',
        accessToken: 'validToken',
        appId: 'appId123',
        nickname: 'testUser',
        profileImageUrl: 'http://example.com/profile.png',
      );

      // When
      final result = await useCase.performLogin(user: user).run();

      // Then
      result.match(
        (failure) {
          expect(failure.state, FailedState.invalidInput);
          expect(failure.message, 'User ID cannot be empty');
        },
        (_) => fail('Expected failure but got success'),
      );
    });

    test('Given 로그인 게이트웨이가 실패를 반환할 때, When 로그인 요청을 수행하면 Then 실패 상태를 반환한다.', () async {
      // Given
      final user = User(
        userId: '12345',
        accessToken: 'validToken',
        appId: 'appId123',
        nickname: 'testUser',
        profileImageUrl: 'http://example.com/profile.png',
      );
      final failure = Failure(
        state: FailedState.operationFailed,
        error: 'Server Error',
        message: 'An error occurred during login',
        stackTrace: StackTrace.current,
      );

      mockLoginGateway.setMockResponse(Left(failure));

      // When
      final result = await useCase.performLogin(user: user).run();

      // Then
      result.match(
        (failure) {
          expect(failure.state, FailedState.operationFailed);
          expect(failure.message, 'An error occurred during login');
        },
        (_) => fail('Expected failure but got success'),
      );
    });
  });
}
