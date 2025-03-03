import 'package:flutter/material.dart';
import '../widgets/navigation-buttons.dart';
import '../widgets/calendar-month.dart';
import '../utils/calendar.dart';
import '../services/firestore_service.dart';
import 'home-screen.dart';

class PeriodLoggingScreen extends StatefulWidget {
  final String userId;
  
  const PeriodLoggingScreen({super.key, required this.userId});

  @override
  State<PeriodLoggingScreen> createState() => _PeriodLoggingScreenState();
}

class _PeriodLoggingScreenState extends State<PeriodLoggingScreen> {
  String? _selectedDate;
  final ScrollController _scrollController = ScrollController();
  late DateTime _currentDate;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    // Scroll to current month initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }

  void _scrollToCurrentMonth() {
    // Calculate approximate position to scroll to current month
    // This is just a rough calculation - you may need to adjust
    double itemHeight = 300; // Estimated height of a month widget
    double targetPosition = (11 - 3) * itemHeight; // Show current month after 3 months
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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

  Future<void> _saveLastPeriodAndFinish() async {
    if (_selectedDate == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Parse the selected date
      final dateParts = _selectedDate!.split('-');
      if (dateParts.length == 3) {
        final month = dateParts[0];
        final day = dateParts[1];
        final year = dateParts[2];
        
        // Convert to DateTime
        final lastPeriodDate = CalendarUtils.parseDisplayDate(
          '$month $day, $year'
        ) ?? DateTime.now();
        
        // Save the last period date
        await _firestoreService.savePeriodData(widget.userId, lastPeriodDate);
        
        // Navigate to home screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userId: widget.userId,
                selectedDate: _selectedDate,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving last period: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NavigationButtonRow(
                        onPrevious: _handlePrevious,
                        onNext: _saveLastPeriodAndFinish,
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