import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/controllers/notification_controller.dart';
import 'package:mindpath/features/profile/controllers/language_controller.dart';
import 'package:mindpath/features/profile/controllers/theme_controller.dart';
import 'package:mindpath/screens/profile/profile_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.dashboardBgTop, AppColors.dashboardBgBottom],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 10, 18, 18),
              children: [
                      _ProfileHeader(controller: controller),
                      const SizedBox(height: 22),
                      const _SectionTitle('profile_section_general'),
                      const SizedBox(height: 10),
                      _SettingsGroup(
                        children: [
                          _SettingRow(
                            leading: _CircleIcon(
                              icon: Icons.edit_rounded,
                              backgroundColor: const Color(0xFFEFF4FF),
                              iconColor: AppColors.dashboardBrand,
                            ),
                            titleKey: 'profile_edit_profile',
                            trailing: Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: AppColors.authTextSecondary,
                            ),
                            onTap: controller.openEditProfile,
                          ),
                          _SettingRow(
                            leading: _CircleIcon(
                              icon: Icons.language_rounded,
                              backgroundColor: const Color(0xFFEAF1FF),
                              iconColor: AppColors.dashboardBrand,
                            ),
                            titleKey: 'profile_language',
                            trailing: const _LanguageToggle(),
                          ),
                          Obx(() {
                            final notificationController =
                                Get.find<NotificationController>();
                            return SwitchListTile(
                              contentPadding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 14,
                              ),
                              secondary: const _CircleIcon(
                                icon: Icons.alarm_rounded,
                                backgroundColor: Color(0xFFEFFDF4),
                                iconColor: Color(0xFF16A34A),
                              ),
                              title: Text(
                                'reminders'.tr,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.authTextPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'reminders_subtitle'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.authTextSecondary.withValues(
                                    alpha: 0.95,
                                  ),
                                ),
                              ),
                              value:
                                  notificationController.remindersEnabled.value,
                              onChanged: notificationController.toggleReminders,
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppColors.dashboardBrand
                                  .withValues(alpha: 0.55),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.black.withValues(
                                alpha: 0.12,
                              ),
                            );
                          }),
                          _SettingRow(
                            leading: _CircleIcon(
                              icon: Icons.dark_mode_rounded,
                              backgroundColor: const Color(0xFFF3E8FF),
                              iconColor: const Color(0xFF7C3AED),
                            ),
                            titleKey: 'profile_dark_mode',
                            trailing: Obx(() {
                              final themeController =
                                  Get.find<ThemeController>();
                              final isDark =
                                  themeController.themeMode.value ==
                                      ThemeMode.dark ||
                                  (themeController.themeMode.value ==
                                          ThemeMode.system &&
                                      WidgetsBinding
                                              .instance
                                              .platformDispatcher
                                              .platformBrightness ==
                                          Brightness.dark);
                              return Switch(
                                value: isDark,
                                onChanged: (value) =>
                                    controller.setDarkMode(value),
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColors.dashboardBrand,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.black.withValues(
                                  alpha: 0.12,
                                ),
                              );
                            }),
                          ),
                          _SettingRow(
                            leading: _CircleIcon(
                              icon: Icons.notifications_rounded,
                              backgroundColor: const Color(0xFFE8F3FF),
                              iconColor: const Color(0xFF2563EB),
                            ),
                            titleKey: 'profile_notifications',
                            trailing: Obx(() {
                              return Switch(
                                value: controller.notificationsEnabled.value,
                                onChanged: controller.setNotifications,
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColors.dashboardBrand
                                    .withValues(alpha: 0.55),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.black.withValues(
                                  alpha: 0.12,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _SectionTitle('profile_section_support_legal'),
                      const SizedBox(height: 10),
                      _SettingsGroup(
                        children: [
                          _SettingRow(
                            leading: _CircleIcon(
                              icon: Icons.help_outline_rounded,
                              backgroundColor: const Color(0xFFEFF4FF),
                              iconColor: AppColors.authTextSecondary,
                            ),
                            titleKey: 'profile_help_support',
                            trailing: Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: AppColors.authTextSecondary,
                            ),
                            onTap: controller.openHelpSupport,
                          ),
                          _SettingRow(
                            leading: _CircleIcon(
                              icon: Icons.verified_user_rounded,
                              backgroundColor: const Color(0xFFEFF4FF),
                              iconColor: AppColors.authTextSecondary,
                            ),
                            titleKey: 'profile_privacy_policy',
                            trailing: Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: AppColors.authTextSecondary,
                            ),
                            onTap: controller.openPrivacyPolicy,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _LogoutButton(onTap: controller.logout),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.dashboardBrand.withValues(alpha: 0.45),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                offset: const Offset(0, 14),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: SizedBox(
            width: 96,
            height: 96,
            child: Obx(() {
              final url = controller.profileImageUrl;
              if (url != null && url.trim().startsWith('http')) {
                return ClipOval(
                  child: Image.network(
                    url.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppColors.authTextSecondary,
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: AppColors.authTextSecondary,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          return Text(
            controller.userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.authTextPrimary,
            ),
          );
        }),
        const SizedBox(height: 6),
        Text(
          'profile_since'.tr,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.authTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.keyName);

  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Text(
        keyName.tr,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.authTextPrimary.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 14),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.leading,
    required this.titleKey,
    required this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String titleKey;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titleKey.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.authTextPrimary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>();
    return Obx(() {
      final selected = lang.currentLang.value;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangChip(
                label: 'profile_english'.tr,
                isSelected: selected == 'en_US',
                onTap: () => lang.changeLanguage('en_US'),
              ),
              _LangChip(
                label: 'profile_urdu'.tr,
                isSelected: selected == 'ur_PK',
                onTap: () => lang.changeLanguage('ur_PK'),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? Colors.white : Colors.transparent;
    final fg = isSelected
        ? AppColors.dashboardBrand
        : AppColors.authTextSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'profile_logout'.tr,
      onPressed: onTap,
      height: 52,
      variant: CustomButtonVariant.outlined,
      backgroundColor: const Color(0xFFF4EFFF).withValues(alpha: 0.65),
      foregroundColor: const Color(0xFF6D28D9),
      borderColor: Colors.black.withValues(alpha: 0.04),
      prefixIcon: Icons.logout_rounded,
      iconSize: 18,
    );
  }
}
