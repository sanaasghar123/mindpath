import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/home/home_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _openMoreApps() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/developer?id=MindPath+Apps',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://example.com/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(
                        Icons.spa_rounded,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'app_name'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: Text('drawer_share_app'.tr),
              onTap: () {
                Get.back();
                Share.share('share_app_text'.tr, subject: 'app_name'.tr);
              },
            ),
            ListTile(
              leading: const Icon(Icons.apps_rounded),
              title: Text('drawer_more_apps'.tr),
              onTap: () {
                Get.back();
                _openMoreApps();
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded),
              title: Text('drawer_privacy_policy'.tr),
              onTap: () {
                Get.back();
                _openPrivacyPolicy();
              },
            ),
          ],
        ),
      ),
      body: DecoratedBox(
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
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                children: [
                  _Header(controller: controller, onMenuTap: _openDrawer),
                  const SizedBox(height: 18),
                  _GuidanceCard(controller: controller),
                  const SizedBox(height: 16),
                  _VitalityCard(controller: controller),
                  const SizedBox(height: 14),
                  _SentimentPulseCard(controller: controller),
                  const SizedBox(height: 14),
                  _CoreVibrationsCard(controller: controller),
                  const SizedBox(height: 14),
                  const _BreathingExercisesCard(),
                  const SizedBox(height: 14),
                  _RecommendedCard(controller: controller),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onMenuTap});

  final HomeController controller;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: AppColors.authTextPrimary,
          ),
          onPressed: onMenuTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 22,
        ),
        const SizedBox(height: 12),
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

class _BreathingExercise {
  final String title;
  final String description;
  final String duration;
  final IconData icon;
  final int totalSeconds;

  const _BreathingExercise({
    required this.title,
    required this.description,
    required this.duration,
    required this.icon,
    required this.totalSeconds,
  });
}

const _breathingExercises = [
  _BreathingExercise(
    title: '4-7-8 Breathing',
    description: 'A simple technique to calm your nervous system',
    duration: '2 min',
    icon: Icons.self_improvement_rounded,
    totalSeconds: 120,
  ),
  _BreathingExercise(
    title: 'Box Breathing',
    description: 'Perfect for reducing stress and improving focus',
    duration: '3 min',
    icon: Icons.square_rounded,
    totalSeconds: 180,
  ),
  _BreathingExercise(
    title: 'Diaphragmatic Breathing',
    description: 'Deep breathing for relaxation and anxiety relief',
    duration: '5 min',
    icon: Icons.waves_rounded,
    totalSeconds: 300,
  ),
];

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

class _BreathingExercisesCard extends StatelessWidget {
  const _BreathingExercisesCard();

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
              'Breathing Exercises',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 14),
            ..._breathingExercises
                .map((exercise) => _BreathingExerciseCard(exercise: exercise))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _BreathingExerciseCard extends StatelessWidget {
  const _BreathingExerciseCard({required this.exercise});

  final _BreathingExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            '/activity-timer',
            arguments: {
              'title': exercise.title,
              'activityType': 'breathing',
              'durationSeconds': exercise.totalSeconds,
            },
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      exercise.icon,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.authTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.description,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      exercise.duration,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
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
