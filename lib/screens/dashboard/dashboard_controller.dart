import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';

class DashboardController extends BaseController {
  final selectedIndex = 0.obs;

  final initialMood = RxnString();
  final initialJournal = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final mood = args['mood'];
      final journal = args['journal'];
      if (mood is String && mood.isNotEmpty) initialMood.value = mood;
      if (journal is String) initialJournal.value = journal;
    }
  }

  void setTab(int index) {
    selectedIndex.value = index;
  }
}
