import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mindpath/core/services/notification_service.dart';
import 'package:mindpath/core/utils/notification_ids.dart';

class NotificationController extends GetxController {
  static const _storageKey = 'reminders_enabled';
  static final GetStorage _box = GetStorage();

  final remindersEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    final raw = _box.read(_storageKey);
    remindersEnabled.value = raw is bool ? raw : true;
  }

  Future<void> toggleReminders(bool val) async {
    remindersEnabled.value = val;
    await _box.write(_storageKey, val);
    if (val) {
      await scheduleDefaultReminders();
    } else {
      await NotificationService().cancelAll();
    }
  }

  Future<void> scheduleDefaultReminders() async {
    if (!remindersEnabled.value) return;

    await NotificationService().scheduleDailyReminder(
      id: kMoodCheckReminder,
      title: 'how_are_you_feeling'.tr,
      body: 'suggestion_breathe'.tr,
      time: const Time(9, 0, 0),
    );

    await NotificationService().scheduleDailyReminder(
      id: kJournalReminder,
      title: 'journal'.tr,
      body: 'suggestion_journal'.tr,
      time: const Time(14, 0, 0),
    );

    await NotificationService().scheduleDailyReminder(
      id: kEveningCheckInReminder,
      title: 'todays_insight'.tr,
      body: 'suggestion_rest'.tr,
      time: const Time(20, 0, 0),
    );
  }
}
