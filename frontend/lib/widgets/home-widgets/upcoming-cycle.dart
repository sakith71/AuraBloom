import 'package:flutter/material.dart';
import '../../utils/calendar.dart';

class UpcomingCycle extends StatelessWidget {
  final String? selectedDate;
  final List<String> selectedDates = [];

  UpcomingCycle({Key? key, this.selectedDate}) : super(key: key);

  Widget _buildCycleInfo({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.pink.shade300),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String nextPeriod = "Not available";
    if (selectedDates.isNotEmpty) {
      try {
        final dateParts = selectedDates.first.split('-');
        final formattedDate = '${dateParts[2]}-${CalendarUtils.getMonthNumber(dateParts[0])}-${dateParts[1]}';
        final lastPeriod = DateTime.parse(formattedDate);
        final nextPeriodDate = lastPeriod.add(const Duration(days: 28));
        final now = DateTime.now();
        final daysUntil = nextPeriodDate.difference(now).inDays;
        nextPeriod = '$daysUntil days';
      } catch (e) {
        nextPeriod = "Calculation error";
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
            'Upcoming Cycle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCycleInfo(
                label: 'Next Period',
                value: nextPeriod,
                icon: Icons.calendar_today,
              ),
              _buildCycleInfo(
                label: 'Cycle Length',
                value: '28 days',
                icon: Icons.loop,
              ),
              _buildCycleInfo(
                label: 'Period Length',
                value: '5 days',
                icon: Icons.favorite,
              ),
            ],
          ),
        ],
      ),
    );
  }
}