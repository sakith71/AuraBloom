// lib/screens/profile/widgets/logout_button.dart
import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;

  const LogoutButton({
    super.key,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showLogoutDialog(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.red.shade300),
          ),
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            color: Colors.red.shade300,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    // Clear user data, tokens, etc.
    // You might want to use a state management solution here
    
    if (onLogout != null) {
      onLogout!();
    } else {
      // Default logout behavior
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully logged out'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}