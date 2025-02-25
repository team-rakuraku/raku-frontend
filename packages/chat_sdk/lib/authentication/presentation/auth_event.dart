import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/entity/user_entity.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String accessToken,
    required String appId,
    required User user,
  }) = LoginAuthEvent;
}
