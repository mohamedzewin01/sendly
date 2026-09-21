import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';

/// زر ترتيب القوائم: قائمة منبثقة بخيارات الترتيب مع علامة على الخيار الحالي
class SortMenuButton<T> extends StatelessWidget {
  const SortMenuButton({
    super.key,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T option) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PopupMenuButton<T>(
      tooltip: 'ترتيب',
      onSelected: onChanged,
      offset: const Offset(0, 52),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<T>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == value ? Icons.check_rounded : null,
                  size: 20,
                  color: context.accent.color,
                ),
                const SizedBox(width: 8),
                Text(
                  labelOf(option),
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: option == value
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(color: p.border),
        ),
        child: Icon(Icons.swap_vert_rounded, color: p.inkSoft),
      ),
    );
  }
}

/// خلفية السحب للحذف في القوائم (Dismissible)
class DeleteSwipeBackground extends StatelessWidget {
  const DeleteSwipeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
      decoration: BoxDecoration(
        color: p.danger.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_rounded, color: p.danger),
          const SizedBox(width: 8),
          Text(
            'حذف',
            style: context.text.labelLarge?.copyWith(
              color: p.danger,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
