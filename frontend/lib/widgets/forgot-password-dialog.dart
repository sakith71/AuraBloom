import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/validators.dart';

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Future<void> _resetPassword() async {
      if (!formKey.currentState!.validate()) return;

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );
        Navigator.pop(context); // Close forgot password dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent")),
        );
        Navigator.pop(context); // Close forgot password dialog
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to send password reset email: ${e.toString()}",
            ),
          ),
        );
      }
    }

    return AlertDialog(
      title: const Text("Forgot your password?"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please enter the account for which you want to reset the password.",
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Enter Email",
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) => Validators.validateEmail(value), // Validate email
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _resetPassword,
          child: const Text("Send Email"),
        ),
      ],
    );
  }
}
