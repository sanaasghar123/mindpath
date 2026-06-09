import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/controllers/notification_controller.dart';
import 'package:mindpath/core/controllers/user_controller.dart';
import 'package:mindpath/core/services/auth_service.dart';
import 'package:mindpath/core/services/notification_service.dart';

class AuthController extends BaseController {
  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;
  StreamSubscription? _authSubscription;

  final firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _authService.currentUser;
    _authSubscription = _authService.authStateChanges().listen(
      (user) {
        firebaseUser.value = user;
      },
      onError: (_) {
        firebaseUser.value = null;
      },
    );
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  bool get isLoggedIn => firebaseUser.value != null;

  Future<void> handleStartup() async {
    if (!isLoggedIn) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }

    final userController = Get.find<UserController>();
    try {
      await userController.fetchUserProfile();
      if (userController.user.value == null) {
        Get.offAllNamed(AppRoutes.completeProfile);
        return;
      }

      try {
        await scheduleDailyRemindersIfEnabled();
      } catch (_) {}
      final completed =
          userController.user.value?.hasCompletedFirstMoodAnalysis ?? false;
      if (!completed) {
        Get.offAllNamed(AppRoutes.moodCheck);
        return;
      }
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (_) {
      await _forceSignOutAndGoToLogin();
      Get.snackbar(
        'auth_profile_load_failed_title'.tr,
        'auth_profile_load_failed_body'.tr,
      );
    }
  }

  Future<void> scheduleDailyRemindersIfEnabled() async {
    if (!Get.isRegistered<NotificationController>()) return;
    final prefs = Get.find<NotificationController>();
    if (!prefs.remindersEnabled.value) return;
    try {
      await prefs.scheduleDefaultReminders();
    } catch (_) {}
  }

  Future<void> login({required String email, required String password}) async {
    try {
      setLoading(true);
      setError(null);
      await _authService.signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final message = _friendlyAuthMessage(e);
      setError(message);
      Get.snackbar('auth_login_failed'.tr, message);
    } finally {
      setLoading(false);
    }
  }

  Future<void> signup({required String email, required String password}) async {
    try {
      setLoading(true);
      setError(null);
      await _authService.signUpWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      final message = _friendlyAuthMessage(e);
      setError(message);
      Get.snackbar('auth_signup_failed'.tr, message);
    } finally {
      setLoading(false);
    }
  }

  Future<void> googleSignIn() async {
    try {
      setLoading(true);
      setError(null);
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      final message = _friendlyAuthMessage(e);
      setError(message);
      Get.snackbar('auth_google_failed'.tr, message);
    } catch (e) {
      setError('auth_google_try_again'.tr);
      Get.snackbar('auth_google_failed'.tr, 'auth_google_try_again'.tr);
    } finally {
      setLoading(false);
    }
  }

  Future<void> logoutWithConfirmation() async {
    final confirmed = await _confirmLogout();
    if (!confirmed) return;
    await logout();
  }

  Future<void> logout() async {
    try {
      setLoading(true);
      setError(null);
      await NotificationService().cancelAll();
      await _authService.signOut();
      Get.find<UserController>().clear();
      Get.offAllNamed(AppRoutes.signIn);
    } finally {
      setLoading(false);
    }
  }

  Future<void> _forceSignOutAndGoToLogin() async {
    try {
      await NotificationService().cancelAll();
      await _authService.signOut();
    } catch (_) {}
    Get.find<UserController>().clear();
    Get.offAllNamed(AppRoutes.signIn);
  }

  Future<bool> _confirmLogout() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('profile_logout'.tr),
        content: Text('auth_logout_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('auth_logout_yes'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return result ?? false;
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'auth_invalid_email'.tr;
      case 'user-disabled':
        return 'auth_account_disabled'.tr;
      case 'user-not-found':
        return 'auth_user_not_found'.tr;
      case 'wrong-password':
      case 'invalid-credential':
        return 'auth_incorrect_credentials'.tr;
      case 'email-already-in-use':
        return 'auth_email_in_use'.tr;
      case 'weak-password':
        return 'auth_weak_password'.tr;
      case 'network-request-failed':
        return 'auth_network_error'.tr;
      case 'missing-id-token':
        return 'auth_google_incomplete'.tr;
      default:
        return e.message ?? 'auth_generic_error'.tr;
    }
  }
}
