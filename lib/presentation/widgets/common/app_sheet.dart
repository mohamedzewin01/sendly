import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_theme.dart';

/// يفتح ورقة سفلية (Bottom Sheet) بالمقاسات والشكل الموحدين للتطبيق
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  // الورقة تُبنى تحت الـ Navigator، فنمرّر لها لون القسم الذي فتحها يدوياً
  final accent = AccentTheme.maybeOf(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: AppSpace.maxContentWidth),
    builder: (sheetContext) => accent == null
        ? builder(sheetContext)
        : AccentScope(accent: accent, child: builder(sheetContext)),
  );
}

/// هيكل موحد لمحتوى الورقة السفلية: عنوان + محتوى قابل للتمرير + تذييل ثابت.
/// يتحرك تلقائياً مع ظهور لوحة المفاتيح.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.footer,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    // مساحة أزرار/شريط النظام السفلي: تُضاف تحت التذييل حتى لا يُغطّي الزر (إلا مع لوحة المفاتيح)
    final systemBottom = bottomInset > 0
        ? 0.0
        : MediaQuery.viewPaddingOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.xl,
                0,
                AppSpace.xl,
                AppSpace.m,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpace.m),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: context.text.bodySmall?.copyWith(
                                color: p.inkSoft,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                child: child,
              ),
            ),
            if (footer != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.xl,
                  AppSpace.m,
                  AppSpace.xl,
                  AppSpace.xxl + systemBottom,
                ),
                child: footer,
              )
            else
              SizedBox(height: AppSpace.xl + systemBottom),
          ],
        ),
      ),
    );
  }
}
