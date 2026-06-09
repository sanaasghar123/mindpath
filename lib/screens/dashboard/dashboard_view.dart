import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/app_routes.dart';
import 'package:mindpath/screens/dashboard/dashboard_controller.dart';
import 'package:mindpath/screens/home/home_view.dart';
import 'package:mindpath/screens/insights/insights_view.dart';
import 'package:mindpath/screens/journal/journal_view.dart';
import 'package:mindpath/screens/profile/profile_view.dart';
import 'package:mindpath/utils/app_colors.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: index,
          children: [
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
