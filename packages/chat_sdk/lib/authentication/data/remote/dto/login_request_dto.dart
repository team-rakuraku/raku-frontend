import 'package:json_annotation/json_annotation.dart';

part 'login_request_dto.g.dart';

@JsonSerializable()
class LoginRequestDto {
  final String userId;
  final String nickname;
  final String profileImageUrl;
  final String appId;
  final String accessToken;

  LoginRequestDto({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.appId,
    required this.accessToken,
  });

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}
