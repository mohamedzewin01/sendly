import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../data/models/message.dart';

/// شريط أفقي بالرسائل المحفوظة لاختيار قالب بضغطة واحدة
class TemplateChips extends StatelessWidget {
  const TemplateChips({
    super.key,
    required this.messages,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Message> messages;
  final String? selectedId;
  final ValueChanged<Message> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (messages.isEmpty) {
      return Row(
        children: [
          Icon(Icons.bookmark_add_outlined, size: 18, color: p.inkFaint),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'احفظ رسائلك المتكررة من تبويب «الرسائل» لتستخدمها هنا بضغطة.',
              style: context.text.bodySmall?.copyWith(color: p.inkFaint),
            ),
          ),
        ],
      );
    }

    final sorted = [...messages]
      ..sort((a, b) {
        final byUsage = b.usageCount.compareTo(a.usageCount);
        return byUsage != 0 ? byUsage : b.createdAt.compareTo(a.createdAt);
      });
    final visible = sorted.take(12).toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final message = visible[index];
          return _TemplateChip(
            title: message.title,
            selected: message.id == selectedId,
            onTap: () => onSelected(message),
          );
        },
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? context.accent.color : context.accent.soft,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? context.accent.color : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: selected
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(
                  color: selected ? Colors.white : p.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
