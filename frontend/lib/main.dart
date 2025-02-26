import 'package:flutter/material.dart';
import 'screens/splash-screen.dart';

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
        scaffoldBackgroundColor: Color(0xFFD4C0D6),
        // Set other theme properties as needed
      ),
      home: const SplashScreen(),
    );
  }
}
