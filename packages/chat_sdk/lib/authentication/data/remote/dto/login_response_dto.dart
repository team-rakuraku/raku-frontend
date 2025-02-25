import 'package:json_annotation/json_annotation.dart';

part 'login_response_dto.g.dart';

String _userIdFromJson(dynamic json) => json.toString();
dynamic _userIdToJson(String userId) => userId;

@JsonSerializable()
final class LoginResponseDto {
  final String status;
  final String message;
  @JsonKey(fromJson: _userIdFromJson, toJson: _userIdToJson)
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
