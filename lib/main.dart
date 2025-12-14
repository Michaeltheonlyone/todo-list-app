import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/task_list_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

import 'screens/logo_screen.dart';
import 'screens/splash_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  // Check Login Status
  final isLoggedIn = await AuthService.isLoggedIn();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rappel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // One UI / iOS Blend
        primaryColor: const Color(0xFF007AFF),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5), // Softer gray/blueish tint
        fontFamily: 'SF Pro Display',
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          primary: const Color(0xFF007AFF),
          secondary: const Color(0xFF5856D6), // Modern Purple
          tertiary: const Color(0xFFFF2D55), // Vibrant Red/Pink
          background: const Color(0xFFF0F2F5),
          surface: Colors.white,
          brightness: Brightness.light,
        ),

        // Modern Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Colors.black87),
          bodyLarge: TextStyle(fontSize: 17, height: 1.4, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: Colors.black54),
        ),

        // Soft Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), 
            borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2)
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIconColor: const Color(0xFF007AFF),
        ),

        // Pill Buttons with Shadow
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF007AFF).withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LogoScreen(),
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/tasks': (context) => const TaskListScreen(),
        // Alias if needed
        '/home': (context) => const TaskListScreen(), 
      },
    );
  }
}