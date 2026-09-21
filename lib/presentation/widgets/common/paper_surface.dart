import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_theme.dart';

/// يجعل كل ما تحته يُرسم بألوان الوضع الفاتح حتى لو كان التطبيق في الوضع الداكن،
/// فتبقى مساحات الكتابة «ورقة بيضاء» واضحة ومريحة للعين في الوضعين.
class PaperSurface extends StatelessWidget {
  const PaperSurface({super.key, required this.child});

  final Widget child;

  static final ThemeData _light = AppTheme.light();

  @override
  Widget build(BuildContext context) {
    if (!context.isDark) return child;

    final accent = AppPalette.onPaper(context.accent);
    return AccentTheme(
      accent: accent,
      child: Theme(
        data: AppTheme.tinted(_light, accent),
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return DefaultTextStyle(
              style: theme.textTheme.bodyMedium!,
              child: IconTheme(
                data: IconThemeData(
                  color: theme.extension<AppPalette>()!.inkSoft,
                ),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// كارت أبيض للكتابة: حدود ناعمة وظل مزرق خفيف، وعند التركيز تتلوّن الحدود
/// وتظهر هالة رقيقة، وتتحوّل للأحمر عند وجود خطأ.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.builder,
    this.focused = false,
    this.hasError = false,
    this.padding = const EdgeInsets.all(AppSpace.l),
  });

  /// يُبنى داخل السطح الأبيض، فيقرأ ألوانه من [BuildContext] الممرَّر
  final WidgetBuilder builder;
  final bool focused;
  final bool hasError;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return PaperSurface(
      child: Builder(
        builder: (context) {
          final p = context.palette;
          final a = context.accent;
          final borderColor = hasError
              ? p.danger
              : focused
              ? a.color
              : p.border;
          final radius = BorderRadius.circular(AppRadius.l);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: radius,
              border: Border.all(
                color: borderColor,
                width: focused || hasError ? 2 : 1.5,
              ),
              // حافة سفلية سميكة تعطي الكارت إحساس الورقة المرفوعة بدل الظل الناعم
              boxShadow: [
                BoxShadow(
                  color: hasError ? p.danger : (focused ? a.color : p.border),
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(padding: padding, child: builder(context)),
          );
        },
      ),
    );
  }
}

/// عنوان صغير لكارت الكتابة: أيقونة داخل مربع بلون القسم ثم النص
class PaperLabel extends StatelessWidget {
  const PaperLabel(this.text, {super.key, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = context.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: a.soft,
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Icon(icon, size: 16, color: a.color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: context.text.labelLarge?.copyWith(
            color: p.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// شكل حقول النماذج على الورقة البيضاء: تعبئة بيضاء وحدود خفيفة بلون القسم
InputDecoration paperFieldDecoration(
  BuildContext context, {
  String? labelText,
  String? hintText,
  TextDirection? hintTextDirection,
  Widget? prefixIcon,
  bool alignLabelWithHint = false,
  String? counterText,
}) {
  final p = context.palette;
  final a = context.accent;

  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    hintTextDirection: hintTextDirection,
    prefixIcon: prefixIcon,
    prefixIconColor: a.color,
    alignLabelWithHint: alignLabelWithHint,
    counterText: counterText,
    filled: true,
    fillColor: p.surface,
    border: border(p.border),
    enabledBorder: border(p.border),
    focusedBorder: border(a.color, 1.5),
    errorBorder: border(p.danger),
    focusedErrorBorder: border(p.danger, 1.5),
  );
}

/// يبني حقلاً على سطح أبيض (للنماذج داخل الأوراق السفلية في الوضع الداكن)
class PaperField extends StatelessWidget {
  const PaperField({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PaperSurface(child: Builder(builder: builder));
  }
}
