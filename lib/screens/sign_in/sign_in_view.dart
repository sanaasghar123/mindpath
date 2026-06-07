import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/screens/sign_in/sign_in_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/app_text_field.dart';
import 'package:mindpath/widgets/auth_tab_switch.dart';
import 'package:mindpath/widgets/custom_button.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.authBgTop, AppColors.primary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _Header(),
                    const SizedBox(height: 18),
                    _Card(controller: controller),
                    const SizedBox(height: 18),
                    _Footer(controller: controller),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 54,
            height: 54,
            child: Icon(
              Icons.spa_rounded,
              color: AppColors.authPrimary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'auth_welcome_back'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.authTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'auth_enter_details'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.authTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.controller});

  final SignInController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.authCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            offset: const Offset(0, 18),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Obx(() {
          final isLogin = controller.isLogin.value;
          final error = controller.errorMessage.value;

          return Column(
            children: [
              AuthTabSwitch(
                isLogin: isLogin,
                onLoginTap: controller.setLogin,
                onSignupTap: controller.setSignup,
              ),
              const SizedBox(height: 16),
              if (error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (!isLogin) ...[
                AppTextField(
                  controller: controller.nameController,
                  hintText: 'auth_full_name'.tr,
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 12),
              ],
              AppTextField(
                controller: controller.emailController,
                hintText: 'auth_email'.tr,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              Obx(() {
                final obscure = controller.obscurePassword.value;
                return AppTextField(
                  controller: controller.passwordController,
                  hintText: 'auth_password'.tr,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: obscure,
                  suffix: IconButton(
                    onPressed: controller.togglePasswordVisibility,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.authTextSecondary,
                    ),
                  ),
                );
              }),
              if (!isLogin) ...[
                const SizedBox(height: 12),
                Obx(() {
                  final obscure = controller.obscureConfirmPassword.value;
                  return AppTextField(
                    controller: controller.confirmPasswordController,
                    hintText: 'auth_confirm_password'.tr,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: obscure,
                    suffix: IconButton(
                      onPressed: controller.toggleConfirmPasswordVisibility,
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.authTextSecondary,
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.authPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'auth_forgot_password'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Obx(() {
                final loading = controller.isLoading.value;
                return CustomButton(
                  label: loading
                      ? 'common_loading'.tr
                      : (isLogin ? 'auth_title_login' : 'auth_title_signup').tr,
                  onPressed: loading ? null : controller.onSubmit,
                  backgroundColor: AppColors.primary,
                );
              }),
              const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.08))),
        const SizedBox(width: 12),
        Text(
          'auth_or_continue_with'.tr,
          style: TextStyle(
            color: AppColors.authTextSecondary.withValues(alpha: 0.85),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.08))),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'auth_continue_with_google'.tr,
      onPressed: onPressed,
      height: 52,
      variant: CustomButtonVariant.outlined,
      backgroundColor: Colors.white.withValues(alpha: 0.55),
      foregroundColor: AppColors.authTextPrimary,
      borderColor: Colors.black.withValues(alpha: 0.08),
      prefix: _GoogleMark(),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: Center(
          child: Text(
            'G',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.authTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});

  final SignInController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLogin = controller.isLogin.value;
      return Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            (isLogin ? 'auth_new_to_app' : 'auth_already_have_account').tr,
            style: const TextStyle(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: isLogin ? controller.setSignup : controller.setLogin,
            behavior: HitTestBehavior.opaque,
            child: Text(
              (isLogin ? 'auth_join_sanctuary' : 'auth_title_login').tr,
              style: const TextStyle(
                color: AppColors.authBgTop,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
    });
  }
}
