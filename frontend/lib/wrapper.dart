import 'package:flutter/material.dart';
import 'services/auth-service.dart';
import 'screens/home/home-screen.dart';
import 'screens/login-page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Check if user is signed in
      if (_authService.isUserSignedIn) {
        // Check if user has completed onboarding
        bool hasCompletedOnboarding = await _authService.hasCompletedOnboarding();
        
        setState(() {
          _isAuthenticated = hasCompletedOnboarding;
          _userId = _authService.currentUserId ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth state: $e');
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking auth state
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFCF0F7),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE82A5)),
            ),
          ),
        ),
      );
    }

    // Navigate to appropriate screen based on authentication state
    if (_isAuthenticated && _userId.isNotEmpty) {
      return HomeScreen(userId: _userId);
    } else {
      return const LoginScreen();
    }
  }
}