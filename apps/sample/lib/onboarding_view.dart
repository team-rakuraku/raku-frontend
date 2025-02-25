import 'dart:convert';
import 'package:chat_sdk/authentication/domain/entity/user_entity.dart';
import 'package:chat_sdk/authentication/presentation/auth_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:chat_ui/chat_rooms/all_chat_rooms_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final TextEditingController _userIdController = TextEditingController();
  String? _error;

  String generateAccessToken(String userId) {
    final header = {"alg": "HS256", "typ": "JWT"};
    final iat = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final exp = iat + 2592000;
    final payload = {"sub": userId, "iat": iat, "exp": exp};

    String base64UrlEncodeWithoutPadding(String input) {
      return base64Url.encode(utf8.encode(input)).replaceAll('=', '');
    }

    final encodedHeader = base64UrlEncodeWithoutPadding(json.encode(header));
    final encodedPayload = base64UrlEncodeWithoutPadding(json.encode(payload));

    final data = '$encodedHeader.$encodedPayload';

    const secretKey = 'aaaadfasdfasdfasfdsadfasdfasdfgasgasdfgadsfgadsfgasdf'; // 예시 시크릿키
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    final signatureBytes = hmac.convert(utf8.encode(data)).bytes;
    final encodedSignature = base64Url.encode(signatureBytes).replaceAll('=', '');

    final token = '$data.$encodedSignature';
    return token;
  }

  void _enterChat() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() {
        _error = "User ID를 입력해주세요.";
      });
      return;
    }
    // 에러 초기화
    setState(() {
      _error = null;
    });

    final accessToken = generateAccessToken(userId);

    final user = User(
      userId: userId,
      accessToken: accessToken,
      appId: "rakuraku3",
      nickname: "",
      profileImageUrl: "",
    );

    final sdk = RakuChatSDK.initialize();
    final result = await sdk.login(
      accessToken: accessToken,
      appId: "rakuraku3",
      user: user,
    );
    debugPrint("login 결과: $result");

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${failure.message}")),
        );
      },
      (loggedInUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AllChatRoomsView(
              userId: loggedInUser.userId,
              accessToken: loggedInUser.accessToken,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _userIdController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: "User ID를 입력하세요",
                  labelStyle: const TextStyle(color: Colors.black),
                  errorText: _error,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _enterChat,
                child: const Text(
                  "입장",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
