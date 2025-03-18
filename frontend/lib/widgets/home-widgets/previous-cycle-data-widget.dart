import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/period-service.dart';
import '../../utils/calendar.dart';

class PreviousCycleDataWidget extends StatefulWidget {
  final String userId;
  final Function()? onDataValidated;

  const PreviousCycleDataWidget({
    super.key,
    required this.userId,
    this.onDataValidated,
  });

  @override
  State<PreviousCycleDataWidget> createState() =>
      _PreviousCycleDataWidgetState();
}

class _PreviousCycleDataWidgetState extends State<PreviousCycleDataWidget> {
  final PeriodService _periodService = PeriodService();

  bool _isLoading = true;
  bool _hasData = false;
  List<PeriodCycleData> _cycleData = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousCycleData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No cycle data available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log your period days on the calendar to see cycle data',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPreviousCycleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 240, 99, 153),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Placeholder return
    return const Center(child: Text('Loading data...'));
  }

  // Placeholder for future implementation
  Future<void> _loadPreviousCycleData() async {
    // Implementation will be added in a future commit
  }
}

// Placeholder class - will be fully implemented in a future commit
class PeriodCycleData {
  final DateTime startDate;
  final DateTime endDate;
  final int periodLength;
  final int? cycleLength;

  PeriodCycleData({
    required this.startDate,
    required this.endDate,
    required this.periodLength,
    this.cycleLength,
  });
}
