import 'package:chat_sdk/authentication/presentation/auth_bloc.dart';
import 'package:dio/dio.dart';

import '../services/remote/transport/http_transport.dart';
import 'data/remote/login_remote_service.dart';
import 'domain/data_interfaces/login_repository_interface.dart';
import 'domain/usecases/auth_uscease.dart';

class DIContainer {
  DIContainer._();

  static final DIContainer _instance = DIContainer._();

  factory DIContainer() => _instance;

  final Map<Type, dynamic> _services = {};

  void register<T>(T Function() factory) {
    _services[T] = factory;
  }

  T resolve<T>() {
    final service = _services[T];
    if (service is T Function()) {
      final instance = service();
      _services[T] = instance;
      return instance;
    } else if (service != null) {
      return service;
    }
    throw Exception("Service of type $T is not registered in DIContainer.");
  }
}

void initializeSDKDependencies() {
  final di = DIContainer();

  di.register<HttpTransport>(() => HttpTransport(Dio()));
  di.register<ILoginRemoteService>(
      () => LoginRemoteService(di.resolve<HttpTransport>()));
  di.register<AuthUseCase>(
      () => AuthUseCase(loginRemoteService: di.resolve<ILoginRemoteService>()));
  di.register<AuthBloc>(() => AuthBloc(authUseCase: di.resolve<AuthUseCase>()));
}
