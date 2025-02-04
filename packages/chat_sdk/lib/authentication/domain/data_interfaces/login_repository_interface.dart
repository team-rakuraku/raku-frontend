import 'package:fpdart/fpdart.dart';

import '../../../types/failure.dart';
import '../../data/remote/dto/login_dto.dart';
import '../../data/remote/dto/login_response_dto.dart';

abstract interface class ILoginRemoteService {
  TaskEither<Failure, LoginResponseDto> login({
    required LoginDto loginDto,
    required String token,
    required String appId,
  });
}
