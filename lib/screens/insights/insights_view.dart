import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/models/mood_record.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';
import 'package:mindpath/screens/insights/insights_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class InsightsView extends GetView<InsightsController> {
  const InsightsView({super.key});

  void _openDrawer() {
    final dashboardController = Get.find<DashboardController>();
    dashboardController.openDrawer();
  }

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
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.authTextPrimary,
                    ),
                    onPressed: _openDrawer,
                  ),
                  title: Text(
                    'app_name'.tr,
                    style: const TextStyle(color: AppColors.authTextPrimary),
                  ),
                  centerTitle: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                  sliver: SliverList.list(
                    children: [
                      Text(
                        controller.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.authTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PeriodToggle(controller: controller),
                      const SizedBox(height: 14),
                      _QuickStatsGrid(controller: controller),
                      const SizedBox(height: 14),
                      _EmotionalLandscapeCard(controller: controller),
                      const SizedBox(height: 18),
                      _JournalHistoryHeader(controller: controller),
                      const SizedBox(height: 10),
                      Obx(() {
                        final items = controller.journalHistory;
                        if (items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'No journal history yet. Add a mood check-in to see insights here.',
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
                                entry: entry,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.journalEntryDetail,
                                    arguments: {
                                      'record': entry,
                                      'openInsight': true,
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      }),
                      const SizedBox(height: 6),
                      _WeeklyMilestoneCard(controller: controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.insightsPeriod.value;
      return Align(
        alignment: Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.04),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Chip(
                  label: 'insights_weekly'.tr,
                  isSelected: selected == InsightsPeriod.weekly,
                  onTap: () => controller.setPeriod(InsightsPeriod.weekly),
                ),
                _Chip(
                  label: 'insights_monthly'.tr,
                  isSelected: selected == InsightsPeriod.monthly,
                  onTap: () => controller.setPeriod(InsightsPeriod.monthly),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? Colors.white : Colors.transparent;
    final fg = isSelected
        ? AppColors.dashboardBrand
        : AppColors.authTextSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _EmotionalLandscapeCard extends StatelessWidget {
  const _EmotionalLandscapeCard({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            blurRadius: 26,
            offset: const Offset(0, 18),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.averageMoodLabel,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.authTextSecondary.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.averageMoodValue,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            color: AppColors.authTextPrimary,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Obx(() {
                  final percent =
                      (controller.stabilityValue.clamp(0.0, 1.0) * 100).round();
                  return _StabilityPill(percent: percent);
                }),
              ],
            ),
            const SizedBox(height: 14),
            Obx(() {
              final points = controller.chartPoints.toList(growable: false);
              return _LandscapeChart(points: points);
            }),
            const SizedBox(height: 14),
            CustomButton(
              label: 'insights_export_pdf'.tr,
              onPressed: controller.exportCurrentPeriodPdf,
              variant: CustomButtonVariant.outlined,
              prefixIcon: Icons.ios_share_rounded,
              height: 52,
              foregroundColor: AppColors.dashboardBrand,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsGrid extends StatelessWidget {
  const _QuickStatsGrid({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final avg = (controller.averageScore.value * 100).round();
      final stability = (controller.stability.value * 100).round();
      final checkins = controller.records.length;
      final label = controller.averageMoodValue;

      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _QuickStatCard(
            icon: Icons.sentiment_satisfied_rounded,
            title: 'Average Mood',
            value: '$avg%',
            subtitle: label,
          ),
          _QuickStatCard(
            icon: Icons.bar_chart_rounded,
            title: 'Stability',
            value: '$stability%',
            subtitle: 'Consistency',
          ),
          _QuickStatCard(
            icon: Icons.calendar_today_rounded,
            title: 'Check-ins',
            value: checkins.toString(),
            subtitle: 'Total entries',
          ),
          _QuickStatCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Streak',
            value: '7',
            subtitle: 'Current streak',
          ),
        ],
      );
    });
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.authTextSecondary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.authTextSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StabilityPill extends StatelessWidget {
  const _StabilityPill({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_graph_rounded,
              size: 16,
              color: AppColors.dashboardBrand.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.authTextPrimary,
                  ),
                ),
                Text(
                  'insights_stability'.tr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.authTextSecondary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LandscapeChart extends StatelessWidget {
  const _LandscapeChart({required this.points});

  final List<double> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _AxisLabel('insights_axis_joy'),
                _AxisLabel('insights_axis_calm'),
                _AxisLabel('insights_axis_neutral'),
                _AxisLabel('insights_axis_low'),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.dashboardBrand.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _LandscapeChartPainter(
                    points: points,
                    lineColor: AppColors.dashboardBrand.withValues(alpha: 0.55),
                    glowColor: AppColors.dashboardBrand.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr,
      style: TextStyle(
        fontSize: 10,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w800,
        color: AppColors.authTextSecondary.withValues(alpha: 0.85),
      ),
    );
  }
}

class _LandscapeChartPainter extends CustomPainter {
  _LandscapeChartPainter({
    required this.points,
    required this.lineColor,
    required this.glowColor,
  });

  final List<double> points;
  final Color lineColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    const padX = 10.0;
    const padY = 10.0;
    final w = size.width - padX * 2;
    final h = size.height - padY * 2;

    final normalized = points
        .map((v) => v.clamp(0.0, 1.0))
        .toList(growable: false);
    final dx = w / (normalized.length - 1);

    final pts = <Offset>[];
    for (var i = 0; i < normalized.length; i++) {
      final x = padX + dx * i;
      final y = padY + (1 - normalized[i]) * h;
      pts.add(Offset(x, y));
    }

    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final y = padY + (h / 4) * i;
      canvas.drawLine(Offset(padX, y), Offset(size.width - padX, y), gridPaint);
    }

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i];
      final p1 = pts[i + 1];
      final cp = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final cp2 = Offset((p0.dx + p1.dx) / 2, p1.dy);
      path.cubicTo(cp.dx, cp.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor.withValues(alpha: 0.9);
    canvas.drawCircle(pts.last, 3.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LandscapeChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.glowColor != glowColor;
  }
}

class _JournalHistoryHeader extends StatelessWidget {
  const _JournalHistoryHeader({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Journal History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.authTextPrimary,
            ),
          ),
        ),
        Obx(() {
          final label = controller.showAllHistory.value
              ? 'Show Less'
              : 'View All';
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
  const _JournalEntryCard({required this.entry, required this.onTap});

  final MoodRecord entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ts = entry.timestamp?.toDate();
    final dateLabel = ts == null ? 'Pending...' : _formatDate(ts);
    final moodLabel = entry.moodLabel.trim().isEmpty
        ? entry.emotion.toUpperCase()
        : entry.moodLabel.toUpperCase();

    final chipFg = moodLabel == 'GRATEFUL'
        ? const Color(0xFF16A34A)
        : moodLabel == 'NEUTRAL'
        ? const Color(0xFF334155)
        : moodLabel == 'DOWN'
        ? const Color(0xFFB91C1C)
        : moodLabel == 'TENSE'
        ? const Color(0xFFB45309)
        : AppColors.dashboardBrand;
    final chipBg = chipFg.withValues(alpha: 0.10);

    final excerpt = entry.moodText.length > 140
        ? '${entry.moodText.substring(0, 140)}…'
        : entry.moodText;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 18,
                        color: AppColors.dashboardBrand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood Check-in',
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
                      color: chipBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: chipFg.withValues(alpha: 0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        moodLabel,
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w900,
                          color: chipFg,
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

String _formatDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final suffix = dt.hour >= 12 ? 'PM' : 'AM';
  return '${months[dt.month - 1]} ${dt.day} • $h:$m $suffix';
}

class _WeeklyMilestoneCard extends StatelessWidget {
  const _WeeklyMilestoneCard({required this.controller});

  final InsightsController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            blurRadius: 26,
            offset: const Offset(0, 18),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 140,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF0B2B3C),
                              const Color(0xFF0B2B3C).withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.25,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.dashboardBrand.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Text(
                        'WEEKLY MILESTONE',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    const Positioned(
                      right: 12,
                      top: 12,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const Positioned(
                      left: 14,
                      bottom: 14,
                      child: Icon(
                        Icons.park_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'insights_streak_title'.tr,
              style: const TextStyle(
                fontSize: 18,
                height: 1.15,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'insights_streak_body'.tr,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppColors.authTextSecondary.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 38,
                child: CustomButton(
                  label: 'insights_explore'.tr,
                  onPressed: controller.exploreInsights,
                  height: 38,
                  width: 200,
                  backgroundColor: AppColors.dashboardBrand.withValues(
                    alpha: 0.12,
                  ),
                  foregroundColor: AppColors.dashboardBrand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
