import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static const _storageKey = 'locale';
  static final GetStorage _box = GetStorage();

  final currentLang = 'en_US'.obs;

  static Locale get savedLocale {
    final raw = _box.read(_storageKey);
    if (raw is String && raw.trim().isNotEmpty) {
      final parts = raw.split('_');
      if (parts.length == 2) return Locale(parts[0], parts[1]);
    }
    return const Locale('en', 'US');
  }

  @override
  void onInit() {
    super.onInit();
    currentLang.value = _box.read(_storageKey) is String
        ? (_box.read(_storageKey) as String)
        : 'en_US';
  }

  void changeLanguage(String langCode) {
    final normalized = langCode.trim();
    final locale = normalized == 'ur_PK'
        ? const Locale('ur', 'PK')
        : const Locale('en', 'US');
    currentLang.value = '${locale.languageCode}_${locale.countryCode}';
    _box.write(_storageKey, currentLang.value);
    Get.updateLocale(locale);
  }

  bool get isUrdu => currentLang.value == 'ur_PK';
}

