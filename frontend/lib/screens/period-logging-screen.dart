import 'package:flutter/material.dart';
import '../widgets/navigation-buttons.dart';
import '../widgets/calendar-month.dart';
import '../utils/calendar.dart';
import '../screens/home-screen.dart';

class PeriodLoggingScreen extends StatefulWidget {
  const PeriodLoggingScreen({super.key});

  @override
  State<PeriodLoggingScreen> createState() => _PeriodLoggingScreenState();
}

class _PeriodLoggingScreenState extends State<PeriodLoggingScreen> {
  String? _selectedDate;
  final ScrollController _scrollController = ScrollController();
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    Stream.periodic(const Duration(days: 1)).listen((_) {
      setState(() {
        _currentDate = DateTime.now();
      });
    });
  }

  void _handleDateSelection(String dateKey) {
    setState(() {
      if (_selectedDate == dateKey) {
        _selectedDate = null;
      } else {
        _selectedDate = dateKey;
      }
    });
  }

  void _handlePrevious() {
    Navigator.pop(context);
  }

  void _handleNext() {
    if (_selectedDate != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(selectedDates: {_selectedDate!}, userId: 'yourUserId'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> monthWidgets = [];
    DateTime currentMonth = DateTime(_currentDate.year, _currentDate.month);

    for (int i = -11; i <= 0; i++) {
      DateTime targetMonth = DateTime(
        currentMonth.year,
        currentMonth.month + i,
      );
      monthWidgets.add(
        CalendarMonth(
          month: CalendarUtils.months[targetMonth.month - 1],
          monthIndex: targetMonth.month - 1,
          year: targetMonth.year,
          selectedDates: _selectedDate != null ? {_selectedDate!} : {},
          onDateSelected: _handleDateSelection,
        ),
      );
    }

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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'When did your last period start?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please select a single date',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(children: monthWidgets),
                  ),
                ),
                const SizedBox(height: 20),
                NavigationButtonRow(
                  onPrevious: _handlePrevious,
                  onNext: _handleNext,
                  isNextEnabled: _selectedDate != null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
