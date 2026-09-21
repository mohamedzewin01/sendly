import 'package:flutter/material.dart';

import 'app_palette.dart';

/// ثيم التطبيق (فاتح وداكن) مبني على [AppPalette]
class AppTheme {
  /// خط التطبيق (مضمَّن داخل التطبيق ولا يتطلب اتصالاً بالإنترنت)
  static const String fontFamily = 'Tajawal';

  static ThemeData light() => _build(AppPalette.light, Brightness.light);
  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: p.primarySoft,
      onPrimaryContainer: p.primary,
      secondary: p.ink,
      onSecondary: p.bg,
      error: p.danger,
      onError: Colors.white,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkSoft,
      surfaceContainerHighest: p.surfaceAlt,
      outline: p.border,
      outlineVariant: p.border,
    );

    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = base.textTheme.apply(
      fontFamily: fontFamily,
      fontSizeFactor: 1.06,
      bodyColor: p.ink,
      displayColor: p.ink,
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.m),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.inkFaint),
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.inkSoft),
        helperStyle: textTheme.bodySmall?.copyWith(color: p.inkFaint),
        errorStyle: textTheme.bodySmall?.copyWith(color: p.danger),
        border: inputBorder(Colors.transparent),
        enabledBorder: inputBorder(Colors.transparent),
        focusedBorder: inputBorder(p.primary, 1.6),
        errorBorder: inputBorder(p.danger),
        focusedErrorBorder: inputBorder(p.danger, 1.6),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withValues(alpha: 0.25),
        selectionHandleColor: p.primary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
        dragHandleSize: const Size(44, 4),
        modalBarrierColor: Colors.black.withValues(alpha: 0.45),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          side: BorderSide(color: p.border),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.bg),
        actionTextColor: p.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : p.inkFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : p.surfaceAlt,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? Colors.transparent : p.border,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: p.border)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? p.primarySoft
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.primary : p.inkSoft,
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.action,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 56),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : p.inkSoft,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => textTheme.labelMedium?.copyWith(
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : p.inkSoft,
          ),
        ),
      ),
    );
  }

  /// نسخة من الثيم بلون قسم معيّن: حدود الحقول والمؤشر والمفاتيح وغيرها
  static ThemeData tinted(ThemeData base, AccentColors accent) {
    final focused = base.inputDecorationTheme.focusedBorder;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: accent.color,
        primaryContainer: accent.soft,
        onPrimaryContainer: accent.color,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent.color,
        selectionColor: accent.color.withValues(alpha: 0.25),
        selectionHandleColor: accent.color,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        focusedBorder: focused is OutlineInputBorder
            ? focused.copyWith(
                borderSide: BorderSide(color: accent.color, width: 1.6),
              )
            : focused,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : base.extension<AppPalette>()!.inkFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.color
              : base.extension<AppPalette>()!.surfaceAlt,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : base.extension<AppPalette>()!.border,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent.color),
      // شريط التنقل السفلي: التبويب النشط بلون قسمه
      navigationBarTheme: base.navigationBarTheme.copyWith(
        indicatorColor: accent.soft,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected)
                ? accent.color
                : base.extension<AppPalette>()!.inkSoft,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => base.textTheme.labelMedium?.copyWith(
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
            color: s.contains(WidgetState.selected)
                ? accent.color
                : base.extension<AppPalette>()!.inkSoft,
          ),
        ),
      ),
    );
  }

  AppTheme._();
}

/// يفعّل لون قسم على كل ما تحته: ألوان الويدجت المخصّصة والثيم معاً
class AccentScope extends StatelessWidget {
  const AccentScope({super.key, required this.accent, required this.child});

  final AccentColors accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AccentTheme(
      accent: accent,
      child: Theme(
        data: AppTheme.tinted(Theme.of(context), accent),
        child: child,
      ),
    );
  }
}
