import 'package:flutter/material.dart';
import '../services/period-prediction-service.dart';
import '../widgets/calendar-month.dart';
import '../utils/calendar.dart';
import '../services/period-service.dart';
import '../services/period-stats-service.dart';

class CalendarPage extends StatefulWidget {
  final String userId;
  final Set<String> selectedDates;
  final Function(Set<String>)? onDatesUpdated; // Add callback for date updates

  const CalendarPage({
    super.key,
    required this.userId,
    required this.selectedDates,
    this.onDatesUpdated, // Optional callback when dates are updated
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Set<String> selectedDates;
  late Set<String> originalDates; // Store original dates before editing
  late Set<String> predictedDates; // Store predicted period dates
  bool isEditing = false;
  bool isSaving = false;
  bool isLoading = true;
  bool hasChanges = false; // Track if changes were made during editing
  bool isCalculatingStats = false;
  bool isFetchingPredictions = false;
  late DateTime _currentDate;
  final PeriodService _periodService = PeriodService();
  final PeriodStatsService _periodStatsService = PeriodStatsService();
  final PeriodPredictionService _predictionService = PeriodPredictionService();

  // Stats information
  int _averageCycleLength = 28;
  int _averagePeriodLength = 5;
  bool _showStats = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize with dates passed from parent
    selectedDates = Set<String>.from(widget.selectedDates);
    originalDates = Set<String>.from(widget.selectedDates);
    predictedDates = {};
    _currentDate = DateTime.now();

    // Fetch period dates from Firestore
    _fetchPeriodDates();

    // Fetch period stats
    _fetchPeriodStats();

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
        originalDates = Set<String>.from(dates); // Make a copy
        isLoading = false;
      });

      // After loading period dates, fetch predictions
      _fetchPredictions();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPeriodStats() async {
    // Calculate period stats
    final stats = await _periodStatsService.calculatePeriodStats(widget.userId);

    // Update UI with stats
    setState(() {
      _averageCycleLength = stats['meanCycleLength'] ?? 28;
      _averagePeriodLength = stats['meanPeriodLength'] ?? 5;
      _showStats = true;
    });
  }

  Future<void> _fetchPredictions() async {
    if (isFetchingPredictions) return;

    try {
      setState(() {
        isFetchingPredictions = true;
      });

      final userId = widget.userId;

      // Get predictions from service
      final prediction = await _predictionService.getPredictionsForUser(userId);

      if (prediction.containsKey('nextPeriodStartDate') &&
          prediction['nextPeriodStartDate'] != null) {
        // Parse next period date
        final nextPeriodStart = DateTime.parse(
          prediction['nextPeriodStartDate'],
        );

        // Use the average period length, not the cycle length
        // Period length is how many days bleeding lasts
        final periodLength = _averagePeriodLength; // Use the value from stats

        // Set the next period date for display
        setState(() {
          // Generate predicted dates for period duration only
          predictedDates = _generatePredictedDates(
            nextPeriodStart,
            periodLength,
          );
        });
      }
    } catch (e) {
      print('Error fetching predictions: $e');
    } finally {
      setState(() {
        isFetchingPredictions = false;
      });
    }
  }

  // Generate a set of date keys for the predicted period
  Set<String> _generatePredictedDates(DateTime startDate, int periodLength) {
    Set<String> dates = {};

    // Generate dates for the period duration (not the whole cycle)
    for (int i = 0; i < periodLength; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String monthName = CalendarUtils.months[currentDate.month - 1];
      String day = currentDate.day.toString().padLeft(2, '0');
      String year = currentDate.year.toString();

      // Format: "January-01-2023"
      String dateKey = '$monthName-$day-$year';
      dates.add(dateKey);
    }

    return dates;
  }

  void _scrollToCurrentMonth() {
    // Calculate approximate position to scroll to current month
    double itemHeight = 300; // Estimated height of a month widget
    double targetPosition =
        (_currentDate.month - 3) *
        itemHeight; // Show current month after 3 months

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetPosition.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void onDateSelected(String dateKey) {
    // Only allow selecting/deselecting if in editing mode
    if (!isEditing) return;

    setState(() {
      if (selectedDates.contains(dateKey)) {
        selectedDates.remove(dateKey);
      } else {
        selectedDates.add(dateKey);
      }
      // Check if the current selection differs from the original
      hasChanges = !_areSetsEqual(selectedDates, originalDates);
    });
  }

  bool _areSetsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.every((element) => b.contains(element));
  }

  Future<void> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Discard Changes?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'You have unsaved changes. Are you sure you want to exit without saving?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel button
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Discard button
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              240,
                              99,
                              153,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Discard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
    );

    // If user confirms exit, reset to original dates
    if (result == true) {
      setState(() {
        selectedDates = Set<String>.from(originalDates);
        isEditing = false;
        hasChanges = false;
      });
    }
  }

  void toggleEditMode() {
    if (isEditing && hasChanges) {
      _showExitConfirmation();
    } else {
      // If entering edit mode, store original dates
      if (!isEditing) {
        originalDates = Set<String>.from(selectedDates);
      }
      setState(() {
        isEditing = !isEditing;
        hasChanges = false;
      });
    }
  }

  Future<void> savePeriodDates() async {
    try {
      setState(() {
        isSaving = true;
      });

      // Fetch current period dates to compare
      Set<String> currentDates = await _periodService.fetchPeriodDates(
        widget.userId,
      );

      // Find dates to add (in selectedDates but not in currentDates)
      Set<String> datesToAdd = Set<String>.from(selectedDates)
        ..removeAll(currentDates);

      // Find dates to remove (in currentDates but not in selectedDates)
      Set<String> datesToRemove = Set<String>.from(currentDates)
        ..removeAll(selectedDates);

      // Add new dates
      if (datesToAdd.isNotEmpty) {
        // Use the enhanced savePeriodDates method to save multiple dates at once
        await _periodService.savePeriodDates(widget.userId, datesToAdd);
      }

      // Remove deleted dates individually
      for (String dateKey in datesToRemove) {
        await _periodService.deletePeriodDate(widget.userId, dateKey);
      }

      // Update original dates to match the saved set
      originalDates = Set<String>.from(selectedDates);

      // Calculate and update period stats after changes
      setState(() {
        isCalculatingStats = true;
      });

      final stats = await _periodStatsService.updatePeriodStats(
        widget.userId,
        cycleLimit: 6,
      );

      // Wait briefly to ensure data is written
      await Future.delayed(const Duration(seconds: 1));

      // Update UI with new stats
      setState(() {
        _averageCycleLength = stats['meanCycleLength'];
        _averagePeriodLength = stats['meanPeriodLength'];
        isCalculatingStats = false;
        _showStats = true;
      });

      // Refresh predictions now that we've updated period data
      await _fetchPredictions();

      // Exit edit mode
      setState(() {
        isEditing = false;
        hasChanges = false;
      });

      // Notify parent about the updated dates
      if (widget.onDatesUpdated != null) {
        widget.onDatesUpdated!(selectedDates);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Period dates and stats saved successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving period dates: $e')),
        );
      }
      setState(() {
        isCalculatingStats = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cycle Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Cycle Length',
                  '$_averageCycleLength days',
                  Icons.calendar_month,
                ),
                _buildStatItem(
                  'Period Length',
                  '$_averagePeriodLength days',
                  Icons.water_drop,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Based on your last 6 cycles',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD64C7F), size: 30),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen
    if (isLoading) {
      return Scaffold(
        // Use the global background color instead of a gradient
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Build list of months (6 months in the past and 6 months in the future)
    List<Widget> monthWidgets = [];
    DateTime currentMonth = DateTime(_currentDate.year, _currentDate.month);

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
          predictedDates:
              isEditing
                  ? {}
                  : predictedDates, // Don't show predictions in edit mode
          onDateSelected: onDateSelected,
        ),
      );
    }

    return Scaffold(
      // Use the global scaffold background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row - MODIFIED to match Health Tips style
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Back arrow - styled like in Health Tips page
                  GestureDetector(
                    onTap: () {
                      if (isEditing && hasChanges) {
                        // If editing with changes, show confirmation
                        _showExitConfirmation();
                      } else if (isEditing) {
                        // If editing but no changes, just exit edit mode
                        setState(() {
                          isEditing = false;
                        });
                      } else {
                        // In normal mode (Period Calendar), navigate back to home
                        Navigator.of(context).pop();
                      }
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: const Color.fromARGB(255, 240, 99, 153),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title in pink color
                  Text(
                    isEditing ? 'Edit Period Dates' : 'Period Calendar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 240, 99, 153),
                    ),
                  ),
                  // Removed the close icon for edit mode
                ],
              ),
            ),

            // Show stats card if available and not editing
            if (_showStats && !isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: _buildStatsCard(),
              ),

            // Show spinner if recalculating stats
            if (isCalculatingStats && !isEditing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text("Calculating cycle statistics..."),
                    ],
                  ),
                ),
              ),

            // Show spinner if fetching predictions
            if (isFetchingPredictions && !isEditing && !isCalculatingStats)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text("Updating predictions..."),
                    ],
                  ),
                ),
              ),

            // Editing hint
            if (isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Select your period days',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),

            // Calendar months
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

            // Bottom button area
            if (isEditing)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving || !hasChanges ? null : savePeriodDates,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color.fromARGB(255, 240, 99, 153),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color.fromARGB(
                        255,
                        240,
                        99,
                        153,
                      ).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        isSaving
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              hasChanges
                                  ? 'Save Period Dates'
                                  : 'No Changes to Save',
                              style: const TextStyle(
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
                      backgroundColor: const Color.fromARGB(255, 240, 99, 153),
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
    );
  }
}
