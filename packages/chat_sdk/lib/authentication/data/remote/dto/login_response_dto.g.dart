// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    LoginResponseDto(
      status: json['status'] as String,
      message: json['message'] as String,
      userId: _userIdFromJson(json['userId']),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$LoginResponseDtoToJson(LoginResponseDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'userId': _userIdToJson(instance.userId),
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
