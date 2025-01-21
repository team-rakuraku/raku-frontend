import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.loggedIn(User user) = _LoggedIn;
  const factory AuthState.error(String message) = _Error;
}
