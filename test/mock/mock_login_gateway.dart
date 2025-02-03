import 'package:fpdart/fpdart.dart';
import 'package:rakuraku/authentication/data/remote/dto/login_request_dto.dart';
import 'package:rakuraku/authentication/data/remote/dto/login_response_dto.dart';
import 'package:rakuraku/authentication/domain/data_interfaces/login_repository_interface.dart';
import 'package:rakuraku/types/failure.dart';

class MockLoginGateway implements LoginGatewayInterface {
  late Either<Failure, LoginResponseDto> _response;

  void setMockResponse(Either<Failure, LoginResponseDto> response) {
    _response = response;
  }

  @override
  TaskEither<Failure, LoginResponseDto> login(LoginRequestDto params) {
    return TaskEither(() async => _response);
  }
}
