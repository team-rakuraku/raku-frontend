import 'dart:async';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:chat_sdk/types/failure.dart'; // Failure 및 buildFailure 관련 헬퍼가 있다고 가정

abstract interface class SocketTransportInterface {
  TaskEither<Failure, Unit> connect();

  /// STOMP 서버와의 연결을 종료합니다.
  TaskEither<Failure, Unit> disconnect();

  /// 지정한 destination으로 메시지를 전송합니다.
  TaskEither<Failure, Unit> sendMessage({
    required String destination,
    required String message,
    Map<String, String>? headers,
  });

  /// 지정한 destination으로부터 수신되는 메시지를 스트림으로 구독합니다.
  Either<Failure, Stream<StompFrame>> subscribe({
    required String destination,
    Map<String, String>? headers,
  });
}

/// 소켓 통신 객체 (stomp_dart_client 사용)
final class SocketTransport extends SocketTransportInterface {
  final String url;
  late final StompClient _client;
  bool _isConnected = false;

  // connect() 호출 시마다 새 completer를 생성하여 연결 완료를 기다림
  Completer<void>? _connectCompleter;

  SocketTransport({required this.url}) {
    _client = StompClient(
      config: StompConfig(
        url: url,
        // onConnect와 onError 콜백은 내부에서 _onConnect, _onError 메서드를 호출함.
        onConnect: _onConnect,
        onWebSocketError: _onError,
        onStompError: _onError,
        // 추가 옵션(예: heartbeat, reconnectDelay 등)을 필요에 따라 설정할 수 있음.
      ),
    );
  }

  void _onConnect(StompFrame frame) {
    _isConnected = true;
    _connectCompleter?.complete();
  }

  void _onError(dynamic error) {
    // 연결 중 에러 발생 시 대기 중인 completer를 error로 완료
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.completeError(error);
    }
  }

  @override
  TaskEither<Failure, Unit> connect() =>
      TaskEither<Failure, Unit>.tryCatch(
            () async {
          if (_isConnected) return unit;
          _connectCompleter = Completer<void>();
          _client.activate();
          // onConnect 콜백을 통해 연결이 완료될 때까지 대기 (타임아웃 10초)
          await _connectCompleter!.future.timeout(
            const Duration(seconds: 10),
          );
          return unit;
        },
            (error, stackTrace) => buildFailure(
          error: error,
          stackTrace: stackTrace,
          message: 'STOMP 서버에 연결하지 못했습니다.',
        ),
      );

  @override
  TaskEither<Failure, Unit> disconnect() =>
      TaskEither<Failure, Unit>.tryCatch(
            () async {
          if (_isConnected) {
            _client.deactivate();
            _isConnected = false;
            _connectCompleter = null;
          }
          return unit;
        },
            (error, stackTrace) => buildFailure(
          error: error,
          stackTrace: stackTrace,
          message: 'STOMP 서버와의 연결 해제에 실패했습니다.',
        ),
      );

  @override
  TaskEither<Failure, Unit> sendMessage({
    required String destination,
    required String message,
    Map<String, String>? headers,
  }) =>
      TaskEither<Failure, Unit>.tryCatch(
            () async {
          if (!_isConnected) {
            throw Exception('STOMP 서버에 연결되어 있지 않습니다.');
          }
          _client.send(
            destination: destination,
            body: message,
            headers: headers,
          );
          return unit;
        },
            (error, stackTrace) => buildFailure(
          error: error,
          stackTrace: stackTrace,
          message: '메시지 전송에 실패했습니다.',
        ),
      );

  @override
  Either<Failure, Stream<StompFrame>> subscribe({
    required String destination,
    Map<String, String>? headers,
  }) {
    if (!_isConnected) {
      return Left(
        buildFailure(
          error: Exception('STOMP 서버에 연결되어 있지 않습니다.'),
          stackTrace: StackTrace.current,
          message: '구독 실패: 서버에 연결되어 있지 않음',
        ),
      );
    }

    try {
      // 수신된 프레임을 emit할 broadcast 스트림 컨트롤러 생성
      final controller = StreamController<StompFrame>.broadcast();

      // 구독을 요청하고, 반환된 unsubscribe 함수를 저장
      final StompUnsubscribe? unsubscribe = _client.subscribe(
        destination: destination,
        headers: headers,
        callback: (frame) {
          controller.add(frame);
        },
      );

      // 스트림 구독이 취소되면 unsubscribe를 호출하여 구독 해제
      controller.onCancel = () {
        unsubscribe?.call();
        controller.close();
      };

      return Right(controller.stream);
    } catch (error, stackTrace) {
      return Left(
        buildFailure(
          error: error,
          stackTrace: stackTrace,
          message: '[$destination] 구독에 실패했습니다.',
        ),
      );
    }
  }
}
