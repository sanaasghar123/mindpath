import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindpath/utils/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

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
              child: DefaultTabController(
                length: 2,
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
                        'privacy_policy_title'.tr,
                        style: const TextStyle(
                          color: AppColors.authTextPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      centerTitle: true,
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                      sliver: SliverList.list(
                        children: [
                          _PolicyContent(),
                        ],
                      ),
                    ),
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.dashboardBgBottom,
      child: TabBar(
        labelColor: AppColors.dashboardBrand,
        unselectedLabelColor: AppColors.authTextSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
        indicatorColor: AppColors.dashboardBrand,
        indicatorWeight: 3,
        tabs: [
          Tab(text: 'privacy_policy_tab_policy'.tr),
          Tab(text: 'privacy_policy_tab_terms'.tr),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _PolicyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: TabBarView(
        children: [
          _PrivacyTab(),
          _TermsTab(),
        ],
      ),
    );
  }
}

class _PrivacyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ScrollableContent(
      children: [
        _Section(
          titleKey: 'privacy_policy_intro',
          isIntro: true,
        ),
        _Section(
          timestampKey: 'privacy_policy_last_updated',
        ),
        _Section(
          titleKey: 'privacy_policy_section1_title',
          bodyKey: 'privacy_policy_section1_body',
        ),
        _Section(
          titleKey: 'privacy_policy_section2_title',
          bodyKey: 'privacy_policy_section2_body',
        ),
        _Section(
          titleKey: 'privacy_policy_section3_title',
          bodyKey: 'privacy_policy_section3_body',
        ),
        _Section(
          titleKey: 'privacy_policy_section4_title',
          bodyKey: 'privacy_policy_section4_body',
        ),
        _Section(
          titleKey: 'privacy_policy_section5_title',
          bodyKey: 'privacy_policy_section5_body',
        ),
      ],
    );
  }
}

class _TermsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ScrollableContent(
      children: [
        _Section(
          titleKey: 'terms_of_service_intro',
          isIntro: true,
        ),
        _Section(
          timestampKey: 'terms_of_service_last_updated',
        ),
        _Section(
          titleKey: 'terms_of_service_section1_title',
          bodyKey: 'terms_of_service_section1_body',
        ),
        _Section(
          titleKey: 'terms_of_service_section2_title',
          bodyKey: 'terms_of_service_section2_body',
        ),
        _Section(
          titleKey: 'terms_of_service_section3_title',
          bodyKey: 'terms_of_service_section3_body',
        ),
        _Section(
          titleKey: 'terms_of_service_section4_title',
          bodyKey: 'terms_of_service_section4_body',
        ),
        _Section(
          titleKey: 'terms_of_service_section5_title',
          bodyKey: 'terms_of_service_section5_body',
        ),
      ],
    );
  }
}

class _ScrollableContent extends StatelessWidget {
  const _ScrollableContent({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    this.titleKey,
    this.bodyKey,
    this.timestampKey,
    this.isIntro = false,
  });

  final String? titleKey;
  final String? bodyKey;
  final String? timestampKey;
  final bool isIntro;

  @override
  Widget build(BuildContext context) {
    if (timestampKey != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Text(
          timestampKey!.tr,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.authTextSecondary.withValues(alpha: 0.8),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleKey != null)
            Text(
              titleKey!.tr,
              style: TextStyle(
                fontSize: isIntro ? 14 : 16,
                fontWeight: isIntro ? FontWeight.w500 : FontWeight.w800,
                color: isIntro
                    ? AppColors.authTextSecondary
                    : AppColors.authTextPrimary,
                height: 1.5,
              ),
            ),
          if (titleKey != null && bodyKey != null)
            const SizedBox(height: 8),
          if (bodyKey != null)
            Text(
              bodyKey!.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.authTextSecondary,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}
