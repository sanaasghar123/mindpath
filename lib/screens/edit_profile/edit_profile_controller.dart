import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';

class EditProfileController extends BaseController {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final profileImageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final existing = Get.find<UserController>().user.value;
    if (existing != null) {
      nameController.text = existing.name;
      if (existing.age != null) ageController.text = '${existing.age}';
      if (existing.gender != null) genderController.text = existing.gender!;
      if (existing.profileImage != null) profileImageController.text = existing.profileImage!;
    }
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      setError('auth_missing_name'.tr);
      Get.snackbar('common_failed'.tr, 'auth_missing_name'.tr);
      return;
    }

    int? parsedAge;
    final rawAge = ageController.text.trim();
    if (rawAge.isNotEmpty) {
      parsedAge = int.tryParse(rawAge);
      if (parsedAge == null || parsedAge <= 0 || parsedAge > 120) {
        setError('profile_invalid_age'.tr);
        Get.snackbar('common_failed'.tr, 'profile_invalid_age'.tr);
        return;
      }
    }

    final gender = genderController.text.trim();
    final profileImage = profileImageController.text.trim();

    try {
      setLoading(true);
      setError(null);
      await Get.find<UserController>().updateUserProfile(
        name: name,
        age: parsedAge,
        gender: gender.isEmpty ? null : gender,
        profileImage: profileImage.isEmpty ? null : profileImage,
      );
      Get.back();
    } catch (_) {} finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    genderController.dispose();
    profileImageController.dispose();
    super.onClose();
  }
}
