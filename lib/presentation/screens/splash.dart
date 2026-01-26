import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _irAHome);
  }

  void _irAHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),

      body: Center(
        child: Text(
          'HABIT CONTROL',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 238, 183, 80),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}