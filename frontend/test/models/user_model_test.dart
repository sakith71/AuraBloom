import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user-model.dart';

void main() {
  group('UserModel', () {
    // Test creating a UserModel with all required parameters
    test('should create a UserModel instance with required parameters', () {
      final DateTime lastPeriodDate = DateTime(2023, 1, 1);
      final userModel = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        age: 25,
        height: 165.0,
        weight: 60.0,
        bmi: 22.0,
        isRegularPeriod: true,
        crampsExperience: 'Moderate',
        symptomDuration: '3-5 days',
        additionalSymptoms: ['Headache', 'Fatigue'],
        cycleLength: 28,
        periodLength: 5,
        lastPeriodDate: lastPeriodDate,
      );

      expect(userModel.uid, 'test-uid');
      expect(userModel.name, 'Test User');
      expect(userModel.age, 25);
      expect(userModel.birthday, null); // Default value should be null
      expect(userModel.height, 165.0);
      expect(userModel.weight, 60.0);
      expect(userModel.bmi, 22.0);
      expect(userModel.isRegularPeriod, true);
      expect(userModel.crampsExperience, 'Moderate');
      expect(userModel.symptomDuration, '3-5 days');
      expect(userModel.additionalSymptoms, ['Headache', 'Fatigue']);
      expect(userModel.cycleLength, 28);
      expect(userModel.periodLength, 5);
      expect(userModel.lastPeriodDate, lastPeriodDate);
    });

    // Test creating a UserModel with all parameters including optional ones
    test('should create a UserModel instance with all parameters', () {
      final DateTime lastPeriodDate = DateTime(2023, 1, 1);
      final DateTime birthday = DateTime(1998, 5, 15);
      final userModel = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        age: 25,
        birthday: birthday,
        height: 165.0,
        weight: 60.0,
        bmi: 22.0,
        isRegularPeriod: true,
        crampsExperience: 'Moderate',
        symptomDuration: '3-5 days',
        additionalSymptoms: ['Headache', 'Fatigue'],
        cycleLength: 28,
        periodLength: 5,
        lastPeriodDate: lastPeriodDate,
      );

      expect(userModel.uid, 'test-uid');
      expect(userModel.name, 'Test User');
      expect(userModel.age, 25);
      expect(userModel.birthday, birthday);
      expect(userModel.height, 165.0);
      expect(userModel.weight, 60.0);
      expect(userModel.bmi, 22.0);
      expect(userModel.isRegularPeriod, true);
      expect(userModel.crampsExperience, 'Moderate');
      expect(userModel.symptomDuration, '3-5 days');
      expect(userModel.additionalSymptoms, ['Headache', 'Fatigue']);
      expect(userModel.cycleLength, 28);
      expect(userModel.periodLength, 5);
      expect(userModel.lastPeriodDate, lastPeriodDate);
    });

    // Test converting UserModel to map
    test('toMap should return correct map representation', () {
      final DateTime lastPeriodDate = DateTime(2023, 1, 1);
      final DateTime birthday = DateTime(1998, 5, 15);
      final userModel = UserModel(
        uid: 'test-uid',
        name: 'Test User',
        age: 25,
        birthday: birthday,
        height: 165.0,
        weight: 60.0,
        bmi: 22.0,
        isRegularPeriod: true,
        crampsExperience: 'Moderate',
        symptomDuration: '3-5 days',
        additionalSymptoms: ['Headache', 'Fatigue'],
        cycleLength: 28,
        periodLength: 5,
        lastPeriodDate: lastPeriodDate,
      );

      final map = userModel.toMap();

      expect(map['uid'], 'test-uid');
      expect(map['name'], 'Test User');
      expect(map['age'], 25);
      expect(map['birthday'], birthday.toIso8601String());
      expect(map['height'], 165.0);
      expect(map['weight'], 60.0);
      expect(map['bmi'], 22.0);
      expect(map['isRegularPeriod'], true);
      expect(map['crampsExperience'], 'Moderate');
      expect(map['symptomDuration'], '3-5 days');
      expect(map['additionalSymptoms'], ['Headache', 'Fatigue']);
      expect(map['cycleLength'], 28);
      expect(map['periodLength'], 5);
      expect(map['lastPeriodDate'], lastPeriodDate.toIso8601String());

      // Check createdAt is present and is a valid date string
      expect(map.containsKey('createdAt'), true);
      expect(() => DateTime.parse(map['createdAt']), returnsNormally);
    });

    // Test creating UserModel from map with all fields
    test('fromMap should properly parse a complete map', () {
      final DateTime lastPeriodDate = DateTime(2023, 1, 1);
      final DateTime birthday = DateTime(1998, 5, 15);
      final map = {
        'uid': 'test-uid',
        'name': 'Test User',
        'age': 25,
        'birthday': birthday.toIso8601String(),
        'height': 165.0,
        'weight': 60.0,
        'bmi': 22.0,
        'isRegularPeriod': true,
        'crampsExperience': 'Moderate',
        'symptomDuration': '3-5 days',
        'additionalSymptoms': ['Headache', 'Fatigue'],
        'cycleLength': 28,
        'periodLength': 5,
        'lastPeriodDate': lastPeriodDate.toIso8601String(),
      };

      final userModel = UserModel.fromMap(map);

      expect(userModel.uid, 'test-uid');
      expect(userModel.name, 'Test User');
      expect(userModel.age, 25);
      expect(userModel.birthday, birthday);
      expect(userModel.height, 165.0);
      expect(userModel.weight, 60.0);
      expect(userModel.bmi, 22.0);
      expect(userModel.isRegularPeriod, true);
      expect(userModel.crampsExperience, 'Moderate');
      expect(userModel.symptomDuration, '3-5 days');
      expect(userModel.additionalSymptoms, ['Headache', 'Fatigue']);
      expect(userModel.cycleLength, 28);
      expect(userModel.periodLength, 5);
      expect(userModel.lastPeriodDate, lastPeriodDate);
    });

    // Test creating UserModel from map with missing fields
    test('fromMap should handle missing fields with default values', () {
      final map = {'uid': 'test-uid'};

      final userModel = UserModel.fromMap(map);

      expect(userModel.uid, 'test-uid');
      expect(userModel.name, '');
      expect(userModel.age, 0);
      expect(userModel.birthday, null);
      expect(userModel.height, 0.0);
      expect(userModel.weight, 0.0);
      expect(userModel.bmi, 0.0);
      expect(userModel.isRegularPeriod, false);
      expect(userModel.crampsExperience, 'No');
      expect(userModel.symptomDuration, '1-3 days');
      expect(userModel.additionalSymptoms, []);
      expect(userModel.cycleLength, 28);
      expect(userModel.periodLength, 5);

      // lastPeriodDate should default to current date, but we can't test exact equality
      expect(userModel.lastPeriodDate.year, DateTime.now().year);
    });

    // Test creating UserModel from map with null birthday
    test('fromMap should handle null birthday', () {
      final DateTime lastPeriodDate = DateTime(2023, 1, 1);
      final map = {
        'uid': 'test-uid',
        'name': 'Test User',
        'age': 25,
        'birthday': null,
        'height': 165.0,
        'weight': 60.0,
        'bmi': 22.0,
        'isRegularPeriod': true,
        'crampsExperience': 'Moderate',
        'symptomDuration': '3-5 days',
        'additionalSymptoms': ['Headache', 'Fatigue'],
        'cycleLength': 28,
        'periodLength': 5,
        'lastPeriodDate': lastPeriodDate.toIso8601String(),
      };

      final userModel = UserModel.fromMap(map);
      expect(userModel.birthday, null);
    });

    // Test creating UserModel from map with missing lastPeriodDate
    test('fromMap should handle missing lastPeriodDate', () {
      final map = {
        'uid': 'test-uid',
        'name': 'Test User',
        'age': 25,
        'height': 165.0,
        'weight': 60.0,
        'bmi': 22.0,
        'isRegularPeriod': true,
        'crampsExperience': 'Moderate',
        'symptomDuration': '3-5 days',
        'additionalSymptoms': ['Headache', 'Fatigue'],
        'cycleLength': 28,
        'periodLength': 5,
      };

      final userModel = UserModel.fromMap(map);

      // lastPeriodDate should default to current date, but we can't test exact equality
      expect(userModel.lastPeriodDate.year, DateTime.now().year);
      expect(userModel.lastPeriodDate.month, DateTime.now().month);
      expect(userModel.lastPeriodDate.day, DateTime.now().day);
    });

    // Test creating UserModel from map with invalid additionalSymptoms
    test('fromMap should handle non-list additionalSymptoms', () {
      final DateTime lastPeriodDate = DateTime(2023, 1, 1);
      final map = {
        'uid': 'test-uid',
        'name': 'Test User',
        'age': 25,
        'height': 165.0,
        'weight': 60.0,
        'bmi': 22.0,
        'isRegularPeriod': true,
        'crampsExperience': 'Moderate',
        'symptomDuration': '3-5 days',
        'additionalSymptoms': 'Not a list', // This is not a list
        'cycleLength': 28,
        'periodLength': 5,
        'lastPeriodDate': lastPeriodDate.toIso8601String(),
      };

      // This should not throw an error but return an empty list
      final userModel = UserModel.fromMap(map);
      expect(userModel.additionalSymptoms, []);
    });
  });
}
