import 'dart:convert';

final class SocketMessageBuilder {
  final Map<String, dynamic> _message = {};

  /// ✅ 앱 ID 설정
  SocketMessageBuilder appId(String appId) {
    _message["appId"] = appId;
    return this;
  }

  /// ✅ 채팅방 ID 설정
  SocketMessageBuilder roomId(String roomId) {
    _message["roomId"] = roomId;
    return this;
  }

  /// ✅ 사용자 ID 설정
  SocketMessageBuilder usersId(String usersId) {
    _message["usersId"] = usersId;
    return this;
  }

  /// ✅ 메시지 내용 설정
  SocketMessageBuilder content(String content) {
    _message["content"] = content;
    return this;
  }

  /// ✅ 클라우드 이미지 URL 설정
  SocketMessageBuilder cloudFrontImageURL(String url) {
    _message["cloudFrontImageURL"] = url;
    return this;
  }

  /// ✅ 메시지 타입 설정 (기본값: `CHAT`)
  SocketMessageBuilder type([String type = "CHAT"]) {
    _message["type"] = type;
    return this;
  }

  /// ✅ 최종 JSON 문자열 반환
  String build() => jsonEncode(_message);
}
