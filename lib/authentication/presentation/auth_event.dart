import 'model/user_params.dart';

class AuthEvent {
  final String accessToken;
  final String appId;
  final UserParams userParams;

  AuthEvent.login({
    required this.accessToken,
    required this.appId,
    required this.userParams,
  });
}
