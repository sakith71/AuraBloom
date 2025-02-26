import 'package:flutter/material.dart';
import 'screens/splash-screen.dart';
import 'screens/login-page.dart';
import 'screens/signup-screen.dart';
import 'screens/home-screen.dart';
import 'screens/personal-info-screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuraBloom',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFD4C0D6)
        // Set other theme properties as needed
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(selectedDates: {}),
        '/personal-info': (context) => const PersonalInfoScreen(),
      },
    );
  }
}