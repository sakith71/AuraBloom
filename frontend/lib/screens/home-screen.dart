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
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.periodStatus,
                style: const TextStyle(
                  fontSize: 34,
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
                      fontSize: 14,
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

    // Check if today is marked as a period day
    if (_selectedDates.contains(todayFormatted)) {
      _isInPeriod = true;

      // Convert all dateKeys to DateTime objects and sort them
      List<String> sortedDates = _selectedDates.toList();
      sortedDates.sort();

      // Find consecutive period days leading up to today
      List<String> currentPeriodDays = [];
      String? firstDay;

      // First, find all consecutive days that include today
      for (int i = 0; i < sortedDates.length; i++) {
        if (sortedDates[i] == todayFormatted) {
          // Found today - now go backward to find the first day of this period
          currentPeriodDays.add(todayFormatted);

          // Check previous days
          int j = i - 1;
          DateTime prevDate = now.subtract(const Duration(days: 1));

          while (j >= 0) {
            String prevDateFormatted = CalendarUtils.formatToYYYYMMDD(prevDate);

            if (sortedDates.contains(prevDateFormatted)) {
              currentPeriodDays.insert(0, prevDateFormatted);
              prevDate = prevDate.subtract(const Duration(days: 1));
              j--;
            } else {
              // Found a gap, this is the start of the period
              break;
            }
          }

          // Now go forward to capture remaining days if needed
          int k = i + 1;
          DateTime nextDate = now.add(const Duration(days: 1));

          while (k < sortedDates.length) {
            String nextDateFormatted = CalendarUtils.formatToYYYYMMDD(nextDate);

            if (sortedDates.contains(nextDateFormatted)) {
              currentPeriodDays.add(nextDateFormatted);
              nextDate = nextDate.add(const Duration(days: 1));
              k++;
            } else {
              // Found a gap, this is the end of the period
              break;
            }
          }

          firstDay = currentPeriodDays.first;
          break;
        }
      }

      if (firstDay != null) {
        // Calculate which day of period this is
        DateTime firstDate = DateTime.parse(firstDay);
        int dayNumber = now.difference(firstDate).inDays + 1;

        setState(() {
          _currentPeriodDay = dayNumber;
          _periodStatus = 'Day $_currentPeriodDay';

          if (dayNumber == 1) {
            _periodSubtext = 'Your period is starting today';
          } else {
            _periodSubtext = 'of $_lastPeriodDuration days (est.)';
          }
        });
      } else {
        // Fallback if calculation fails
        setState(() {
          _periodStatus = 'Active';
          _periodSubtext = 'Your period is active';
        });
      }
    } else {
      // Not currently in period
      _isInPeriod = false;

      // Check if next period prediction is available
      if (_nextPeriodStartDate != null) {
        int daysUntil = CalendarUtils.calculateDaysUntil(_nextPeriodStartDate!);

        if (daysUntil <= 0) {
          // Period should be starting soon/today
          setState(() {
            _periodStatus = 'Expected Today';
            _periodSubtext = 'Your period may start today';
          });
        } else {
          // Show countdown to next period
          setState(() {
            _daysUntilNextPeriod = daysUntil;
            _periodStatus = '$daysUntil Days Away';
            _periodSubtext = 'Until your next period';
          });
        }
      } else {
        // No prediction available
        setState(() {
          _periodStatus = 'No Prediction';
          _periodSubtext = 'Check back soon';
        });
      }

      // Check if period recently ended
      List<String> convertedDates = [];
      for (String dateKey in _selectedDates) {
        // Make sure we convert dateKey to YYYY-MM-DD format if needed
        final parts = dateKey.split('-');
        if (parts.length == 3) {
          // Format is like "January-01-2023", convert to DateTime then to YYYY-MM-DD
          final month = parts[0];
          final day = parts[1];
          final year = parts[2];

          final DateTime? date = CalendarUtils.parseDisplayDate(
            '$month $day, $year',
          );
          if (date != null) {
            convertedDates.add(CalendarUtils.formatToYYYYMMDD(date));
          }
        } else {
          // Already in expected format
          convertedDates.add(dateKey);
        }
      }

      convertedDates.sort();

      // Find the last period day
      DateTime? lastPeriodDay;
      for (String date in convertedDates) {
        try {
          lastPeriodDay = DateTime.parse(date);
        } catch (e) {
          // Skip invalid dates
        }
      }

      if (lastPeriodDay != null) {
        // Check if period recently ended (within 3 days)
        int daysSinceEnd = now.difference(lastPeriodDay).inDays;

        if (daysSinceEnd <= 3) {
          setState(() {
            _periodStatus = 'Period Over';
            _periodSubtext =
                daysSinceEnd == 0
                    ? 'Period ended today'
                    : 'Period ended $daysSinceEnd ${daysSinceEnd == 1 ? 'day' : 'days'} ago';
          });
        }
      }
    }
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
