import 'package:flutter/material.dart';
import 'package:frontend/screens/calender-page.dart';
import 'package:frontend/screens/chat-screen.dart';
import '../widgets/home-widgets/daily-insights.dart';
import '../widgets/home-widgets/tip-of-the-day.dart';
import '../widgets/home-widgets/app-bar.dart';
import '../widgets/prediction-widget.dart';
import '../widgets/home-widgets/welcome-section.dart'; // Import the WelcomeSection widget
import '../services/period-service.dart';
import 'profile-screen/profile-screen.dart';
import 'community/community-screen.dart';
import 'dart:math' as math;

class AnimatedWaveSection extends StatefulWidget {
  final String periodDay;

  const AnimatedWaveSection({super.key, required this.periodDay});

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
                widget.periodDay,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _selectedDates =
        widget.selectedDates.isNotEmpty
            ? Set<String>.from(widget.selectedDates)
            : {};

    // If no dates were passed but we have a single date, add it
    if (_selectedDates.isEmpty && widget.selectedDate != null) {
      _selectedDates.add(widget.selectedDate!);
    }

    // If still empty, fetch from Firestore
    if (_selectedDates.isEmpty) {
      _fetchPeriodDates();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchPeriodDates() async {
    try {
      Set<String> dates = await _periodService.fetchPeriodDates(widget.userId);
      setState(() {
        _selectedDates = dates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  Widget _getPage() {
    // Show a loading spinner until we fetch the user's dates
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Return the page matching the selected nav index
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return CalendarPage(
          userId: widget.userId,
          selectedDates: _selectedDates,
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
          // Animated wave section
          const AnimatedWaveSection(periodDay: 'Day 1'),
          const SizedBox(height: 20),
          DailyInsights(userId: widget.userId),
          const SizedBox(height: 20),
          const TipOfTheDay(),
          const SizedBox(height: 20),
          
          // Insert the PredictionWidget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PredictionWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final dates = [9, 10, 11, 12, 13, 14, 15];
    final selectedIndex = 1; // Example: "Day 10" is selected

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
              (index) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index == selectedIndex
                          ? const Color(0xFFE6E9FF)
                          : Colors.white,
                ),
                child: Center(
                  child: Text(
                    '${dates[index]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          index == selectedIndex
                              ? FontWeight.w500
                              : FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
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
