import 'package:flutter/material.dart';

/// ثوابت التطبيق والألوان والتدرجات
class AppConstants {
  // ألوان الواتساب الرسمية
  static const Color whatsappGreen = Color(0xFF25D366);
  static const Color whatsappDarkGreen = Color(0xFF128C7E);
  static const Color whatsappLight = Color(0xFFDCF8C6);
  static const Color whatsappBlue = Color(0xFF34B7F1);

  // ألوان التطبيق الأساسية
  static const Color primaryBlue = Color(0xFF667eea);
  static const Color primaryPurple = Color(0xFF764ba2);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color warningOrange = Color(0xFFF39C12);
  static const Color infoBlue = Color(0xFF3498DB);

  // ألوان إضافية
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onSurfaceColor = Color(0xFF212529);
  static const Color dividerColor = Color(0xFFE9ECEF);

  // التدرجات اللونية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient whatsappGradient = LinearGradient(
    colors: [whatsappGreen, whatsappDarkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, Color(0xFF2ECC71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorRed, Color(0xFFC0392B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // أبعاد ومسافات
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 20.0;

  static const double defaultElevation = 4.0;
  static const double smallElevation = 2.0;
  static const double largeElevation = 8.0;

  // أحجام الخطوط
  static const double titleLarge = 24.0;
  static const double titleMedium = 20.0;
  static const double titleSmall = 18.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double captionSize = 10.0;

  // أحجام الأيقونات
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconExtraLarge = 48.0;

  // المدة الزمنية للرسوم المتحركة
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // نقاط الكسر للاستجابة
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  // قيود وحدود
  static const int maxContactsPerBulkSend = 100;
  static const int maxMessageLength = 4096;
  static const int maxContactNameLength = 50;
  static const int maxMessageTitleLength = 100;

  // مفاتيح التخزين المحلي
  static const String contactsKey = 'contacts';
  static const String messagesKey = 'messages';
  static const String settingsKey = 'settings';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';

  // روابط ومعرفات
  static const String whatsappBaseUrl = 'https://wa.me/';
  static const String supportEmail = 'support@whatsapphelper.com';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // رسائل النظام
  static const String loadingMessage = 'جاري التحميل...';
  static const String noDataMessage = 'لا توجد بيانات';
  static const String errorMessage = 'حدث خطأ غير متوقع';
  static const String successMessage = 'تم بنجاح';

  // منع إنشاء كائن من هذه الفئة
  AppConstants._();
}