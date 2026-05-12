import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mindpath/screens/journal_entry_detail/journal_entry_detail_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class JournalEntryDetailView extends GetView<JournalEntryDetailController> {
  const JournalEntryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('mood_entry_title'.tr),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.authTextPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
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
              child: Obx(() {
                final entry = controller.record.value;
                if (entry == null) {
                  return Center(
                    child: Text('journal_detail_entry_not_found'.tr),
                  );
                }
                if (controller.consumeAutoOpenInsight()) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    Get.bottomSheet(
                      _InsightSheet(controller: controller),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  });
                }
                final ts = entry.timestamp?.toDate();
                final timestampLabel = ts == null
                    ? 'common_pending'.tr
                    : _formatTimestamp(ts);

                final tags = <String>[
                  if (entry.moodLabel.trim().isNotEmpty) entry.moodLabel,
                  if (entry.sentiment.trim().isNotEmpty) entry.sentiment,
                  if (entry.emotion.trim().isNotEmpty) entry.emotion,
                ];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoCard(
                        title: 'common_mood'.tr,
                        value: entry.moodLabel.trim().isEmpty
                            ? entry.emotion
                            : entry.moodLabel,
                        subtitle: timestampLabel,
                        tags: tags,
                        score: entry.moodScore,
                      ),
                      const SizedBox(height: 14),
                      _TextCard(
                        title: 'journal_detail_journal_text'.tr,
                        child: Obx(() {
                          final editing = controller.isEditing.value;
                          if (!editing) {
                            return Text(
                              entry.moodText,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: AppColors.authTextSecondary,
                              ),
                            );
                          }
                          return TextField(
                            controller: controller.moodTextController,
                            maxLines: 8,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      Obx(() {
                        final editing = controller.isEditing.value;
                        if (!editing) {
                          return Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: 'journal_detail_ai_insight'.tr,
                                  onPressed: () {
                                    Get.bottomSheet(
                                      _InsightSheet(controller: controller),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    );
                                  },
                                  height: 52,
                                  backgroundColor: AppColors.dashboardBrand,
                                  prefixIcon: Icons.auto_awesome_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  label: 'common_edit'.tr,
                                  onPressed: controller.startEdit,
                                  height: 52,
                                  variant: CustomButtonVariant.outlined,
                                  foregroundColor: AppColors.dashboardBrand,
                                  prefixIcon: Icons.edit_rounded,
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _EditControls(controller: controller),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    label: 'common_save'.tr,
                                    onPressed: controller.saveEdit,
                                    height: 52,
                                    backgroundColor: AppColors.primary,
                                    prefixIcon: Icons.check_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    label: 'common_cancel'.tr,
                                    onPressed: controller.cancelEdit,
                                    height: 52,
                                    variant: CustomButtonVariant.outlined,
                                    foregroundColor:
                                        AppColors.authTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 14),
                      CustomButton(
                        label: 'journal_delete_entry_title'.tr,
                        onPressed: () async {
                          final confirmed = await Get.dialog<bool>(
                            AlertDialog(
                              title: Text('journal_delete_entry_title'.tr),
                              content: Text('journal_delete_entry_body'.tr),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: Text('common_cancel'.tr),
                                ),
                                TextButton(
                                  onPressed: () => Get.back(result: true),
                                  child: Text('common_delete'.tr),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          await controller.deleteEntry();
                        },
                        height: 52,
                        variant: CustomButtonVariant.outlined,
                        foregroundColor: Colors.red.shade700,
                        prefixIcon: Icons.delete_outline_rounded,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.tags,
    required this.score,
  });

  final String title;
  final String value;
  final String subtitle;
  final List<String> tags;
  final double score;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.authTextSecondary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.authTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.authTextSecondary.withValues(
                            alpha: 0.95,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.03),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'common_score'.tr,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.authTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          score.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.authTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in tags)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.dashboardBrand.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.dashboardBrand.withValues(
                            alpha: 0.18,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          t.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.dashboardBrand,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextSecondary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _EditControls extends StatelessWidget {
  const _EditControls({required this.controller});

  final JournalEntryDetailController controller;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'mood_edit_details'.tr,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
              return DropdownButtonFormField<String>(
                key: ValueKey(controller.moodLabel.value),
                initialValue: controller.moodLabel.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                items: JournalEntryDetailController.moodLabelOptions
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v.toUpperCase()),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (v) {
                  if (v == null) return;
                  controller.moodLabel.value = v;
                },
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'mood_score_value'.trParams({
                      'score': controller.moodScore.value.toStringAsFixed(1),
                    }),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.authTextSecondary,
                    ),
                  ),
                  Slider(
                    value: controller.moodScore.value,
                    min: 0,
                    max: 10,
                    divisions: 20,
                    onChanged: (v) => controller.moodScore.value = v,
                    activeColor: AppColors.dashboardBrand,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _InsightSheet extends StatelessWidget {
  const _InsightSheet({required this.controller});

  final JournalEntryDetailController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 26,
                  offset: const Offset(0, -10),
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'journal_detail_ai_insight'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.authTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: controller.fetchInsight(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'common_generating'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.authTextSecondary.withValues(
                                    alpha: 0.95,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'journal_deep_insight_failed'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700,
                          ),
                        );
                      }
                      final result = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InsightBlock(
                            title: 'common_reflection'.tr,
                            body: result.reflection,
                          ),
                          const SizedBox(height: 10),
                          _InsightBlock(
                            title: 'common_suggestion'.tr,
                            body: result.suggestion,
                          ),
                          const SizedBox(height: 10),
                          _InsightBlock(
                            title: 'common_next_step'.tr,
                            body: result.nextStep,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    label: 'common_close'.tr,
                    onPressed: () => Get.back(),
                    height: 50,
                    variant: CustomButtonVariant.outlined,
                    foregroundColor: AppColors.dashboardBrand,
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

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.authTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppColors.authTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTimestamp(DateTime dt) {
  final loc = Get.locale;
  final localeName = (loc == null)
      ? null
      : (loc.countryCode == null || loc.countryCode!.isEmpty)
      ? loc.languageCode
      : '${loc.languageCode}_${loc.countryCode}';
  return DateFormat.yMMMEd(localeName).add_jm().format(dt);
}
