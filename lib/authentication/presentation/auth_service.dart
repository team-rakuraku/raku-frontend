import 'auth_bloc.dart';
import 'auth_event.dart';
import 'model/user_params.dart';

final class RakuChatSDK {
  final AuthBloc _authBloc;

  RakuChatSDK(this._authBloc);

  void login({
    required String accessToken,
    required String appId,
    required UserParams userParams,
  }) {
    _authBloc.add(AuthEvent.login(
      accessToken: accessToken,
      appId: appId,
      userParams: userParams,
    ));
  }
}
