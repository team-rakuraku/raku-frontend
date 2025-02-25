import 'dart:ui';
import 'package:chat_ui/chat_rooms/all_chat_rooms_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_sdk/chat/domain/usecases/chat_usecase.dart';
import 'chat_rooms_bloc.dart';
import 'chat_rooms_event.dart';

final class CreateChatRoomView extends StatefulWidget {
  final String accessToken;
  final String userId;

  const CreateChatRoomView({
    super.key,
    required this.accessToken,
    required this.userId,
  });

  @override
  State<CreateChatRoomView> createState() => _CreateChatRoomViewState();
}

final class _CreateChatRoomViewState extends State<CreateChatRoomView> {
  final TextEditingController _roomNameController = TextEditingController();
  bool _isCreating = false;
  bool _isValid = false;

  static final RegExp _validRoomNameRegExp = RegExp(r'^[a-zA-Z0-9가-힣\s]{5,20}$');

  @override
  void initState() {
    super.initState();
    _roomNameController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isValid = _validRoomNameRegExp.hasMatch(_roomNameController.text);
    });
  }

  LinearGradient _buttonGradient() {
    return _isValid
        ? const LinearGradient(
      colors: [Colors.blue, Colors.tealAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Colors.grey, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Future<void> _createChatRoom() async {
    if (!_isValid) return;

    setState(() {
      _isCreating = true;
    });

    final chatUseCase = context.read<ChatUseCase>();

    final either = await chatUseCase
        .createChatRoom(
      appId: 'rakuraku3',
      accessToken: widget.accessToken,
      userId: widget.userId,
      roomName: _roomNameController.text,
    )
        .run();

    either.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${failure.message}')),
        );
      },
          (room) {
        context.read<ChatRoomsBloc>().add(const FetchAllChatRooms(0, 10));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AllChatRoomsView(accessToken: widget.accessToken, userId: widget.userId)),
        );
      },
    );

    setState(() {
      _isCreating = false;
    });
  }

  @override
  void dispose() {
    _roomNameController.removeListener(_validateInput);
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isCreating,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              elevation: 0,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  TextField(
                    controller: _roomNameController,
                    cursorColor: Colors.grey,
                    decoration: const InputDecoration(
                      labelText: '채팅방 제목을 입력해주세요',
                      labelStyle: TextStyle(fontSize: 16),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      helperText: "5글자 이상 20글자 이하로 입력해주세요",
                      helperStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 50),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: _buttonGradient(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isValid && !_isCreating ? _createChatRoom : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '채팅방 만들기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isValid ? Colors.white : Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isCreating)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}