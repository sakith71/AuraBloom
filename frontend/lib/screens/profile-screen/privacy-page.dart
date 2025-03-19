import 'package:flutter/material.dart';
import '../login-page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _profileVisible = true;
  bool _dataSharing = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileVisible = prefs.getBool('profileVisible') ?? true;
      _dataSharing = prefs.getBool('dataSharing') ?? true;
    });
  }

  Future<void> _saveProfileVisibility(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileVisible', value);
    setState(() {
      _profileVisible = value;
    });
  }

  Future<void> _saveDataSharing(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataSharing', value);
    setState(() {
      _dataSharing = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                    ),
                    const SizedBox(height: 15),
                    _buildPrivacySection(
                      title: 'Health Data Sharing',
                      subtitle:
                          'Share anonymous health data to improve the app',
                      value: _dataSharing,
                      onChanged: (value) {
                        _saveDataSharing(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _handleDataDownload(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      'Download My Data',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => _handleDataDeletion(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(
                      'Delete My Account',
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
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
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }

  void _handleDataDownload() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Download My Data'),
            content: const Text(
              'You can download all your personal data. The process may take a few minutes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data download started. You\'ll be notified when it\'s ready.',
                      ),
                    ),
                  );
                },
                child: const Text('Download'),
              ),
            ],
          ),
    );
  }

  void _handleDataDeletion() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                  // Implement account deletion logic

                  // Clear the navigation stack and navigate to login page
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false, // Clear all routes
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Account'),
              ),
            ],
          ),
    );
  }
}
