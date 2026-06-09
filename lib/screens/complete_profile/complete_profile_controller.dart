import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/auth_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/services/storage_service.dart';

class CompleteProfileController extends BaseController {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final gender = RxnString();
  final RxString selectedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final initialName = args['name'];
      if (initialName is String && initialName.trim().isNotEmpty) {
        nameController.text = initialName.trim();
      }
    }

    final existing = Get.find<UserController>().user.value;
    if (existing != null) {
      if (nameController.text.isEmpty) nameController.text = existing.name;
      if (existing.age != null) ageController.text = '${existing.age}';
      if (existing.gender != null && existing.gender!.isNotEmpty) {
        gender.value = existing.gender;
      }
    }
  }

  void setGender(String? value) {
    gender.value = value;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('common_failed'.tr, 'profile_image_pick_failed'.tr);
    }
  }

  Future<void> submit() async {
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

    String? profileImage;

    try {
      setLoading(true);
      setError(null);

      if (selectedImagePath.value.isNotEmpty) {
        final uid = Get.find<UserController>().userId;
        if (uid != null) {
          final XFile xFile = XFile(selectedImagePath.value);
          profileImage = await Get.find<StorageService>().uploadUserProfileImage(
            userId: uid,
            image: xFile,
          );
        }
      }

      await Get.find<UserController>().createUserProfile(
        name: name,
        age: parsedAge,
        gender: gender.value,
        profileImage: profileImage,
      );
      await Get.find<AuthController>().scheduleDailyRemindersIfEnabled();
      Get.toNamed(AppRoutes.moodCheck);
    } catch (e) {
      setError('profile_save_failed'.tr);
      Get.snackbar('common_failed'.tr, 'profile_save_failed'.tr);
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    super.onClose();
  }
}
