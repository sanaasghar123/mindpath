import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/edit_profile/edit_profile_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/app_text_field.dart';
import 'package:mindpath/widgets/custom_button.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    color: AppColors.authTextPrimary,
                    splashRadius: 22,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'profile_edit_profile'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.authTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.03),
                  ),
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
                      AppTextField(
                        controller: controller.genderController,
                        hintText: 'profile_gender_optional'.tr,
                        prefixIcon: Icons.wc_rounded,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: controller.profileImageController,
                        hintText: 'profile_image_url_optional'.tr,
                        prefixIcon: Icons.image_outlined,
                        keyboardType: TextInputType.url,
                      ),
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
                              : 'profile_save_changes'.tr,
                          onPressed: loading ? null : controller.save,
                          backgroundColor:
                              AppColors.dashboardPrimaryButton,
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
    );
  }
}
