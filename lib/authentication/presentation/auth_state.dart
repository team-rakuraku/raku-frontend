import '../domain/user_entity.dart';

abstract interface class AuthState {
  const AuthState();
}

class InitialAuthState extends AuthState {
  const InitialAuthState();
}

class LoadingAuthState extends AuthState {
  const LoadingAuthState();
}

class LoggedInAuthState extends AuthState {
  final User user;

  const LoggedInAuthState(this.user);
}

class ErrorAuthState extends AuthState {
  final String message;

  const ErrorAuthState(this.message);
}
