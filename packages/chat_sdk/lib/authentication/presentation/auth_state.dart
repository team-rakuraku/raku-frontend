import 'package:freezed_annotation/freezed_annotation.dart';
import '../../types/failure.dart';
import '../domain/entity/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = InitialAuthState;
  const factory AuthState.loading() = LoadingAuthState;
  const factory AuthState.loggedIn(User user) = LoggedInAuthState;
  const factory AuthState.error(Failure failure) = ErrorAuthState;
}
