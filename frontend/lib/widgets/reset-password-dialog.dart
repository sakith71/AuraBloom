import 'package:flutter/material.dart';
import '../utils/validators.dart';

class ResetPasswordDialog extends StatelessWidget {
  final String email; // Pass email from ForgotPasswordDialog

  const ResetPasswordDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text("Reset your password"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Please enter your new password."),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Enter New Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: Validators.validatePassword, // Validate password
            ),
            const SizedBox(height: 10),
            const Text(
              "• The length of password should be 8 - 20 characters.\n"
                  "• Password should contain letters, numbers, and special characters.\n"
                  "• Password can only include .!@#\$%^&*<> symbols.",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst); // Navigate back to login page
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              // Perform password reset logic here (e.g., API call)
              Navigator.popUntil(context, (route) => route.isFirst); // Navigate back to login page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password reset successfully!")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a valid password")),
              );
            }
          },
          child: const Text("Reset Password"),
        ),
      ],
    );
  }
}

