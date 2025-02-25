final class Failure {
  final Object error;
  final String? message;
  final StackTrace? stackTrace;
  final Failure? cause;

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
