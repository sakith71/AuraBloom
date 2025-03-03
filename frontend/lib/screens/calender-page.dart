import 'package:flutter/material.dart';
import '../widgets/calendar-month.dart';
import '../utils/calendar.dart';
import '../services/firestore_service.dart';
import '../services/period-service.dart';

class CalendarPage extends StatefulWidget {
  final String userId;
  final Set<String> selectedDates;
  
  const CalendarPage({
    super.key,
    required this.userId,
    required this.selectedDates,
  });

  @override
  State<CalendarPage> createState() => _ModifiedCalendarPageState();
}

class _ModifiedCalendarPageState extends State<CalendarPage> {
  late Set<String> selectedDates;
  bool isEditing = false;
  bool isSaving = false;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  late DateTime _currentDate;
  final FirestoreService _firestoreService = FirestoreService();
  final PeriodService _periodService = PeriodService();

  @override
  void initState() {
    super.initState();
    // Initialize with dates passed from parent
    selectedDates = Set<String>.from(widget.selectedDates);
    _currentDate = DateTime.now();
    
    // Fetch period dates from Firestore
    _fetchPeriodDates();
    
    // Scroll to current month initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth();
    });
  }
  
  Future<void> _fetchPeriodDates() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      // Get period dates from Firestore
      Set<String> dates = await _periodService.fetchPeriodDates(widget.userId);
      
      setState(() {
        selectedDates = dates;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching period dates: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollToCurrentMonth() {
    // Calculate approximate position to scroll to current month
    double itemHeight = 300; // Estimated height of a month widget
    double targetPosition = (_currentDate.month - 3) * itemHeight; // Show current month after 3 months
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetPosition.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void onDateSelected(String dateKey) {
    if (!isEditing) return;
    
    setState(() {
      if (selectedDates.contains(dateKey)) {
        selectedDates.remove(dateKey);
      } else {
        selectedDates.add(dateKey);
      }
    });
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> savePeriodDates() async {
    try {
      setState(() {
        isSaving = true;
      });
      
      // First, fetch current period dates to compare
      Set<String> currentDates = await _periodService.fetchPeriodDates(widget.userId);
      
      // Find dates to add (in selectedDates but not in currentDates)
      Set<String> datesToAdd = Set<String>.from(selectedDates)
        ..removeAll(currentDates);
      
      // Find dates to remove (in currentDates but not in selectedDates)
      Set<String> datesToRemove = Set<String>.from(currentDates)
        ..removeAll(selectedDates);
      
      // Add new dates
      for (String dateKey in datesToAdd) {
        final dateParts = dateKey.split('-');
        if (dateParts.length == 3) {
          final month = dateParts[0];
          final day = dateParts[1];
          final year = dateParts[2];
          
          // Convert to DateTime
          final periodDate = CalendarUtils.parseDisplayDate(
            '$month $day, $year'
          ) ?? DateTime.now();
          
          // Save the period date
          await _firestoreService.savePeriodData(widget.userId, periodDate);
        }
      }
      
      // Remove deleted dates
      for (String dateKey in datesToRemove) {
        await _periodService.deletePeriodDate(widget.userId, dateKey);
      }
      
      // Exit edit mode after saving
      setState(() {
        isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Period dates saved successfully')),
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
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    List<Widget> monthWidgets = [];
    DateTime currentMonth = DateTime(_currentDate.year, _currentDate.month);

    // Generate 6 months in the past and 6 months in the future
    for (int i = -6; i <= 6; i++) {
      DateTime targetMonth = DateTime(
        currentMonth.year,
        currentMonth.month + i,
      );
      monthWidgets.add(
        CalendarMonth(
          month: CalendarUtils.months[targetMonth.month - 1],
          monthIndex: targetMonth.month - 1,
          year: targetMonth.year,
          selectedDates: selectedDates,
          onDateSelected: onDateSelected,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Period Calendar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: toggleEditMode,
                      ),
                  ],
                ),
              ),
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Select your period days',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: monthWidgets,
                  ),
                ),
              ),
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : savePeriodDates,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xFFE57373),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Period Dates',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: toggleEditMode,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xFFE57373),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Edit Period Dates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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