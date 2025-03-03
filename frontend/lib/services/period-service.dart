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
        }
      }
    } catch (e) {
      print('Error deleting period date: $e');
      rethrow;
    }
  }
}