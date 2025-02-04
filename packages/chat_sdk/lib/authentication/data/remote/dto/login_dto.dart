import 'package:json_annotation/json_annotation.dart';

part 'login_dto.g.dart';

@JsonSerializable()
final class LoginDto {
  final String userId;
  final String nickname;
  final String profileImageUrl;

  const LoginDto({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory LoginDto.fromJson(Map<String, dynamic> json) => _$LoginDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);
}
