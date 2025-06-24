import 'package:flutter/material.dart';
import '../../app/constants/app_constants.dart';

/// مساعد لجعل التطبيق متجاوب مع أحجام الشاشات المختلفة
class ResponsiveHelper {
  /// التحقق من كون الجهاز هاتف محمول
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  /// التحقق من كون الجهاز تابلت
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.tabletBreakpoint;
  }

  /// التحقق من كون الجهاز سطح مكتب
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  /// الحصول على المسافة المناسبة حسب حجم الشاشة
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return AppConstants.defaultPadding;
    if (isTablet(context)) return AppConstants.largePadding;
    return AppConstants.extraLargePadding;
  }

  /// الحصول على عدد الأعمدة المناسب للشبكة
  static int getCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  /// الحصول على حجم الخط المناسب
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  /// الحصول على حجم الأيقونة المناسب
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) return baseIconSize;
    if (isTablet(context)) return baseIconSize * 1.2;
    return baseIconSize * 1.4;
  }

  /// الحصول على ارتفاع البطاقة المناسب
  static double getCardHeight(BuildContext context) {
    if (isMobile(context)) return 120.0;
    if (isTablet(context)) return 140.0;
    return 160.0;
  }

  /// الحصول على عرض الحوار المناسب
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) return screenWidth * 0.9;
    if (isTablet(context)) return screenWidth * 0.7;
    return 600.0;
  }

  /// التحقق من الاتجاه الأفقي
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// التحقق من الاتجاه الرأسي
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// الحصول على ارتفاع الشاشة
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// الحصول على عرض الشاشة
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// الحصول على نسبة العرض إلى الارتفاع للشاشة
  static double getAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  /// التحقق من كون الشاشة صغيرة جداً
  static bool isSmallScreen(BuildContext context) {
    return getScreenHeight(context) < 600 || getScreenWidth(context) < 360;
  }

  /// الحصول على المسافة الآمنة من الأعلى
  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// الحصول على المسافة الآمنة من الأسفل
  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// التحقق من وجود نوتش في الشاشة
  static bool hasNotch(BuildContext context) {
    return getTopSafeArea(context) > 20;
  }

  /// الحصول على نوع الجهاز كنص
  static String getDeviceType(BuildContext context) {
    if (isMobile(context)) return 'Mobile';
    if (isTablet(context)) return 'Tablet';
    return 'Desktop';
  }

  /// التحقق من كون النص يحتاج للف
  static bool shouldWrapText(BuildContext context, String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.rtl,
    );
    textPainter.layout();
    return textPainter.width > getScreenWidth(context) * 0.8;
  }

  /// حساب عدد الأسطر المطلوبة للنص
  static int calculateTextLines(BuildContext context, String text, TextStyle style, double maxWidth) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.rtl,
      maxLines: null,
    );
    textPainter.layout(maxWidth: maxWidth);
    return (textPainter.height / textPainter.preferredLineHeight).ceil();
  }

  /// منع إنشاء كائن من هذه الفئة
  ResponsiveHelper._();
}