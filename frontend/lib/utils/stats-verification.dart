// import 'package:cloud_firestore/cloud_firestore.dart';

// class StatsVerificationUtil {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
//   // Verify that stats were saved to the database
//   Future<Map<String, dynamic>> verifyPeriodStats(String userId) async {
//     try {
//       // Get the user document
//       DocumentSnapshot userDoc = await _firestore
//           .collection('users')
//           .doc(userId)
//           .get();
      
//       if (!userDoc.exists) {
//         return {
//           'success': false,
//           'message': 'User document not found',
//           'data': null,
//         };
//       }
      
//       // Extract the data
//       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
//       // Check if the stats fields exist
//       bool hasPeriodLength = userData.containsKey('periodLength');
//       bool hasCycleLength = userData.containsKey('cycleLength');
//       bool hasStatsLastUpdated = userData.containsKey('statsLastUpdated');
      
//       return {
//         'success': hasPeriodLength && hasCycleLength,
//         'message': hasPeriodLength && hasCycleLength 
//             ? 'Period stats found in database' 
//             : 'Some period stats are missing',
//         'data': {
//           'periodLength': userData['periodLength'],
//           'cycleLength': userData['cycleLength'],
//           'statsLastUpdated': userData['statsLastUpdated'],
//         },
//         'fieldsFound': {
//           'periodLength': hasPeriodLength,
//           'cycleLength': hasCycleLength,
//           'statsLastUpdated': hasStatsLastUpdated,
//         },
//       };
//     } catch (e) {
//       print('Error verifying period stats: $e');
//       return {
//         'success': false,
//         'message': 'Error verifying period stats: $e',
//         'data': null,
//       };
//     }
//   }
// }