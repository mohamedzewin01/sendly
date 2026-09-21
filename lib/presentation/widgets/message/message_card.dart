import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../data/models/message.dart';
import '../common/app_card.dart';
import '../format/formatted_text.dart';
import 'category_style.dart';

enum MessageAction { edit, delete }

/// بطاقة الرسالة المحفوظة في القائمة
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.message,
    required this.onTap,
    required this.onSend,
    required this.onCopy,
    required this.onAction,
  });

  final Message message;
  final VoidCallback onTap;
  final VoidCallback onSend;
  final VoidCallback onCopy;
  final ValueChanged<MessageAction> onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final category = message.category;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.l,
        AppSpace.m,
        AppSpace.s,
        AppSpace.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.tone(context).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Icon(
                  category.icon,
                  color: category.tone(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.displayName,
                      style: context.text.bodySmall?.copyWith(
                        color: category.tone(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<MessageAction>(
                tooltip: 'المزيد',
                icon: Icon(Icons.more_vert_rounded, color: p.inkFaint),
                onSelected: onAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: MessageAction.edit,
                    child: _menuRow(context, Icons.edit_rounded, 'تعديل'),
                  ),
                  PopupMenuItem(
                    value: MessageAction.delete,
                    child: _menuRow(
                      context,
                      Icons.delete_rounded,
                      'حذف',
                      danger: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpace.m),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpace.m),
            child: FormattedText(
              message.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textDirection: message.textDirection,
              style: context.text.bodyMedium?.copyWith(
                color: p.inkSoft,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.m),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpace.s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    [
                      '${message.wordCount} كلمة',
                      if (message.usageCount > 0)
                        'استُخدمت ${message.usageCount} مرة',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: p.inkFaint),
                  ),
                ),
                const SizedBox(width: AppSpace.s),
                _RoundAction(
                  icon: Icons.copy_rounded,
                  tooltip: 'نسخ',
                  onTap: onCopy,
                ),
                const SizedBox(width: 6),
                _SendPill(onTap: onSend),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(
    BuildContext context,
    IconData icon,
    String label, {
    bool danger = false,
  }) {
    final p = context.palette;
    return Row(
      children: [
        Icon(icon, size: 20, color: danger ? p.danger : p.inkSoft),
        const SizedBox(width: 12),
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: danger ? p.danger : p.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.s),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: p.inkSoft),
          ),
        ),
      ),
    );
  }
}

class _SendPill extends StatelessWidget {
  const _SendPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.accent.soft,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send_rounded, size: 17, color: context.accent.color),
              const SizedBox(width: 6),
              Text(
                'إرسال',
                style: context.text.labelLarge?.copyWith(
                  color: context.accent.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
