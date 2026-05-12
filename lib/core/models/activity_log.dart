import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.durationSeconds,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String activityType;
  final int durationSeconds;
  final Timestamp? createdAt;

  Map<String, dynamic> toMapForCreate() {
    return {
      'userId': userId,
      'activityType': activityType,
      'duration': durationSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static ActivityLog fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ActivityLog(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      activityType: (data['activityType'] ?? '') as String,
      durationSeconds: (data['duration'] is num) ? (data['duration'] as num).toInt() : 0,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}

