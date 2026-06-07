import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindpath/utils/app_colors.dart';

class ThemeController extends GetxController {
  static const _storageKey = 'theme_mode';
  static final GetStorage _box = GetStorage();

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  static ThemeMode get savedThemeMode {
    final raw = _box.read(_storageKey);
    if (raw == null) return ThemeMode.system;
    if (raw is String) {
      switch (raw) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
          return ThemeMode.light;
        default:
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }

  @override
  void onInit() {
    super.onInit();
    themeMode.value = savedThemeMode;
  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _box.write(_storageKey, mode.name);
    Get.changeThemeMode(mode);
  }

  bool get isDarkMode =>
      themeMode.value == ThemeMode.dark ||
      (themeMode.value == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);
}
