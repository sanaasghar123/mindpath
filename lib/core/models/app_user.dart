import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.userId,
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.profileImage,
    this.hasCompletedFirstMoodAnalysis,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final String? profileImage;
  final bool? hasCompletedFirstMoodAnalysis;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'profileImage': profileImage,
      'hasCompletedFirstMoodAnalysis': hasCompletedFirstMoodAnalysis,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: (map['userId'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      age: map['age'] is int ? map['age'] as int : null,
      gender: map['gender'] as String?,
      profileImage: map['profileImage'] as String?,
      hasCompletedFirstMoodAnalysis:
          map['hasCompletedFirstMoodAnalysis'] as bool?,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  AppUser copyWith({
    String? name,
    int? age,
    String? gender,
    String? profileImage,
    bool? hasCompletedFirstMoodAnalysis,
    Timestamp? updatedAt,
  }) {
    return AppUser(
      userId: userId,
      name: name ?? this.name,
      email: email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
      hasCompletedFirstMoodAnalysis:
          hasCompletedFirstMoodAnalysis ?? this.hasCompletedFirstMoodAnalysis,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
