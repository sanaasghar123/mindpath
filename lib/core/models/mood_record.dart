import 'package:cloud_firestore/cloud_firestore.dart';

class MoodRecord {
  const MoodRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.moodLabel,
    required this.moodText,
    required this.moodScore,
    required this.sentiment,
    required this.emotion,
    required this.insight,
  });

  final String id;
  final String userId;
  final Timestamp? timestamp;
  final String moodLabel;
  final String moodText;
  final double moodScore;
  final String sentiment;
  final String emotion;
  final String insight;

  Map<String, dynamic> toMapForCreate() {
    return {
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'moodLabel': moodLabel,
      'moodText': moodText,
      'moodScore': moodScore,
      'sentiment': sentiment,
      'emotion': emotion,
      'insight': insight,
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'moodLabel': moodLabel,
      'moodText': moodText,
      'moodScore': moodScore,
      'sentiment': sentiment,
      'emotion': emotion,
      'insight': insight,
    };
  }

  static MoodRecord fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return MoodRecord(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      timestamp: data['timestamp'] as Timestamp?,
      moodLabel: (data['moodLabel'] ?? '') as String,
      moodText: (data['moodText'] ?? '') as String,
      moodScore: (data['moodScore'] is num)
          ? (data['moodScore'] as num).toDouble()
          : 0,
      sentiment: (data['sentiment'] ?? '') as String,
      emotion: (data['emotion'] ?? '') as String,
      insight: (data['insight'] ?? '') as String,
    );
  }
}
