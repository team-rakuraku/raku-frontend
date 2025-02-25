import 'dart:async';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart';

final class SocketTransport {
  final String url;
  late final StompClient _client;
  bool _isConnected = false;
  Completer<void>? _connectCompleter;

  SocketTransport({required this.url}) {
    _client = StompClient(
      config: StompConfig.sockJS(
        url: url,
        onConnect: _onConnect,
        onWebSocketError: _onError,
        onStompError: _onError,
      ),
    );
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    _connectCompleter?.complete();
  }

  void _onError(dynamic error) {
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.completeError(error);
    }
  }

  TaskEither<Failure, Unit> connect() => TaskEither<Failure, Unit>.tryCatch(
        () async {
          if (_isConnected) return unit;
          _connectCompleter = Completer<void>();
          _client.activate();
          await _connectCompleter!.future.timeout(
            const Duration(seconds: 10),
          );
          return unit;
        },
        (error, stackTrace) => Failure(
          error: error,
          stackTrace: stackTrace,
          message: 'STOMP 서버에 연결하지 못했습니다.',
        ),
      );

  TaskEither<Failure, Unit> disconnect() => TaskEither<Failure, Unit>.tryCatch(
        () async {
          if (!_isConnected) throw Exception("⚠️ STOMP WebSocket이 연결되어 있지 않습니다.");
          _client.deactivate();
          _isConnected = false;
          _connectCompleter = null;
          return unit;
        },
        (error, stackTrace) => Failure(
          error: error,
          stackTrace: stackTrace,
          message: 'STOMP 서버 연결 해제 실패',
        ),
      );

  TaskEither<Failure, Unit> sendMessage({
    required String destination,
    required String message,
    Map<String, String>? headers,
  }) =>
      TaskEither<Failure, Unit>.tryCatch(
        () async {
          if (!_isConnected) throw Exception('❌ STOMP WebSocket이 연결되지 않음.');
          _client.send(destination: destination, body: message, headers: headers);
          return unit;
        },
        (error, stackTrace) => Failure(
          error: error,
          stackTrace: stackTrace,
          message: '메시지 전송 실패',
        ),
      );

  TaskEither<Failure, Stream<StompFrame>> subscribe({
    required String destination,
    Map<String, String>? headers,
  }) =>
      TaskEither.tryCatch(
        () async {
          if (!_isConnected) throw Exception('❌ STOMP WebSocket이 연결되지 않음.');

          final controller = StreamController<StompFrame>.broadcast();
          final StompUnsubscribe? unsubscribe = _client.subscribe(
            destination: destination,
            headers: headers,
            callback: (frame) => controller.add(frame),
          );

          controller.onCancel = () {
            unsubscribe?.call();
            controller.close();
          };

          return controller.stream;
        },
        (error, stackTrace) => Failure(
          error: error,
          stackTrace: stackTrace,
          message: '구독 실패: $destination',
        ),
      );
}
