import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:mindpath/core/models/app_user.dart';
import 'package:mindpath/core/services/auth_service.dart';
import 'package:mindpath/core/services/user_service.dart';

class UserController extends BaseController {
  UserController({AuthService? authService, UserService? userService})
    : _authService = authService ?? AuthService(),
      _userService = userService ?? UserService();

  final AuthService _authService;
  final UserService _userService;

  final user = Rxn<AppUser>();

  String? get userId => _authService.currentUser?.uid;

  String? get email => _authService.currentUser?.email;

  Future<void> fetchUserProfile() async {
    final uid = userId;
    if (uid == null) {
      user.value = null;
      return;
    }

    try {
      setLoading(true);
      setError(null);
      user.value = await _userService.fetchUser(uid);
    } on FirebaseException catch (e) {
      setError(e.message ?? 'Failed to load your profile.');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> createUserProfile({
    required String name,
    int? age,
    String? gender,
    String? profileImage,
  }) async {
    final uid = userId;
    final userEmail = email;
    if (uid == null || userEmail == null) {
      throw StateError('Not authenticated');
    }

    try {
      setLoading(true);
      setError(null);
      await _userService.createUserProfile(
        userId: uid,
        name: name,
        email: userEmail,
        age: age,
        gender: gender,
        profileImage: profileImage,
      );
      await fetchUserProfile();
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateUserProfile({
    String? name,
    int? age,
    String? gender,
    String? profileImage,
    bool? hasCompletedFirstMoodAnalysis,
  }) async {
    final uid = userId;
    if (uid == null) throw StateError('Not authenticated');

    try {
      setLoading(true);
      setError(null);
      await _userService.updateUserProfile(
        userId: uid,
        name: name,
        age: age,
        gender: gender,
        profileImage: profileImage,
        hasCompletedFirstMoodAnalysis: hasCompletedFirstMoodAnalysis,
      );
      await fetchUserProfile();
    } finally {
      setLoading(false);
    }
  }

  void clear() {
    user.value = null;
    setLoading(false);
    setError(null);
  }
}
