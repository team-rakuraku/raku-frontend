import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import '../../types/failure.dart';
import '../../di_container.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';
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
    required User user,
  }) async {
    final completer = Completer<Either<Failure, User>>();

    final subscription = _authBloc.stream.listen((state) {
      debugPrint("AuthBloc state changed: $state");
      state.when(
        loggedIn: (user) => completer.complete(Right(user)),
        error: (failure) => completer.complete(Left(failure)),
        loading: () => debugPrint("AuthBloc loading..."),
        initial: () => debugPrint("AuthBloc initial state"),
      );
    });

    _authBloc.add(AuthEvent.login(
      accessToken: accessToken,
      appId: appId,
      user: user,
    ));

    final result = await completer.future;
    subscription.cancel();
    return result;
  }
}
