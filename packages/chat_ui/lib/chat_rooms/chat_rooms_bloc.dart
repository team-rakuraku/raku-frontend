import 'package:chat_sdk/chat/domain/usecases/chat_usecase.dart';
import 'package:chat_sdk/types/failure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_room_state.dart';
import 'chat_rooms_event.dart';

class ChatRoomsBloc extends Bloc<ChatRoomsEvent, ChatRoomsState> {
  final ChatUseCase chatUseCase;

  ChatRoomsBloc({required this.chatUseCase}) : super(const ChatRoomsState()) {
    on<FetchUserChatRooms>(_onFetchUserChatRooms);
    on<FetchAllChatRooms>(_onFetchAllChatRooms);
  }

  /// 내가 참여한 채팅방 목록 불러오기
  Future<void> _onFetchUserChatRooms(
      FetchUserChatRooms event,
      Emitter<ChatRoomsState> emit,
      ) async {
    try {
      emit(state.copyWith(status: ChatRoomsStatus.loading));

      final either = await chatUseCase.getUserChatRooms(userId: event.userId).run();

      either.fold(
            (failure) {
          emit(state.copyWith(
            status: ChatRoomsStatus.failure,
            error: failure,
          ));
        },
            (rooms) {
          // 기존 allRooms에 추가할 수도 있고, myRooms에만 저장할 수도 있음
          emit(state.copyWith(
            myRooms: rooms,
            status: ChatRoomsStatus.success,
            error: null,
          ));
        },
      );
    } catch (e, stack) {
      emit(state.copyWith(
        status: ChatRoomsStatus.failure,
        error: Failure(error: e, stackTrace: stack),
      ));
    }
  }

  Future<void> _onFetchAllChatRooms(
      FetchAllChatRooms event,
      Emitter<ChatRoomsState> emit,
      ) async {
    try {
      emit(state.copyWith(status: ChatRoomsStatus.loading));

      final either = await chatUseCase.requestChatRoomsList(event.page, event.size).run();

      either.fold(
            (failure) {
          debugPrint('❌ Failure 발생: ${failure.toString()}');
          debugPrint('Error: ${failure.error}');
          debugPrint('Message: ${failure.message}');
          debugPrint('StackTrace: ${failure.stackTrace}');
          emit(state.copyWith(
            status: ChatRoomsStatus.failure,
            error: failure,
          ));
        },
            (rooms) {
          // 응답받은 채팅방들의 id를 로그로 출력
          for (var room in rooms) {
            debugPrint('Room ID: ${room.id}');
          }

          final isFirstPage = event.page == 0;

          // 중복 제거하고 기존 데이터 유지
          final mergedRooms = isFirstPage
              ? [...rooms, ...state.allRooms] // 최신 데이터 추가 후 기존 데이터 유지
              : [...state.allRooms, ...rooms];

          // 중복된 채팅방 제거 (ID 기반)
          final uniqueRooms = {for (var room in mergedRooms) room.id: room}.values.toList();

          final isLastPage = rooms.length < event.size;

          emit(state.copyWith(
            allRooms: uniqueRooms, // 중복 제거된 데이터 저장
            status: ChatRoomsStatus.success,
            error: null,
            lastPage: isLastPage,
          ));
        },
      );
    } catch (e, stack) {
      emit(state.copyWith(
        status: ChatRoomsStatus.failure,
        error: Failure(error: e, stackTrace: stack),
      ));
    }
  }
}
