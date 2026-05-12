import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindpath/core/models/mood_record.dart';

class MoodService {
  MoodService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection('mood_records');

  Future<void> createMoodRecord(MoodRecord record) async {
    await _records.add(record.toMapForCreate());
  }

  Future<void> updateMoodRecord(MoodRecord record) async {
    await _records.doc(record.id).update(record.toMapForUpdate());
  }

  Future<void> deleteMoodRecord({required String recordId}) async {
    await _records.doc(recordId).delete();
  }

  Future<List<MoodRecord>> getLatestRecords({
    required String userId,
    int limit = 10,
  }) async {
    final snapshot = await _records
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(MoodRecord.fromDoc).toList();
  }

  Stream<List<MoodRecord>> watchLatestRecords({
    required String userId,
    int limit = 30,
  }) {
    return _records
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(MoodRecord.fromDoc).toList());
  }
}
