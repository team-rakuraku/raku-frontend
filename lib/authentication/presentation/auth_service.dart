import '../di_container.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';
import 'model/user_params.dart';

final class RakuChatSDK {
  late final AuthBloc _authBloc;

  RakuChatSDK.initialize() {
    initializeSDKDependencies();
    final di = DIContainer();
    _authBloc = di.resolve<AuthBloc>();
  }

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
