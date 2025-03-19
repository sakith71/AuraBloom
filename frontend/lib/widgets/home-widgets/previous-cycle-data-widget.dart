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

  Future<void> _loadPreviousCycleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all period dates
      final dates = await _periodService.fetchPeriodDates(widget.userId);

      // Convert date keys to DateTime objects
      final periodDates =
          dates
              .map((dateKey) {
                final parts = dateKey.split('-');
                if (parts.length == 3) {
                  final month = parts[0];
                  final day = parts[1];
                  final year = parts[2];
                  return CalendarUtils.parseDisplayDate('$month $day, $year');
                }
                return null;
              })
              .whereType<DateTime>()
              .toList();

      // Sort dates in ascending order
      periodDates.sort((a, b) => a.compareTo(b));

      // Generate cycle data using the PeriodStatsService methods
      final cycles = await _loadCycles(periodDates);

      setState(() {
        _cycleData = cycles;
        _hasData = cycles.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading previous cycle data: $e');
      setState(() {
        _isLoading = false;
        _hasData = false;
      });
    }
  }

  Future<List<PeriodCycleData>> _loadCycles(List<DateTime> dates) async {
    if (dates.isEmpty) return [];

    // Detect cycles (periods that are separated by more than 1 day)
    List<PeriodCycleData> cycles = [];
    DateTime? currentStart;
    DateTime? currentEnd;

    for (int i = 0; i < dates.length; i++) {
      if (currentStart == null) {
        // Start a new period
        currentStart = dates[i];
        currentEnd = dates[i];
      } else if (i < dates.length - 1 &&
          dates[i + 1].difference(dates[i]).inDays == 1) {
        // Consecutive day, extend the current period
        currentEnd = dates[i + 1];
      } else {
        // End of a period, add it to cycles
        int periodLength = currentEnd!.difference(currentStart).inDays + 1;

        // Calculate cycle length only if there's a next period
        int? cycleLength;
        if (i < dates.length - 1) {
          final nextPeriodStart = dates[i + 1];
          cycleLength = nextPeriodStart.difference(currentStart).inDays;
        }

        cycles.add(
          PeriodCycleData(
            startDate: currentStart,
            endDate: currentEnd,
            periodLength: periodLength,
            cycleLength: cycleLength, // Default to validated
          ),
        );

        // Reset for next period
        currentStart = (i < dates.length - 1) ? dates[i + 1] : null;
        currentEnd = currentStart;
      }
    }

    // Add the last period if there's one in progress
    if (currentStart != null && currentEnd != null) {
      int periodLength = currentEnd.difference(currentStart).inDays + 1;
      cycles.add(
        PeriodCycleData(
          startDate: currentStart,
          endDate: currentEnd,
          periodLength: periodLength,
          cycleLength:
              null, // No next period to calculate cycle length// Default to validated
        ),
      );
    }

    // Sort cycles by start date (descending - most recent first)
    cycles.sort((a, b) => b.startDate.compareTo(a.startDate));

    return cycles;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Previous Cycles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _cycleData.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final cycle = _cycleData[index];
              return CycleCard(cycle: cycle);
            },
          ),
        ),
      ],
    );
  }
}

class CycleCard extends StatelessWidget {
  final PeriodCycleData cycle;
  final Function(bool)? onValidationChanged;

  const CycleCard({super.key, required this.cycle, this.onValidationChanged});

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
