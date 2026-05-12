import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mindpath/screens/journal_detail/journal_detail_controller.dart';
import 'package:mindpath/utils/app_colors.dart';
import 'package:mindpath/widgets/custom_button.dart';

class JournalDetailView extends GetView<JournalDetailController> {
  const JournalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('journal_detail_title'.tr),
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
                final entry = controller.entry.value;
                if (entry == null) {
                  return Center(child: Text('journal_detail_entry_not_found'.tr));
                }
                final ts = entry.createdAt?.toDate();
                final dateLabel =
                    ts == null ? 'common_pending'.tr : _formatDate(ts);
                final chip = _chipColors(entry.emotion);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.03),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.title.isEmpty
                                              ? 'journal_fallback_title'.tr
                                              : entry.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.authTextPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.authTextSecondary.withValues(alpha: 0.95),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: chip.$1,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: chip.$2.withValues(alpha: 0.25)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      child: Text(
                                        entry.emotion.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          letterSpacing: 1.1,
                                          fontWeight: FontWeight.w900,
                                          color: chip.$2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (entry.tags.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final t in entry.tags)
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppColors.dashboardBrand.withValues(alpha: 0.10),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(
                                            color: AppColors.dashboardBrand.withValues(alpha: 0.18),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Card(
                        title: 'journal_detail_journal_text'.tr,
                        child: Obx(() {
                          final editing = controller.isEditing.value;
                          if (!editing) {
                            return Text(
                              entry.text,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                                color: AppColors.authTextSecondary,
                              ),
                            );
                          }
                          return TextField(
                            controller: controller.textController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 14),
                      _Card(
                        title: 'journal_detail_ai_insight'.tr,
                        child: Text(
                          entry.insight.isEmpty
                              ? 'journal_no_insight_yet'.tr
                              : entry.insight,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authTextSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Obx(() {
                        final editing = controller.isEditing.value;
                        if (editing) {
                          return Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: controller.isLoading.value
                                      ? 'common_saving'.tr
                                      : 'common_save'.tr,
                                  onPressed: controller.isLoading.value ? null : controller.saveEdit,
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
                                  foregroundColor: AppColors.authTextSecondary,
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: 'journal_detail_deeper_ai_insight'.tr,
                                onPressed: () {
                                  Get.bottomSheet(
                                    _DeepInsightSheet(controller: controller),
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

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

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

class _DeepInsightSheet extends StatelessWidget {
  const _DeepInsightSheet({required this.controller});

  final JournalDetailController controller;

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    'journal_detail_deeper_ai_insight'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.authTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: controller.fetchDeepInsight(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'common_generating'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.authTextSecondary.withValues(alpha: 0.95),
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
                          _Block(
                            title: 'common_reflection'.tr,
                            body: result.reflection,
                          ),
                          const SizedBox(height: 10),
                          _Block(
                            title: 'common_suggestion'.tr,
                            body: result.suggestion,
                          ),
                          const SizedBox(height: 10),
                          _Block(
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

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body});

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

(Color, Color) _chipColors(String emotion) {
  final e = emotion.toLowerCase().trim();
  if (e == 'joy') return (const Color(0xFFEFFDF4), const Color(0xFF16A34A));
  if (e == 'calm') return (const Color(0xFFF1F5F9), const Color(0xFF334155));
  if (e == 'stress') return (const Color(0xFFFFF7ED), const Color(0xFFB45309));
  if (e == 'anxiety') return (const Color(0xFFFEE2E2), const Color(0xFFB91C1C));
  return (const Color(0xFFF1F6FF), AppColors.dashboardBrand);
}

String _formatDate(DateTime dt) {
  final loc = Get.locale;
  final localeName = (loc == null)
      ? null
      : (loc.countryCode == null || loc.countryCode!.isEmpty)
          ? loc.languageCode
          : '${loc.languageCode}_${loc.countryCode}';
  return DateFormat.yMMMEd(localeName).add_jm().format(dt);
}
