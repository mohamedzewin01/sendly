import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import 'gradient_button.dart';

enum SnackKind { success, error, info }

/// رسائل التنبيه العائمة (Snackbar) بالشكل الموحد للتطبيق
class AppSnack {
  static void show(
    BuildContext context,
    String message, {
    SnackKind kind = SnackKind.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final p = context.palette;
    final (IconData icon, Color color) = switch (kind) {
      SnackKind.success => (Icons.check_circle_rounded, p.success),
      SnackKind.error => (Icons.error_rounded, p.danger),
      SnackKind.info => (Icons.info_rounded, p.primary),
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        content: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => show(
    context,
    message,
    kind: SnackKind.success,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void error(BuildContext context, String message) =>
      show(context, message, kind: SnackKind.error);

  AppSnack._();
}

/// تنفيذ عملية مع عرض رسالة نجاح أو خطأ تلقائياً
Future<bool> runGuarded(
  BuildContext context,
  Future<void> Function() action, {
  String? success,
}) async {
  try {
    await action();
    if (success != null && context.mounted) AppSnack.success(context, success);
    return true;
  } catch (e) {
    if (context.mounted) AppSnack.error(context, errorText(e));
    return false;
  }
}

/// نص الخطأ بدون أسماء الأنواع التقنية
String errorText(Object error) {
  final text = error.toString();
  return text
      .replaceFirst(RegExp(r'^(Exception|MessagingException): '), '')
      .trim();
}

/// حوار تأكيد بالشكل الموحد. يرجع true عند التأكيد.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'تأكيد',
  String cancelText = 'إلغاء',
  bool destructive = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final p = context.palette;
      final accent = destructive ? p.danger : p.primary;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 30),
              ),
              const SizedBox(height: AppSpace.l),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpace.s),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: p.inkSoft,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              GradientButton(
                label: confirmText,
                height: 52,
                gradient: destructive
                    ? LinearGradient(colors: [p.danger, p.danger])
                    : null,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: AppSpace.s),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: p.inkSoft,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(cancelText),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
