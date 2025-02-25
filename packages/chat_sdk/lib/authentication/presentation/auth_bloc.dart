import 'package:bloc/bloc.dart';
import '../domain/usecases/auth_uscease.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../domain/entity/user_entity.dart';

final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCase _authUseCase;

  AuthBloc({required AuthUseCase authUseCase})
      : _authUseCase = authUseCase,
        super(const AuthState.initial()) {
    on<LoginAuthEvent>(_onLogin);
  }

  /// 로그인 이벤트 처리
  Future<void> _onLogin(LoginAuthEvent event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final user = User(
      userId: event.user.userId,
      nickname: event.user.nickname,
      profileImageUrl: event.user.profileImageUrl,
      accessToken: event.accessToken,
      appId: event.appId,
    );

    final result = await _authUseCase.performLogin(user, event.accessToken, event.appId).run();

    result.match(
      (failure) => emit(AuthState.error(failure)),
      (loggedInUser) => emit(AuthState.loggedIn(loggedInUser)),
    );
  }
}
