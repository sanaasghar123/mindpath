import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/auth_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/features/profile/controllers/theme_controller.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';

enum AppLanguage { english, urdu }

class ProfileController extends BaseController {
  final language = AppLanguage.english.obs;
  final notificationsEnabled = true.obs;

  DashboardController get _dashboard => Get.find<DashboardController>();
  UserController get _userController => Get.find<UserController>();
  ThemeController get _themeController => Get.find<ThemeController>();

  String get userName => _userController.user.value?.name ?? 'profile_default_user'.tr;

  String? get profileImageUrl => _userController.user.value?.profileImage;

  void backToHome() {
    _dashboard.setTab(0);
  }

  void openEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void setLanguage(AppLanguage value) {
    language.value = value;
  }

  void setDarkMode(bool value) {
    _themeController.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void openHelpSupport() {
    Get.toNamed(AppRoutes.helpSupport);
  }

  void openPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  void logout() {
    Get.find<AuthController>().logoutWithConfirmation();
  }
}
