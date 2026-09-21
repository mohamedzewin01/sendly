import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/utils/remote_config.dart';
import 'app_feedback.dart';
import 'gradient_button.dart';

/// يعرض حوار التحديث. عند التحديث الإجباري لا يمكن إغلاقه.
Future<void> showUpdateDialog(BuildContext context, UpdateInfo info) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !info.forceUpdate,
    builder: (_) => PopScope(
      canPop: !info.forceUpdate,
      child: _UpdateDialog(info: info),
    ),
  );
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({required this.info});

  final UpdateInfo info;

  Future<void> _openStore(BuildContext context) async {
    final uri = Uri.parse(info.storeUrl);
    try {
      if (!info.forceUpdate) Navigator.of(context).pop();
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        AppSnack.error(context, 'لا يمكن فتح متجر التطبيقات');
      }
    } catch (_) {
      if (context.mounted) {
        AppSnack.error(context, 'حدث خطأ أثناء فتح متجر التطبيقات');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final force = info.forceUpdate;
    final accent = force ? p.danger : p.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                force
                    ? Icons.system_security_update_warning_rounded
                    : Icons.system_update_rounded,
                color: accent,
                size: 34,
              ),
            ),
            const SizedBox(height: AppSpace.l),
            Text(
              force ? 'تحديث مطلوب' : 'تحديث متاح',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpace.s),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Text(
                'الإصدار ${info.latestVersion}',
                style: context.text.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.l),
            Text(
              info.updateMessage ??
                  (force
                      ? 'للاستمرار في استخدام التطبيق بأمان، يجب تحديثه إلى أحدث إصدار.'
                      : 'يتوفر إصدار جديد من التطبيق مع ميزات محسّنة وتحسينات في الأداء.'),
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: p.inkSoft,
                height: 1.7,
              ),
            ),
            if (info.features.isNotEmpty) ...[
              const SizedBox(height: AppSpace.l),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpace.l),
                decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: p.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'الميزات الجديدة',
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s),
                    for (final feature in info.features.take(3))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: p.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                feature.trim(),
                                style: context.text.bodyMedium?.copyWith(
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpace.xl),
            GradientButton(
              label: force ? 'تحديث الآن' : 'تحديث',
              icon: Icons.download_rounded,
              height: 52,
              onPressed: () => _openStore(context),
            ),
            if (!force) ...[
              const SizedBox(height: AppSpace.s),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: p.inkSoft,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('لاحقاً'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
