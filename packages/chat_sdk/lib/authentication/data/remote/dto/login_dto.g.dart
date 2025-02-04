// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
    );

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
    };
