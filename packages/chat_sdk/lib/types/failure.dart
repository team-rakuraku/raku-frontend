final class Failure {
  final FailedState state;
  final Object error;
  final String? message;
  final StackTrace? stackTrace;

  const Failure({
    required this.state,
    required this.error,
    this.message,
    this.stackTrace,
  });

  String get userFriendlyMessage {
    switch (state) {
      case FailedState.permissionDenied:
        return 'Permission is denied. Please check your app settings.';
      case FailedState.invalidData:
        return 'Invalid data provided. Please verify your input.';
      case FailedState.timeout:
        return 'Request timed out. Try again later.';
      case FailedState.storageFull:
        return 'Storage is full. Please free up space.';
      case FailedState.saveDataInSecureStorage:
        return 'Failed to save data securely.';
      case FailedState.encryptionError:
        return 'An error occurred during encryption. Please try again.';
      default:
        return message ?? 'An unknown error occurred.';
    }
  }

  @override
  String toString() => 'Failure(state: $state, error: $error, message: $message, stackTrace: $stackTrace)';

  Failure copyWith({
    FailedState? state,
    Object? error,
    String? message,
    StackTrace? stackTrace,
  }) {
    return Failure(
      state: state ?? this.state,
      error: error ?? this.error,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

enum FailedState {
  // 공통 상태
  unknown,
  permissionDenied,
  invalidData,
  notFound,
  timeout,
  storageFull,
  operationFailed,
  userFriendlyMessage,
  invalidInput,

  // Secure Storage
  saveDataInSecureStorage,
  secureStorageUnavailable,
  encryptionError,

  // Cache
  downloadFileFromCache,
  getCachedFile,
  removeFileFromCache,
  clearCache,

  // SharedPreferences
  initializeLocalStorage,
  requestSettingInLocalStorage,
  deleteSettingInLocalStorage,
  checkKeyInLocalStorage,
  clearAllSettingsInLocalStorage,
  saveSettingInLocalStorage,

  // RdbStorageService
  insert,
  query,
  delete,
  rawQuery,
  closeDatabase,
  update,

  // Network
  networkError,
  invalidRequest;

  String get category {
    if (this == FailedState.saveDataInSecureStorage ||
        this == FailedState.secureStorageUnavailable ||
        this == FailedState.encryptionError) {
      return 'Secure Storage';
    }
    if (this == FailedState.downloadFileFromCache ||
        this == FailedState.getCachedFile ||
        this == FailedState.removeFileFromCache ||
        this == FailedState.clearCache) {
      return 'cache';
    }
    if (this == FailedState.initializeLocalStorage ||
        this == FailedState.saveSettingInLocalStorage ||
        this == FailedState.deleteSettingInLocalStorage ||
        this == FailedState.checkKeyInLocalStorage ||
        this == FailedState.clearAllSettingsInLocalStorage ||
        this == FailedState.requestSettingInLocalStorage) {
      return 'Shared Preferences';
    }
    if (this == FailedState.insert ||
        this == FailedState.query ||
        this == FailedState.delete ||
        this == FailedState.rawQuery ||
        this == FailedState.closeDatabase ||
        this == FailedState.rawQuery ||
        this == FailedState.update) {
      return 'RDB Storage Service';
    }
    if (this == FailedState.invalidData || this == FailedState.networkError) {
      return 'Network';
    }

    return 'General';
  }
}

Failure buildFailure({
  required Object error,
  required StackTrace stackTrace,
  required FailedState state,
  String? customMessage,
}) {
  return Failure(
    state: state,
    error: error,
    message: customMessage,
    stackTrace: stackTrace,
  );
}
