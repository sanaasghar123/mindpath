import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/features/profile/controllers/theme_controller.dart';

class AppColors {
  static ThemeController get _themeController => Get.find<ThemeController>();

  // Light mode
  static const primary = Color(0xFF1E5B49);
  static const bgA = Color(0xFFF2F9F4);
  static const bgB = Color(0xFFE2F0E7);

  static const authPrimary = Color(0xFF2F556F);
  static const authBgTop = Color(0xFFF7F9FF);
  static const authBgBottom = Color(0xFFEEDCFF);
  static const authCard = Color(0xFFF6F8FF);
  static const authFieldFill = Color(0xFFEEF2F8);
  static const authTextPrimary = Color(0xFF273241);
  static const authTextSecondary = Color(0xFF8B97A8);

  static const moodBgTop = Color(0xFFF2F4FF);
  static const moodBgBottom = Color(0xFFE8EDFF);
  static const moodTextPrimary = Color(0xFF1F2937);
  static const moodTextSecondary = Color(0xFF6B7280);
  static const moodAccent = Color(0xFF3B82F6);
  static const moodPrimaryButton = Color(0xFF36556B);

  static const dashboardBgTop = Color(0xFFF3F6FF);
  static const dashboardBgBottom = Color(0xFFEAF0FF);
  static const dashboardBrand = Color(0xFF274CFF);
  static const dashboardPrimaryButton = Color(0xFF2F4C63);

  static const blackColor = Colors.black;
  static const error = Color(0xFFDC2626);

  // Dark mode
  static const primaryDark = Color(0xFF4F9F86);
  static const bgADark = Color(0xFF121212);
  static const bgBDark = Color(0xFF1E1E1E);

  static const authPrimaryDark = Color(0xFF5F88A3);
  static const authBgTopDark = Color(0xFF1A1A1A);
  static const authBgBottomDark = Color(0xFF252530);
  static const authCardDark = Color(0xFF2C2C34);
  static const authFieldFillDark = Color(0xFF3A3A45);
  static const authTextPrimaryDark = Color(0xFFE5E7EB);
  static const authTextSecondaryDark = Color(0xFF9CA3AF);

  static const moodBgTopDark = Color(0xFF1A1A2E);
  static const moodBgBottomDark = Color(0xFF16213E);
  static const moodTextPrimaryDark = Color(0xFFE5E7EB);
  static const moodTextSecondaryDark = Color(0xFF9CA3AF);
  static const moodAccentDark = Color(0xFF60A5FA);
  static const moodPrimaryButtonDark = Color(0xFF5A7A90);

  static const dashboardBgTopDark = Color(0xFF1A1A2E);
  static const dashboardBgBottomDark = Color(0xFF16213E);
  static const dashboardBrandDark = Color(0xFF5B7BFF);
  static const dashboardPrimaryButtonDark = Color(0xFF5A7A8F);

  static Color get adaptivePrimary => _themeController.isDarkMode ? primaryDark : primary;

  static Color get adaptiveBgA => _themeController.isDarkMode ? bgADark : bgA;
  static Color get adaptiveBgB => _themeController.isDarkMode ? bgBDark : bgB;

  static Color get adaptiveAuthPrimary => _themeController.isDarkMode ? authPrimaryDark : authPrimary;
  static Color get adaptiveAuthBgTop => _themeController.isDarkMode ? authBgTopDark : authBgTop;
  static Color get adaptiveAuthBgBottom => _themeController.isDarkMode ? authBgBottomDark : authBgBottom;
  static Color get adaptiveAuthCard => _themeController.isDarkMode ? authCardDark : authCard;
  static Color get adaptiveAuthFieldFill => _themeController.isDarkMode ? authFieldFillDark : authFieldFill;
  static Color get adaptiveAuthTextPrimary => _themeController.isDarkMode ? authTextPrimaryDark : authTextPrimary;
  static Color get adaptiveAuthTextSecondary => _themeController.isDarkMode ? authTextSecondaryDark : authTextSecondary;

  static Color get adaptiveMoodBgTop => _themeController.isDarkMode ? moodBgTopDark : moodBgTop;
  static Color get adaptiveMoodBgBottom => _themeController.isDarkMode ? moodBgBottomDark : moodBgBottom;
  static Color get adaptiveMoodTextPrimary => _themeController.isDarkMode ? moodTextPrimaryDark : moodTextPrimary;
  static Color get adaptiveMoodTextSecondary => _themeController.isDarkMode ? moodTextSecondaryDark : moodTextSecondary;
  static Color get adaptiveMoodAccent => _themeController.isDarkMode ? moodAccentDark : moodAccent;
  static Color get adaptiveMoodPrimaryButton => _themeController.isDarkMode ? moodPrimaryButtonDark : moodPrimaryButton;

  static Color get adaptiveDashboardBgTop => _themeController.isDarkMode ? dashboardBgTopDark : dashboardBgTop;
  static Color get adaptiveDashboardBgBottom => _themeController.isDarkMode ? dashboardBgBottomDark : dashboardBgBottom;
  static Color get adaptiveDashboardBrand => _themeController.isDarkMode ? dashboardBrandDark : dashboardBrand;
  static Color get adaptiveDashboardPrimaryButton => _themeController.isDarkMode ? dashboardPrimaryButtonDark : dashboardPrimaryButton;
}
