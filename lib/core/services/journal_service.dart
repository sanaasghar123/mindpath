import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindpath/core/models/activity_log.dart';
import 'package:mindpath/core/models/journal_entry.dart';
import 'package:mindpath/core/services/firestore_service.dart';

class JournalService {
  JournalService({FirestoreService? firestoreService})
    : _firestore = (firestoreService ?? FirestoreService()).firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _journals =>
      _firestore.collection('journals');

  CollectionReference<Map<String, dynamic>> get _activityLogs =>
      _firestore.collection('activity_logs');

  Stream<List<JournalEntry>> watchJournals({
    required String userId,
    int limit = 200,
  }) {
    return _journals
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(JournalEntry.fromDoc).toList());
  }

  Future<List<JournalEntry>> getLatestJournals({
    required String userId,
    int limit = 10,
  }) async {
    final snapshot = await _journals
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map(JournalEntry.fromDoc).toList();
  }

  Future<JournalEntry> createJournal(JournalEntry entry) async {
    final doc = _journals.doc();
    final withId = JournalEntry(
      id: doc.id,
      userId: entry.userId,
      text: entry.text,
      sentiment: entry.sentiment,
      emotion: entry.emotion,
      insight: entry.insight,
      tags: entry.tags,
      activityType: entry.activityType,
      createdAt: entry.createdAt,
      title: entry.title,
    );
    await doc.set(withId.toMapForCreate());
    return withId;
  }

  Future<void> updateJournal(JournalEntry entry) async {
    await _journals.doc(entry.id).update(entry.toMapForUpdate());
  }

  Future<void> deleteJournal({required String journalId}) async {
    await _journals.doc(journalId).delete();
  }

  Future<void> logActivity(ActivityLog log) async {
    await _activityLogs.add(log.toMapForCreate());
  }
}

