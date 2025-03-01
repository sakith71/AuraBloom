import 'package:flutter/material.dart';
import '/utils/calendar.dart';
import '/widgets/calendar-month.dart';

class CalendarCard extends StatelessWidget {
  final int currentMonthIndex;
  final int currentYear;
  final Set<String> selectedDates;
  final Function(String) onDateSelected;
  final Function(int) onNavigateMonth;

  const CalendarCard({
    super.key,
    required this.currentMonthIndex,
    required this.currentYear,
    required this.selectedDates,
    required this.onDateSelected,
    required this.onNavigateMonth,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonth = CalendarUtils.months[currentMonthIndex];

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentMonth $currentYear',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => onNavigateMonth(-1),
                    iconSize: 18,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => onNavigateMonth(1),
                    iconSize: 18,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          CalendarMonth(
            month: currentMonth,
            monthIndex: currentMonthIndex,
            year: currentYear,
            selectedDates: selectedDates,
            onDateSelected: onDateSelected,
          ),
        ],
      ),
    );
  }
}
