import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';

/// بطاقة موحدة للتطبيق: حدود ناعمة، ضغطة بتأثير تصغير، وتموّج عند اللمس.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.l),
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.radius = AppRadius.l,
    this.gradient,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final Gradient? gradient;
  final bool elevated;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final interactive = widget.onTap != null || widget.onLongPress != null;
    final radius = BorderRadius.circular(widget.radius);

    Widget content = Padding(padding: widget.padding, child: widget.child);
    if (widget.gradient != null) {
      content = Ink(
        decoration: BoxDecoration(gradient: widget.gradient),
        child: content,
      );
    }
    if (interactive) {
      content = InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        child: content,
      );
    }

    Widget card = Material(
      color: widget.gradient != null
          ? Colors.transparent
          : (widget.color ?? p.surface),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: widget.gradient != null
              ? Colors.transparent
              : (widget.borderColor ?? p.border),
        ),
      ),
      child: content,
    );

    if (widget.elevated) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: card,
      );
    }

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: card,
    );
  }
}
