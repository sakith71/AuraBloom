import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/community/community-screen.dart';
import 'screens/splash-screen.dart';
import 'screens/login-page.dart';
import 'screens/signup-screen.dart';
import 'screens/home-screen.dart';
import 'screens/personal-info-screen.dart';
// We'll comment out this import until we fix the file location

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // For testing community feature: sign in anonymously if not already signed in
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    print('Error signing in anonymously: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuraBloom',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFD4C0D6),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(selectedDates: {}),
        '/personal-info': (context) => const PersonalInfoScreen(),
        // We'll comment out this route until we have the file
        '/community': (context) => const CommunityScreen(),
      },
    );
  }
}
