import 'package:flutter/material.dart';
import '../utils/calendar.dart';
import 'calendar-day.dart';

class CalendarMonth extends StatelessWidget {
  final String month;
  final int monthIndex;
  final int year;
  final Set<String> selectedDates;
  final Set<String> predictedDates;
  final Function(String) onDateSelected;

  const CalendarMonth({
    super.key,
    required this.month,
    required this.monthIndex,
    required this.year,
    required this.selectedDates,
    this.predictedDates = const {},
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = CalendarUtils.getWeeksForMonth(year, monthIndex + 1);
    final today = DateTime.now();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$month $year',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (monthIndex + 1 == today.month && year == today.year)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 233, 242),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Current',
                      style: TextStyle(
                        color: Color.fromARGB(255, 240, 99, 153),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('M', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('T', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('W', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('T', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('F', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('S', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('S', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ...weeks.map((week) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: week.map((day) {
                final dateKey = '$month-$day-$year';
                final isSelected = selectedDates.contains(dateKey);
                final isPredicted = predictedDates.contains(dateKey);
                final isEnabled = day.isNotEmpty;
                
                bool isPastOrToday = false;
                if (isEnabled) {
                  final currentDate = DateTime(year, monthIndex + 1, int.parse(day));
                  final nowDate = DateTime(today.year, today.month, today.day);
                  isPastOrToday = currentDate.compareTo(nowDate) <= 0;
                }

                final isToday = isEnabled && 
                    year == today.year && 
                    monthIndex + 1 == today.month && 
                    int.parse(day) == today.day;

                return CalendarDay(
                  day: day,
                  isSelected: isSelected,
                  isEnabled: isEnabled,
                  isPastOrToday: isPastOrToday,
                  isToday: isToday,
                  isPredicted: isPredicted,
                  onTap: isEnabled ? () => onDateSelected(dateKey) : null,
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }
}