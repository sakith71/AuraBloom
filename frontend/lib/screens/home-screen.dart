import 'package:flutter/material.dart';
import 'package:frontend/screens/calender-page.dart';
import 'package:frontend/screens/chat-screen.dart';
import '../services/period-stats-service.dart';
import '../widgets/home-widgets/daily-insights.dart';
import '../widgets/home-widgets/previous-cycle-box.dart';
import '../widgets/home-widgets/tip-of-the-day.dart';
import '../widgets/home-widgets/app-bar.dart';
import '../widgets/prediction-widget.dart';
import '../widgets/home-widgets/welcome-section.dart';
import '../services/period-service.dart';
import '../services/period-prediction-service.dart';
import '../utils/calendar.dart';
import 'cycle-history-page.dart';
import 'profile-screen/profile-screen.dart';
import 'community/community-screen.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimatedWaveSection extends StatefulWidget {
  final String periodStatus;
  final String periodSubtext;

  const AnimatedWaveSection({
    super.key,
    required this.periodStatus,
    this.periodSubtext = '',
  });

  @override
  State<AnimatedWaveSection> createState() => _AnimatedWaveSectionState();
}

class _AnimatedWaveSectionState extends State<AnimatedWaveSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 140),
              painter: _AnimatedWavePainter(
                animationValue: _animationController.value,
              ),
            );
          },
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Period:',
                style: TextStyle(
                  fontSize: 14, // Reduced from 16
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.periodStatus,
                style: const TextStyle(
                  fontSize: 30, // Reduced from 34
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (widget.periodSubtext.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.periodSubtext,
                    style: TextStyle(
                      fontSize: 13, // Reduced from 14
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedWavePainter extends CustomPainter {
  final double animationValue;

  _AnimatedWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFF8D7E8)
          ..style = PaintingStyle.fill;

    const waveCount = 2; // Number of complete sine waves
    const amplitude = 10.0; // Height of the waves
    final path = Path();

    // Starting position (bottom left)
    path.moveTo(0, size.height);

    // Go to the starting wave position
    path.lineTo(0, size.height * 0.5);

    // Draw the animated wave
    for (var i = 0; i <= size.width; i++) {
      // Calculate the y-offset with a sine wave that moves with the animation
      final wavePhase = animationValue * 2 * math.pi;
      final normalizedX = i / size.width;
      final waveY = math.sin(
        (normalizedX * waveCount * 2 * math.pi) + wavePhase,
      );

      // Adjust the y position and scale the amplitude
      final y = size.height * 0.5 + (waveY * amplitude);

      path.lineTo(i.toDouble(), y);
    }

    // Complete the path to form a closed shape
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;
  final String? selectedDate;
  final Set<String> selectedDates;

  const HomeScreen({
    super.key,
    required this.userId,
    this.selectedDate,
    this.selectedDates = const {},
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Set<String> _selectedDates;
  final PeriodService _periodService = PeriodService();
  final PeriodStatsService _periodStatsService = PeriodStatsService();
  final PeriodPredictionService _predictionService = PeriodPredictionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  DateTime? _lastCycleStartDate;
  DateTime? _nextPeriodStartDate;
  int _lastCycleDuration = 28;
  int _lastPeriodDuration = 5;

  // Period tracking variables
  String _periodStatus = '';
  String _periodSubtext = '';
  bool _isInPeriod = false;
  int _currentPeriodDay = 0;
  int _daysUntilNextPeriod = 0;

  // Track the current week dates
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();

    // Initialize the week dates
    _weekDates = CalendarUtils.getCurrentWeekDates();

    _selectedDates =
        widget.selectedDates.isNotEmpty
            ? Set<String>.from(widget.selectedDates)
            : {};

    // If no dates were passed but we have a single date, add it
    if (_selectedDates.isEmpty && widget.selectedDate != null) {
      _selectedDates.add(widget.selectedDate!);
    }

    // Show loading indicator until data is loaded
    setState(() {
      _isLoading = true;
      _periodStatus = 'Loading...';
    });

    // If still empty, fetch from Firestore
    if (_selectedDates.isEmpty) {
      _fetchPeriodDates();
    }

    // Load all user data
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load period stats and cycle data
      await _fetchCycleData();

      // Get prediction for next period
      await _fetchPrediction();

      // Calculate current period status
      _calculatePeriodStatus();

      // Mark loading as complete
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _periodStatus = 'Error';
        _periodSubtext = 'Could not load data';
      });
    }
  }

  // Method to handle date updates from calendar page
  void _handlePeriodDatesUpdated(Set<String> updatedDates) async {
    setState(() {
      _selectedDates = updatedDates;
      _isLoading = true; // Show loading while recalculating
    });

    try {
      // Find the most recent date from the selected dates
      DateTime? mostRecentDate = _findMostRecentDate(updatedDates);

      if (mostRecentDate != null) {
        // Clear cached predictions in Firestore user document
        await _firestore.collection('users').doc(widget.userId).update({
          'lastPredictionDate': null, // Force new prediction
          'predictedNextPeriodStart': null,
        });

        // Force refresh prediction with the most recent period date
        await _predictionService.updateAfterPeriod(
          userId: widget.userId,
          actualPeriodStartDate: mostRecentDate,
        );

        // Wait a moment to ensure Firestore updates
        await Future.delayed(const Duration(milliseconds: 800));
      }

      // Reload all user data to update UI
      await _loadUserData();
    } catch (e) {
      print('Error refreshing prediction: $e');
      // Continue with loading user data even if prediction refresh fails
      _loadUserData();
    }
  }

  // Helper method to find most recent date in the set
  DateTime? _findMostRecentDate(Set<String> dateKeys) {
    if (dateKeys.isEmpty) return null;

    List<DateTime> dates = [];
    for (String dateKey in dateKeys) {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final month = parts[0];
        final day = parts[1];
        final year = parts[2];

        final date = CalendarUtils.parseDisplayDate('$month $day, $year');
        if (date != null) {
          dates.add(date);
        }
      }
    }

    if (dates.isEmpty) return null;

    // Sort dates with most recent last
    dates.sort((a, b) => a.compareTo(b));
    return dates.last; // Return the most recent date
  }

  Future<void> _fetchPrediction() async {
    try {
      final prediction = await _predictionService.getPredictionsForUser(
        widget.userId,
      );

      if (prediction.containsKey('nextPeriodStartDate')) {
        setState(() {
          _nextPeriodStartDate = DateTime.parse(
            prediction['nextPeriodStartDate'],
          );
        });
      }
    } catch (e) {
      print('Error fetching prediction: $e');
    }
  }

  void _calculatePeriodStatus() {
    if (_selectedDates.isEmpty) {
      setState(() {
        _periodStatus = 'No Data';
        _periodSubtext = 'Add your period dates';
        _isInPeriod = false;
      });
      return;
    }

    final DateTime now = DateTime.now();
    final String todayFormatted = CalendarUtils.formatToYYYYMMDD(now);
    final String yesterdayFormatted = CalendarUtils.formatToYYYYMMDD(
      now.subtract(const Duration(days: 1)),
    );

    // Convert all period dates to DateTime objects for comparison
    List<DateTime> allPeriodDates = [];
    for (String dateKey in _selectedDates) {
      try {
        if (dateKey.contains('-')) {
          // Handle two possible formats
          DateTime? date;
          if (dateKey.split('-').length == 3) {
            // Format like "January-01-2023"
            final parts = dateKey.split('-');
            date = CalendarUtils.parseDisplayDate(
              '${parts[0]} ${parts[1]}, ${parts[2]}',
            );
          } else {
            // Format like "2023-01-01"
            date = DateTime.parse(dateKey);
          }

          if (date != null) {
            allPeriodDates.add(DateTime(date.year, date.month, date.day));
          }
        }
      } catch (e) {
        print('Error parsing date: $e');
      }
    }
    allPeriodDates.sort();

    // Check if today is a period day
    if (_selectedDates.contains(todayFormatted)) {
      _isInPeriod = true;

      // Find the current period sequence
      List<DateTime> currentPeriodSequence = [];
      DateTime today = DateTime(now.year, now.month, now.day);
      currentPeriodSequence.add(today);

      // Search backward to find start of period
      DateTime checkDate = today.subtract(const Duration(days: 1));
      while (allPeriodDates.any(
        (date) =>
            date.year == checkDate.year &&
            date.month == checkDate.month &&
            date.day == checkDate.day,
      )) {
        currentPeriodSequence.insert(0, checkDate);
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      // Calculate day of period
      if (currentPeriodSequence.isNotEmpty) {
        DateTime firstDayOfPeriod = currentPeriodSequence.first;
        int dayNumber = today.difference(firstDayOfPeriod).inDays + 1;

        setState(() {
          _currentPeriodDay = dayNumber;
          _periodStatus = 'Day $dayNumber';

          if (dayNumber == 1) {
            _periodSubtext = 'Your period is starting today';
          } else {
            _periodSubtext = 'of $_lastPeriodDuration days (est.)';
          }
        });
      }
      return;
    }
    // Check if yesterday was marked and we need to show Day 2 today
    else if (_selectedDates.contains(yesterdayFormatted)) {
      bool isPeriodContinuing = true;

      if (isPeriodContinuing) {
        _isInPeriod = true;
        setState(() {
          _currentPeriodDay = 2; // It's day 2 since yesterday was day 1
          _periodStatus = 'Day 2';
          _periodSubtext = 'of $_lastPeriodDuration days (est.)';
        });
        return;
      }
    }

    // If we're here, check if prediction indicates we should be in period
    if (_nextPeriodStartDate != null) {
      final predictedStart = DateTime(
        _nextPeriodStartDate!.year,
        _nextPeriodStartDate!.month,
        _nextPeriodStartDate!.day,
      );

      final today = DateTime(now.year, now.month, now.day);
      final differenceInDays = today.difference(predictedStart).inDays;

      if (differenceInDays == 0) {
        // Expected to start today
        _isInPeriod = true;
        setState(() {
          _currentPeriodDay = 1;
          _periodStatus = 'Day 1';
          _periodSubtext = 'Your period may start today';
        });
        return;
      } else if (differenceInDays == 1) {
        // Expected to have started yesterday, should be day 2 today
        _isInPeriod = true;
        setState(() {
          _currentPeriodDay = 2;
          _periodStatus = 'Day 2';
          _periodSubtext = 'Your period was expected to start yesterday';
        });
        return;
      } else if (differenceInDays < 0) {
        // Future prediction
        _isInPeriod = false;
        setState(() {
          _daysUntilNextPeriod = -differenceInDays;
          _periodStatus = '$_daysUntilNextPeriod Days Away';
          _periodSubtext = 'Until your next period';
        });
        return;
      } else if (differenceInDays > 1) {
        // Period was expected to start more than 1 day ago
        _isInPeriod = false;
        setState(() {
          _periodStatus = 'Expected $differenceInDays Days Ago';
          _periodSubtext = 'Your period was expected to start';
        });
        return;
      }
    }

    // Check if period recently ended
    if (allPeriodDates.isNotEmpty) {
      final DateTime lastPeriodDate = allPeriodDates.last;
      final int daysSinceEnd = now.difference(lastPeriodDate).inDays;

      if (daysSinceEnd <= 3 && !_isInPeriod) {
        setState(() {
          _isInPeriod = false;
          _periodStatus = 'Period Over';
          _periodSubtext =
              daysSinceEnd == 1
                  ? 'Period ended yesterday'
                  : 'Period ended $daysSinceEnd days ago';
        });
        return;
      }
    }

    // Default state if no other conditions match
    setState(() {
      _isInPeriod = false;
      _periodStatus = 'No Prediction';
      _periodSubtext = 'Check back soon';
    });
  }

  Future<void> _fetchCycleData() async {
    try {
      // Use the PeriodService to get the last cycle date
      DateTime? lastCycleDate = await _periodService.fetchLastCycleStartDate(
        widget.userId,
      );

      // Use the PeriodStatsService to get cycle stats
      final stats = await _periodStatsService.calculatePeriodStats(
        widget.userId,
      );

      setState(() {
        _lastCycleStartDate = lastCycleDate;
        _lastCycleDuration = stats['meanCycleLength'] ?? 28;
        _lastPeriodDuration = stats['meanPeriodLength'] ?? 5;
      });
    } catch (e) {
      throw Exception('Failed to fetch cycle data: $e');
    }
  }

  Future<void> _fetchPeriodDates() async {
    try {
      Set<String> dates = await _periodService.fetchPeriodDates(widget.userId);
      setState(() {
        _selectedDates = dates;
      });
    } catch (e) {
      print('Error fetching period dates: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToProfile() {
    setState(() {
      _selectedIndex = 4;
    });
  }

  void _navigateToCycleHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CycleHistoryPage()),
    ).then((_) {
      // Refresh cycle data when returning from history page
      _fetchCycleData();
      _calculatePeriodStatus();
    });
  }

  Widget _getPage() {
    // Return the page matching the selected nav index
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return CalendarPage(
          userId: widget.userId,
          selectedDates: _selectedDates,
          onDatesUpdated: _handlePeriodDatesUpdated, // Pass the callback
        );
      case 2:
        return const CommunityScreen();
      case 3:
        return PeriodPainChatScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    // Use a SingleChildScrollView so the screen scrolls only if needed
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use WelcomeSection with user ID
          WelcomeSection(
            userId: widget.userId,
            selectedDate: widget.selectedDate,
            selectedDates: _selectedDates.toList(),
          ),
          _buildWeekCalendar(),
          // Animated wave section with updated period status
          _isLoading
              ? Center(
                child: Container(
                  height: 140,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFE3A6DD),
                      ),
                    ),
                  ),
                ),
              )
              : AnimatedWaveSection(
                periodStatus: _periodStatus,
                periodSubtext: _periodSubtext,
              ),
          const SizedBox(height: 20),
          DailyInsights(userId: widget.userId),
          const SizedBox(height: 20),
          const TipOfTheDay(),
          const SizedBox(height: 20),
          const PredictionWidget(),
          PreviousCycleBox(
            lastCycleStartDate: _lastCycleStartDate,
            cycleDuration: _lastCycleDuration,
            periodDuration: _lastPeriodDuration,
            onReviewTap: _navigateToCycleHistory,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Get today's date for highlighting
    final today = DateTime.now();

    // Find today's index in the week
    final todayIndex = _weekDates.indexWhere(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );

    // Create a list of formatted dates to check against selected dates
    final List<String> formattedWeekDates =
        _weekDates.map((date) => CalendarUtils.formatToYYYYMMDD(date)).toList();

    // Check which dates have period markers
    final List<bool> hasMarkers =
        formattedWeekDates
            .map((dateStr) => _selectedDates.contains(dateStr))
            .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              7,
              (index) => SizedBox(
                width: 40,
                child: Text(
                  days[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              7,
              (index) => Stack(
                alignment: Alignment.center,
                children: [
                  // Date circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index == todayIndex
                              ? const Color(0xFFE6E9FF)
                              : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        '${_weekDates[index].day}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              index == todayIndex
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // Period indicator dot
                  if (hasMarkers[index])
                    Positioned(
                      bottom: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE3A6DD),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // After: Only display the app bar on the home page (index 0)
    return Scaffold(
      backgroundColor: const Color(0xFFFCF0F7),
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex == 0)
              CustomAppBar(onProfileTap: _navigateToProfile),
            Expanded(child: _getPage()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat Bot',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 238, 107, 209),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
