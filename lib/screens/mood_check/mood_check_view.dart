import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/services/speech_service.dart';
import 'package:mindpath/screens/mood_check/mood_check_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class MoodCheckView extends GetView<MoodCheckController> {
  const MoodCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.moodBgTop, AppColors.moodBgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 08,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    const SizedBox(height: 26),
                    _MoodRow(controller: controller),
                    const SizedBox(height: 22),
                    Obx(() {
                      final message = controller.errorMessage.value;
                      if (message == null || message.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                    _JournalCard(controller: controller),
                    const SizedBox(height: 18),
                    Obx(() {
                      return _InfoCard(
                        icon: Icons.lightbulb_outline_rounded,
                        title: controller.gentleReminderTitle,
                        body: controller.gentleReminderBody,
                      );
                    }),
                    const SizedBox(height: 14),
                    _InfoCard(
                      icon: Icons.waves_rounded,
                      title: 'mood_visualizing_calm_title'.tr,
                      body: 'mood_visualizing_calm_body'.tr,
                    ),
                    const SizedBox(height: 10),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void safeBack() {
      if (Navigator.of(context).canPop()) {
        Get.back();
      } else {
        final userController = Get.isRegistered<UserController>()
            ? Get.find<UserController>()
            : null;
        final completed =
            userController?.user.value?.hasCompletedFirstMoodAnalysis ?? true;
        Get.offAllNamed(
          completed ? AppRoutes.dashboard : AppRoutes.completeProfile,
        );
      }
    }

    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            onPressed: safeBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.moodTextPrimary,
            tooltip: 'common_back'.tr,
          ),
        ),
        Text(
          'mood_title'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: AppColors.moodTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'mood_subtitle'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: AppColors.moodTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _MoodRow extends StatelessWidget {
  const _MoodRow({required this.controller});

  final MoodCheckController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedMood.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MoodOptionChip(
            emoji: '😊',
            label: 'mood_option_grateful'.tr.toUpperCase(),
            isSelected: selected == MoodOption.grateful,
            onTap: () => controller.selectMood(MoodOption.grateful),
          ),
          _MoodOptionChip(
            emoji: '😐',
            label: 'mood_option_neutral'.tr.toUpperCase(),
            isSelected: selected == MoodOption.neutral,
            onTap: () => controller.selectMood(MoodOption.neutral),
          ),
          _MoodOptionChip(
            emoji: '😔',
            label: 'mood_option_pensive'.tr.toUpperCase(),
            isSelected: selected == MoodOption.pensive,
            onTap: () => controller.selectMood(MoodOption.pensive),
          ),
          _MoodOptionChip(
            emoji: '😢',
            label: 'mood_option_down'.tr.toUpperCase(),
            isSelected: selected == MoodOption.down,
            onTap: () => controller.selectMood(MoodOption.down),
          ),
          _MoodOptionChip(
            emoji: '😠',
            label: 'mood_option_tense'.tr.toUpperCase(),
            isSelected: selected == MoodOption.tense,
            onTap: () => controller.selectMood(MoodOption.tense),
          ),
        ],
      );
    });
  }
}

class _MoodOptionChip extends StatelessWidget {
  const _MoodOptionChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = isSelected ? AppColors.moodAccent : Colors.transparent;
    final labelColor = isSelected
        ? AppColors.moodAccent
        : AppColors.moodTextSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ],
              border: Border.all(color: ring, width: 2),
            ),
            child: SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.controller});

  final MoodCheckController controller;

  @override
  Widget build(BuildContext context) {
    final speech = Get.find<SpeechService>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            offset: const Offset(0, 18),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'mood_digital_journal'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.moodTextPrimary,
                    ),
                  ),
                ),
                Obx(() {
                  if (!speech.isAvailable.value) return const SizedBox.shrink();
                  return _VoiceChip(
                    isActive: speech.isListening.value,
                    onTap: () async {
                      if (!speech.isAvailable.value) {
                        Get.snackbar(
                          'voice_input'.tr,
                          'voice_not_available'.tr,
                        );
                        return;
                      }
                      if (speech.isListening.value) {
                        await speech.stopListening();
                        return;
                      }
                      try {
                        await speech.startListening(
                          onResult: (text) {
                            controller.journalController.text = text;
                            controller.journalController.selection =
                                TextSelection.collapsed(offset: text.length);
                          },
                        );
                      } catch (_) {
                        Get.snackbar(
                          'voice_input'.tr,
                          'voice_not_available'.tr,
                        );
                      }
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            _JournalField(controller: controller.journalController),
            Obx(() {
              if (!speech.isListening.value) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.graphic_eq_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'listening'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),
            Obx(() {
              final value = controller.moodScore.value;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'mood_score_label'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.moodTextPrimary,
                        ),
                      ),
                      Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.moodPrimaryButton,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: value.clamp(0, 10),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    onChanged: (v) => controller.moodScore.value = v,
                    activeColor: AppColors.moodPrimaryButton,
                    inactiveColor: AppColors.moodPrimaryButton.withValues(
                      alpha: 0.15,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: AppColors.moodTextSecondary,
                ),
                const SizedBox(width: 6),
                Obx(() {
                  return Text(
                    controller.currentTimeLabel.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.moodTextSecondary,
                    ),
                  );
                }),
                const SizedBox(width: 14),
                Text(
                  '•',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.moodTextSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'mood_private_encrypted'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.moodTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Obx(() {
              final loading = controller.isLoading.value;
              return CustomButton(
                label: loading
                    ? 'common_analyzing'.tr
                    : 'mood_analyze_button'.tr,
                onPressed: loading ? null : controller.analyzeMood,
                height: 56,
                backgroundColor: AppColors.moodPrimaryButton,
                foregroundColor: Colors.white,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VoiceChip extends StatelessWidget {
  const _VoiceChip({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? AppColors.moodAccent.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.75);
    final fg = isActive ? AppColors.moodAccent : AppColors.moodPrimaryButton;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_none_rounded, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(
                'mood_voice_to_text'.tr,
                style: TextStyle(fontWeight: FontWeight.w700, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalField extends StatelessWidget {
  const _JournalField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final speech = Get.find<SpeechService>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: TextField(
          controller: controller,
          minLines: 7,
          maxLines: 10,
          style: const TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.moodTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'mood_journal_hint'.tr,
            hintStyle: const TextStyle(
              color: AppColors.moodTextSecondary,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: Obx(() {
              if (!speech.isAvailable.value) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'tap_mic_to_speak'.tr,
                icon: Icon(
                  speech.isListening.value
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  color: speech.isListening.value
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: () async {
                  if (!speech.isAvailable.value) {
                    Get.snackbar('voice_input'.tr, 'voice_not_available'.tr);
                    return;
                  }
                  if (speech.isListening.value) {
                    await speech.stopListening();
                    return;
                  }
                  try {
                    await speech.startListening(
                      onResult: (text) {
                        controller.text = text;
                        controller.selection = TextSelection.collapsed(
                          offset: text.length,
                        );
                      },
                    );
                  } catch (_) {
                    Get.snackbar('voice_input'.tr, 'voice_not_available'.tr);
                  }
                },
              );
            }),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: AppColors.moodPrimaryButton),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.moodTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.moodTextSecondary,
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
