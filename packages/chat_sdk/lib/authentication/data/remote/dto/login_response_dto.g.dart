// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    LoginResponseDto(
      status: json['status'] as String,
      userId: json['userId'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$LoginResponseDtoToJson(LoginResponseDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'userId': instance.userId,
      'expiresAt': instance.expiresAt,
    };
