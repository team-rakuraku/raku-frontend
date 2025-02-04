import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

@JsonSerializable()
chat-list
final class LoginResponseDto {
  final String status;
  final String message;
  final String userId;
  final DateTime expiresAt;

  const LoginResponseDto({
    required this.status,
    required this.message,
    required this.userId,
    required this.expiresAt,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);
}
