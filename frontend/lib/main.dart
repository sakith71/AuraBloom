import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash-screen.dart';
import 'screens/login-page.dart';
import 'screens/signup-screen.dart';
import 'screens/home/home-screen.dart';
import 'screens/community/community-screen.dart';
import 'screens/register/personal-info-screen.dart';
import 'wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // For testing community feature: sign in anonymously if not already signed in
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    Exception('Error signing in anonymously: $e');
  }
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
        scaffoldBackgroundColor: const Color(0xFFFCF0F7),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/wrapper': (context) => const Wrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(userId: 'someUserId'),
        '/community': (context) => const CommunityScreen(),
        '/personal_info': (context) {
          final userId = ModalRoute.of(context)?.settings.arguments as String;
          return PersonalInfoScreen(userId: userId);
        },
      },
    );
  }
}
