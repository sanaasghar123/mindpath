import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/auth_controller.dart';

class SplashController extends BaseController {
  @override
  void onReady() {
    super.onReady();
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        auth.handleStartup();
      });
    }
  }

  void onGetStarted() {
    Get.toNamed(AppRoutes.signIn);
  }
}
