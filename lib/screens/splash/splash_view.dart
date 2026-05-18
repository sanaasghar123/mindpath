import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/core/controllers/auth_controller.dart';
import 'package:mindpath/screens/splash/splash_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/utils/app_constants.dart';
import 'package:mindpath/widgets/custom_button.dart';
import 'package:mindpath/widgets/mindpath_logo.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    final auth = Get.find<AuthController>();

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage('assets/splash_bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.bgA.withValues(alpha: 0.55),
                    AppColors.bgB.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth >= 420 ? 32.0 : 24.0;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      const Spacer(flex: 18),
                      MindPathLogoMark(primary: primary),
                      const SizedBox(height: 22),
                      MindPathWordmark(primary: primary),
                      const SizedBox(height: 14),
                      Text(
                        AppConstants.taglineKey.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.68),
                          fontSize: 18,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(flex: 16),
                      Text(
                        AppConstants.ctaSubtitleKey.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.35),
                          letterSpacing: 2.2,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Obx(() {
                        if (auth.isLoggedIn) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 14, bottom: 18),
                          child: CustomButton(
                            label: 'splash_get_started'.tr,
                            onPressed: controller.onGetStarted,
                            height: 64,
                            backgroundColor: primary,
                            suffixIcon: Icons.arrow_forward_rounded,
                            iconSize: 22,
                          ),
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black.withValues(alpha: 0.35),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            child: Text(
                              'splash_privacy_policy'.tr,
                              style: const TextStyle(
                                letterSpacing: 1.2,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black.withValues(alpha: 0.35),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            child: Text(
                              'splash_terms_of_service'.tr,
                              style: const TextStyle(
                                letterSpacing: 1.2,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
