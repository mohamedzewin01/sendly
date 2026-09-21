import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../common/app_sheet.dart';

/// رموز تعبيرية شائعة في الرسائل، مقسّمة حسب الاستخدام
const Map<String, List<String>> _emojiGroups = {
  'الأكثر استخداماً': [
    '👍',
    '🙏',
    '❤️',
    '😊',
    '😂',
    '🔥',
    '✨',
    '🎉',
    '👏',
    '💯',
    '✅',
    '⭐',
  ],
  'وجوه': [
    '😀',
    '😍',
    '🥰',
    '😎',
    '🤝',
    '😉',
    '🤔',
    '😅',
    '🥳',
    '😢',
    '😇',
    '🤗',
  ],
  'للتنبيه والمواعيد': [
    '📌',
    '📍',
    '⏰',
    '📅',
    '📞',
    '💬',
    '📎',
    '🔔',
    '⚠️',
    '❗',
    '❓',
    '➡️',
  ],
  'أعمال ومناسبات': [
    '🛍️',
    '🎁',
    '💰',
    '🏷️',
    '📦',
    '🚚',
    '🌙',
    '🕌',
    '☕',
    '🌹',
    '🎂',
    '🤲',
  ],
};

/// يفتح لوحة رموز تعبيرية سريعة ويرجع الرمز المختار
Future<String?> showEmojiSheet(BuildContext context) {
  return showAppSheet<String>(context, builder: (_) => const _EmojiSheet());
}

class _EmojiSheet extends StatelessWidget {
  const _EmojiSheet();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SheetScaffold(
      title: 'رموز تعبيرية',
      subtitle: 'اضغط على رمز لإدراجه في الرسالة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in _emojiGroups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpace.s,
                bottom: AppSpace.s,
              ),
              child: Text(
                entry.key,
                style: context.text.labelLarge?.copyWith(
                  color: p.inkSoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final emoji in entry.value)
                  Material(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      onTap: () => Navigator.of(context).pop(emoji),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
