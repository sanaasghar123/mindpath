import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.text,
    required this.sentiment,
    required this.emotion,
    required this.insight,
    required this.tags,
    required this.activityType,
    required this.createdAt,
    required this.title,
    this.prompt,
  });

  final String id;
  final String userId;
  final String text;
  final String sentiment;
  final String emotion;
  final String insight;
  final List<String> tags;
  final String activityType;
  final Timestamp? createdAt;
  final String title;
  final String? prompt;

  Map<String, dynamic> toMapForCreate() {
    return {
      'journalId': id,
      'userId': userId,
      'text': text,
      'sentiment': sentiment,
      'emotion': emotion,
      'insight': insight,
      'tags': tags,
      'activityType': activityType,
      'createdAt': FieldValue.serverTimestamp(),
      'title': title,
      'prompt': prompt,
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'text': text,
      'sentiment': sentiment,
      'emotion': emotion,
      'insight': insight,
      'tags': tags,
      'title': title,
      'prompt': prompt,
    };
  }

  static JournalEntry fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawTags = data['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList(growable: false)
        : <String>[];
    return JournalEntry(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      text: (data['text'] ?? '') as String,
      sentiment: (data['sentiment'] ?? '') as String,
      emotion: (data['emotion'] ?? '') as String,
      insight: (data['insight'] ?? '') as String,
      tags: tags,
      activityType: (data['activityType'] ?? '') as String,
      createdAt: data['createdAt'] as Timestamp?,
      title: (data['title'] ?? '') as String,
      prompt: data['prompt'] as String?,
    );
  }
}

