import 'dart:async';

import 'package:fpdart/fpdart.dart';
import '../../types/failure.dart';
import '../di_container.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'model/user_params.dart';
import '../domain/entity/user_entity.dart';

final class RakuChatSDK {
  late final AuthBloc _authBloc;

  RakuChatSDK.initialize() {
    initializeSDKDependencies();
    final di = DIContainer();
    _authBloc = di.resolve<AuthBloc>();
  }

  Future<Either<Failure, User>> login({
    required String accessToken,
    required String appId,
    required UserParams userParams,
  }) async {
    final completer = Completer<Either<Failure, User>>();

    final subscription = _authBloc.stream.listen((state) {
      if (state is LoggedInAuthState) {
        completer.complete(Right(state.user));
      } else if (state is ErrorAuthState) {
        completer.complete(Left(state.failure));
      }
    });

    _authBloc.add(AuthEvent.login(
      accessToken: accessToken,
      appId: appId,
      userParams: userParams,
    ));

    final result = await completer.future;
    subscription.cancel();
    return result;
  }
}
