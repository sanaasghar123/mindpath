import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/models/journal_entry.dart';
import 'package:mindpath/core/services/journal_service.dart';
import 'package:mindpath/core/services/llm_service.dart';
import 'package:mindpath/core/services/speech_service.dart';

class JournalInputController extends BaseController {
  JournalInputController({
    JournalService? journalService,
    LlmService? llmService,
  }) : _journalService = journalService ?? JournalService(),
       _llmService = llmService ?? LlmService();

  final JournalService _journalService;
  final LlmService _llmService;

  final prompt = ''.obs;
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map) {
      final p = arg['prompt'];
      if (p is String && p.trim().isNotEmpty) {
        prompt.value = p.trim();
      }
    }
    if (prompt.value.isEmpty) {
      prompt.value = 'journal_default_prompt'.tr;
    }
  }

  Future<void> submit() async {
    final text = textController.text.trim();
    if (text.isEmpty) {
      setError('journal_write_something_first'.tr);
      Get.snackbar('journal_empty_title'.tr, 'journal_empty_body'.tr);
      return;
    }

    final uid = Get.find<UserController>().userId;
    if (uid == null) return;

    try {
      setLoading(true);
      setError(null);

      final historyEntries = await _journalService.getLatestJournals(
        userId: uid,
        limit: 8,
      );
      final history = historyEntries
          .map(
            (e) => <String, dynamic>{
              'createdAt': e.createdAt?.toDate().toIso8601String() ?? '',
              'sentiment': e.sentiment,
              'emotion': e.emotion,
              'insight': e.insight,
              'tags': e.tags,
            },
          )
          .toList(growable: false);

      final analysis = await _llmService.analyzeJournal(
        text: text,
        history: history,
      );

      final entry = JournalEntry(
        id: '',
        userId: uid,
        text: text,
        sentiment: analysis.sentiment,
        emotion: analysis.emotion,
        insight: analysis.insight,
        tags: analysis.tags,
        activityType: 'journal',
        createdAt: null,
        title: _defaultTitleFromNow(),
      );

      await _journalService.createJournal(entry);
      Get.back();
      Get.snackbar('journal_saved_title'.tr, 'journal_saved_body'.tr);
    } catch (e) {
      final message = e is StateError ? e.message : 'journal_save_failed'.tr;
      setError(message);
      Get.snackbar('journal_save_failed'.tr, message);
    } finally {
      setLoading(false);
    }
  }

  String _defaultTitleFromNow() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'journal_morning_reflection'.tr;
    if (hour < 18) return 'journal_afternoon_reflection'.tr;
    return 'journal_evening_reflection'.tr;
  }

  @override
  void onClose() {
    if (Get.isRegistered<SpeechService>()) {
      Get.find<SpeechService>().stopListening();
    }
    textController.dispose();
    super.onClose();
  }
}
