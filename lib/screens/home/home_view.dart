import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/home/home_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WelcomeBlock(controller: controller),
                  const SizedBox(height: 14),
                  _GuidanceCard(controller: controller),
                  const SizedBox(height: 16),
                  _VitalityCard(controller: controller),
                  const SizedBox(height: 14),
                  _SentimentPulseCard(controller: controller),
                  const SizedBox(height: 14),
                  _CoreVibrationsCard(controller: controller),
                  const SizedBox(height: 14),
                  _RecommendedCard(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeBlock extends StatelessWidget {
  const _WelcomeBlock({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return Text(
            controller.welcomeTitle,
            style: const TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: AppColors.authTextPrimary,
            ),
          );
        }),
        const SizedBox(height: 6),
        Text(
          controller.welcomeSubtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: AppColors.authTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.dashboardBrand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: AppColors.dashboardBrand,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(
                        color: AppColors.dashboardBrand.withValues(alpha: 0.45),
                        width: 3,
                      ),
                    ),
                  ),
                  padding: const EdgeInsetsDirectional.only(start: 10),
                  child: Text(
                    controller.guidanceText,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: AppColors.authTextPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _VitalityCard extends StatelessWidget {
  const _VitalityCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 14),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home_daily_vitality'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Obx(() {
                final value = controller.vitalityScore.value.clamp(0.0, 1.0);
                final percent = (value * 100).round();
                return SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 10,
                          backgroundColor: const Color(0xFFE8EEF8),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.dashboardBrand.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$percent%',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppColors.authTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'home_resilient'.tr.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                              color: AppColors.authTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final weekly =
                  (controller.weeklyAverage.value.clamp(0.0, 1.0) * 100)
                      .round();
              final consistency = controller.consistencyDays.value;
              return Row(
                children: [
                  Expanded(
                    child: _StatPill(
                      icon: Icons.show_chart_rounded,
                      label: 'home_weekly_avg_label'.tr,
                      valueBuilder: () => '$weekly%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatPill(
                      icon: Icons.verified_rounded,
                      label: 'home_consistency_label'.tr,
                      valueBuilder: () =>
                          'home_days_value'.trParams({'days': '$consistency'}),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.valueBuilder,
  });

  final IconData icon;
  final String label;
  final String Function() valueBuilder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.dashboardPrimaryButton,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.15,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTextSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    valueBuilder(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.authTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentimentPulseCard extends StatelessWidget {
  const _SentimentPulseCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home_sentiment_pulse'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return Column(
                children: [
                  for (final item in controller.sentiments) ...[
                    _SentimentRow(item: item),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SentimentRow extends StatelessWidget {
  const _SentimentRow({required this.item});

  final SentimentItem item;

  @override
  Widget build(BuildContext context) {
    final percent = (item.value.clamp(0.0, 1.0) * 100).round();
    final color = Color(item.color);
    return Column(
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox(width: 6, height: 6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.authTextPrimary,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.authTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: item.value.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.black.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CoreVibrationsCard extends StatelessWidget {
  const _CoreVibrationsCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home_core_vibrations'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final tag in controller.coreVibrations)
                    _VibrationChip(tag: tag),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VibrationChip extends StatelessWidget {
  const _VibrationChip({required this.tag});

  final VibrationTag tag;

  @override
  Widget build(BuildContext context) {
    final bg = Color(tag.backgroundColor);
    final fg = Color(tag.foregroundColor);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tag.icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              tag.label.tr,
              style: TextStyle(fontWeight: FontWeight.w800, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.dashboardPrimaryButton,
                    AppColors.dashboardPrimaryButton.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home_recommended'.tr.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'home_quote'.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    height: 36,
                    child: CustomButton(
                      label: 'home_start_session'.tr,
                      onPressed: controller.startSession,
                      height: 36,
                      width: 160,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.dashboardPrimaryButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
