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
  bool _locationSharing = false;
  bool _dataSharing = true;
  String _selectedDataRetention = '6 months';

  final List<String> _dataRetentionOptions = [
    '1 month',
    '3 months',
    '6 months',
    '1 year',
    'Forever',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileVisible = prefs.getBool('profileVisible') ?? true;
      _locationSharing = prefs.getBool('locationSharing') ?? false;
      _dataSharing = prefs.getBool('dataSharing') ?? true;
      _selectedDataRetention = prefs.getString('dataRetention') ?? '6 months';
    });
  }

  Future<void> _saveProfileVisibility(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileVisible', value);
    setState(() {
      _profileVisible = value;
    });
  }

  Future<void> _saveLocationSharing(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationSharing', value);
    setState(() {
      _locationSharing = value;
    });
  }

  Future<void> _saveDataSharing(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataSharing', value);
    setState(() {
      _dataSharing = value;
    });
  }

  Future<void> _saveDataRetention(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataRetention', value);
    setState(() {
      _selectedDataRetention = value;
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
        child: ListView(
          padding: const EdgeInsets.all(20),
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
              title: 'Location Sharing',
              subtitle: 'Share your location for better recommendations',
              value: _locationSharing,
              onChanged: (value) {
                _saveLocationSharing(value);
              },
            ),
            const SizedBox(height: 15),
            _buildPrivacySection(
              title: 'Health Data Sharing',
              subtitle: 'Share anonymous health data to improve the app',
              value: _dataSharing,
              onChanged: (value) {
                _saveDataSharing(value);
              },
            ),
            const SizedBox(height: 15),
            _buildDataRetentionSection(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _handleDataDownload(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              ),
              child: Text(
                'Delete My Account',
                style: TextStyle(color: Colors.red.shade300, fontSize: 16),
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

  Widget _buildDataRetentionSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Retention',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how long to keep your data',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _selectedDataRetention,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
            ),
            items:
                _dataRetentionOptions.map((String duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Text(duration),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                _saveDataRetention(newValue);
              }
            },
          ),
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
