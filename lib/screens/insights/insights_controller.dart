import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/models/mood_record.dart';
import 'package:mindpath/core/services/llm_service.dart';
import 'package:mindpath/core/services/mood_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum InsightsPeriod { weekly, monthly }

class InsightsController extends BaseController {
  InsightsController({MoodService? moodService, LlmService? llmService})
    : _moodService = moodService ?? MoodService(),
      _llmService = llmService ?? LlmService();

  final MoodService _moodService;
  final LlmService _llmService;

  final insightsPeriod = InsightsPeriod.weekly.obs;

  final chartPoints = <double>[].obs;
  final stability = 0.0.obs;
  final averageScore = 0.0.obs;

  final records = <MoodRecord>[].obs;
  final showAllHistory = false.obs;

  StreamSubscription<List<MoodRecord>>? _sub;
  bool _nudgeShown = false;

  String get title => 'insights_title'.tr;

  String get brand => 'insights_brand'.tr;

  String get averageMoodLabel {
    switch (insightsPeriod.value) {
      case InsightsPeriod.weekly:
        return 'insights_avg_week'.tr;
      case InsightsPeriod.monthly:
        return 'insights_avg_month'.tr;
    }
  }

  String get averageMoodValue {
    final v = averageScore.value;
    if (v >= 0.75) return 'insights_value_joy_light'.tr;
    if (v >= 0.58) return 'insights_value_calm_steady'.tr;
    if (v >= 0.42) return 'insights_value_neutral_okay'.tr;
    return 'insights_value_low_heavy'.tr;
  }

  double get stabilityValue => stability.value;

  List<MoodRecord> get journalHistory {
    final sorted = [...records];
    sorted.sort((a, b) {
      final at = a.timestamp?.toDate();
      final bt = b.timestamp?.toDate();
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    if (showAllHistory.value) return sorted;
    return sorted.take(6).toList(growable: false);
  }

  void setPeriod(InsightsPeriod value) {
    insightsPeriod.value = value;
    _recompute();
  }

  void toggleHistoryViewAll() {
    showAllHistory.value = !showAllHistory.value;
  }

  @override
  void onInit() {
    super.onInit();

    final userController = Get.find<UserController>();
    final uid = userController.userId;
    if (uid == null) return;

    _sub = _moodService.watchLatestRecords(userId: uid, limit: 250).listen((
      list,
    ) {
      records.assignAll(list);
      _recompute();
      _maybeNudge();
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<JournalInsightResult> fetchJournalInsight(MoodRecord record) async {
    final history = records
        .where((r) => r.id != record.id)
        .take(20)
        .map(
          (r) => <String, dynamic>{
            'timestamp': r.timestamp?.toDate().toIso8601String() ?? '',
            'moodLabel': r.moodLabel,
            'moodText': r.moodText,
            'moodScore': r.moodScore,
            'sentiment': r.sentiment,
            'emotion': r.emotion,
            'insight': r.insight,
          },
        )
        .toList(growable: false);

    final entry = <String, dynamic>{
      'timestamp': record.timestamp?.toDate().toIso8601String() ?? '',
      'moodLabel': record.moodLabel,
      'moodText': record.moodText,
      'moodScore': record.moodScore,
      'sentiment': record.sentiment,
      'emotion': record.emotion,
      'insight': record.insight,
    };

    return _llmService.journalInsight(entry: entry, history: history);
  }

  Future<void> deleteRecord(MoodRecord record) async {
    await _moodService.deleteMoodRecord(recordId: record.id);
  }

  Future<void> exportCurrentPeriodPdf() async {
    final now = DateTime.now();
    final days = insightsPeriod.value == InsightsPeriod.weekly ? 7 : 30;
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));

    final filtered = records
        .where((r) {
          final ts = r.timestamp?.toDate();
          if (ts == null) return false;
          return !ts.isBefore(start);
        })
        .toList(growable: false);

    final periodLabel = insightsPeriod.value == InsightsPeriod.weekly
        ? 'Weekly'
        : 'Monthly';
    final scorePct = (averageScore.value * 100).round();
    final stabilityPct = (stability.value * 100).round();

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text(
            'MindPath $periodLabel Mood Summary',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Timeframe: ${start.toIso8601String()} → ${now.toIso8601String()}',
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Average mood: $scorePct% (${averageMoodValue.replaceAll('\n', ' ')})',
          ),
          pw.Text('Stability: $stabilityPct%'),
          pw.SizedBox(height: 14),
          pw.Text(
            'Recent entries',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (filtered.isEmpty)
            pw.Text('No mood check-ins in this timeframe.')
          else
            ...filtered.take(12).map((r) {
              final ts = r.timestamp?.toDate().toIso8601String() ?? '';
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$ts • ${r.moodLabel.toUpperCase()} • score: ${r.moodScore.toStringAsFixed(1)}',
                    ),
                    pw.Text(
                      'sentiment: ${r.sentiment} • emotion: ${r.emotion}',
                    ),
                    pw.Text('insight: ${r.insight}'),
                  ],
                ),
              );
            }),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'mindpath_${periodLabel.toLowerCase()}_summary.pdf',
    );
  }

  void exploreInsights() {
    Get.snackbar(
      'insights_tip_title'.tr,
      'insights_tip_body'.tr,
    );
  }

  void _maybeNudge() {
    if (_nudgeShown) return;
    final ts = records.isNotEmpty ? records.first.timestamp?.toDate() : null;
    if (ts == null) return;

    final diff = DateTime.now().difference(ts);
    if (diff.inHours >= 36) {
      _nudgeShown = true;
      Get.snackbar(
        'insights_checkin_nudge_title'.tr,
        'insights_checkin_nudge_body'.tr,
      );
    }
  }

  void _recompute() {
    final now = DateTime.now();
    final days = insightsPeriod.value == InsightsPeriod.weekly ? 7 : 30;
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));

    final filtered = records
        .where((r) {
          final ts = r.timestamp?.toDate();
          if (ts == null) return false;
          return !ts.isBefore(start);
        })
        .toList(growable: false);

    final byDay = <String, List<double>>{};
    for (final r in filtered) {
      final ts = r.timestamp?.toDate();
      if (ts == null) continue;
      final key = _dayKey(ts);
      (byDay[key] ??= <double>[]).add(_normalize(r.moodScore));
    }

    final points = <double>[];
    double? last;
    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = _dayKey(date);
      final vals = byDay[key];
      if (vals != null && vals.isNotEmpty) {
        final avg = vals.reduce((a, b) => a + b) / vals.length;
        points.add(avg);
        last = avg;
      } else {
        points.add(last ?? 0.5);
      }
    }

    chartPoints.assignAll(points);

    if (points.isEmpty) {
      averageScore.value = 0;
      stability.value = 0;
      return;
    }

    final mean = points.reduce((a, b) => a + b) / points.length;
    averageScore.value = mean;

    if (points.length < 2) {
      stability.value = 0;
      return;
    }

    var sumSq = 0.0;
    for (final v in points) {
      final d = v - mean;
      sumSq += d * d;
    }
    final stdDev = sqrt(sumSq / points.length);
    final normalizedStd = (stdDev / 0.35).clamp(0.0, 1.0);
    stability.value = (1 - normalizedStd).clamp(0.0, 1.0);
  }

  String _dayKey(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  double _normalize(double score) => (score / 10).clamp(0.0, 1.0);
}
