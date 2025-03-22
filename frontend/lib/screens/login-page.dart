import 'package:flutter/material.dart';
import '../widgets/login-form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFCF0F7)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Center(
                child: Image.asset(
                  'assets/loginPage.png',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please log in to continue",
                style: TextStyle(color: Colors.black87, fontSize: 20),
              ),
              const SizedBox(height: 30),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
