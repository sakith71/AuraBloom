import 'package:flutter/material.dart';
import 'package:frontend/screens/calender-page.dart';
import 'package:frontend/screens/chat-screen.dart';
import '../widgets/home-widgets/app-bar.dart';
import '../widgets/home-widgets/welcome-section.dart';
import '../widgets/home-widgets/quick-actions.dart';
import '../widgets/home-widgets/upcoming-cycle.dart';
import '../widgets/home-widgets/mood-tracker.dart';
import '../services/period-service.dart';
import 'profile-screen/profile-screen.dart';
import 'community/community-screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String? selectedDate;
  final Set<String> selectedDates; // Add this parameter

  const HomeScreen({
    super.key, 
    required this.userId, 
    this.selectedDate,
    this.selectedDates = const {}, // Default to empty set
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
    // Initialize with dates from constructor or empty set
    _selectedDates = widget.selectedDates.isNotEmpty 
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
      // Get period dates from Firestore
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
      _selectedIndex = 4; // Set to profile index (4)
    });
  }

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

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pass all selected dates to components that need them
          WelcomeSection(
            selectedDate: widget.selectedDate,
            // selectedDates: _selectedDates,
          ),
          const SizedBox(height: 25),
          QuickActions(onItemTapped: _onItemTapped),
          const SizedBox(height: 25),
          UpcomingCycle(
            selectedDate: widget.selectedDate,
            // selectedDates: _selectedDates,
          ),
          const SizedBox(height: 25),
          const MoodTracker(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              CustomAppBar(onProfileTap: _navigateToProfile),
              Expanded(child: _getPage()),
            ],
          ),
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