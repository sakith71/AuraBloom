import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/calendar.dart';

class PeriodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Fetch period dates for a user
  Future<Set<String>> fetchPeriodDates(String userId) async {
    try {
      Set<String> periodDates = {};
      
      // Get all period documents for the user
      QuerySnapshot periodSnapshot = await _firestore
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
      print('Error fetching period dates: $e');
      return {};
    }
  }
  
  // Fetch the most recent period date
  Future<DateTime?> fetchLastPeriodDate(String userId) async {
    try {
      // Get the user document which should have the lastPeriodDate field
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['lastPeriodDate'] != null) {
          return DateTime.parse(userData['lastPeriodDate']);
        }
      }
      
      // If not found in user doc, try to find the most recent from period collection
      QuerySnapshot periodSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('periods')
          .orderBy('periodStartDate', descending: true)
          .limit(1)
          .get();
      
      if (periodSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = periodSnapshot.docs.first.data() as Map<String, dynamic>;
        if (data['periodStartDate'] != null) {
          return DateTime.parse(data['periodStartDate']);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching last period date: $e');
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
        final periodDate = CalendarUtils.parseDisplayDate(
          '$month $day, $year'
        );
        
        if (periodDate != null) {
          // Format date to ISO string for query
          String isoDate = periodDate.toIso8601String();
          
          // Find and delete matching documents
          QuerySnapshot docsToDelete = await _firestore
              .collection('users')
              .doc(userId)
              .collection('periods')
              .where('periodStartDate', isEqualTo: isoDate)
              .get();
          
          for (var doc in docsToDelete.docs) {
            await doc.reference.delete();
          }
          
          // After deletion, update the lastPeriodDate field if needed
          await updateLastPeriodDate(userId);
        }
      }
    } catch (e) {
      print('Error deleting period date: $e');
      rethrow;
    }
  }
  
  // Save multiple period dates and update the lastPeriodDate field
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
            '$month $day, $year'
          );
          
          if (periodDate != null) {
            periodDates.add(periodDate);
            
            // Save each period date to the periods collection
            await _firestore.collection('users').doc(userId).collection('periods').add({
              'periodStartDate': periodDate.toIso8601String(),
              'loggedAt': DateTime.now().toIso8601String(),
            });
          }
        }
      }
      
      // Find the most recent date and update lastPeriodDate in user document
      if (periodDates.isNotEmpty) {
        // Sort dates to find the most recent
        periodDates.sort((a, b) => b.compareTo(a)); // descending order
        DateTime mostRecentDate = periodDates.first;
        
        // Update the lastPeriodDate field in the user document
        await _firestore.collection('users').doc(userId).update({
          'lastPeriodDate': mostRecentDate.toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving period dates: $e');
      rethrow;
    }
  }
  
  // Update the lastPeriodDate field based on existing period entries
  Future<void> updateLastPeriodDate(String userId) async {
    try {
      // Get the most recent period date from the periods collection
      QuerySnapshot periodSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('periods')
          .orderBy('periodStartDate', descending: true)
          .limit(1)
          .get();
      
      if (periodSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = periodSnapshot.docs.first.data() as Map<String, dynamic>;
        if (data['periodStartDate'] != null) {
          // Update the lastPeriodDate field in the user document
          await _firestore.collection('users').doc(userId).update({
            'lastPeriodDate': data['periodStartDate'],
          });
        } else {
          // If there are no more period entries, set lastPeriodDate to null or a default value
          await _firestore.collection('users').doc(userId).update({
            'lastPeriodDate': null,
          });
        }
      } else {
        // If there are no period entries, set lastPeriodDate to null or a default value
        await _firestore.collection('users').doc(userId).update({
            'lastPeriodDate': null,
        });
      }
    } catch (e) {
      print('Error updating last period date: $e');
      rethrow;
    }
  }
}