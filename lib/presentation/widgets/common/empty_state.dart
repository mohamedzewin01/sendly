import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import 'gradient_button.dart';
import 'motion.dart';

/// حالة فارغة بأيقونة عائمة ونص وزر اختياري
class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.xxl,
          vertical: AppSpace.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _float,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_float.value);
                return Transform.translate(
                  offset: Offset(0, -8 * t),
                  child: child,
                );
              },
              child: Container(
                width: 132,
                height: 132,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.accent.soft.withValues(alpha: 0.55),
                ),
                child: Container(
                  width: 92,
                  height: 92,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.accent.soft,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 42,
                    color: context.accent.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: AppSpace.s),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: p.inkSoft,
                  height: 1.6,
                ),
              ),
            ],
            if (widget.actionLabel != null && widget.onAction != null) ...[
              const SizedBox(height: AppSpace.xl),
              GradientButton(
                label: widget.actionLabel!,
                icon: Icons.add_rounded,
                onPressed: widget.onAction,
                expanded: false,
                height: 52,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
