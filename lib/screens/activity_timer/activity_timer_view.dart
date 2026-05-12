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
                    'Breathe slowly',
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
