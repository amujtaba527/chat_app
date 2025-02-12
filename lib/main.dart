import 'package:chat_app/chat_screen.dart';
import 'package:chat_app/conversation.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/forgotpassword.dart';
import 'package:chat_app/login.dart';
import 'package:chat_app/profile.dart';
import 'package:chat_app/add_friend_screen.dart';
import 'package:chat_app/signup.dart';
import 'package:chat_app/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/chatscreen': (context) => const ChatsScreen(),
        '/conversation': (context) => const ConversationScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/addfriend': (context) => const AddFriendScreen(),
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use FirebaseAuth to check the user's authentication state
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, redirect to ChatsScreen
      return const ChatsScreen();
    } else {
      // User is not logged in, redirect to LoginScreen
      return const SplashScreen();
    }
  }
}
