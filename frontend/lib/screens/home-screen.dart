import 'package:flutter/material.dart';
import 'package:frontend/screens/calender-page.dart';
import 'package:frontend/screens/chat-screen.dart';
import '../widgets/home-widgets/daily-insights.dart';
import '../widgets/home-widgets/tip-of-the-day.dart';
import '../widgets/home-widgets/my-cycles.dart';
import '../widgets/home-widgets/app-bar.dart';
import '../services/period-service.dart';
import 'profile-screen/profile-screen.dart';
import 'community/community-screen.dart';

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
      print('Error fetching period dates: $e');
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
          _buildWelcomeSection(),
          _buildWeekCalendar(),
          _buildPeriodStatus(),
          const SizedBox(height: 20),
          DailyInsights(userId: widget.userId),
          const SizedBox(height: 20),
          const TipOfTheDay(),
          const SizedBox(height: 20),
          const MyCycles(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Sarah!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Today, 4 Mar, TUE',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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

  Widget _buildPeriodStatus() {
    return Stack(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 140),
          painter: _WavePainter(),
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
              const Text(
                'Day 1',
                style: TextStyle(
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

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFF8D7E8)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.75,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
