import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/home-widgets/previous-cycle-data-widget.dart';

class CycleHistoryPage extends StatefulWidget {
  const CycleHistoryPage({super.key});

  @override
  State<CycleHistoryPage> createState() => _CycleHistoryPageState();
}

class _CycleHistoryPageState extends State<CycleHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser?.uid;
  }

  Future<void> _refreshCycleData() async {
    // This will be called after validating cycle data
    // Trigger any refresh logic if needed

    // Show a success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cycle data refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color.fromARGB(255, 240, 99, 153),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Cycle History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 240, 99, 153),
            ),
          ),
          backgroundColor: Color(0xFFFCF0F7),
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Please log in to view your cycle history'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_sharp,
            color: Color.fromARGB(255, 240, 99, 153),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cycle History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 240, 99, 153),
          ),
        ),
        backgroundColor: Color(0xFFFCF0F7),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: PreviousCycleDataWidget(
        userId: _userId!,
        onDataValidated: _refreshCycleData,
      ),
    );
  }
}