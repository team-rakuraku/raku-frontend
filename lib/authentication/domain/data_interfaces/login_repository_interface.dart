import 'package:fpdart/fpdart.dart';

import '../../../types/failure.dart';
import '../../data/remote/dto/login_request_dto.dart';
import '../../data/remote/dto/login_response_dto.dart';

abstract interface class LoginGatewayInterface {
  TaskEither<Failure, LoginResponseDto> login(LoginRequestDto params);
}
