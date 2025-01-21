import 'auth_bloc.dart';
import 'auth_event.dart';

final class RakuChatSDK {
  final AuthBloc _authBloc;

  RakuChatSDK(this._authBloc);

  void login({
    required String accessToken,
    required String appId,
    required _UserParams userParams,
  }) {
    _authBloc.add(AuthEvent.login(
      accessToken: accessToken,
      appId: appId,
      userId: userParams.userId,
      nickname: userParams.nickname,
      profileImageUrl: userParams.profileImageUrl,
    ));
  }
}

final class _UserParams {
  final String userId;
  final String nickname;
  final String profileImageUrl;

  _UserParams({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });
}
