final class Failure {
  final Object error; // 실제 발생한 예외 객체
  final String? message; // 사람이 읽을 수 있는 오류 설명
  final StackTrace? stackTrace; // 오류 발생 지점 추적
  final Failure? cause; // 이전 단계(래핑 전) Failure

  const Failure({
    required this.error,
    this.message,
    this.stackTrace,
    this.cause,
  });

  String get fullErrorMessage {
    final causeMsg = cause?.fullErrorMessage ?? '';
    final current = message ?? '';
    if (causeMsg.isEmpty) return current;
    if (current.isEmpty) return causeMsg;
    return '\n$causeMsg\n =======> $current';
  }

  String get fullErrorStack {
    final causeErr = cause?.fullErrorStack ?? '';
    final currentErr = error.toString();
    if (causeErr.isEmpty) return currentErr;
    if (currentErr.isEmpty) return causeErr;
    return '\n$causeErr\n =======> $currentErr';
  }

  Failure copyWith({
    Object? error,
    String? message,
    StackTrace? stackTrace,
    Failure? cause,
  }) {
    return Failure(
      error: error ?? this.error,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      cause: cause ?? this.cause,
    );
  }
}

Failure buildFailure({
  required Object error,
  required StackTrace stackTrace,
  String? message,
  Failure? cause,
}) {
  return Failure(
    error: error,
    stackTrace: stackTrace,
    message: message,
    cause: cause,
  );
}
