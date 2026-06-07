import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_pages.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/controllers/auth_controller.dart';
import 'package:mindpath/core/controllers/notification_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/services/notification_service.dart';
import 'package:mindpath/core/services/speech_service.dart';
import 'package:mindpath/core/services/storage_service.dart';
import 'package:mindpath/core/translations/app_translations.dart';
import 'package:mindpath/features/profile/controllers/language_controller.dart';
import 'package:mindpath/features/profile/controllers/theme_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await NotificationService().init();
  Get.lazyPut(() => SpeechService(), fenix: true);
  await Get.find<SpeechService>().init();
  Get.put(StorageService(), permanent: true);
  Get.put(UserController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  Get.put(LanguageController(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  runApp(const MindPathApp());
}

class MindPathApp extends StatelessWidget {
  const MindPathApp({super.key});

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        title: 'app_name'.tr,
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.themeMode.value,
        translations: AppTranslations(),
        locale: LanguageController.savedLocale,
        fallbackLocale: const Locale('en', 'US'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('ur', 'PK')],
        builder: (context, child) {
          final locale = Get.locale ?? LanguageController.savedLocale;
          final textDirection = locale.languageCode == 'ur'
              ? TextDirection.rtl
              : TextDirection.ltr;
          return Directionality(
            textDirection: textDirection,
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}
