// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String name;
  final int age;
  final double height;
  final double weight;


  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,

  });

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }

  // Create a UserModel from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      height: map['height'] ?? 0.0,
      weight: map['weight'] ?? 0.0,
    );
  }
}