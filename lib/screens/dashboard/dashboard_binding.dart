import 'package:get/get.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';
import 'package:mindpath/screens/home/home_binding.dart';
import 'package:mindpath/screens/insights/insights_binding.dart';
import 'package:mindpath/screens/journal/journal_binding.dart';
import 'package:mindpath/screens/profile/profile_binding.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    HomeBinding().dependencies();
    JournalBinding().dependencies();
    InsightsBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
