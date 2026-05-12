import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:mindpath/features/profile/controllers/language_controller.dart';

class MoodAnalysisResult {
  const MoodAnalysisResult({
    required this.sentiment,
    required this.emotion,
    required this.insight,
    required this.progression,
  });

  final String sentiment;
  final String emotion;
  final String insight;
  final String progression;
}

class JournalInsightResult {
  const JournalInsightResult({
    required this.reflection,
    required this.suggestion,
    required this.nextStep,
  });

  final String reflection;
  final String suggestion;
  final String nextStep;
}

class JournalAnalyzeResult {
  const JournalAnalyzeResult({
    required this.sentiment,
    required this.emotion,
    required this.insight,
    required this.tags,
  });

  final String sentiment;
  final String emotion;
  final String insight;
  final List<String> tags;
}

class LlmService {
  LlmService({GetConnect? client}) : _client = client ?? GetConnect();

  final GetConnect _client;

  static const _baseUrl = String.fromEnvironment('LLM_API_BASE_URL');
  static const _apiKey = String.fromEnvironment('LLM_API_KEY');

  String? get _languageInstruction {
    if (!Get.isRegistered<LanguageController>()) return null;
    final lang = Get.find<LanguageController>();
    if (!lang.isUrdu) return null;
    return 'Respond entirely in Urdu. Use simple, clear Urdu suitable for a mental health context.';
  }

  String get _resolvedBaseUrl {
    final configured = _baseUrl.trim();
    if (configured.isNotEmpty) return configured;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<MoodAnalysisResult> analyzeMood({
    required String moodText,
    required double moodScore,
    required String moodLabel,
    List<Map<String, dynamic>> history = const [],
  }) async {
    final baseUrl = _resolvedBaseUrl.replaceAll(RegExp(r'/*$'), '');
    final uri = '$baseUrl/mood/analyze';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
    };

    final prompt = _buildPrompt(
      moodText: moodText,
      moodScore: moodScore,
      moodLabel: moodLabel,
      history: history,
    );
    final languageInstruction = _languageInstruction;
    final effectivePrompt =
        (languageInstruction == null || languageInstruction.isEmpty)
            ? prompt
            : '$prompt\n\n$languageInstruction';

    final payload = <String, dynamic>{
      'prompt': effectivePrompt,
      'inputs': {
        'moodText': moodText,
        'moodScore': moodScore,
        'moodLabel': moodLabel,
      },
      'history': history,
      if (languageInstruction != null) 'languageInstruction': languageInstruction,
    };

    late final Response response;
    try {
      response = await _client
          .post(uri, payload, headers: headers)
          .timeout(const Duration(seconds: 25));
    } catch (e) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (response.statusCode == null) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (!response.isOk) {
      final status = response.statusCode;
      final detail = (response.statusText ?? '').trim();
      if (detail.isEmpty) {
        throw StateError('Analysis request failed ($status)');
      }
      throw StateError('Analysis request failed ($status): $detail');
    }

    final body = response.body;
    final map = body is Map<String, dynamic>
        ? body
        : (body is String ? (jsonDecode(body) as Map<String, dynamic>) : null);
    if (map == null) {
      throw StateError('Invalid LLM response format');
    }

    final result = map['result'];
    final resultMap = result is Map<String, dynamic> ? result : map;

    final sentiment = (resultMap['sentiment'] ?? '').toString().trim();
    final emotion = (resultMap['emotion'] ?? '').toString().trim();
    final insight = (resultMap['insight'] ?? '').toString().trim();
    final progression = (resultMap['progression'] ?? '').toString().trim();

    if (sentiment.isEmpty ||
        emotion.isEmpty ||
        insight.isEmpty ||
        progression.isEmpty) {
      throw StateError('LLM response missing fields');
    }

    return MoodAnalysisResult(
      sentiment: sentiment,
      emotion: emotion,
      insight: insight,
      progression: progression,
    );
  }

  Future<JournalInsightResult> journalInsight({
    required Map<String, dynamic> entry,
    List<Map<String, dynamic>> history = const [],
  }) async {
    final baseUrl = _resolvedBaseUrl.replaceAll(RegExp(r'/*$'), '');
    final uri = '$baseUrl/journal/insight';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
    };

    final languageInstruction = _languageInstruction;
    final payload = <String, dynamic>{
      'entry': entry,
      'history': history,
      if (languageInstruction != null) 'languageInstruction': languageInstruction,
    };

    late final Response response;
    try {
      response = await _client
          .post(uri, payload, headers: headers)
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (response.statusCode == null) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (!response.isOk) {
      final status = response.statusCode;
      final detail = (response.statusText ?? '').trim();
      if (detail.isEmpty) {
        throw StateError('Analysis request failed ($status)');
      }
      throw StateError('Analysis request failed ($status): $detail');
    }

    final body = response.body;
    final map = body is Map<String, dynamic>
        ? body
        : (body is String ? (jsonDecode(body) as Map<String, dynamic>) : null);
    if (map == null) {
      throw StateError('Invalid LLM response format');
    }

    final reflection = (map['reflection'] ?? '').toString().trim();
    final suggestion = (map['suggestion'] ?? '').toString().trim();
    final nextStep = (map['nextStep'] ?? '').toString().trim();

    if (reflection.isEmpty || suggestion.isEmpty || nextStep.isEmpty) {
      throw StateError('LLM response missing fields');
    }

    return JournalInsightResult(
      reflection: reflection,
      suggestion: suggestion,
      nextStep: nextStep,
    );
  }

  Future<JournalAnalyzeResult> analyzeJournal({
    required String text,
    List<Map<String, dynamic>> history = const [],
  }) async {
    final baseUrl = _resolvedBaseUrl.replaceAll(RegExp(r'/*$'), '');
    final uri = '$baseUrl/journal/analyze';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
    };

    final languageInstruction = _languageInstruction;
    final payload = <String, dynamic>{
      'text': text,
      'history': history,
      if (languageInstruction != null) 'languageInstruction': languageInstruction,
    };

    late final Response response;
    try {
      response = await _client
          .post(uri, payload, headers: headers)
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (response.statusCode == null) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (!response.isOk) {
      final status = response.statusCode;
      final detail = (response.statusText ?? '').trim();
      if (detail.isEmpty) {
        throw StateError('Analysis request failed ($status)');
      }
      throw StateError('Analysis request failed ($status): $detail');
    }

    final body = response.body;
    final map = body is Map<String, dynamic>
        ? body
        : (body is String ? (jsonDecode(body) as Map<String, dynamic>) : null);
    if (map == null) {
      throw StateError('Invalid LLM response format');
    }

    final sentiment = (map['sentiment'] ?? '').toString().trim();
    final emotion = (map['emotion'] ?? '').toString().trim();
    final insight = (map['insight'] ?? '').toString().trim();
    final rawTags = map['tags'];
    final tags = rawTags is List
        ? rawTags
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList()
        : <String>[];

    if (sentiment.isEmpty || emotion.isEmpty || insight.isEmpty) {
      throw StateError('LLM response missing fields');
    }

    return JournalAnalyzeResult(
      sentiment: sentiment,
      emotion: emotion,
      insight: insight,
      tags: tags,
    );
  }

  Future<JournalInsightResult> journalDeepInsight({
    required Map<String, dynamic> entry,
    List<Map<String, dynamic>> history = const [],
  }) async {
    final baseUrl = _resolvedBaseUrl.replaceAll(RegExp(r'/*$'), '');
    final uri = '$baseUrl/journal/deep_insight';
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
    };

    final languageInstruction = _languageInstruction;
    final payload = <String, dynamic>{
      'entry': entry,
      'history': history,
      if (languageInstruction != null) 'languageInstruction': languageInstruction,
    };

    late final Response response;
    try {
      response = await _client
          .post(uri, payload, headers: headers)
          .timeout(const Duration(seconds: 25));
    } catch (_) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (response.statusCode == null) {
      throw StateError('Couldn’t reach analysis server at $baseUrl');
    }

    if (!response.isOk) {
      final status = response.statusCode;
      final detail = (response.statusText ?? '').trim();
      if (detail.isEmpty) {
        throw StateError('Analysis request failed ($status)');
      }
      throw StateError('Analysis request failed ($status): $detail');
    }

    final body = response.body;
    final map = body is Map<String, dynamic>
        ? body
        : (body is String ? (jsonDecode(body) as Map<String, dynamic>) : null);
    if (map == null) {
      throw StateError('Invalid LLM response format');
    }

    final reflection = (map['reflection'] ?? '').toString().trim();
    final suggestion = (map['suggestion'] ?? '').toString().trim();
    final nextStep = (map['nextStep'] ?? '').toString().trim();

    if (reflection.isEmpty || suggestion.isEmpty || nextStep.isEmpty) {
      throw StateError('LLM response missing fields');
    }

    return JournalInsightResult(
      reflection: reflection,
      suggestion: suggestion,
      nextStep: nextStep,
    );
  }

  String _buildPrompt({
    required String moodText,
    required double moodScore,
    required String moodLabel,
    required List<Map<String, dynamic>> history,
  }) {
    final historyText = history.isEmpty
        ? 'No previous assessments.'
        : history
              .take(8)
              .map((item) {
                final ts = (item['timestamp'] ?? '').toString().trim();
                final label = (item['moodLabel'] ?? '').toString().trim();
                final score = (item['moodScore'] ?? '').toString().trim();
                final sentiment = (item['sentiment'] ?? '').toString().trim();
                final emotion = (item['emotion'] ?? '').toString().trim();
                final insight = (item['insight'] ?? '').toString().trim();
                final text = (item['moodText'] ?? '').toString().trim();
                final shortText = text.length > 140
                    ? '${text.substring(0, 140)}…'
                    : text;
                return '- $ts | label: $label | score: $score | $sentiment | $emotion | insight: "$insight" | text: "$shortText"';
              })
              .join('\n');

    return '''
You are a mental wellness assistant. Analyze the user's mood check-in and produce a concise JSON object.

User input:
- moodLabel: "$moodLabel"
- moodScore (0-10): $moodScore
- moodText: "$moodText"

Previous context (most recent first):
$historyText

Return ONLY valid JSON with exactly these keys:
{
  "sentiment": "positive|neutral|negative",
  "emotion": "stress|anxiety|calm|joy|sadness|anger|fatigue|overwhelm|other",
  "insight": "A short, compassionate, personalized insight (1-2 sentences).",
  "progression": "A short progression compared to the previous assessment (e.g., improving|stable|worsening + one short phrase)."
}

Rules:
- Keep insight supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
''';
  }
}
