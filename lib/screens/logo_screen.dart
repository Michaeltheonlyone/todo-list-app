import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      // Check auth here
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;
      
      if (isLoggedIn) {
        // If already logged in, show splash (loading) then tasks
        Navigator.pushReplacementNamed(context, '/splash');
      } else {
        // If not, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        child: Image.asset(
          'assets/images/splash_logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}