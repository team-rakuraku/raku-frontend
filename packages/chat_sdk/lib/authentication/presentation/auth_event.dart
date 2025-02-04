import 'package:freezed_annotation/freezed_annotation.dart';
import 'model/user_params.dart';

part 'auth_event.freezed.dart';

// AuthEvent 정의
@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String accessToken,
    required String appId,
    required UserParams userParams,
  }) = LoginAuthEvent;
}
