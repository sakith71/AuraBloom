class UserModel {
  final String uid;
  final String name;
  final int age;
  final DateTime? birthday;
  final double height;
  final double weight;
  final double bmi;
  final bool isRegularPeriod;
  final String crampsExperience;
  final String symptomDuration;
  final List<String> additionalSymptoms;
  final int cycleLength;
  final int periodLength;
  final DateTime lastPeriodDate;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    this.birthday, // Made optional with default value
    required this.height,
    required this.weight,
    required this.bmi,
    required this.isRegularPeriod,
    required this.crampsExperience,
    required this.symptomDuration,
    required this.additionalSymptoms,
    required this.cycleLength,
    required this.periodLength,
    required this.lastPeriodDate,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'birthday': birthday?.toIso8601String(), // Store birthday in Firestore
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'isRegularPeriod': isRegularPeriod,
      'crampsExperience': crampsExperience,
      'symptomDuration': symptomDuration,
      'additionalSymptoms': additionalSymptoms,
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Create a UserModel from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      birthday:
          map['birthday'] != null
              ? DateTime.parse(map['birthday'])
              : null, // Parse birthday from Firestore
      height: map['height'] ?? 0.0,
      weight: map['weight'] ?? 0.0,
      bmi: map['bmi'] ?? 0.0,
      isRegularPeriod: map['isRegularPeriod'] ?? false,
      crampsExperience: map['crampsExperience'] ?? 'No',
      symptomDuration: map['symptomDuration'] ?? '1-3 days',
      additionalSymptoms: List<String>.from(map['additionalSymptoms'] ?? []),
      cycleLength: map['cycleLength'] ?? 28,
      periodLength: map['periodLength'] ?? 5,
      lastPeriodDate:
          map['lastPeriodDate'] != null
              ? DateTime.parse(map['lastPeriodDate'])
              : DateTime.now(),
    );
  }
}
