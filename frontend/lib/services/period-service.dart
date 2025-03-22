import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/calendar.dart';

class PeriodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch period dates for a user
  Future<Set<String>> fetchPeriodDates(String userId) async {
    try {
      Set<String> periodDates = {};

      // Get all period documents for the user
      QuerySnapshot periodSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('periods')
              .get();

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

      return periodDates;
    } catch (e) {
      return {};
    }
  }

  // Fetch the first date of the most recent period cycle
  Future<DateTime?> fetchLastCycleStartDate(String userId) async {
    try {
      // Get the user document which should have the lastCycleStartDate field
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['lastCycleStartDate'] != null) {
          return DateTime.parse(userData['lastCycleStartDate']);
        }
      }

      // If not found in user doc, find the most recent cycle start date
      QuerySnapshot periodSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('periods')
              .orderBy('periodStartDate', descending: true)
              .get();

      if (periodSnapshot.docs.isNotEmpty) {
        // Convert all dates to DateTime objects
        List<DateTime> allDates = [];
        for (var doc in periodSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data['periodStartDate'] != null) {
            allDates.add(DateTime.parse(data['periodStartDate']));
          }
        }

        // Sort dates
        allDates.sort((a, b) => a.compareTo(b));

        // Find cycle start dates (dates that don't have a previous date exactly 1 day before)
        List<DateTime> cycleStartDates = [];
        DateTime? previousDate;

        for (DateTime date in allDates) {
          if (previousDate == null ||
              date.difference(previousDate).inDays > 1) {
            cycleStartDates.add(date);
          }
          previousDate = date;
        }

        // Get the most recent cycle start date
        if (cycleStartDates.isNotEmpty) {
          cycleStartDates.sort((a, b) => b.compareTo(a)); // descending order
          return cycleStartDates.first;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Delete a period date
  Future<void> deletePeriodDate(String userId, String dateKey) async {
    try {
      // Convert date key to DateTime
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final month = parts[0];
        final day = parts[1];
        final year = parts[2];

        // Convert to DateTime
        final periodDate = CalendarUtils.parseDisplayDate('$month $day, $year');

        if (periodDate != null) {
          // Format date to ISO string for query
          String isoDate = periodDate.toIso8601String();

          // Find and delete matching documents
          QuerySnapshot docsToDelete =
              await _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('periods')
                  .where('periodStartDate', isEqualTo: isoDate)
                  .get();

          for (var doc in docsToDelete.docs) {
            await doc.reference.delete();
          }

          // After deletion, update the lastCycleStartDate field
          await updateLastCycleStartDate(userId);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Save multiple period dates and update the lastCycleStartDate field
  Future<void> savePeriodDates(String userId, Set<String> dateKeys) async {
    try {
      // Convert all dateKeys to DateTime objects for comparison
      List<DateTime> periodDates = [];
      for (String dateKey in dateKeys) {
        final parts = dateKey.split('-');
        if (parts.length == 3) {
          final month = parts[0];
          final day = parts[1];
          final year = parts[2];

          // Convert to DateTime
          final periodDate = CalendarUtils.parseDisplayDate(
            '$month $day, $year',
          );

          if (periodDate != null) {
            periodDates.add(periodDate);

            // Save each period date to the periods collection
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('periods')
                .add({
                  'periodStartDate': periodDate.toIso8601String(),
                  'loggedAt': DateTime.now().toIso8601String(),
                });
          }
        }
      }

      // After saving all dates, determine the cycle start dates and update lastCycleStartDate
      await updateLastCycleStartDate(userId);
    } catch (e) {
      rethrow;
    }
  }

  // Update the lastCycleStartDate field based on existing period entries
  Future<void> updateLastCycleStartDate(String userId) async {
    try {
      // Get all period dates
      QuerySnapshot periodSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('periods')
              .orderBy('periodStartDate')
              .get();

      if (periodSnapshot.docs.isNotEmpty) {
        // Convert all dates to DateTime objects
        List<DateTime> allDates = [];
        for (var doc in periodSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data['periodStartDate'] != null) {
            allDates.add(DateTime.parse(data['periodStartDate']));
          }
        }

        // Find cycle start dates (dates that don't have a previous date exactly 1 day before)
        List<DateTime> cycleStartDates = [];
        DateTime? previousDate;

        for (DateTime date in allDates) {
          if (previousDate == null ||
              date.difference(previousDate).inDays > 1) {
            cycleStartDates.add(date);
          }
          previousDate = date;
        }

        // If we found cycle start dates, update the user document with the most recent one
        if (cycleStartDates.isNotEmpty) {
          // Sort to find the most recent
          cycleStartDates.sort((a, b) => b.compareTo(a)); // descending order
          DateTime mostRecentCycleStart = cycleStartDates.first;

          // Update the lastCycleStartDate field in the user document
          await _firestore.collection('users').doc(userId).update({
            'lastCycleStartDate': mostRecentCycleStart.toIso8601String(),
          });
        } else {
          // If no cycle start dates found, set to null
          await _firestore.collection('users').doc(userId).update({
            'lastCycleStartDate': null,
          });
        }
      } else {
        // If no period entries, set to null
        await _firestore.collection('users').doc(userId).update({
          'lastCycleStartDate': null,
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
