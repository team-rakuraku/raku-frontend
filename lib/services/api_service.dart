import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../authentication/data/remote/dto/login_request_dto.dart';
import '../authentication/data/remote/dto/login_response_dto.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("{endpoint}")
  Future<LoginResponseDto> postRequest(
    @Path("endpoint") String endpoint,
    @Body() LoginRequestDto body,
    @Header("Authorization") String authorization,
    @Header("App-Id") String appId,
  );
}
