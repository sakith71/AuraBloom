import 'package:intl/intl.dart';

class PeriodPredictionModel {
  final int predictedCycleLength;
  final DateTime nextPeriodStartDate;
  final DateTime? lastPeriodStartDate;
  final DateTime lastPredictionDate;
  final bool isAiPrediction;
  final bool isFallback;
  final String modelType;

  PeriodPredictionModel({
    required this.predictedCycleLength,
    required this.nextPeriodStartDate,
    this.lastPeriodStartDate,
    required this.lastPredictionDate,
    this.isAiPrediction = false,
    this.isFallback = false,
    String? modelType,
  }) : modelType = modelType ?? 'Simple Calculation';

  // Factory constructor to create a model from Firestore data
  factory PeriodPredictionModel.fromMap(Map<String, dynamic> map) {
    try {
      // Parse dates from ISO strings with null safety
      DateTime parseDate(String? dateString) {
        if (dateString == null || dateString.isEmpty) {
          return DateTime.now(); // Default to current date if missing
        }

        try {
          return DateTime.parse(dateString);
        } catch (e) {
          return DateTime.now();
        }
      }

      // Extract cycle length with null safety
      int cycleLength = 28; // Default value
      if (map.containsKey('predictedCycleLength')) {
        if (map['predictedCycleLength'] is int) {
          cycleLength = map['predictedCycleLength'];
        } else if (map['predictedCycleLength'] is String) {
          cycleLength = int.tryParse(map['predictedCycleLength']) ?? 28;
        } else if (map['predictedCycleLength'] is double) {
          cycleLength = map['predictedCycleLength'].round();
        }
      }

      // Extract date strings with null safety
      String? nextPeriodStartStr =
          map['predictedNextPeriodStart'] ?? map['nextPeriodStartDate'];
      String? lastPeriodStartStr =
          map['lastPeriodStartDate'] ?? map['lastCycleStartDate'];
      String? lastPredictionStr = map['lastPredictionDate'];

      return PeriodPredictionModel(
        predictedCycleLength: cycleLength,
        nextPeriodStartDate: parseDate(nextPeriodStartStr),
        lastPeriodStartDate:
            lastPeriodStartStr != null ? parseDate(lastPeriodStartStr) : null,
        lastPredictionDate:
            lastPredictionStr != null
                ? parseDate(lastPredictionStr)
                : DateTime.now(),
        isAiPrediction: map['usedActualModel'] == true,
        isFallback: map['isFallback'] == true,
        modelType: map['modelType'] as String? ?? 'Simple Calculation',
      );
    } catch (e) {
      // Return a default model if parsing fails
      return PeriodPredictionModel(
        predictedCycleLength: 28,
        nextPeriodStartDate: DateTime.now().add(Duration(days: 28)),
        lastPredictionDate: DateTime.now(),
        isFallback: true,
      );
    }
  }

  // Convert model to a map for Firestore storage
  Map<String, dynamic> toMap() {
    try {
      Map<String, dynamic> result = {
        'predictedCycleLength': predictedCycleLength,
        'predictedNextPeriodStart': nextPeriodStartDate.toIso8601String(),
        'lastPredictionDate': lastPredictionDate.toIso8601String(),
        'usedActualModel': isAiPrediction,
        'isFallback': isFallback,
        'modelType': modelType,
      };

      // Only add lastPeriodStartDate if it's not null
      if (lastPeriodStartDate != null) {
        result['lastPeriodStartDate'] = lastPeriodStartDate!.toIso8601String();
      }

      return result;
    } catch (e) {
      // Return a valid fallback map
      return {
        'predictedCycleLength': 28,
        'predictedNextPeriodStart':
            DateTime.now().add(Duration(days: 28)).toIso8601String(),
        'lastPredictionDate': DateTime.now().toIso8601String(),
        'usedActualModel': false,
        'isFallback': true,
        'modelType': 'Error Fallback',
      };
    }
  }

  // Format next period date for display
  String getFormattedNextPeriodDate() {
    try {
      return DateFormat('MMM dd, yyyy').format(nextPeriodStartDate);
    } catch (e) {
      return 'Date unavailable';
    }
  }

  // Format last prediction date for display
  String getFormattedLastPredictionDate() {
    try {
      return DateFormat('MMM dd, yyyy').format(lastPredictionDate);
    } catch (e) {
      return 'Date unavailable';
    }
  }

  // Calculate days until next period
  int getDaysUntilNextPeriod() {
    try {
      final now = DateTime.now();
      return nextPeriodStartDate.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  // Check if prediction is recent (less than 24 hours old)
  bool isRecentPrediction() {
    try {
      final now = DateTime.now();
      return now.difference(lastPredictionDate).inHours < 24;
    } catch (e) {
      return false;
    }
  }

  // Create a copy of this prediction with some fields updated
  PeriodPredictionModel copyWith({
    int? predictedCycleLength,
    DateTime? nextPeriodStartDate,
    DateTime? lastPeriodStartDate,
    DateTime? lastPredictionDate,
    bool? isAiPrediction,
    bool? isFallback,
    String? modelType,
  }) {
    return PeriodPredictionModel(
      predictedCycleLength: predictedCycleLength ?? this.predictedCycleLength,
      nextPeriodStartDate: nextPeriodStartDate ?? this.nextPeriodStartDate,
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
      lastPredictionDate: lastPredictionDate ?? this.lastPredictionDate,
      isAiPrediction: isAiPrediction ?? this.isAiPrediction,
      isFallback: isFallback ?? this.isFallback,
      modelType: modelType ?? this.modelType,
    );
  }
}
