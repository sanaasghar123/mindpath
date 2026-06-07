import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/base_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> openMoreApps() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/developer?id=MindPath+Apps',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openPrivacyPolicy() async {
    final url = Uri.parse('https://example.com/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void shareApp() {
    Share.share('share_app_text'.tr, subject: 'app_name'.tr);
  }
}
