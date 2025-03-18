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

class CycleCard extends StatelessWidget {
  final PeriodCycleData cycle;
  final Function(bool)? onValidationChanged;

  const CycleCard({Key? key, required this.cycle, this.onValidationChanged})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = dateFormat.format(cycle.startDate);
    final endDate = dateFormat.format(cycle.endDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: const Color.fromARGB(255, 240, 99, 153),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Period: $startDate - $endDate',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (cycle.isRecent())
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Recent',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(
                  'Period Length',
                  '${cycle.periodLength} days',
                  Icons.water_drop,
                ),
                const SizedBox(width: 24),
                if (cycle.cycleLength != null)
                  _buildInfoItem(
                    'Cycle Length',
                    '${cycle.cycleLength} days',
                    Icons.loop,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

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

  bool isRecent() {
    final now = DateTime.now();
    final diff = now.difference(startDate).inDays;
    return diff <= 60; // Consider cycles in the last 2 months as recent
  }

  @override
  String toString() {
    return 'PeriodCycle(start: $startDate, end: $endDate, periodLength: $periodLength, cycleLength: $cycleLength)';
  }
}
