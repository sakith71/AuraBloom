import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/calendar.dart';

// Structure to hold period information
class PeriodCycle {
  final DateTime startDate;
  final DateTime endDate;
  final int periodLength; // in days
  int? cycleLength; // in days, will be calculated later
  
  PeriodCycle({
    required this.startDate,
    required this.endDate,
    required this.periodLength,
    this.cycleLength,
  });
  
  @override
  String toString() {
    return 'PeriodCycle(start: $startDate, end: $endDate, length: $periodLength, cycle: $cycleLength)';
  }
}

class PeriodStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get consecutive dates from the set of period dates
  List<DateTime> _getConsecutiveDatesFromKeys(Set<String> dateKeys) {
    // Convert date keys to DateTime objects
    List<DateTime> dates = [];
    for (String dateKey in dateKeys) {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final month = parts[0];
        final day = parts[1];
        final year = parts[2];
        
        final periodDate = CalendarUtils.parseDisplayDate('$month $day, $year');
        if (periodDate != null) {
          dates.add(periodDate);
        }
      }
    }
    
    // Sort dates in ascending order
    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }
  
  // Detect separate period cycles from a list of dates
  List<PeriodCycle> _detectPeriodCycles(List<DateTime> dates) {
    List<PeriodCycle> cycles = [];
    if (dates.isEmpty) return cycles;
    
    DateTime? currentStart;
    DateTime? currentEnd;
    
    for (int i = 0; i < dates.length; i++) {
      if (currentStart == null) {
        // Start a new period
        currentStart = dates[i];
        currentEnd = dates[i];
      } else if (i < dates.length - 1 && 
                dates[i+1].difference(dates[i]).inDays == 1) {
        // Consecutive day, extend the current period
        currentEnd = dates[i+1];
      } else {
        // End of a period, add it to cycles
        int periodLength = currentEnd!.difference(currentStart).inDays + 1;
        cycles.add(PeriodCycle(
          startDate: currentStart,
          endDate: currentEnd,
          periodLength: periodLength,
        ));
        
        // Reset for next period
        currentStart = (i < dates.length - 1) ? dates[i+1] : null;
        currentEnd = currentStart;
      }
    }
    
    // Add the last period if there's one in progress
    if (currentStart != null && currentEnd != null) {
      int periodLength = currentEnd.difference(currentStart).inDays + 1;
      cycles.add(PeriodCycle(
        startDate: currentStart,
        endDate: currentEnd,
        periodLength: periodLength,
      ));
    }
    
    // Calculate cycle lengths (from the start of one period to the start of the next)
    for (int i = 0; i < cycles.length - 1; i++) {
      cycles[i].cycleLength = cycles[i+1].startDate.difference(cycles[i].startDate).inDays;
    }
    return cycles;
  }
  
  // Calculate stats from period cycles
  Map<String, dynamic> _calculateStats(List<PeriodCycle> cycles) {
    if (cycles.isEmpty) {
      return {
        'meanPeriodLength': 0,
        'meanCycleLength': 0,
      };
    }
    
    // Calculate mean period length
    int totalPeriodLength = 0;
    for (var cycle in cycles) {
      totalPeriodLength += cycle.periodLength;
    }
    double meanPeriodLength = totalPeriodLength / cycles.length;
    
    // Calculate mean cycle length (excluding the last cycle)
    int totalCycleLength = 0;
    int cycleCount = 0;
    for (var cycle in cycles) {
      if (cycle.cycleLength != null) {
        totalCycleLength += cycle.cycleLength!;
        cycleCount++;
      }
    }
    double meanCycleLength = cycleCount > 0 ? totalCycleLength / cycleCount : 28; // Default to 28 if no complete cycles
    
    return {
      'meanPeriodLength': meanPeriodLength.round(),
      'meanCycleLength': meanCycleLength.round(),
      'periodCycles': cycles.length,
      'lastCalculated': DateTime.now().toIso8601String(),
    };
  }
  
  // Fetch all period dates for a user, detect cycles and calculate stats
  Future<Map<String, dynamic>> calculatePeriodStats(String userId, {int cycleLimit = 3}) async {
    try {
      // Get all period documents for the user
      QuerySnapshot periodSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('periods')
          .orderBy('periodStartDate', descending: true)
          .get();
      
      Set<String> periodDates = {};
      
      // Convert each date to the format used in the calendar
      for (var doc in periodSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        if (data['periodStartDate'] != null) {
          DateTime periodDate = DateTime.parse(data['periodStartDate']);
          String monthName = CalendarUtils.months[periodDate.month - 1];
          String day = periodDate.day.toString().padLeft(2, '0');
          String year = periodDate.year.toString();
          
          // Format: "January-01-2023"
          String dateKey = '$monthName-$day-$year';
          periodDates.add(dateKey);
        }
      }
      
      // Process the dates to find cycles
      List<DateTime> orderedDates = _getConsecutiveDatesFromKeys(periodDates);
      List<PeriodCycle> allCycles = _detectPeriodCycles(orderedDates);
      
      // Limit to the most recent cycles
      List<PeriodCycle> recentCycles = allCycles.length > cycleLimit 
          ? allCycles.sublist(allCycles.length - cycleLimit) 
          : allCycles;
      
      // Calculate statistics
      Map<String, dynamic> stats = _calculateStats(recentCycles);
      return stats;
    } catch (e) {
      return {
        'meanPeriodLength': 0,
        'meanCycleLength': 0,
        'error': e.toString(),
      };
    }
  }
  
  // Save the calculated stats to the user's document
  Future<void> savePeriodStats(String userId, Map<String, dynamic> stats) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'periodLength': stats['meanPeriodLength'],
        'cycleLength': stats['meanCycleLength'],
        'statsLastUpdated': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      rethrow;
    }
  }
  
  // Combined method to calculate and save the stats
  Future<Map<String, dynamic>> updatePeriodStats(String userId, {int cycleLimit = 3}) async {
    final stats = await calculatePeriodStats(userId, cycleLimit: cycleLimit);
    if (stats['meanPeriodLength'] > 0) {
      await savePeriodStats(userId, stats);
    }
    return stats;
  }
}