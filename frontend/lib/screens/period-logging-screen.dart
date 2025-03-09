import 'package:flutter/material.dart';
import '../widgets/navigation-buttons.dart';
import '../widgets/calendar-month.dart';
import '../utils/calendar.dart';
import '../services/period-service.dart';
import '../services/period-stats-service.dart';
import '../utils/stats-verification.dart'; // Import the verification utility
import 'home-screen.dart';

class PeriodLoggingScreen extends StatefulWidget {
  final String userId;
  
  const PeriodLoggingScreen({super.key, required this.userId});

  @override
  State<PeriodLoggingScreen> createState() => _PeriodLoggingScreenState();
}

class _PeriodLoggingScreenState extends State<PeriodLoggingScreen> {
  final Set<String> _selectedDates = {};
  final ScrollController _scrollController = ScrollController();
  late DateTime _currentDate;
  bool _isLoading = false;
  final PeriodService _periodService = PeriodService();
  final PeriodStatsService _periodStatsService = PeriodStatsService();
  final StatsVerificationUtil _verificationUtil = StatsVerificationUtil();

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
      // Toggle selection
      if (_selectedDates.contains(dateKey)) {
        _selectedDates.remove(dateKey);
      } else {
        _selectedDates.add(dateKey);
      }
    });
  }

  void _handlePrevious() {
    Navigator.pop(context);
  }

  Future<void> _saveMultiplePeriodDatesAndFinish() async {
    if (_selectedDates.isEmpty) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Save the period dates
      await _periodService.savePeriodDates(widget.userId, _selectedDates);
      
      // Calculate and update period stats for the last 6 cycles
      final stats = await _periodStatsService.updatePeriodStats(widget.userId, cycleLimit: 6);
      
      // Log to confirm stats are being saved
      print('Stats calculated and saved to database:');
      print('Mean Period Length: ${stats['meanPeriodLength']} days');
      print('Mean Cycle Length: ${stats['meanCycleLength']} days');
      
      // Verify that the stats were saved to the database
      await Future.delayed(const Duration(seconds: 1)); // Small delay to ensure data is written
      final verificationResult = await _verificationUtil.verifyPeriodStats(widget.userId);
      
      print('Database verification result: ${verificationResult['success'] ? 'Success' : 'Failed'}');
      print('Database message: ${verificationResult['message']}');
      if (verificationResult['success']) {
        print('Saved periodLength: ${verificationResult['data']['periodLength']}');
        print('Saved cycleLength: ${verificationResult['data']['cycleLength']}');
        print('Last updated: ${verificationResult['data']['statsLastUpdated']}');
      }
      
      if (mounted) {
        // Find the most recent date for display purposes
        String? mostRecentDateKey;
        if (_selectedDates.isNotEmpty) {
          final sortedDates = _selectedDates.toList()
            ..sort((a, b) {
              final aParts = a.split('-');
              final bParts = b.split('-');
              
              final aDate = CalendarUtils.parseDisplayDate(
                '${aParts[0]} ${aParts[1]}, ${aParts[2]}'
              );
              final bDate = CalendarUtils.parseDisplayDate(
                '${bParts[0]} ${bParts[1]}, ${bParts[2]}'
              );
              
              return (bDate ?? DateTime.now()).compareTo(aDate ?? DateTime.now());
            });
          
          mostRecentDateKey = sortedDates.first;
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userId: widget.userId,
              selectedDate: mostRecentDateKey,
              selectedDates: _selectedDates,
              // periodStats: stats, // Pass the calculated stats to the home screen
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving period dates: $e')),
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
    // Rest of the build method remains the same
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
          selectedDates: _selectedDates,
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
                  'Please select all days of your period',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(children: monthWidgets),
                  ),
                ),
                // Show count of selected dates
                if (_selectedDates.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Selected ${_selectedDates.length} days',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NavigationButtonRow(
                        onPrevious: _handlePrevious,
                        onNext: _saveMultiplePeriodDatesAndFinish,
                        isNextEnabled: _selectedDates.isNotEmpty,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}