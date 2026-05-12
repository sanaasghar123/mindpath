import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindpath/core/models/app_user.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<AppUser?> fetchUser(String userId) async {
    final doc = await _users.doc(userId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return AppUser.fromMap(data);
  }

  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    int? age,
    String? gender,
    String? profileImage,
  }) async {
    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'userId': userId,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'profileImage': profileImage,
      'hasCompletedFirstMoodAnalysis': false,
      'createdAt': now,
      'updatedAt': now,
    };

    await _users.doc(userId).set(data);
  }

  Future<void> updateUserProfile({
    required String userId,
    String? name,
    int? age,
    String? gender,
    String? profileImage,
    bool? hasCompletedFirstMoodAnalysis,
  }) async {
    final data = <String, dynamic>{
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (profileImage != null) 'profileImage': profileImage,
      if (hasCompletedFirstMoodAnalysis != null)
        'hasCompletedFirstMoodAnalysis': hasCompletedFirstMoodAnalysis,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _users.doc(userId).update(data);
  }
}
