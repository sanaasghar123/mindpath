import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/models/journal_entry.dart';
import 'package:mindpath/core/services/journal_service.dart';
import 'package:mindpath/core/services/llm_service.dart';

class JournalDetailController extends BaseController {
  JournalDetailController({
    JournalService? journalService,
    LlmService? llmService,
  }) : _journalService = journalService ?? JournalService(),
       _llmService = llmService ?? LlmService();

  final JournalService _journalService;
  final LlmService _llmService;

  final entry = Rxn<JournalEntry>();
  final isEditing = false.obs;
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is JournalEntry) {
      entry.value = arg;
      textController.text = arg.text;
    }
  }

  void startEdit() {
    final e = entry.value;
    if (e == null) return;
    isEditing.value = true;
    textController.text = e.text;
    setError(null);
  }

  void cancelEdit() {
    isEditing.value = false;
    setError(null);
  }

  Future<void> saveEdit() async {
    final e = entry.value;
    if (e == null) return;
    final text = textController.text.trim();
    if (text.isEmpty) {
      setError('journal_write_something_first'.tr);
      Get.snackbar('journal_empty_title'.tr, 'journal_empty_body'.tr);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      final historyEntries = await _journalService.getLatestJournals(
        userId: e.userId,
        limit: 10,
      );
      final history = historyEntries
          .where((x) => x.id != e.id)
          .map(
            (x) => <String, dynamic>{
              'createdAt': x.createdAt?.toDate().toIso8601String() ?? '',
              'sentiment': x.sentiment,
              'emotion': x.emotion,
              'insight': x.insight,
              'tags': x.tags,
            },
          )
          .toList(growable: false);

      final analysis = await _llmService.analyzeJournal(
        text: text,
        history: history,
      );
      final updated = JournalEntry(
        id: e.id,
        userId: e.userId,
        text: text,
        sentiment: analysis.sentiment,
        emotion: analysis.emotion,
        insight: analysis.insight,
        tags: analysis.tags,
        activityType: e.activityType,
        createdAt: e.createdAt,
        title: e.title,
      );

      await _journalService.updateJournal(updated);
      entry.value = updated;
      isEditing.value = false;
      Get.snackbar('journal_updated_title'.tr, 'journal_updated_body'.tr);
    } catch (err) {
      final message = err is StateError
          ? err.message
          : 'journal_update_failed'.tr;
      setError(message);
      Get.snackbar('journal_update_failed'.tr, message);
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteEntry() async {
    final e = entry.value;
    if (e == null) return;
    try {
      setLoading(true);
      setError(null);
      await _journalService.deleteJournal(journalId: e.id);
      Get.back();
      Get.snackbar('journal_deleted_title'.tr, 'journal_deleted_body'.tr);
    } catch (_) {
      Get.snackbar('journal_delete_failed'.tr, 'journal_delete_failed'.tr);
    } finally {
      setLoading(false);
    }
  }

  Future<JournalInsightResult> fetchDeepInsight() async {
    final e = entry.value;
    if (e == null) throw StateError('journal_detail_entry_not_found'.tr);

    final historyEntries = await _journalService.getLatestJournals(
      userId: e.userId,
      limit: 12,
    );
    final history = historyEntries
        .where((x) => x.id != e.id)
        .map(
          (x) => <String, dynamic>{
            'createdAt': x.createdAt?.toDate().toIso8601String() ?? '',
            'sentiment': x.sentiment,
            'emotion': x.emotion,
            'insight': x.insight,
            'tags': x.tags,
          },
        )
        .toList(growable: false);

    final entryPayload = <String, dynamic>{
      'createdAt': e.createdAt?.toDate().toIso8601String() ?? '',
      'text': e.text,
      'sentiment': e.sentiment,
      'emotion': e.emotion,
      'insight': e.insight,
      'tags': e.tags,
    };

    return _llmService.journalDeepInsight(
      entry: entryPayload,
      history: history,
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
