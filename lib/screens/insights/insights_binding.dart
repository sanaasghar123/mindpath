import 'package:get/get.dart';
import 'package:mindpath/screens/insights/insights_controller.dart';

class InsightsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InsightsController>(() => InsightsController());
  }
}
