import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/models/mood_record.dart';
import 'package:mindpath/core/services/llm_service.dart';
import 'package:mindpath/core/services/mood_service.dart';

class JournalEntryDetailController extends BaseController {
  JournalEntryDetailController({
    MoodService? moodService,
    LlmService? llmService,
  }) : _moodService = moodService ?? MoodService(),
       _llmService = llmService ?? LlmService();

  final MoodService _moodService;
  final LlmService _llmService;

  final record = Rxn<MoodRecord>();

  final isEditing = false.obs;
  final autoOpenInsight = false.obs;
  final _autoInsightOpened = false.obs;
  final moodTextController = TextEditingController();
  final moodScore = 5.0.obs;
  final moodLabel = ''.obs;

  static const moodLabelOptions = <String>[
    'grateful',
    'neutral',
    'pensive',
    'down',
    'tense',
  ];

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    MoodRecord? r;
    if (arg is MoodRecord) {
      r = arg;
    } else if (arg is Map) {
      final rawRecord = arg['record'];
      if (rawRecord is MoodRecord) {
        r = rawRecord;
      }
      autoOpenInsight.value = arg['openInsight'] == true;
    }

    if (r != null) {
      record.value = r;
      moodTextController.text = r.moodText;
      moodScore.value = r.moodScore;
      moodLabel.value = r.moodLabel.isEmpty ? 'neutral' : r.moodLabel;
    }
  }

  bool consumeAutoOpenInsight() {
    if (!autoOpenInsight.value) return false;
    if (_autoInsightOpened.value) return false;
    _autoInsightOpened.value = true;
    return true;
  }

  void startEdit() {
    final r = record.value;
    if (r == null) return;
    isEditing.value = true;
    moodTextController.text = r.moodText;
    moodScore.value = r.moodScore;
    moodLabel.value = r.moodLabel.isEmpty ? 'neutral' : r.moodLabel;
  }

  void cancelEdit() {
    isEditing.value = false;
    setError(null);
  }

  Future<void> saveEdit() async {
    final r = record.value;
    if (r == null) return;

    final text = moodTextController.text.trim();
    if (text.isEmpty) {
      setError('entry_missing_text_body'.tr);
      Get.snackbar('entry_missing_text_title'.tr, 'entry_missing_text_body'.tr);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      final historyRecords = await _moodService.getLatestRecords(
        userId: r.userId,
        limit: 20,
      );
      final history = historyRecords
          .where((x) => x.id != r.id)
          .map(
            (x) => <String, dynamic>{
              'timestamp': x.timestamp?.toDate().toIso8601String() ?? '',
              'moodLabel': x.moodLabel,
              'moodText': x.moodText,
              'moodScore': x.moodScore,
              'sentiment': x.sentiment,
              'emotion': x.emotion,
              'insight': x.insight,
            },
          )
          .toList(growable: false);

      final analysis = await _llmService.analyzeMood(
        moodText: text,
        moodScore: moodScore.value,
        moodLabel: moodLabel.value,
        history: history,
      );

      final updated = MoodRecord(
        id: r.id,
        userId: r.userId,
        timestamp: r.timestamp,
        moodLabel: moodLabel.value,
        moodText: text,
        moodScore: moodScore.value,
        sentiment: analysis.sentiment,
        emotion: analysis.emotion,
        insight: analysis.insight,
      );

      await _moodService.updateMoodRecord(updated);
      record.value = updated;
      isEditing.value = false;
    } catch (e) {
      final message = e is StateError
          ? e.message
          : 'entry_update_failed_body'.tr;
      setError(message);
      Get.snackbar('entry_update_failed_title'.tr, message);
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteEntry() async {
    final r = record.value;
    if (r == null) return;

    try {
      setLoading(true);
      setError(null);
      await _moodService.deleteMoodRecord(recordId: r.id);
      Get.back();
    } catch (_) {
      setError('entry_delete_failed_body'.tr);
      Get.snackbar(
        'entry_delete_failed_title'.tr,
        'entry_delete_failed_body'.tr,
      );
    } finally {
      setLoading(false);
    }
  }

  Future<JournalInsightResult> fetchInsight() async {
    final r = record.value;
    if (r == null) {
      throw StateError('entry_missing_entry'.tr);
    }

    final historyRecords = await _moodService.getLatestRecords(
      userId: r.userId,
      limit: 20,
    );
    final history = historyRecords
        .where((x) => x.id != r.id)
        .map(
          (x) => <String, dynamic>{
            'timestamp': x.timestamp?.toDate().toIso8601String() ?? '',
            'moodLabel': x.moodLabel,
            'moodText': x.moodText,
            'moodScore': x.moodScore,
            'sentiment': x.sentiment,
            'emotion': x.emotion,
            'insight': x.insight,
          },
        )
        .toList(growable: false);

    final entry = <String, dynamic>{
      'timestamp': r.timestamp?.toDate().toIso8601String() ?? '',
      'moodLabel': r.moodLabel,
      'moodText': r.moodText,
      'moodScore': r.moodScore,
      'sentiment': r.sentiment,
      'emotion': r.emotion,
      'insight': r.insight,
    };

    return _llmService.journalInsight(entry: entry, history: history);
  }

  @override
  void onClose() {
    moodTextController.dispose();
    super.onClose();
  }
}
