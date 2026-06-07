import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/services/speech_service.dart';
import 'package:mindpath/screens/journal_input/journal_input_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class JournalInputView extends GetView<JournalInputController> {
  const JournalInputView({super.key});

  @override
  Widget build(BuildContext context) {
    final speech = Get.find<SpeechService>();
    return Scaffold(
      appBar: AppBar(
        title: Text('journal_prompt_title'.tr),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.03),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Obx(() {
                          return Text(
                            controller.prompt.value,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                              color: AppColors.authTextPrimary,
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.03),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: TextField(
                          controller: controller.textController,
                          maxLines: 10,
                          decoration: InputDecoration(
                            hintText: 'journal_write_hint'.tr,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      if (!speech.isListening.value) {
                        return const SizedBox.shrink();
                      }
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
                      if (!speech.isAvailable.value) {
                        return const SizedBox.shrink();
                      }
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
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
                            final base = controller.textController.text.trim();
                            try {
                              await speech.startListening(
                                onResult: (text) {
                                  final spoken = text.trim();
                                  final appended = base.isEmpty
                                      ? spoken
                                      : (spoken.isEmpty
                                            ? base
                                            : '$base $spoken');
                                  controller.textController.text = appended;
                                  controller.textController.selection =
                                      TextSelection.collapsed(
                                        offset: appended.length,
                                      );
                                },
                              );
                            } catch (_) {
                              Get.snackbar(
                                'voice_input'.tr,
                                'voice_not_available'.tr,
                              );
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Obx(() {
                                final fg = speech.isListening.value
                                    ? Theme.of(context).colorScheme.primary
                                    : AppColors.authTextSecondary;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.mic_none_rounded,
                                        size: 18, color: fg),
                                    const SizedBox(width: 8),
                                    Text(
                                      'mood_voice_to_text'.tr,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700, color: fg),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),
                    Obx(() {
                      final loading = controller.isLoading.value;
                      return CustomButton(
                        label: loading
                            ? 'common_analyzing'.tr
                            : 'common_submit'.tr,
                        onPressed: loading ? null : controller.submit,
                        height: 54,
                        backgroundColor: AppColors.primary,
                        prefixIcon: Icons.check_rounded,
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
