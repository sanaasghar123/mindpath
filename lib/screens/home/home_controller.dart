import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/models/mood_record.dart';
import 'package:mindpath/core/services/mood_service.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';

class SentimentItem {
  const SentimentItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final int color;
}

class VibrationTag {
  const VibrationTag({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final int backgroundColor;
  final int foregroundColor;
}

class HomeController extends BaseController {
  HomeController({MoodService? moodService})
    : _moodService = moodService ?? MoodService();

  final MoodService _moodService;

  final vitalityScore = 0.72.obs;
  final weeklyAverage = 0.68.obs;
  final consistencyDays = 12.obs;

  final sentiments = <SentimentItem>[].obs;

  final coreVibrations = <VibrationTag>[].obs;

  final latestRecord = Rxn<MoodRecord>();
  final recentRecords = <MoodRecord>[].obs;

  DashboardController get _dashboard => Get.find<DashboardController>();
  UserController get _userController => Get.find<UserController>();

  StreamSubscription<List<MoodRecord>>? _recordsSub;

  @override
  void onInit() {
    super.onInit();
    _setDefaults();
    _startMoodStream();
  }

  void _startMoodStream() {
    final uid = _userController.userId;
    if (uid == null) return;
    _recordsSub?.cancel();
    _recordsSub = _moodService
        .watchLatestRecords(userId: uid, limit: 60)
        .listen(
          (records) {
            recentRecords.assignAll(records);
            latestRecord.value = records.isEmpty ? null : records.first;
            _recomputeMetrics(records);
          },
          onError: (error) {
            recentRecords.clear();
            latestRecord.value = null;
            _setDefaults();
            setError(error.toString());
          },
        );
  }

  String get welcomeTitle {
    final name = _userController.user.value?.name ?? 'profile_default_user'.tr;
    return 'home_welcome_title'.trParams({'name': name});
  }

  String get welcomeSubtitle => 'home_welcome_subtitle'.tr;

  String get guidanceText {
    final name = _userController.user.value?.name ?? 'profile_default_user'.tr;
    final record = latestRecord.value;
    if (record != null && record.insight.trim().isNotEmpty) {
      return 'home_guidance_insight'.trParams(
        {'insight': record.insight.trim()},
      );
    }
    final mood = _dashboard.initialMood.value;
    if (mood == 'tense' || mood == 'down') {
      return 'home_guidance_stressed'.trParams({'name': name});
    }
    if (mood == 'pensive') {
      return 'home_guidance_thoughtful'.trParams({'name': name});
    }
    if (mood == 'grateful') {
      return 'home_guidance_grateful'.trParams({'name': name});
    }
    if (mood == 'neutral') {
      return 'home_guidance_neutral'.trParams({'name': name});
    }
    return 'home_guidance_default'.trParams({'name': name});
  }

  void startSession() {
    Get.snackbar(
      'home_start_session'.tr,
      'home_start_session_body'.tr,
    );
  }

  void openVoiceAssistant() {
    Get.snackbar(
      'home_voice_title'.tr,
      'home_voice_body'.tr,
    );
  }

  void _setDefaults() {
    sentiments.assignAll(const [
      SentimentItem(label: 'home_sentiment_positive', value: 0.60, color: 0xFF22C55E),
      SentimentItem(label: 'home_sentiment_neutral', value: 0.30, color: 0xFFF59E0B),
      SentimentItem(label: 'home_sentiment_stress', value: 0.10, color: 0xFFEF4444),
    ]);
    coreVibrations.assignAll(const [
      VibrationTag(
        label: 'home_vibe_stress',
        icon: Icons.flash_on_rounded,
        backgroundColor: 0xFFFFF1F2,
        foregroundColor: 0xFFEF4444,
      ),
      VibrationTag(
        label: 'home_vibe_slight_anxiety',
        icon: Icons.air_rounded,
        backgroundColor: 0xFFFFF7ED,
        foregroundColor: 0xFFF59E0B,
      ),
      VibrationTag(
        label: 'home_vibe_underlying_calm',
        icon: Icons.water_drop_rounded,
        backgroundColor: 0xFFEFFDF4,
        foregroundColor: 0xFF16A34A,
      ),
    ]);
  }

  void _recomputeMetrics(List<MoodRecord> records) {
    if (records.isEmpty) return;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));

    final today = <MoodRecord>[];
    final week = <MoodRecord>[];
    final daysWithRecord = <String>{};

    for (final r in records) {
      final ts = r.timestamp?.toDate();
      if (ts == null) continue;
      final dayKey = '${ts.year}-${ts.month}-${ts.day}';
      daysWithRecord.add(dayKey);
      if (!ts.isBefore(todayStart)) {
        today.add(r);
      }
      if (!ts.isBefore(weekStart)) {
        week.add(r);
      }
    }

    final todayAvg = _avgScore(today);
    final weekAvg = _avgScore(week);
    vitalityScore.value = (todayAvg / 10).clamp(0.0, 1.0);
    weeklyAverage.value = (weekAvg / 10).clamp(0.0, 1.0);
    consistencyDays.value = _streakDays(daysWithRecord, todayStart);

    final pulse = _sentimentPulse(week);
    sentiments.assignAll(pulse);

    final vibes = _topVibrations(week);
    if (vibes.isNotEmpty) coreVibrations.assignAll(vibes);
  }

  double _avgScore(List<MoodRecord> records) {
    if (records.isEmpty) return 0;
    final sum = records.fold<double>(0, (acc, r) => acc + r.moodScore);
    return sum / records.length;
  }

  int _streakDays(Set<String> daysWithRecord, DateTime todayStart) {
    var streak = 0;
    for (var i = 0; i < 365; i++) {
      final d = todayStart.subtract(Duration(days: i));
      final key = '${d.year}-${d.month}-${d.day}';
      if (!daysWithRecord.contains(key)) break;
      streak++;
    }
    return streak;
  }

  List<SentimentItem> _sentimentPulse(List<MoodRecord> records) {
    if (records.isEmpty) return sentiments.toList(growable: false);
    var positive = 0;
    var neutral = 0;
    var stress = 0;
    for (final r in records) {
      final e = r.emotion.toLowerCase();
      final s = r.sentiment.toLowerCase();
      if (s.contains('positive')) {
        positive++;
      } else if (s.contains('neutral')) {
        neutral++;
      } else if (e.contains('stress') ||
          e.contains('anxiety') ||
          e.contains('overwhelm') ||
          s.contains('negative')) {
        stress++;
      }
    }
    final total = (positive + neutral + stress).clamp(1, 1 << 30);
    return [
      SentimentItem(
        label: 'home_sentiment_positive',
        value: positive / total,
        color: 0xFF22C55E,
      ),
      SentimentItem(
        label: 'home_sentiment_neutral',
        value: neutral / total,
        color: 0xFFF59E0B,
      ),
      SentimentItem(
        label: 'home_sentiment_stress',
        value: stress / total,
        color: 0xFFEF4444,
      ),
    ];
  }

  List<VibrationTag> _topVibrations(List<MoodRecord> records) {
    final counts = <String, int>{};
    for (final r in records) {
      final e = r.emotion.trim();
      if (e.isEmpty) continue;
      counts[e] = (counts[e] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => _mapVibration(e.key)).toList();
  }

  VibrationTag _mapVibration(String emotion) {
    final key = emotion.toLowerCase();
    if (key.contains('stress')) {
      return const VibrationTag(
        label: 'home_vibe_stress',
        icon: Icons.flash_on_rounded,
        backgroundColor: 0xFFFFF1F2,
        foregroundColor: 0xFFEF4444,
      );
    }
    if (key.contains('anxiety')) {
      return const VibrationTag(
        label: 'home_vibe_slight_anxiety',
        icon: Icons.air_rounded,
        backgroundColor: 0xFFFFF7ED,
        foregroundColor: 0xFFF59E0B,
      );
    }
    if (key.contains('calm')) {
      return const VibrationTag(
        label: 'home_vibe_underlying_calm',
        icon: Icons.water_drop_rounded,
        backgroundColor: 0xFFEFFDF4,
        foregroundColor: 0xFF16A34A,
      );
    }
    if (key.contains('joy')) {
      return const VibrationTag(
        label: 'home_vibe_joy',
        icon: Icons.emoji_emotions_rounded,
        backgroundColor: 0xFFECFDF5,
        foregroundColor: 0xFF16A34A,
      );
    }
    if (key.contains('sad')) {
      return const VibrationTag(
        label: 'home_vibe_sadness',
        icon: Icons.water_drop_outlined,
        backgroundColor: 0xFFEFF6FF,
        foregroundColor: 0xFF2563EB,
      );
    }
    if (key.contains('anger')) {
      return const VibrationTag(
        label: 'home_vibe_anger',
        icon: Icons.local_fire_department_rounded,
        backgroundColor: 0xFFFFF1F2,
        foregroundColor: 0xFFEF4444,
      );
    }
    if (key.contains('fatigue')) {
      return const VibrationTag(
        label: 'home_vibe_fatigue',
        icon: Icons.bedtime_rounded,
        backgroundColor: 0xFFF5F3FF,
        foregroundColor: 0xFF7C3AED,
      );
    }
    return VibrationTag(
      label: emotion,
      icon: Icons.bubble_chart_rounded,
      backgroundColor: 0xFFF4F7FF,
      foregroundColor: 0xFF334155,
    );
  }

  @override
  void onClose() {
    _recordsSub?.cancel();
    super.onClose();
  }
}
