import 'package:chat_ui/chat/chat_bloc.dart';
import 'package:chat_ui/chat_rooms/chat_rooms_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:chat_sdk/chat/data/mapper/chat_mappers.dart';
import 'package:chat_sdk/chat/data/remote/chat_repository.dart';
import 'package:chat_sdk/chat/domain/data_interfaces/chat_repository_interface.dart';
import 'package:chat_sdk/chat/domain/usecases/chat_usecase.dart';
import 'package:chat_sdk/services/remote/transport/http_transport.dart';
import 'package:sample/onboarding_view.dart';

void main() {
  final IChatRepository chatRepository = ChatRepositoryImpl(
    http: HttpTransport(Dio()),
    mapper: ChatMapper(),
    socketUrl: 'http://acec93397c45740cd91228806400ad86-1631035604.ap-northeast-2.elb.amazonaws.com:4000/ws', // 예시 주소
  );

  final ChatUseCase chatUseCase = ChatUseCase(chatRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        RepositoryProvider<ChatUseCase>(create: (context) => chatUseCase),
        BlocProvider<ChatRoomsBloc>(
          create: (context) => ChatRoomsBloc(chatUseCase: chatUseCase),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(chatUseCase: chatUseCase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.transparent,
          secondary: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      home: const OnboardingView(),
    );
  }
}
