// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthEvent {
  String get accessToken => throw _privateConstructorUsedError;
  String get appId => throw _privateConstructorUsedError;
  UserParams get userParams => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String appId, UserParams userParams)
        login,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String accessToken, String appId, UserParams userParams)?
        login,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String accessToken, String appId, UserParams userParams)?
        login,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginAuthEvent value) login,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginAuthEvent value)? login,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginAuthEvent value)? login,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthEventCopyWith<AuthEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
  @useResult
  $Res call({String accessToken, String appId, UserParams userParams});
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? appId = null,
    Object? userParams = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      appId: null == appId
          ? _value.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      userParams: null == userParams
          ? _value.userParams
          : userParams // ignore: cast_nullable_to_non_nullable
              as UserParams,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginAuthEventImplCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory _$$LoginAuthEventImplCopyWith(_$LoginAuthEventImpl value,
          $Res Function(_$LoginAuthEventImpl) then) =
      __$$LoginAuthEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String appId, UserParams userParams});
}

/// @nodoc
class __$$LoginAuthEventImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$LoginAuthEventImpl>
    implements _$$LoginAuthEventImplCopyWith<$Res> {
  __$$LoginAuthEventImplCopyWithImpl(
      _$LoginAuthEventImpl _value, $Res Function(_$LoginAuthEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? appId = null,
    Object? userParams = null,
  }) {
    return _then(_$LoginAuthEventImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      appId: null == appId
          ? _value.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      userParams: null == userParams
          ? _value.userParams
          : userParams // ignore: cast_nullable_to_non_nullable
              as UserParams,
    ));
  }
}

/// @nodoc

class _$LoginAuthEventImpl implements LoginAuthEvent {
  const _$LoginAuthEventImpl(
      {required this.accessToken,
      required this.appId,
      required this.userParams});

  @override
  final String accessToken;
  @override
  final String appId;
  @override
  final UserParams userParams;

  @override
  String toString() {
    return 'AuthEvent.login(accessToken: $accessToken, appId: $appId, userParams: $userParams)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginAuthEventImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.userParams, userParams) ||
                other.userParams == userParams));
  }

  @override
  int get hashCode => Object.hash(runtimeType, accessToken, appId, userParams);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginAuthEventImplCopyWith<_$LoginAuthEventImpl> get copyWith =>
      __$$LoginAuthEventImplCopyWithImpl<_$LoginAuthEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String accessToken, String appId, UserParams userParams)
        login,
  }) {
    return login(accessToken, appId, userParams);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String accessToken, String appId, UserParams userParams)?
        login,
  }) {
    return login?.call(accessToken, appId, userParams);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String accessToken, String appId, UserParams userParams)?
        login,
    required TResult orElse(),
  }) {
    if (login != null) {
      return login(accessToken, appId, userParams);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoginAuthEvent value) login,
  }) {
    return login(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoginAuthEvent value)? login,
  }) {
    return login?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoginAuthEvent value)? login,
    required TResult orElse(),
  }) {
    if (login != null) {
      return login(this);
    }
    return orElse();
  }
}

abstract class LoginAuthEvent implements AuthEvent {
  const factory LoginAuthEvent(
      {required final String accessToken,
      required final String appId,
      required final UserParams userParams}) = _$LoginAuthEventImpl;

  @override
  String get accessToken;
  @override
  String get appId;
  @override
  UserParams get userParams;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginAuthEventImplCopyWith<_$LoginAuthEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
