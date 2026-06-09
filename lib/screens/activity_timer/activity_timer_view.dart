import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/activity_timer/activity_timer_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class ActivityTimerView extends GetView<ActivityTimerController> {
  const ActivityTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.title.value)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.authTextPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      if (controller.activityType.value == 'walk') {
                        return const _WalkTips();
                      } else {
                        return const _BreathingSteps();
                      }
                    }),
                    Expanded(
                      child: Center(
                        child: Obx(() {
                          final progress = controller.progress;
                          final remaining = controller.mmss;
                          return _PulseTimerRing(
                            progress: progress,
                            label: remaining,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(() {
                      final running = controller.isRunning.value;
                      return Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: running
                                  ? 'activity_pause'.tr
                                  : 'activity_start'.tr,
                              onPressed: running
                                  ? controller.pause
                                  : controller.start,
                              height: 54,
                              backgroundColor: AppColors.primary,
                              prefixIcon: running
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'activity_reset'.tr,
                              onPressed: controller.reset,
                              height: 54,
                              variant: CustomButtonVariant.outlined,
                              foregroundColor: AppColors.dashboardBrand,
                              prefixIcon: Icons.refresh_rounded,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalkTips extends StatelessWidget {
  const _WalkTips();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'activity_walk_tips'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WalkTip(
                  icon: Icons.air_rounded,
                  label: 'activity_breathe'.tr,
                ),
                _WalkTip(
                  icon: Icons.visibility_rounded,
                  label: 'activity_observe'.tr,
                ),
                _WalkTip(
                  icon: Icons.waves_rounded,
                  label: 'activity_feel'.tr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkTip extends StatelessWidget {
  const _WalkTip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.dashboardBrand.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: AppColors.dashboardBrand,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.authTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _BreathingSteps extends StatelessWidget {
  const _BreathingSteps();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'activity_how_to_breathe'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BreathingStep(
                  icon: Icons.arrow_downward_rounded,
                  label: 'activity_inhale'.tr,
                  duration: '4s',
                ),
                _BreathingStep(
                  icon: Icons.pause_rounded,
                  label: 'activity_hold'.tr,
                  duration: '7s',
                ),
                _BreathingStep(
                  icon: Icons.arrow_upward_rounded,
                  label: 'activity_exhale'.tr,
                  duration: '8s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathingStep extends StatelessWidget {
  const _BreathingStep({
    required this.icon,
    required this.label,
    required this.duration,
  });

  final IconData icon;
  final String label;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.authTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          duration,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.authTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _PulseTimerRing extends StatefulWidget {
  const _PulseTimerRing({required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  State<_PulseTimerRing> createState() => _PulseTimerRingState();
}

class _PulseTimerRingState extends State<_PulseTimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final scale = 1 + (0.04 * sin(t * pi));
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: widget.progress.clamp(0.0, 1.0),
                  strokeWidth: 10,
                  backgroundColor: Colors.black.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation(
                    AppColors.dashboardBrand.withValues(alpha: 0.85),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                      color: Colors.black.withValues(alpha: 0.10),
                    ),
                  ],
                ),
                child: const SizedBox(width: 176, height: 176),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.authTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'activity_breathe_slowly'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTextSecondary.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
