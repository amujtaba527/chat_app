import 'package:chat_app/chat_screen.dart';
import 'package:chat_app/conversation.dart';
import 'package:chat_app/login.dart';
import 'package:chat_app/signup.dart';
import 'package:chat_app/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/chatscreen': (context) => ChatsScreen(),
        '/conversation': (context) => ConversationScreen(),
      },
    );
  }
}
