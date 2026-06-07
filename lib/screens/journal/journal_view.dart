import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/journal/journal_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class JournalView extends GetView<JournalController> {
  const JournalView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.dashboardBgTop, AppColors.dashboardBgBottom],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              children: [
                _AiGuideCard(controller: controller),
                const SizedBox(height: 18),
                for (final activity in controller.journalActivities) ...[
                  _ActivityCard(
                    activity: activity,
                    onStart: () => controller.startActivity(activity),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 6),
                _HistoryHeader(controller: controller),
                const SizedBox(height: 10),
                Obx(() {
                  final items = controller.journalHistory;
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'journal_empty'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.authTextSecondary.withValues(
                            alpha: 0.95,
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final entry in items) ...[
                        _JournalEntryCard(
                          title: entry.title.isEmpty
                              ? 'journal_fallback_title'.tr
                              : entry.title,
                          dateLabel: _formatDate(entry.createdAt?.toDate()),
                          preview: entry.text,
                          emotion: entry.emotion,
                          onTap: () => controller.openJournalDetail(entry),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AiGuideCard extends StatelessWidget {
  const _AiGuideCard({required this.controller});

  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                controller.aiGuideLabel.value,
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w900,
                  color: AppColors.authTextSecondary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.aiGuideText.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.authTextPrimary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onStart});

  final JournalActivity activity;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final iconBg = Color(activity.iconBackgroundColor);
    final iconFg = Color(activity.iconForegroundColor);
    final btnBg = Color(activity.buttonColor);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 14),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(activity.icon, size: 44, color: iconFg),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activity.titleKey.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              activity.descriptionKey.tr,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppColors.authTextSecondary,
              ),
            ),
            if (activity.durationSeconds != null) ...[
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    '${activity.durationSeconds! ~/ 60} min',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 40,
                width: 160,
                child: CustomButton(
                  label: 'journal_start_activity'.tr,
                  onPressed: onStart,
                  height: 40,
                  width: 160,
                  backgroundColor: btnBg,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.controller});

  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'journal_history'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.authTextPrimary,
            ),
          ),
        ),
        Obx(() {
          final label = controller.showAllHistory.value
              ? 'journal_show_less'.tr
              : 'journal_view_all'.tr;
          return TextButton(
            onPressed: controller.toggleHistoryViewAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.dashboardBrand,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          );
        }),
      ],
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({
    required this.title,
    required this.dateLabel,
    required this.preview,
    required this.emotion,
    required this.onTap,
  });

  final String title;
  final String dateLabel;
  final String preview;
  final String emotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chip = _chipColors(emotion);
    final excerpt = preview.length > 140
        ? '${preview.substring(0, 140)}…'
        : preview;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 14),
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.authTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authTextSecondary.withValues(
                              alpha: 0.95,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: chip.$1,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: chip.$2.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        emotion.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w900,
                          color: chip.$2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                excerpt,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

(Color, Color) _chipColors(String emotion) {
  final e = emotion.toLowerCase().trim();
  if (e == 'joy') return (const Color(0xFFEFFDF4), const Color(0xFF16A34A));
  if (e == 'calm') return (const Color(0xFFF1F5F9), const Color(0xFF334155));
  if (e == 'stress') return (const Color(0xFFFFF7ED), const Color(0xFFB45309));
  if (e == 'anxiety') return (const Color(0xFFFEE2E2), const Color(0xFFB91C1C));
  return (const Color(0xFFF1F6FF), AppColors.dashboardBrand);
}

String _formatDate(DateTime? dt) {
  if (dt == null) return 'common_pending'.tr;
  final y = dt.year.toString().padLeft(4, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$y-$mo-$d $h:$m';
}
