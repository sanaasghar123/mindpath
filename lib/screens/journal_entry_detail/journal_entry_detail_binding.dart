import 'package:get/get.dart';
import 'package:mindpath/screens/journal_entry_detail/journal_entry_detail_controller.dart';

class JournalEntryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JournalEntryDetailController>(() => JournalEntryDetailController());
  }
}

