import 'package:flutter/material.dart';
import '../../utils/calendar.dart';
import '../../services/user-service.dart';

class WelcomeSection extends StatefulWidget {
  final String userId;
  final String? selectedDate;
  final List<String> selectedDates;

  const WelcomeSection({
    super.key,
    required this.userId,
    this.selectedDate,
    this.selectedDates = const [],
  });

  @override
  State<WelcomeSection> createState() => _WelcomeSectionState();
}

class _WelcomeSectionState extends State<WelcomeSection> {
  final UserService _userService = UserService();
  String _username = '';
  bool _isLoading = true;
  String _todayFormatted = '';

  @override
  void initState() {
    super.initState();
    _todayFormatted = CalendarUtils.getTodayFormatted();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final username = await _userService.getUserName(widget.userId);

      if (mounted) {
        setState(() {
          _username = username;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _username = 'User'; // Fallback
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isLoading
              ? const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
              : Text(
                'Welcome back, $_username!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
          const SizedBox(height: 4),
          Text(
            'Today, $_todayFormatted',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
