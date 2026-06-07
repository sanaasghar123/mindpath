import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/utils/app_colors.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
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
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: AppColors.authTextPrimary,
                      ),
                    ),
                    title: Text(
                      'help_support_title'.tr,
                      style: const TextStyle(
                        color: AppColors.authTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    sliver: SliverList.list(
                      children: [
                        Text(
                          'help_support_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.authTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle('help_support_faq_title'),
                        const SizedBox(height: 10),
                        _Card(
                          children: [
                            _FaqTile(
                              questionKey: 'help_support_faq_q1',
                              answerKey: 'help_support_faq_a1',
                            ),
                            const _Divider(),
                            _FaqTile(
                              questionKey: 'help_support_faq_q2',
                              answerKey: 'help_support_faq_a2',
                            ),
                            const _Divider(),
                            _FaqTile(
                              questionKey: 'help_support_faq_q3',
                              answerKey: 'help_support_faq_a3',
                            ),
                            const _Divider(),
                            _FaqTile(
                              questionKey: 'help_support_faq_q4',
                              answerKey: 'help_support_faq_a4',
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle('help_support_contact_title'),
                        const SizedBox(height: 10),
                        _Card(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.mail_outline_rounded,
                                    size: 40,
                                    color: AppColors.dashboardBrand,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'help_support_contact_email'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.authTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'help_support_contact_response'.tr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.authTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

class _Card extends StatelessWidget {
  const _Card({required this.children});

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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.black.withValues(alpha: 0.04),
      indent: 16,
      endIndent: 16,
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.questionKey,
    required this.answerKey,
  });

  final String questionKey;
  final String answerKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionKey.tr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.authTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answerKey.tr,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.authTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
