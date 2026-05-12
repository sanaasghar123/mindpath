import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/models/journal_entry.dart';
import 'package:mindpath/core/services/journal_service.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';

class JournalActivity {
  const JournalActivity({
    required this.titleKey,
    required this.descriptionKey,
    required this.activityType,
    this.durationSeconds,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    required this.buttonColor,
  });

  final String titleKey;
  final String descriptionKey;
  final String activityType;
  final int? durationSeconds;
  final IconData icon;
  final int iconBackgroundColor;
  final int iconForegroundColor;
  final int buttonColor;
}

class JournalController extends BaseController {
  JournalController({JournalService? journalService})
    : _journalService = journalService ?? JournalService();

  final JournalService _journalService;

  final journals = <JournalEntry>[].obs;
  final showAllHistory = false.obs;

  final aiGuideText = ''.obs;
  final aiGuideLabel = ''.obs;

  StreamSubscription<List<JournalEntry>>? _sub;

  final journalActivities = <JournalActivity>[
    const JournalActivity(
      titleKey: 'journal_activity_breathing_title',
      descriptionKey: 'journal_activity_breathing_desc',
      activityType: 'breathing',
      durationSeconds: 300,
      icon: Icons.air_rounded,
      iconBackgroundColor: 0xFFEAF1FF,
      iconForegroundColor: 0xFF2563EB,
      buttonColor: 0xFF1E5B49,
    ),
    const JournalActivity(
      titleKey: 'journal_activity_prompt_title',
      descriptionKey: 'journal_activity_prompt_desc',
      activityType: 'journal',
      icon: Icons.edit_note_rounded,
      iconBackgroundColor: 0xFFF3E8FF,
      iconForegroundColor: 0xFF7C3AED,
      buttonColor: 0xFF6D5A86,
    ),
    const JournalActivity(
      titleKey: 'journal_activity_walk_title',
      descriptionKey: 'journal_activity_walk_desc',
      activityType: 'walk',
      durationSeconds: 600,
      icon: Icons.directions_walk_rounded,
      iconBackgroundColor: 0xFFE8F3FF,
      iconForegroundColor: 0xFF2563EB,
      buttonColor: 0xFF1E5B49,
    ),
  ];

  String get brand => 'Sanctuary';

  List<JournalEntry> get journalHistory {
    final items = journals.toList(growable: false);
    if (showAllHistory.value) return items;
    return items.take(8).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    final uid = Get.find<UserController>().userId;
    if (uid == null) return;
    _sub = _journalService
        .watchJournals(userId: uid)
        .listen(
          (list) {
            journals.assignAll(list);
            _updateAiGuide(list);
          },
          onError: (error) {
            journals.clear();
            _updateAiGuide(const []);
            setError(error.toString());
          },
        );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void toggleHistoryViewAll() {
    showAllHistory.value = !showAllHistory.value;
  }

  void openSettings() {
    Get.find<DashboardController>().setTab(3);
  }

  void startActivity(JournalActivity activity) {
    if (activity.activityType == 'journal') {
      Get.toNamed(
        AppRoutes.journalInput,
        arguments: {'prompt': activity.descriptionKey.tr},
      );
      return;
    }
    Get.toNamed(
      AppRoutes.activityTimer,
      arguments: {
        'title': activity.titleKey.tr,
        'activityType': activity.activityType,
        'durationSeconds': activity.durationSeconds ?? 300,
      },
    );
  }

  void openJournalDetail(JournalEntry entry) {
    Get.toNamed(AppRoutes.journalDetail, arguments: entry);
  }

  void _updateAiGuide(List<JournalEntry> list) {
    if (list.isEmpty) {
      aiGuideText.value = 'journal_ai_guide_empty_text'.tr;
      aiGuideLabel.value = 'journal_ai_guide'.tr;
      return;
    }
    final latest = list.first;
    aiGuideText.value = latest.insight.isEmpty
        ? 'journal_ai_guide_keep_checking'.tr
        : latest.insight;
    aiGuideLabel.value = 'journal_latest_insight'.tr;
  }
}
