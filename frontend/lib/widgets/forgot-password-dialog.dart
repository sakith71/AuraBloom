import 'package:flutter/material.dart';
import '../utils/validators.dart';
import 'reset-password-dialog.dart';

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text("Forgot your password?"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Please enter the account for which you want to reset the password."),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Enter Email",
                border: OutlineInputBorder(),
              ),
              validator: (value) => Validators.validateEmail(value), // Validate email
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
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context); // Close forgot password dialog
              showDialog(
                context: context,
                builder: (context) => const ResetPasswordDialog(email: '',),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a valid email")),
              );
            }
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}

