import 'dart:async';

import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/models/activity_log.dart';
import 'package:mindpath/core/services/journal_service.dart';

class ActivityTimerController extends BaseController {
  ActivityTimerController({JournalService? journalService})
    : _journalService = journalService ?? JournalService();

  final JournalService _journalService;

  final title = ''.obs;
  final activityType = ''.obs;
  final totalSeconds = 0.obs;
  final remainingSeconds = 0.obs;
  final isRunning = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map) {
      final t = arg['title'];
      final type = arg['activityType'];
      final seconds = arg['durationSeconds'];
      if (t is String) title.value = t;
      if (type is String) activityType.value = type;
      if (seconds is int) {
        totalSeconds.value = seconds;
        remainingSeconds.value = seconds;
      }
    }
    if (title.value.isEmpty) title.value = 'activity_fallback_title'.tr;
    if (activityType.value.isEmpty) activityType.value = 'activity';
    if (totalSeconds.value <= 0) {
      totalSeconds.value = 300;
      remainingSeconds.value = 300;
    }
  }

  void start() {
    if (isRunning.value) return;
    isRunning.value = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = remainingSeconds.value - 1;
      if (next <= 0) {
        remainingSeconds.value = 0;
        _complete();
      } else {
        remainingSeconds.value = next;
      }
    });
  }

  void pause() {
    isRunning.value = false;
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    pause();
    remainingSeconds.value = totalSeconds.value;
  }

  Future<void> _complete() async {
    pause();
    final uid = Get.find<UserController>().userId;
    if (uid == null) return;
    try {
      setLoading(true);
      await _journalService.logActivity(
        ActivityLog(
          id: '',
          userId: uid,
          activityType: activityType.value,
          durationSeconds: totalSeconds.value,
          createdAt: null,
        ),
      );
      Get.back();
      Get.snackbar(
        'common_completed'.tr,
        'activity_completed_body'.trParams({'title': title.value}),
      );
    } catch (_) {
      Get.snackbar('common_failed'.tr, 'activity_save_failed'.tr);
    } finally {
      setLoading(false);
    }
  }

  String get mmss {
    final s = remainingSeconds.value;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  double get progress {
    final total = totalSeconds.value;
    if (total <= 0) return 0;
    return 1 - (remainingSeconds.value / total).clamp(0.0, 1.0);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
