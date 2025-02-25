import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_sdk/chat/domain/entity/chat_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart'; // MIME 타입 판별
import 'package:flutter_image_compress/flutter_image_compress.dart'; // HEIC -> JPEG 변환

import 'chat_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatView extends StatefulWidget {
  final String roomId;
  final String accessToken;
  final String senderId;

  const ChatView({
    Key? key,
    required this.roomId,
    required this.accessToken,
    required this.senderId,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  final ScrollController _scrollController = ScrollController();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1) 기존 메시지 불러오기
    context.read<ChatBloc>().add(FetchChatHistory(roomId: widget.roomId));

    // 2) STOMP WebSocket 연결
    context.read<ChatBloc>().add(ConnectToChat());

    // 3) 연결 후 메시지 구독
    context
        .read<ChatBloc>()
        .stream
        .firstWhere((state) => state.status == ChatStatus.connected)
        .then((_) {
      context
          .read<ChatBloc>()
          .add(SubscribeToMessages(roomId: widget.roomId));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 키보드 열림 감지 → 자동 스크롤
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() => _isKeyboardVisible = bottomInset > 0);
    if (_isKeyboardVisible) {
      _scrollToBottom();
    }
  }

  /// 채팅 목록 자동 스크롤
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      debugPrint("❌ 전송할 내용이 없습니다.");
      return;
    }

    final message = ChatMessage(
      messageId: "", // 서버에서 반환하는 ID 사용
      tempId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.senderId,
      roomId: widget.roomId,
      content: text,
      imageUrl: null,
      createdAt: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessage(
      message: message,
      accessToken: widget.accessToken,
      hasImage: false,
    ));

    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      debugPrint("❌ 이미지 선택 취소됨");
      return;
    }

    File imageFile = File(picked.path);
    debugPrint("🟢 로컬 파일 경로: ${imageFile.path}");

    String mimeType =
        lookupMimeType(imageFile.path) ?? "application/octet-stream";
    if (mimeType == "image/heic" || mimeType == "image/heif") {
      imageFile = await convertToJpeg(imageFile);
      mimeType = "image/jpeg";
    }

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticMessage = ChatMessage(
      messageId: tempId,
      tempId: tempId,
      senderId: widget.senderId,
      roomId: widget.roomId,
      content: "",
      imageUrl: imageFile.path,
      createdAt: DateTime.now(),
    );

    context.read<ChatBloc>().add(ReceiveMessage(message: optimisticMessage));

    final uploadEither = await context
        .read<ChatBloc>()
        .uploadFileToS3(accessToken: widget.accessToken, file: imageFile,)
        .run();

    uploadEither.match(
          (failure) {
        debugPrint("❌ S3 업로드 실패: ${failure.message}");
      },
          (s3Url) {
        debugPrint("✅ S3 업로드 완료. 업로드된 URL: $s3Url");

        final finalMessage = optimisticMessage.copyWith(
          imageUrl: s3Url, // S3 URL 적용
        );

        context.read<ChatBloc>().add(SendMessage(
          message: finalMessage,
          accessToken: widget.accessToken,
          hasImage: true,
        ));
      },
    );
  }

  /// HEIC → JPEG 변환
  Future<File> convertToJpeg(File file) async {
    final targetPath = file.path
        .replaceAll('.heic', '.jpg')
        .replaceAll('.heif', '.jpg');

    final File? compressedFile = (await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      format: CompressFormat.jpeg,
      quality: 90,
    )) as File?;

    return compressedFile ?? file;
  }

  /// 채팅 상대방 아바타 (임의로 색상 그라디언트 적용)
  Widget buildGradientAvatar(String userId) {
    final hash = userId.hashCode;
    final hue = (hash % 360).toDouble();

    final color1 = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    final color2 = HSVColor.fromAHSV(1.0, (hue + 30) % 360, 1.0, 1.0).toColor();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  /// 메시지 버블 빌드
  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    // 내용과 이미지가 모두 없으면 빈 위젯 반환
    if (message.content.trim().isEmpty &&
        (message.imageUrl == null || message.imageUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final imageToShow = message.imageUrl;
    Widget? imageWidget;
    if (imageToShow != null && imageToShow.isNotEmpty) {
      if (imageToShow.startsWith("http")) {
        imageWidget = Image.network(
          imageToShow,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      } else {
        // 로컬 파일 경로인 경우
        imageWidget = Image.file(
          File(imageToShow),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMe ? 3.0 : 10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Row(
              children: [
                buildGradientAvatar(message.senderId),
                const SizedBox(width: 8),
                Text(
                  message.senderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: isMe ? null : Colors.grey[300],
                  gradient: isMe
                      ? const LinearGradient(
                    colors: [Color(0xFF61BD4C), Color(0xFF39D053)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.content.isNotEmpty)
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    if (imageWidget != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: imageWidget,
                      ),
                  ],
                ),
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
      // 채팅 입력창이 화면 아래에 노출되도록
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
        title: const Text(
          "Chat",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // GestureDetector로 전체 영역을 감싸서 빈 공간 터치 시 키보드 내리기
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // 메시지 목록
            BlocListener<ChatBloc, ChatState>(
              listenWhen: (previous, current) =>
              previous.messages.length < current.messages.length,
              listener: (context, state) {
                // 새 메시지 도착 시 자동 스크롤
                _scrollToBottom();
              },
              child: Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.messages.isEmpty) {
                      return const Center(child: Text("채팅 내역이 없습니다."));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = (message.senderId == widget.senderId);
                        return _buildMessageBubble(message, isMe);
                      },
                    );
                  },
                ),
              ),
            ),
            // 입력창
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/icons/gallery.svg",
                            width: 20,
                            height: 20,
                          ),
                          onPressed: _pickImage,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: "메시지를 입력하세요...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            "assets/icons/send.svg",
                            width: 20,
                            height: 20,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
