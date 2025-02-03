import 'package:dio/dio.dart';
import 'package:rakuraku/authentication/presentation/auth_bloc.dart';

import '../services/api_service.dart';
import 'data/gateway/api_endpoint.dart';
import 'data/gateway/login_gateway.dart';
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

  di.register<ApiService>(() => ApiService(
        Dio(),
        baseUrl: ApiEndpoint.baseUrl.path,
      ));
  di.register<LoginGatewayInterface>(() => LoginGateway(apiService: di.resolve<ApiService>()));
  di.register<AuthUseCase>(() => AuthUseCase(loginGateway: di.resolve<LoginGateway>()));
  di.register<AuthBloc>(() => AuthBloc(authUseCase: di.resolve<AuthUseCase>()));
}
