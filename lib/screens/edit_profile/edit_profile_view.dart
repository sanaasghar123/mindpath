import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
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
                      Obx(() {
                        final user = Get.find<UserController>().user.value;
                        final selectedPath = controller.selectedImagePath.value;
                        final existingImageUrl = user?.profileImage;

                        Widget imageWidget;

                        if (selectedPath.isNotEmpty) {
                          imageWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              File(selectedPath),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
                          imageWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: CachedNetworkImage(
                              imageUrl: existingImageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          );
                        } else {
                          imageWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 100,
                              height: 100,
                              color: AppColors.primary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Get.bottomSheet(
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.camera_alt),
                                            title: Text('profile_take_photo'.tr),
                                            onTap: () {
                                              Get.back();
                                              controller.pickImage(ImageSource.camera);
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.photo_library),
                                            title: Text('profile_choose_gallery'.tr),
                                            onTap: () {
                                              Get.back();
                                              controller.pickImage(ImageSource.gallery);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    isScrollControlled: true,
                                  );
                                },
                                child: imageWidget,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'profile_tap_to_change'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.authTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
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
