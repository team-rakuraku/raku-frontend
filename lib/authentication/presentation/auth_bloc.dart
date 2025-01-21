import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../domain/user_entity.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const InitialAuthState()) {
    on<AuthEvent>(_onLogin);
  }

  /// 로그인 이벤트 처리
  Future<void> _onLogin(AuthEvent event, Emitter<AuthState> emit) async {
    emit(const LoadingAuthState());
    try {
      // TODO: 실제 로그인 로직 추가
      final user = User(
        userId: event.userParams.userId,
        nickname: event.userParams.nickname,
        profileImageUrl: event.userParams.profileImageUrl,
      );

      // 로그인 성공 시 상태 업데이트
      emit(LoggedInAuthState(user));
    } catch (error) {
      // 로그인 실패 시 에러 상태로 전환
      emit(ErrorAuthState(error.toString()));
    }
  }
}
