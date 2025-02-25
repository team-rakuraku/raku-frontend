import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../chat/chat_view.dart';
import 'chat_room_state.dart';
import 'chat_rooms_bloc.dart';
import 'chat_rooms_event.dart';
import 'create_chat-room_view.dart';

/// 특정 이름을 기반으로 고유한 색상을 생성
Color getStableVividColor(String name) {
  final int hash = name.hashCode;
  final double hue = (hash % 360).toDouble();
  const double saturation = 0.9;
  const double brightness = 0.9;
  return HSVColor.fromAHSV(1.0, hue, saturation, brightness).toColor();
}

class AllChatRoomsView extends StatefulWidget {
  final String accessToken;
  final String userId;

  const AllChatRoomsView({
    Key? key,
    required this.accessToken,
    required this.userId,
  }) : super(key: key);

  @override
  State<AllChatRoomsView> createState() => _AllChatRoomsViewState();
}

class _AllChatRoomsViewState extends State<AllChatRoomsView> {
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 0;
  bool _isFetching = false;
  bool _hasMoreData = true;

  static const int _initialPageSize = 30;
  static const int _pageSize = 30;

  @override
  void initState() {
    super.initState();
    _fetchChatRooms(firstLoad: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.5 &&
        !_isFetching &&
        _hasMoreData) {
      _fetchChatRooms();
    }
  }

  void _fetchChatRooms({bool firstLoad = false}) {
    if (_isFetching || !_hasMoreData) return;
    setState(() => _isFetching = true);

    final fetchSize = firstLoad ? _initialPageSize : _pageSize;
    context
        .read<ChatRoomsBloc>()
        .add(FetchAllChatRooms(_currentPage, fetchSize));
  }

  /// Pull-to-refresh 시 챗방 목록 새로고침
  Future<void> _refreshChatRooms() async {
    setState(() {
      _currentPage = 0;
      _hasMoreData = true;
    });
    context.read<ChatRoomsBloc>().add(FetchAllChatRooms(0, _initialPageSize));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAvatar(String name) {
    final color1 = getStableVividColor(name);
    final color2 = getStableVividColor(name + 'gradient');

    return ClipOval(
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color1, color2],
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white.withOpacity(0.2),
        elevation: 0,
        title: const Text(
          'Chat',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () {
              // CreateChatRoomView에 accessToken과 userId 전달
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateChatRoomView(
                    accessToken: widget.accessToken,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<ChatRoomsBloc, ChatRoomsState>(
        listener: (context, state) {
          if (state.status == ChatRoomsStatus.success) {
            setState(() {
              _isFetching = false;
              _hasMoreData = !state.lastPage;
              if (_hasMoreData) _currentPage++;
            });
          } else if (state.status == ChatRoomsStatus.failure) {
            setState(() {
              _isFetching = false;
              _hasMoreData = false;
            });
          }
        },
        child: BlocBuilder<ChatRoomsBloc, ChatRoomsState>(
          builder: (context, state) {
            if (state.status == ChatRoomsStatus.loading &&
                state.allRooms.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ChatRoomsStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Failed to load chat rooms',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 8),
                    Text(state.error?.message ?? 'Unknown error',
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _currentPage = 0;
                        _hasMoreData = true;
                        _fetchChatRooms(firstLoad: true);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshChatRooms,
              color: Colors.black,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.allRooms.length + (_isFetching ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.allRooms.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final room = state.allRooms[index];
                  return ListTile(
                    leading: _buildAvatar(room.name),
                    title: Text(room.name),
                    onTap: () {
                      // 채팅방 선택 시 ChatView로 이동 (accessToken, userId 전달)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatView(
                            roomId: room.id,
                            accessToken: widget.accessToken,
                            senderId: widget.userId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
