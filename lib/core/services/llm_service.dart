import 'dart:convert';

import 'package:get/get.dart';
import 'package:mindpath/core/config/app_config.dart';
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

  static const _openRouterBaseUrl = 'https://openrouter.ai';
  static const _timeoutSeconds = 25;

  static const _apiKey = AppConfig.openRouterApiKey;
  static const _primaryModel = AppConfig.openRouterModel;
  static const _fallbackModel = AppConfig.openRouterFallbackModel;

  String? get _languageInstruction {
    if (!Get.isRegistered<LanguageController>()) return null;
    final lang = Get.find<LanguageController>();
    if (!lang.isUrdu) return null;
    return 'Respond entirely in Urdu (simple, clear, suitable for a mental health context).';
  }

  Future<Map<String, dynamic>> _callOpenRouter(String prompt) async {
    final uri = '$_openRouterBaseUrl/api/v1/chat/completions';
    if (_apiKey.isEmpty) {
      throw StateError('OpenRouter API key is not configured in AppConfig.');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final systemMessage =
        'You are a helpful mental wellness assistant. '
        'Always respond with valid JSON only. '
        'No markdown formatting, no code fences, no extra text. '
        'Output exactly one valid JSON object and nothing else.';

    Map<String, dynamic> payload(String model) => <String, dynamic>{
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemMessage},
        {'role': 'user', 'content': prompt},
      ],
      'response_format': {'type': 'json_object'},
      'temperature': 0.2,
      'max_tokens': 300,
    };

    Future<Response> post(String model) => _client
        .post(uri, payload(model), headers: headers)
        .timeout(const Duration(seconds: _timeoutSeconds));

    late Response response;
    String usedModel = _primaryModel;

    try {
      response = await post(usedModel);
    } catch (e) {
      throw StateError('OpenRouter request failed: ${e.runtimeType} — $e');
    }

    if (response.statusCode == 429) {
      usedModel = _fallbackModel;
      try {
        response = await post(usedModel);
      } catch (e) {
        throw StateError('OpenRouter rate limited. Fallback also failed: ${e.runtimeType} — $e');
      }
    }

    if (response.statusCode == null) {
      throw StateError('OpenRouter returned no status code. Response body: ${(response.body ?? '').toString().substring(0, 200)}');
    }

    if (!response.isOk) {
      final status = response.statusCode;
      final detail = (response.statusText ?? '').trim();
      if (detail.contains('Insufficient credits') || detail.contains('insufficient_quota')) {
        throw StateError(
          'OpenRouter API credits exhausted. '
          'Please add credits to your OpenRouter account.',
        );
      }
      if (detail.contains('rate_limit') || status == 429) {
        throw StateError(
          'OpenRouter rate limit reached. Please wait a moment and try again.',
        );
      }
      if (status == 401 || status == 403) {
        throw StateError(
          'Invalid OpenRouter API key. '
          'Check that OPENROUTER_API_KEY is correct.',
        );
      }
      throw StateError(
        detail.isNotEmpty
            ? 'OpenRouter request failed ($status): $detail'
            : 'OpenRouter request failed ($status)',
      );
    }

    final body = response.body;
    final map = body is Map<String, dynamic>
        ? body
        : (body is String ? jsonDecode(body) as Map<String, dynamic> : null);
    if (map == null) {
      throw StateError('Invalid OpenRouter response format');
    }

    final choices = map['choices'];
    if (choices is! List || choices.isEmpty) {
      final error = map['error'];
      if (error is Map<String, dynamic>) {
        final msg = (error['message'] ?? '').toString();
        throw StateError('OpenRouter API error: $msg');
      }
      throw StateError('OpenRouter response missing choices');
    }

    final firstChoice = choices[0];
    if (firstChoice is! Map<String, dynamic>) {
      throw StateError('OpenRouter response missing message');
    }

    final msg = firstChoice['message'];
    if (msg is! Map<String, dynamic>) {
      throw StateError('OpenRouter response missing message content');
    }

    final content = (msg['content'] ?? '').toString().trim();
    if (content.isEmpty) {
      if (usedModel != _fallbackModel) {
        try {
          response = await post(_fallbackModel);
        } catch (_) {
          throw StateError('OpenRouter returned empty content');
        }
        final retryBody = response.body;
        final retryMap = retryBody is Map<String, dynamic>
            ? retryBody
            : (retryBody is String ? jsonDecode(retryBody) as Map<String, dynamic> : null);
        final retryChoices = retryMap?['choices'];
        if (retryChoices is List && retryChoices.isNotEmpty) {
          final retryMsg = retryChoices[0];
          if (retryMsg is Map<String, dynamic>) {
            final retryContent = ((retryMsg['message'] as Map<String, dynamic>?)?['content'] ?? '').toString().trim();
            if (retryContent.isNotEmpty) {
              final json = _extractJson(retryContent);
              if (json != null) return json;
            }
          }
        }
      }
      throw StateError('OpenRouter returned empty content');
    }

    final json = _extractJson(content);
    if (json == null) {
      if (usedModel != _fallbackModel) {
        try {
          response = await post(_fallbackModel);
        } catch (_) {
          throw StateError('Could not parse JSON from LLM response');
        }
        final retryBody = response.body;
        final retryMap = retryBody is Map<String, dynamic>
            ? retryBody
            : (retryBody is String ? jsonDecode(retryBody) as Map<String, dynamic> : null);
        final retryChoices = retryMap?['choices'];
        if (retryChoices is List && retryChoices.isNotEmpty) {
          final retryMsg = retryChoices[0] as Map<String, dynamic>?;
          final retryContent = ((retryMsg?['message'] as Map<String, dynamic>?)?['content'] ?? '').toString().trim();
          if (retryContent.isNotEmpty) {
            final retryJson = _extractJson(retryContent);
            if (retryJson != null) return retryJson;
          }
        }
      }
      throw StateError('Could not parse JSON from LLM response');
    }

    return json;
  }

  Map<String, dynamic>? _extractJson(String text) {
    text = text.trim();
    if (text.startsWith('```')) {
      text = text.replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '').replaceAll(RegExp(r'\n?```$'), '').trim();
    }
    int? start;
    var depth = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '{') {
        start ??= i;
        depth++;
      } else if (text[i] == '}') {
        depth--;
        if (depth == 0 && start != null) {
          try {
            return jsonDecode(text.substring(start, i + 1)) as Map<String, dynamic>;
          } catch (_) {
            return null;
          }
        }
      }
    }
    return null;
  }

  Future<MoodAnalysisResult> analyzeMood({
    required String moodText,
    required double moodScore,
    required String moodLabel,
    List<Map<String, dynamic>> history = const [],
  }) async {
    final prompt = _buildMoodAnalyzePrompt(
      moodText: moodText,
      moodScore: moodScore,
      moodLabel: moodLabel,
      history: history,
    );
    final lang = _languageInstruction;
    final effectivePrompt = lang != null ? '$prompt\n\n$lang' : prompt;

    final map = await _callOpenRouter(effectivePrompt);

    final sentiment = (map['sentiment'] ?? '').toString().trim();
    final emotion = (map['emotion'] ?? '').toString().trim();
    final insight = (map['insight'] ?? '').toString().trim();
    final progression = (map['progression'] ?? '').toString().trim();

    if (sentiment.isEmpty || emotion.isEmpty || insight.isEmpty || progression.isEmpty) {
      throw StateError('LLM response missing required fields');
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
    final prompt = _buildJournalInsightPrompt(entry: entry, history: history);
    final lang = _languageInstruction;
    final effectivePrompt = lang != null ? '$prompt\n\n$lang' : prompt;

    final map = await _callOpenRouter(effectivePrompt);

    final reflection = (map['reflection'] ?? '').toString().trim();
    final suggestion = (map['suggestion'] ?? '').toString().trim();
    final nextStep = (map['nextStep'] ?? '').toString().trim();

    if (reflection.isEmpty || suggestion.isEmpty || nextStep.isEmpty) {
      throw StateError('LLM response missing required fields');
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
    final prompt = _buildJournalAnalyzePrompt(text: text, history: history);
    final lang = _languageInstruction;
    final effectivePrompt = lang != null ? '$prompt\n\n$lang' : prompt;

    final map = await _callOpenRouter(effectivePrompt);

    final sentiment = (map['sentiment'] ?? '').toString().trim();
    final emotion = (map['emotion'] ?? '').toString().trim();
    final insight = (map['insight'] ?? '').toString().trim();
    final rawTags = map['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
        : <String>[];

    if (sentiment.isEmpty || emotion.isEmpty || insight.isEmpty) {
      throw StateError('LLM response missing required fields');
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
    final prompt = _buildDeepInsightPrompt(entry: entry, history: history);
    final lang = _languageInstruction;
    final effectivePrompt = lang != null ? '$prompt\n\n$lang' : prompt;

    final map = await _callOpenRouter(effectivePrompt);

    final reflection = (map['reflection'] ?? '').toString().trim();
    final suggestion = (map['suggestion'] ?? '').toString().trim();
    final nextStep = (map['nextStep'] ?? '').toString().trim();

    if (reflection.isEmpty || suggestion.isEmpty || nextStep.isEmpty) {
      throw StateError('LLM response missing required fields');
    }

    return JournalInsightResult(
      reflection: reflection,
      suggestion: suggestion,
      nextStep: nextStep,
    );
  }

  String _buildMoodAnalyzePrompt({
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
                final shortText = text.length > 140 ? '${text.substring(0, 140)}…' : text;
                return '- $ts | label: $label | score: $score | $sentiment | $emotion | insight: "$insight" | text: "$shortText"';
              })
              .join('\n');

    return '''
Analyze the user's mood check-in and produce a concise JSON object.

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

  String _buildJournalAnalyzePrompt({
    required String text,
    required List<Map<String, dynamic>> history,
  }) {
    final historyText = history.isEmpty
        ? 'No previous entries.'
        : history
              .take(8)
              .map((item) {
                final ts = (item['createdAt'] ?? '').toString().trim();
                final emotion = (item['emotion'] ?? '').toString().trim();
                final sentiment = (item['sentiment'] ?? '').toString().trim();
                final insight = (item['insight'] ?? '').toString().trim();
                final rawTags = item['tags'];
                final tags = rawTags is List ? rawTags.take(6).join(', ') : '';
                return '- $ts | $sentiment | $emotion | tags: [$tags] | insight: "$insight"';
              })
              .join('\n');

    return '''
Analyze the following journal entry.

Journal entry:
"""$text"""

Previous patterns (optional context):
$historyText

Return ONLY valid JSON:
{
  "sentiment": "positive|neutral|negative",
  "emotion": "calm|stress|anxiety|joy",
  "insight": "short supportive reflection",
  "tags": ["overthinking", "growth"]
}

Rules:
- Be supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
''';
  }

  String _buildJournalInsightPrompt({
    required Map<String, dynamic> entry,
    required List<Map<String, dynamic>> history,
  }) {
    final timestamp = (entry['timestamp'] ?? '').toString().trim();
    final moodLabel = (entry['moodLabel'] ?? '').toString().trim();
    final moodScore = entry['moodScore'];
    final moodText = (entry['moodText'] ?? '').toString().trim();

    final historyText = history.isEmpty
        ? 'No previous assessments.'
        : history
              .take(12)
              .map((item) {
                final ts = (item['timestamp'] ?? '').toString().trim();
                final score = item['moodScore']?.toString() ?? '';
                final label = (item['moodLabel'] ?? '').toString().trim();
                final sentiment = (item['sentiment'] ?? '').toString().trim();
                final emotion = (item['emotion'] ?? '').toString().trim();
                final insight = (item['insight'] ?? '').toString().trim();
                final text = (item['moodText'] ?? '').toString().trim();
                final shortText = text.length > 140 ? '${text.substring(0, 140)}…' : text;
                return '- $ts | label: $label | score: $score | $sentiment | $emotion | insight: "$insight" | text: "$shortText"';
              })
              .join('\n');

    return '''
Provide AI-based insights for a single journal entry while considering the user's prior mood patterns.

Journal entry (focus on this entry):
- timestamp: "$timestamp"
- moodLabel: "$moodLabel"
- moodScore (0-10): $moodScore
- moodText: "$moodText"

Previous mood context (most recent first):
$historyText

Return ONLY valid JSON with exactly these keys:
{
  "reflection": "A personalized reflection referencing this journal entry and the user's trend (2-4 sentences).",
  "suggestion": "One personalized suggestion based on the emotional trend (1-2 sentences).",
  "nextStep": "One concrete next step (e.g., breathing tip, mindful exercise) written as a short instruction."
}

Rules:
- Be supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
''';
  }

  String _buildDeepInsightPrompt({
    required Map<String, dynamic> entry,
    required List<Map<String, dynamic>> history,
  }) {
    final text = (entry['text'] ?? '').toString().trim();
    final emotion = (entry['emotion'] ?? '').toString().trim();
    final sentiment = (entry['sentiment'] ?? '').toString().trim();
    final rawTags = entry['tags'];
    final tagText = rawTags is List ? rawTags.take(8).join(', ') : '';
    final createdAt = (entry['createdAt'] ?? '').toString().trim();

    final historyText = history.isEmpty
        ? 'No previous entries.'
        : history
              .take(10)
              .map((item) {
                final ts = (item['createdAt'] ?? '').toString().trim();
                final e = (item['emotion'] ?? '').toString().trim();
                final s = (item['sentiment'] ?? '').toString().trim();
                final i = (item['insight'] ?? '').toString().trim();
                final tgs = item['tags'];
                final ttxt = tgs is List ? tgs.take(6).join(', ') : '';
                return '- $ts | $s | $e | tags: [$ttxt] | insight: "$i"';
              })
              .join('\n');

    return '''
Provide AI-based insights for a single journal entry while considering the user's previous journaling patterns.

Journal entry (focus on this entry):
- createdAt: "$createdAt"
- sentiment: "$sentiment"
- emotion: "$emotion"
- tags: [$tagText]
- text: "$text"

Previous journal context (most recent first):
$historyText

Return ONLY valid JSON with exactly these keys:
{
  "reflection": "A personalized reflection referencing this journal entry and the user's trend (2-4 sentences).",
  "suggestion": "One personalized suggestion based on the emotional trend (1-2 sentences).",
  "nextStep": "One concrete next step (e.g., breathing tip, mindful exercise) written as a short instruction."
}

Rules:
- Be supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
''';
  }
}
