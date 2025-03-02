import 'package:flutter/material.dart';
import '../widgets/calendar-widgets/calendar-card.dart';
import '../widgets/calendar-widgets/upcoming-events.dart';

class CalendarPage extends StatefulWidget {
  final String? selectedDate;
  final Set<String> selectedDates; // Add this line
  const CalendarPage({super.key, this.selectedDate, required this.selectedDates});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Set<String> selectedDates;
  int currentMonthIndex = DateTime.now().month - 1;
  int currentYear = DateTime.now().year;
  bool isDatesChanged = false;

  @override
  void initState() {
    super.initState();
    // Initialize with dates passed from parent
    selectedDates = Set<String>.from(widget.selectedDates);
  }

  void onDateSelected(String dateKey) {
    setState(() {
      if (selectedDates.contains(dateKey)) {
        selectedDates.remove(dateKey);
      } else {
        selectedDates.add(dateKey);
      }
      isDatesChanged = true;
    });
  }

  void navigateMonth(int direction) {
    setState(() {
      currentMonthIndex += direction;
      
      if (currentMonthIndex > 11) {
        currentMonthIndex = 0;
        currentYear++;
      } else if (currentMonthIndex < 0) {
        currentMonthIndex = 11;
        currentYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Period Calendar',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalendarCard(
                        currentMonthIndex: currentMonthIndex,
                        currentYear: currentYear,
                        selectedDates: selectedDates,
                        onDateSelected: onDateSelected,
                        onNavigateMonth: navigateMonth,
                      ),
                      const SizedBox(height: 20),
                      UpcomingEvents(selectedDates: selectedDates),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}