import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';

/// كان يفرض ألوان الوضع الفاتح على مساحات الكتابة. صارت مساحات الكتابة شفافة
/// بلون القسم فتقرأ ألوان الثيم الحالي مباشرة، وبقي الصنف لتوافق الاستدعاءات.
class PaperSurface extends StatelessWidget {
  const PaperSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// كارت الكتابة: تعبئة شفافة بلون القسم وحدود بنفس اللون، وعند التركيز تشتد الحدود
/// وتظهر هالة رقيقة، وتتحوّل للأحمر عند وجود خطأ.
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.builder,
    this.focused = false,
    this.hasError = false,
    this.padding = const EdgeInsets.all(AppSpace.l),
  });

  /// يُبنى داخل الكارت الشفاف، فيقرأ ألوانه من [BuildContext] الممرَّر
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
              : a.color.withValues(alpha: focused ? 1 : 0.32);
          final fill = (hasError ? p.danger : a.color).withValues(
            alpha: context.isDark ? 0.12 : 0.08,
          );
          final radius = BorderRadius.circular(AppRadius.l);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(
                color: borderColor,
                width: focused || hasError ? 2 : 1.5,
              ),
              // هالة رقيقة عند التركيز فقط
              boxShadow: focused || hasError
                  ? [
                      BoxShadow(
                        color: (hasError ? p.danger : a.color).withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 14,
                      ),
                    ]
                  : const [],
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

/// شكل حقول النماذج: تعبئة شفافة بلون القسم وحدود بنفس اللون
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
    fillColor: a.color.withValues(alpha: 0.07),
    border: border(a.color.withValues(alpha: 0.30)),
    enabledBorder: border(a.color.withValues(alpha: 0.30)),
    focusedBorder: border(a.color, 1.5),
    errorBorder: border(p.danger),
    focusedErrorBorder: border(p.danger, 1.5),
  );
}

/// يبني حقلاً داخل نموذج (يحافظ على الاسم القديم للتوافق)
class PaperField extends StatelessWidget {
  const PaperField({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PaperSurface(child: Builder(builder: builder));
  }
}
