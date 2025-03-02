import 'package:flutter/material.dart';
import '/utils/calendar.dart';
import 'event-item.dart';

class UpcomingEvents extends StatelessWidget {
  final Set<String> selectedDates;

  const UpcomingEvents({
    super.key,
    required this.selectedDates,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate next period date assuming 28-day cycle from the last selected date
    String nextPeriodDate = '';
    
    if (selectedDates.isNotEmpty) {
      // Get the most recent date from selected dates
      final sortedDates = selectedDates.toList()
        ..sort((a, b) {
          final aParts = a.split('-');
          final bParts = b.split('-');
          
          // Compare years
          final aYear = int.parse(aParts[2]);
          final bYear = int.parse(bParts[2]);
          if (aYear != bYear) return aYear.compareTo(bYear);
          
          // Compare months
          final aMonthIndex = CalendarUtils.months.indexOf(aParts[0]);
          final bMonthIndex = CalendarUtils.months.indexOf(bParts[0]);
          if (aMonthIndex != bMonthIndex) return aMonthIndex.compareTo(bMonthIndex);
          
          // Compare days
          final aDay = int.parse(aParts[1]);
          final bDay = int.parse(bParts[1]);
          return aDay.compareTo(bDay);
        });
      
      final lastPeriodDateKey = sortedDates.last;
      final parts = lastPeriodDateKey.split('-');
      final month = parts[0];
      final day = parts[1];
      final year = parts[2];
      
      // Convert to DateTime
      final standardDate = CalendarUtils.formatToStandardDate(month, day, year);
      final lastPeriodDate = DateTime.parse(standardDate);
      
      // Calculate next period (28 days after last period)
      final nextPeriod = CalendarUtils.calculateNextPeriod(lastPeriodDate);
      nextPeriodDate = CalendarUtils.formatDateForDisplay(nextPeriod);
      
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
            'Upcoming Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          selectedDates.isEmpty
              ? const Text('Select your period dates to see predictions',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
              : Column(
                  children: [
                    EventItem(
                      title: 'Next Period',
                      date: nextPeriodDate,
                      icon: Icons.calendar_today,
                      color: Colors.pink,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}