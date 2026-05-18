import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';
import 'package:mindpath/screens/home/home_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
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
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverList.list(
                  children: [
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                      valueBuilder: () => '$consistency',
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
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.dashboardBrand.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(icon, size: 16, color: AppColors.dashboardBrand),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valueBuilder(),
                    style: const TextStyle(
                      fontSize: 16,
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
              'home_sentiment_pulse'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final items = controller.sentiments;
              return Row(
                children: [
                  for (final item in items) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: item.value,
                              backgroundColor: const Color(0xFFE8EEF8),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(item.color),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label.tr,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.authTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (items.indexOf(item) != items.length - 1)
                      const SizedBox(width: 12),
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

class _CoreVibrationsCard extends StatelessWidget {
  const _CoreVibrationsCard({required this.controller});

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
              'home_top_emotions'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final vibes = controller.coreVibrations;
              if (vibes.isEmpty) {
                return Text(
                  'home_no_emotions_yet'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authTextSecondary.withValues(alpha: 0.9),
                  ),
                );
              }
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final vibe in vibes)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(vibe.backgroundColor),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              vibe.icon,
                              size: 18,
                              color: Color(vibe.foregroundColor),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vibe.label.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(vibe.foregroundColor),
                              ),
                            ),
                          ],
                        ),
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

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.controller});

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'home_recommended'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 14),
            CustomButton(
              label: 'home_record_mood'.tr,
              onPressed: () => Get.toNamed('/mood-check'),
              variant: CustomButtonVariant.filled,
              prefixIcon: Icons.edit_note_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
