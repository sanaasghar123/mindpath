import 'package:get/get.dart';
import 'package:mindpath/screens/complete_profile/complete_profile_controller.dart';

class CompleteProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CompleteProfileController());
  }
}
