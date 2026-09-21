import 'package:flutter/material.dart';

/// مجموعة من الوظائف المساعدة المستخدمة في التطبيق
class AppUtils {
  /// تنسيق التاريخ والوقت بشكل نسبي (منذ ...)
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// اقتطاع النص
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// التحقق من كون النص عربي
  static bool isArabicText(String text) {
    final arabicPattern = RegExp(r'[؀-ۿ]');
    return arabicPattern.hasMatch(text);
  }

  /// الحصول على اتجاه النص
  static TextDirection getTextDirection(String text) {
    return isArabicText(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// حساب مدة القراءة المقدرة للنص
  static Duration estimateReadingTime(String text) {
    const wordsPerMinute = 200; // متوسط سرعة القراءة
    final wordCount = text.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return Duration(minutes: minutes.clamp(1, 60));
  }

  /// تنظيف النص من المسافات الزائدة
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// منع إنشاء كائن من هذه الفئة
  AppUtils._();
}
