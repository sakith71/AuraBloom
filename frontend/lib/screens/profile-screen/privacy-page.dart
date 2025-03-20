import 'package:flutter/material.dart';
import '../login-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Auth import

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _profileVisible = true;
  bool _healthInfoVisible = true; // Health info visibility
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize Firebase Auth

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileVisible = prefs.getBool('profileVisible') ?? true;
      _healthInfoVisible = prefs.getBool('healthInfoVisible') ?? true;
    });
  }

  Future<void> _saveProfileVisibility(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileVisible', value);
    setState(() {
      _profileVisible = value;
    });
  }

  Future<void> _saveHealthInfoVisibility(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('healthInfoVisible', value);
    setState(() {
      _healthInfoVisible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the toggle color
    const Color toggleColor = Color.fromARGB(255, 255, 115, 166);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCF0F7)
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildPrivacySection(
                      title: 'Profile Visibility',
                      subtitle: 'Make your profile visible to other users',
                      value: _profileVisible,
                      onChanged: (value) {
                        _saveProfileVisibility(value);
                      },
                      activeColor: toggleColor,
                    ),
                    const SizedBox(height: 15),
                    _buildPrivacySection(
                      title: 'Health Information Visibility',
                      subtitle:
                          'Display your health information on your profile',
                      value: _healthInfoVisible,
                      onChanged: (value) {
                        _saveHealthInfoVisibility(value);
                      },
                      activeColor: toggleColor,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => _handleDataDeletion(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(255, 255, 115, 166),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Delete My Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      ),
    );
  }

  // Delete the user account from Firebase Authentication
  Future<void> _deleteUserAccount() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;
      
      if (user != null) {
        // Delete the user account
        await user.delete();
        
        // Clear local storage and preferences if needed
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Navigate to login page
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false, // Clear all routes
          );
        }
      }
    } catch (e) {
      // Handle errors (e.g., requires recent authentication)
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        _showReauthDialog();
      } else {
        _showErrorDialog('Failed to delete account: ${e.toString()}');
      }
    }
  }

  // Show dialog for reauthentication if needed
  void _showReauthDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'For security reasons, please re-enter your credentials to delete your account.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Create a credential
                AuthCredential credential = EmailAuthProvider.credential(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
                
                // Reauthenticate user
                await _auth.currentUser?.reauthenticateWithCredential(credential);
                
                // Try deleting again after reauthentication
                await _deleteUserAccount();
              } catch (e) {
                _showErrorDialog('Authentication failed: ${e.toString()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 115, 166),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleDataDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUserAccount(); // Call the method to delete the account
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 255, 115, 166),
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}