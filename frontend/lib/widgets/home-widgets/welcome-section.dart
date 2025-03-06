import 'package:flutter/material.dart';
import '../../utils/calendar.dart';

class WelcomeSection extends StatelessWidget {
  final String? selectedDate;
  final List<String> selectedDates = [];

  WelcomeSection({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    String lastPeriodDate = "Not set";
    if (selectedDates.isNotEmpty) {
      try {
        final dateParts = selectedDates.first.split('-');
        final formattedDate = '${dateParts[2]}-${CalendarUtils.getMonthNumber(dateParts[0])}-${dateParts[1]}';
        final date = DateTime.parse(formattedDate);
        lastPeriodDate = CalendarUtils.formatDateForDisplay(date);
      } catch (e) {
        lastPeriodDate = "Date format error";
      }
    }

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
            'Welcome back!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Last period started: $lastPeriodDate',
            style: TextStyle(
              fontSize: 14,
              color: Colors.pink.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}