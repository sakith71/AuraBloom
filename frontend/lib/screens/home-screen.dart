import 'package:flutter/material.dart';
import '../widgets/home-widgets/app-bar.dart';
import '../widgets/home-widgets/welcome-section.dart';
import '../widgets/home-widgets/quick-actions.dart';
import '../widgets/home-widgets/upcoming-cycle.dart';
import '../widgets/home-widgets/mood-tracker.dart';


class HomeScreen extends StatefulWidget {
  final Set<String> selectedDates;

  const HomeScreen({
    super.key, 
    required this.selectedDates,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeSection(selectedDates: widget.selectedDates),
          const SizedBox(height: 25),
          QuickActions(onItemTapped: _onItemTapped),
          const SizedBox(height: 25),
          UpcomingCycle(selectedDates: widget.selectedDates),
          const SizedBox(height: 25),
          const MoodTracker(),
          // const SizedBox(height: 25),
          // const HealthInsights(),
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
              CustomAppBar(
                onProfileTap: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
                },
              ),
              Expanded(
                child: _buildHomePage(),
              ),
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
            icon: Icon(Icons.medical_services),
            label: 'Management',
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
        ],
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}