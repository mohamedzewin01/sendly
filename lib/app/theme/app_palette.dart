import 'package:flutter/material.dart';

/// المسافات الموحدة: مقياس رحب مبني على مضاعفات 4
class AppSpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 18;
  static const double xl = 24;
  static const double xxl = 32;

  /// أقصى عرض للمحتوى على الشاشات الكبيرة
  static const double maxContentWidth = 640;

  AppSpace._();
}

/// الأنصاف: كروت كبيرة الاستدارة (24) وحقول (16) وأزرار وشرائح على شكل حبة
class AppRadius {
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;

  AppRadius._();
}

/// لون مميّز لقسم من التطبيق: للنص والأيقونات، وخلفية خفيفة، وتدرّج للأزرار
@immutable
class AccentColors {
  const AccentColors({
    required this.color,
    required this.soft,
    required this.gradient,
  });

  final Color color;
  final Color soft;
  final LinearGradient gradient;

  /// لون التوهّج والظل (بداية التدرّج)
  Color get glow => gradient.colors.first;

  static AccentColors lerp(AccentColors a, AccentColors b, double t) {
    return AccentColors(
      color: Color.lerp(a.color, b.color, t)!,
      soft: Color.lerp(a.soft, b.soft, t)!,
      gradient: LinearGradient.lerp(a.gradient, b.gradient, t)!,
    );
  }
}

/// يمرّر اللون المميّز للقسم الحالي إلى كل الويدجت تحته
class AccentTheme extends InheritedWidget {
  const AccentTheme({super.key, required this.accent, required super.child});

  final AccentColors accent;

  static AccentColors? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccentTheme>()?.accent;

  @override
  bool updateShouldNotify(AccentTheme oldWidget) => accent != oldWidget.accent;
}

/// ألوان الهوية البصرية للتطبيق (فاتح / داكن)
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.primary,
    required this.primarySoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.brand,
    required this.send,
    required this.contacts,
    required this.messages,
    required this.settings,
  });

  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color ink;
  final Color inkSoft;
  final Color inkFaint;
  final Color primary;
  final Color primarySoft;
  final Color success;
  final Color warning;
  final Color danger;

  /// التدرج الرئيسي للأزرار والعناصر البارزة
  final LinearGradient brand;

  /// لون كل قسم: الإرسال، الجهات، الرسائل، الإعدادات
  final AccentColors send;
  final AccentColors contacts;
  final AccentColors messages;
  final AccentColors settings;

  /// هوية «رمل وفيروز»: كريمي دافئ + فيروزي عميق، وكل قسم بلون ترابي خاص به.
  /// تعبئة الأزرار مصمتة (بلا تدرج) والتدرج للبطاقة الرئيسية في الإعدادات فقط.
  static const LinearGradient _brandLight = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF0A4F4A)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
  static const LinearGradient _brandDark = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF0A4F4A)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient _tealFill = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF0F766E)],
  );
  static const LinearGradient _coralFill = LinearGradient(
    colors: [Color(0xFFD9472F), Color(0xFFD9472F)],
  );
  static const LinearGradient _plumFill = LinearGradient(
    colors: [Color(0xFF7B3FA0), Color(0xFF7B3FA0)],
  );
  static const LinearGradient _amberFill = LinearGradient(
    colors: [Color(0xFFA8631A), Color(0xFFA8631A)],
  );

  static const AccentColors _sendLight = AccentColors(
    color: Color(0xFF0F766E),
    soft: Color(0xFFD9F0EC),
    gradient: _tealFill,
  );
  static const AccentColors _contactsLight = AccentColors(
    color: Color(0xFFD9472F),
    soft: Color(0xFFFDE3DC),
    gradient: _coralFill,
  );
  static const AccentColors _messagesLight = AccentColors(
    color: Color(0xFF7B3FA0),
    soft: Color(0xFFF1E4F8),
    gradient: _plumFill,
  );
  static const AccentColors _settingsLight = AccentColors(
    color: Color(0xFFA8631A),
    soft: Color(0xFFFAE9CF),
    gradient: _amberFill,
  );

  static const AccentColors _sendDark = AccentColors(
    color: Color(0xFF4FD1BF),
    soft: Color(0xFF15332F),
    gradient: _tealFill,
  );
  static const AccentColors _contactsDark = AccentColors(
    color: Color(0xFFFF8F78),
    soft: Color(0xFF3C1F19),
    gradient: _coralFill,
  );
  static const AccentColors _messagesDark = AccentColors(
    color: Color(0xFFD2A6EC),
    soft: Color(0xFF33203F),
    gradient: _plumFill,
  );
  static const AccentColors _settingsDark = AccentColors(
    color: Color(0xFFF0B45C),
    soft: Color(0xFF3A2B14),
    gradient: _amberFill,
  );

  static const AppPalette light = AppPalette(
    bg: Color(0xFFFBF6EE),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF5EDE1),
    border: Color(0xFFE9DECD),
    ink: Color(0xFF221A14),
    inkSoft: Color(0xFF6A5B4E),
    inkFaint: Color(0xFF8C7B6C),
    primary: Color(0xFF0F766E),
    primarySoft: Color(0xFFD9F0EC),
    success: Color(0xFF2F9E44),
    warning: Color(0xFFC77D0A),
    danger: Color(0xFFD0342C),
    brand: _brandLight,
    send: _sendLight,
    contacts: _contactsLight,
    messages: _messagesLight,
    settings: _settingsLight,
  );

  static const AppPalette dark = AppPalette(
    bg: Color(0xFF16110E),
    surface: Color(0xFF211A15),
    surfaceAlt: Color(0xFF2C231D),
    border: Color(0xFF3B2F26),
    ink: Color(0xFFF6EDE2),
    inkSoft: Color(0xFFBBAA99),
    inkFaint: Color(0xFF8D7D6D),
    primary: Color(0xFF4FD1BF),
    primarySoft: Color(0xFF15332F),
    success: Color(0xFF5BD68A),
    warning: Color(0xFFF0B45C),
    danger: Color(0xFFFF8A80),
    brand: _brandDark,
    send: _sendDark,
    contacts: _contactsDark,
    messages: _messagesDark,
    settings: _settingsDark,
  );

  /// لون تعبئة الأزرار المصمتة
  Color get action => brand.colors.first;

  /// لون القسم المناسب للسطح الأبيض (النسخة الغامقة من اللون بدل الفاتحة)
  static AccentColors onPaper(AccentColors a) {
    if (identical(a, dark.send)) return light.send;
    if (identical(a, dark.contacts)) return light.contacts;
    if (identical(a, dark.messages)) return light.messages;
    if (identical(a, dark.settings)) return light.settings;
    return a;
  }

  @override
  AppPalette copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? ink,
    Color? inkSoft,
    Color? inkFaint,
    Color? primary,
    Color? primarySoft,
    Color? success,
    Color? warning,
    Color? danger,
    LinearGradient? brand,
    AccentColors? send,
    AccentColors? contacts,
    AccentColors? messages,
    AccentColors? settings,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      brand: brand ?? this.brand,
      send: send ?? this.send,
      contacts: contacts ?? this.contacts,
      messages: messages ?? this.messages,
      settings: settings ?? this.settings,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      brand: LinearGradient.lerp(brand, other.brand, t)!,
      send: AccentColors.lerp(send, other.send, t),
      contacts: AccentColors.lerp(contacts, other.contacts, t),
      messages: AccentColors.lerp(messages, other.messages, t),
      settings: AccentColors.lerp(settings, other.settings, t),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  /// لون القسم الحالي (أو لون الإرسال الأزرق إن لم يكن هناك قسم)
  AccentColors get accent => AccentTheme.maybeOf(this) ?? palette.send;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  TextTheme get text => Theme.of(this).textTheme;
}
