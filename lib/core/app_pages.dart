import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/screens/complete_profile/complete_profile_binding.dart';
import 'package:mindpath/screens/complete_profile/complete_profile_view.dart';
import 'package:mindpath/screens/dashboard/dashboard_binding.dart';
import 'package:mindpath/screens/dashboard/dashboard_view.dart';
import 'package:mindpath/screens/edit_profile/edit_profile_binding.dart';
import 'package:mindpath/screens/edit_profile/edit_profile_view.dart';
import 'package:mindpath/screens/activity_timer/activity_timer_binding.dart';
import 'package:mindpath/screens/activity_timer/activity_timer_view.dart';
import 'package:mindpath/screens/journal_entry_detail/journal_entry_detail_binding.dart';
import 'package:mindpath/screens/journal_entry_detail/journal_entry_detail_view.dart';
import 'package:mindpath/screens/journal_detail/journal_detail_binding.dart';
import 'package:mindpath/screens/journal_detail/journal_detail_view.dart';
import 'package:mindpath/screens/journal_input/journal_input_binding.dart';
import 'package:mindpath/screens/journal_input/journal_input_view.dart';
import 'package:mindpath/screens/mood_check/mood_check_controller.dart';
import 'package:mindpath/screens/mood_check/mood_check_view.dart';
import 'package:mindpath/screens/next/next_controller.dart';
import 'package:mindpath/screens/next/next_view.dart';
import 'package:mindpath/screens/sign_in/sign_in_controller.dart';
import 'package:mindpath/screens/sign_in/sign_in_view.dart';
import 'package:mindpath/screens/splash/splash_controller.dart';
import 'package:mindpath/screens/splash/splash_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
      binding: BindingsBuilder(() {
        Get.put(SignInController());
      }),
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => const CompleteProfileView(),
      binding: CompleteProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.moodCheck,
      page: () => const MoodCheckView(),
      binding: BindingsBuilder(() {
        Get.put(MoodCheckController());
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.journalEntryDetail,
      page: () => const JournalEntryDetailView(),
      binding: JournalEntryDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.journalInput,
      page: () => const JournalInputView(),
      binding: JournalInputBinding(),
    ),
    GetPage(
      name: AppRoutes.journalDetail,
      page: () => const JournalDetailView(),
      binding: JournalDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.activityTimer,
      page: () => const ActivityTimerView(),
      binding: ActivityTimerBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.next,
      page: () => const NextView(),
      binding: BindingsBuilder(() {
        Get.put(NextController());
      }),
    ),
  ];
}
