import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/login-page.dart';
import 'package:frontend/services/auth-service.dart';
import '../widgets/custom-text-field.dart';
import '../widgets/signup-illustration.dart';
import '../widgets/signup-button.dart';
import '../utils/validators.dart';
import 'personal-info-screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // New state variable to control password visibility
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    // Hide keyboard when sign up is pressed
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();

        // Call the updated signUp method from the AuthService class
        AuthService authService = AuthService();
        final result = await authService.signUp(email, password);

        if (result['success']) {
          User? user = result['user'];
          if (user != null) {
            // Navigate to personal info screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalInfoScreen(userId: user.uid),
              ),
            );
          }
        } else {
          // Show error message returned from the service
          setState(() {
            _errorMessage = result['message'];
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4C2CA), // Light Pink
              Color(0xFFD4C0D6), // Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const SignUpIllustration(),
                    const SizedBox(height: 20),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Please fill in the details to sign up',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // Error message display
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    CustomTextField(
                      controller: _usernameController,
                      hintText: 'Enter User Name',
                      validator: Validators.validateUsername,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Enter Email',
                      validator: Validators.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Password field with visibility toggle
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Enter Password',
                      validator: Validators.validatePassword,
                      isPassword: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password field with same visibility toggle
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      validator:
                          (value) => Validators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                      isPassword: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Loading state handling with sign up button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SignUpButton(onPressed: _handleSignUp),

                    const SizedBox(height: 20),

                    // Login redirect row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 240, 99, 153),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
