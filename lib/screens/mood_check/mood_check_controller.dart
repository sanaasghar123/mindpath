import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/models/mood_record.dart';
import 'package:mindpath/core/services/llm_service.dart';
import 'package:mindpath/core/services/mood_service.dart';
import 'package:mindpath/core/services/speech_service.dart';

enum MoodOption { grateful, neutral, pensive, down, tense }

class MoodCheckController extends BaseController {
  MoodCheckController({MoodService? moodService, LlmService? llmService})
    : _moodService = moodService ?? MoodService(),
      _llmService = llmService ?? LlmService();

  final MoodService _moodService;
  final LlmService _llmService;

  final selectedMood = Rxn<MoodOption>();
  final journalController = TextEditingController();
  final currentTimeLabel = ''.obs;
  final isListening = false.obs;
  final moodScore = 5.0.obs;

  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    _updateTimeLabel();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _updateTimeLabel(),
    );
  }

  void selectMood(MoodOption mood) {
    selectedMood.value = mood;
    moodScore.value = _defaultScoreFor(mood);
    setError(null);
  }

  String get gentleReminderTitle {
    switch (selectedMood.value) {
      case MoodOption.grateful:
        return 'mood_reminder_title_grateful'.tr;
      case MoodOption.neutral:
        return 'mood_reminder_title_neutral'.tr;
      case MoodOption.pensive:
        return 'mood_reminder_title_pensive'.tr;
      case MoodOption.down:
        return 'mood_reminder_title_down'.tr;
      case MoodOption.tense:
        return 'mood_reminder_title_tense'.tr;
      case null:
        return 'mood_reminder_title_default'.tr;
    }
  }

  String get gentleReminderBody {
    switch (selectedMood.value) {
      case MoodOption.grateful:
        return 'mood_reminder_body_grateful'.tr;
      case MoodOption.neutral:
        return 'mood_reminder_body_neutral'.tr;
      case MoodOption.pensive:
        return 'mood_reminder_body_pensive'.tr;
      case MoodOption.down:
        return 'mood_reminder_body_down'.tr;
      case MoodOption.tense:
        return 'mood_reminder_body_tense'.tr;
      case null:
        return 'mood_reminder_body_default'.tr;
    }
  }

  void toggleVoiceToText() {
    isListening.value = !isListening.value;
    if (isListening.value) {
      Get.snackbar('mood_voice_to_text'.tr, 'mood_voice_unavailable'.tr);
      isListening.value = false;
    }
  }

  Future<void> analyzeMood() async {
    if (isLoading.value) return;
    final mood = selectedMood.value;
    if (mood == null) {
      setError('mood_select_mood'.tr);
      Get.snackbar('mood_select_mood'.tr, 'mood_select_mood_body'.tr);
      return;
    }

    final userController = Get.find<UserController>();
    final uid = userController.userId;
    if (uid == null) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }

    final moodText = journalController.text.trim();
    if (moodText.isEmpty) {
      setError('mood_add_note_body'.tr);
      Get.snackbar('mood_add_note_title'.tr, 'mood_add_note_body'.tr);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      final historyRecords = await _moodService.getLatestRecords(
        userId: uid,
        limit: 10,
      );
      final history = historyRecords
          .map(
            (record) => <String, dynamic>{
              'timestamp': record.timestamp?.toDate().toIso8601String() ?? '',
              'moodLabel': record.moodLabel,
              'moodText': record.moodText,
              'moodScore': record.moodScore,
              'sentiment': record.sentiment,
              'emotion': record.emotion,
              'insight': record.insight,
            },
          )
          .toList();

      final result = await _llmService.analyzeMood(
        moodText: moodText,
        moodScore: moodScore.value,
        moodLabel: mood.name,
        history: history,
      );

      final record = MoodRecord(
        id: '',
        userId: uid,
        timestamp: null,
        moodLabel: mood.name,
        moodText: moodText,
        moodScore: moodScore.value,
        sentiment: result.sentiment,
        emotion: result.emotion,
        insight: result.insight,
      );

      await _moodService.createMoodRecord(record);
      final completed =
          userController.user.value?.hasCompletedFirstMoodAnalysis ?? false;
      if (!completed) {
        await userController.updateUserProfile(
          hasCompletedFirstMoodAnalysis: true,
        );
      }

      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      final message = e is StateError
          ? e.message
          : 'mood_analysis_failed_body'.tr;
      setError(message);
      Get.snackbar('mood_analysis_failed_title'.tr, message);
    } finally {
      setLoading(false);
    }
  }

  double _defaultScoreFor(MoodOption mood) {
    switch (mood) {
      case MoodOption.grateful:
        return 8.5;
      case MoodOption.neutral:
        return 6.0;
      case MoodOption.pensive:
        return 5.0;
      case MoodOption.down:
        return 3.0;
      case MoodOption.tense:
        return 2.5;
    }
  }

  void _updateTimeLabel() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'PM' : 'AM';
    currentTimeLabel.value = '$hour:$minute $suffix';
  }

  @override
  void onClose() {
    if (Get.isRegistered<SpeechService>()) {
      Get.find<SpeechService>().stopListening();
    }
    _clockTimer?.cancel();
    journalController.dispose();
    super.onClose();
  }
}
