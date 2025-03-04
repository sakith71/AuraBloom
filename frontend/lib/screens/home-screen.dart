import 'package:flutter/material.dart';
import 'package:frontend/screens/calender-page.dart';
import 'package:frontend/screens/chat-screen.dart';
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

    // If a single date was passed in, add it
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

  // Navigate to profile (used by custom app bar if needed)
  void _navigateToProfile() {
    setState(() {
      _selectedIndex = 4;
    });
  }

  // Decides which page to display based on bottom nav index
  Widget _getPage() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
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

  // The new home page layout in one method (basic placeholders).
  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Welcome Section placeholder
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome back, Sarah!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Today, 4 Mar, TUE',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 2) Week Calendar placeholder
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: const Text(
              'Week Calendar Placeholder',
              style: TextStyle(fontSize: 16),
            ),
          ),

          // 3) Period Status placeholder with WavePainter
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _WavePainter())),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Period:',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
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
            ),
          ),

          const SizedBox(height: 20),

          // 4) My daily insights placeholder
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'My daily insights placeholder',
              style: TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 20),

          // 5) Tip of the day placeholder
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Tip of the day placeholder',
              style: TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 20),

          // 6) My cycles placeholder
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'My cycles placeholder',
              style: TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // New background color
      backgroundColor: const Color(0xFFFCF0F7),
      body: SafeArea(
        child: Column(
          children: [
            // Replace this with your custom app bar if needed
            // Or remove if you don't have a custom app bar method
            Container(
              height: 60,
              color: Colors.pink[100],
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      // Example placeholder for menu or profile
                      _navigateToProfile();
                    },
                  ),
                  const Spacer(),
                  const Text(
                    'AuraBloom',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // The main page content
            Expanded(child: _getPage()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Basic bottom nav with 5 items
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
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
    );
  }
}

// A private wave painter for the "Period Status" placeholder
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
