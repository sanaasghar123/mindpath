import 'package:get/get.dart';
import 'package:mindpath/screens/activity_timer/activity_timer_controller.dart';

class ActivityTimerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityTimerController>(() => ActivityTimerController());
  }
}

