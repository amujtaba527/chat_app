import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/splash_frame.png', 
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover
            ),
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 170,
              height: 170,
            ),
          ),
        ],
      ),
    );
  }
}