import 'package:get/get.dart';
import 'package:mindpath/screens/journal_input/journal_input_controller.dart';

class JournalInputBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JournalInputController>(() => JournalInputController());
  }
}

