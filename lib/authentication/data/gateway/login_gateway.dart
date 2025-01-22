import 'package:fpdart/fpdart.dart';
import '../../../services/api_service.dart';
import '../../domain/data_interfaces/login_repository_interface.dart';
import '../../../types/failure.dart';
import '../remote/dto/login_request_dto.dart';
import '../remote/dto/login_response_dto.dart';
import 'api_endpoint.dart';

final class LoginGateway implements LoginGatewayInterface {
  final ApiService _apiService;

  LoginGateway({required ApiService apiService}) : _apiService = apiService;

  @override
  TaskEither<Failure, LoginResponseDto> login(
    LoginRequestDto params,
  ) =>
      _validateInputs(params)
          .flatMap((headers) => _sendLoginRequest(params, headers))
          .mapLeft((failure) => _enhanceFailure(failure));
}

extension LoginGatewayHelper on LoginGateway {
  TaskEither<Failure, Map<String, String>> _validateInputs(
    LoginRequestDto params,
  ) {
    if (params.appId.isEmpty || params.accessToken.isEmpty) {
      return TaskEither.left(Failure(
        state: FailedState.invalidInput,
        error: "Invalid App ID or Access Token",
        message: "App ID and Access Token must not be empty",
        stackTrace: StackTrace.current,
      ));
    }

    final headers = {
      "Content-Type": "application/json",
      "Authorization": params.accessToken,
      "App-Id": params.appId,
    };

    return TaskEither.right(headers);
  }

  TaskEither<Failure, LoginResponseDto> _sendLoginRequest(LoginRequestDto loginRequestDto, Map<String, String> headers,
  ) =>
      TaskEither.tryCatch(() async {
        final response = await _apiService.postRequest(
          ApiEndpoint.login.path,
          loginRequestDto,
          headers["Authorization"]!,
          headers["App-Id"]!,
        );
        return LoginResponseDto.fromJson(response as Map<String, dynamic>);
      },
          (error, stackTrace) => Failure(
                state: FailedState.operationFailed,
                error: error,
                stackTrace: stackTrace,
              ));

  Failure _enhanceFailure(Failure failure) => failure.copyWith(
        message: failure.message ?? "An error occurred during the login process",
        stackTrace: failure.stackTrace ?? StackTrace.current,
      );
}
