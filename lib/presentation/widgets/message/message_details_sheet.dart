import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/message.dart';
import '../../../providers/app_provider.dart';
import '../common/app_feedback.dart';
import '../common/app_sheet.dart';
import '../common/gradient_button.dart';
import '../common/info_pill.dart';
import '../format/formatted_text.dart';
import '../send/send_sheet.dart';
import 'category_style.dart';

/// يفتح تفاصيل الرسالة كاملة مع أزرار الإرسال والنسخ
Future<void> showMessageDetails(BuildContext context, Message message) {
  return showAppSheet<void>(
    context,
    builder: (_) =>
        _MessageDetailsSheet(messageId: message.id, fallback: message),
  );
}

/// ينسخ نص الرسالة ويسجل استخدامها
Future<void> copyMessage(BuildContext context, Message message) async {
  final controller = AppScope.read(context);
  await Clipboard.setData(ClipboardData(text: message.content));
  await controller.recordMessageUsage(message.id);
  if (context.mounted) AppSnack.success(context, 'تم نسخ الرسالة');
}

class _MessageDetailsSheet extends StatelessWidget {
  const _MessageDetailsSheet({required this.messageId, required this.fallback});

  final String messageId;
  final Message fallback;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final message =
        AppScope.of(
          context,
        ).messages.where((m) => m.id == messageId).firstOrNull ??
        fallback;
    final category = message.category;

    return SheetScaffold(
      title: message.title,
      subtitle: category.displayName,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: category.tone(context).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
        child: Icon(category.icon, color: category.tone(context)),
      ),
      footer: Row(
        children: [
          Expanded(
            child: GradientButton(
              label: 'إرسال',
              icon: Icons.send_rounded,
              onPressed: () {
                final parent = Navigator.of(context);
                parent.pop();
                showSendSheet(
                  parent.context,
                  initialMessage: message.content,
                  initialTemplateId: message.id,
                );
              },
            ),
          ),
          const SizedBox(width: AppSpace.m),
          SizedBox(
            height: 56,
            width: 56,
            child: OutlinedButton(
              onPressed: () => copyMessage(context, message),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: p.inkSoft,
                side: BorderSide(color: p.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.m + 2),
                ),
              ),
              child: const Icon(Icons.copy_rounded),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpace.l),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: FormattedText(
              message.content,
              selectable: true,
              textDirection: message.textDirection,
              style: context.text.bodyLarge?.copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: AppSpace.l),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoPill(
                text: '${message.wordCount} كلمة',
                icon: Icons.notes_rounded,
              ),
              InfoPill(
                text: '${message.length} حرف',
                icon: Icons.text_fields_rounded,
              ),
              InfoPill(
                text: AppUtils.formatDateTime(message.createdAt),
                icon: Icons.schedule_rounded,
              ),
              InfoPill(
                text: message.usageCount == 0
                    ? 'لم تُستخدم بعد'
                    : 'استُخدمت ${message.usageCount} مرة',
                icon: Icons.trending_up_rounded,
                color: message.usageCount == 0 ? null : p.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
