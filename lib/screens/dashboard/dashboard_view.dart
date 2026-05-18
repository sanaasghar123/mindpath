import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';
import 'package:mindpath/screens/home/home_view.dart';
import 'package:mindpath/screens/insights/insights_view.dart';
import 'package:mindpath/screens/journal/journal_view.dart';
import 'package:mindpath/screens/profile/profile_view.dart';
import 'package:mindpath/utils/app_colors.dart';

class DashboardView extends GetView<DashboardController> {
  DashboardView({super.key});

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _openMoreApps() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/developer?id=MindPath+Apps',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://example.com/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    Share.share('share_app_text'.tr, subject: 'app_name'.tr);
  }

  @override
  Widget build(BuildContext context) {
    controller.openDrawerCallback = () {
      _scaffoldKey.currentState?.openDrawer();
    };

    return Obx(() {
      final index = controller.selectedIndex.value;
      return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 52,
                        height: 52,
                        child: Icon(
                          Icons.spa_rounded,
                          size: 28,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'app_name'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: Text('drawer_share_app'.tr),
                onTap: () {
                  Get.back();
                  _shareApp();
                },
              ),
              ListTile(
                leading: const Icon(Icons.apps_rounded),
                title: Text('drawer_more_apps'.tr),
                onTap: () {
                  Get.back();
                  _openMoreApps();
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_rounded),
                title: Text('drawer_privacy_policy'.tr),
                onTap: () {
                  Get.back();
                  _openPrivacyPolicy();
                },
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: index,
          children: const [
            HomeView(),
            JournalView(),
            InsightsView(),
            ProfileView(),
          ],
        ),
        floatingActionButton: index == 0
            ? FloatingActionButton(
                onPressed: () => Get.toNamed(AppRoutes.moodCheck),
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: AppColors.authBgTop),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: controller.setTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.black.withValues(alpha: 0.45),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: 'dashboard_tab_home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.edit_note_rounded),
              label: 'dashboard_tab_journal'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.insights_rounded),
              label: 'dashboard_tab_insights'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: 'dashboard_tab_profile'.tr,
            ),
          ],
        ),
      );
    });
  }
}
