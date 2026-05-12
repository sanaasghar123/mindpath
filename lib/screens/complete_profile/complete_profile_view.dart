import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/complete_profile/complete_profile_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/app_text_field.dart';
import 'package:mindpath/widgets/custom_button.dart';

class CompleteProfileView extends GetView<CompleteProfileController> {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.authBgTop, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'complete_profile_title'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.authTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'complete_profile_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.authCard.withValues(alpha: 0.92),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: controller.nameController,
                              hintText: 'auth_full_name'.tr,
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: controller.ageController,
                              hintText: 'profile_age_optional'.tr,
                              prefixIcon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _GenderPicker(controller: controller),
                            const SizedBox(height: 14),
                            Obx(() {
                              final message = controller.errorMessage.value;
                              if (message == null || message.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
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
                            Obx(() {
                              final loading = controller.isLoading.value;
                              return CustomButton(
                                label: loading
                                    ? 'common_saving'.tr
                                    : 'common_continue'.tr,
                                onPressed: loading ? null : controller.submit,
                                backgroundColor: AppColors.authPrimary,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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

class _GenderPicker extends StatelessWidget {
  const _GenderPicker({required this.controller});

  final CompleteProfileController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.authFieldFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.wc_rounded, color: AppColors.authTextSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GenderChip(
                      label: 'common_male'.tr,
                      isSelected: controller.gender.value == 'Male',
                      onTap: () => controller.setGender('Male'),
                    ),
                    _GenderChip(
                      label: 'common_female'.tr,
                      isSelected: controller.gender.value == 'Female',
                      onTap: () => controller.setGender('Female'),
                    ),
                    _GenderChip(
                      label: 'common_other'.tr,
                      isSelected: controller.gender.value == 'Other',
                      onTap: () => controller.setGender('Other'),
                    ),
                    _GenderChip(
                      label: 'common_skip'.tr,
                      isSelected: controller.gender.value == null,
                      onTap: () => controller.setGender(null),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5);
    final fg = isSelected ? AppColors.authPrimary : AppColors.authTextSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}
