import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/auth_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';

class SignInController extends BaseController {
  final isLogin = true.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  void setLogin() {
    isLogin.value = true;
    setError(null);
  }

  void setSignup() {
    isLogin.value = false;
    setError(null);
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> onSubmit() async {
    if (isLoading.value) return;
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!GetUtils.isEmail(email)) {
      setError('auth_invalid_email'.tr);
      Get.snackbar('common_failed'.tr, 'auth_invalid_email'.tr);
      return;
    }
    if (password.length < 6) {
      setError('auth_weak_password'.tr);
      Get.snackbar('common_failed'.tr, 'auth_weak_password'.tr);
      return;
    }

    final auth = Get.find<AuthController>();
    final user = Get.find<UserController>();

    if (isLogin.value) {
      try {
        setLoading(true);
        setError(null);
        await auth.login(email: email, password: password);
        // Check if login was successful
        if (auth.firebaseUser.value == null) {
          return;
        }
        await user.fetchUserProfile();
        if (user.user.value == null) {
          Get.offAllNamed(AppRoutes.completeProfile);
        } else if (!(user.user.value?.hasCompletedFirstMoodAnalysis ?? false)) {
          try {
            await auth.scheduleDailyRemindersIfEnabled();
          } catch (_) {}
          Get.toNamed(AppRoutes.moodCheck);
        } else {
          try {
            await auth.scheduleDailyRemindersIfEnabled();
          } catch (_) {}
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } finally {
        setLoading(false);
      }
      return;
    }

    final fullName = nameController.text.trim();
    if (fullName.isEmpty) {
      setError('auth_missing_name'.tr);
      Get.snackbar('common_failed'.tr, 'auth_missing_name'.tr);
      return;
    }

    final confirm = confirmPasswordController.text;
    if (confirm != password) {
      setError('auth_password_mismatch'.tr);
      Get.snackbar('common_failed'.tr, 'auth_password_mismatch'.tr);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      await auth.signup(email: email, password: password);
      if (auth.firebaseUser.value == null) {
        return;
      }
      Get.offAllNamed(AppRoutes.completeProfile, arguments: {'name': fullName});
    } finally {
      setLoading(false);
    }
  }

  Future<void> onGoogleSignIn() async {
    final auth = Get.find<AuthController>();
    final user = Get.find<UserController>();
    try {
      setLoading(true);
      setError(null);
      await auth.googleSignIn();
      if (auth.firebaseUser.value == null) {
        return;
      }
      await user.fetchUserProfile();
      if (user.user.value == null) {
        Get.offAllNamed(AppRoutes.completeProfile);
      } else if (!(user.user.value?.hasCompletedFirstMoodAnalysis ?? false)) {
        try {
          await auth.scheduleDailyRemindersIfEnabled();
        } catch (_) {}
        Get.toNamed(AppRoutes.moodCheck);
      } else {
        try {
          await auth.scheduleDailyRemindersIfEnabled();
        } catch (_) {}
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } finally {
      setLoading(false);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
