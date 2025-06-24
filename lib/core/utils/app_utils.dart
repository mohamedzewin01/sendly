import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/app_strings.dart';

/// مجموعة من الوظائف المساعدة المستخدمة في التطبيق
class AppUtils {
  /// عرض رسالة تأكيد مخصصة
  static void showCustomSnackBar(
      BuildContext context,
      String message, {
        bool isError = false,
        bool isSuccess = false,
        bool isWarning = false,
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
      }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = AppConstants.errorRed;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = AppConstants.successGreen;
      icon = Icons.check_circle_outline;
    } else if (isWarning) {
      backgroundColor = AppConstants.warningOrange;
      icon = Icons.warning_outlined;
    } else {
      backgroundColor = AppConstants.whatsappGreen;
      icon = Icons.info_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        duration: duration,
        margin: const EdgeInsets.all(AppConstants.defaultPadding),
        action: action,
      ),
    );
  }

  /// عرض حوار تأكيد
  static Future<bool?> showConfirmDialog(
      BuildContext context,
      String title,
      String content, {
        String confirmText = AppStrings.confirm,
        String cancelText = AppStrings.cancel,
        bool isDestructive = false,
        IconData? icon,
      }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
        icon: icon != null
            ? Icon(
          icon,
          color: isDestructive
              ? AppConstants.errorRed
              : AppConstants.whatsappGreen,
          size: AppConstants.iconLarge,
        )
            : null,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? AppConstants.errorRed
                  : AppConstants.whatsappGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// نسخ النص إلى الحافظة
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      showCustomSnackBar(
        context,
        AppStrings.dataCopiedToClipboard,
        isSuccess: true,
      );
    } catch (e) {
      showCustomSnackBar(
        context,
        'فشل في النسخ: ${e.toString()}',
        isError: true,
      );
    }
  }

  /// تنسيق التاريخ والوقت
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

  /// الحصول على لون الحالة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'sent':
      case 'completed':
        return AppConstants.successGreen;
      case 'error':
      case 'failed':
        return AppConstants.errorRed;
      case 'pending':
      case 'sending':
      case 'loading':
        return AppConstants.warningOrange;
      case 'info':
        return AppConstants.infoBlue;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على أيقونة الحالة
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'sent':
      case 'completed':
        return Icons.check_circle;
      case 'error':
      case 'failed':
        return Icons.error;
      case 'pending':
      case 'sending':
      case 'loading':
        return Icons.schedule;
      case 'info':
        return Icons.info;
      default:
        return Icons.help_outline;
    }
  }

  /// اقتطاع النص
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// التحقق من كون النص عربي
  static bool isArabicText(String text) {
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    return arabicPattern.hasMatch(text);
  }

  /// الحصول على اتجاه النص
  static TextDirection getTextDirection(String text) {
    return isArabicText(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// تحويل الرقم إلى تنسيق مقروء
  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  /// تحويل البايتات إلى تنسيق مقروء
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// إنشاء معرف فريد
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailPattern.hasMatch(email);
  }

  /// تنظيف النص من المسافات الزائدة
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// عرض حوار تحميل
  static void showLoadingDialog(BuildContext context, [String? message]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.whatsappGreen,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                message ?? AppStrings.loading,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// إخفاء حوار التحميل
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// تشغيل اهتزاز بسيط
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // تجاهل الخطأ إذا لم يكن الاهتزاز مدعوماً
    }
  }

  /// تشغيل اهتزاز متوسط
  static Future<void> vibrateImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  /// تشغيل اهتزاز قوي
  static Future<void> vibrateHeavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  /// التحقق من الاتصال بالإنترنت (يحتاج مكتبة connectivity_plus)
  static Future<bool> hasInternetConnection() async {
    try {
      // في التطبيق الحقيقي، استخدم connectivity_plus package
      return true; // افتراضي
    } catch (e) {
      return false;
    }
  }

  /// حساب مدة القراءة المقدرة للنص
  static Duration estimateReadingTime(String text) {
    const wordsPerMinute = 200; // متوسط سرعة القراءة
    final wordCount = text.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return Duration(minutes: minutes.clamp(1, 60));
  }

  /// تحويل اللون إلى كود hex
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// تحويل كود hex إلى لون
  static Color hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  /// التحقق من كون الرقم في النطاق المحدد
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  /// إنشاء تأخير زمني
  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }

  /// تنفيذ دالة مع إعادة المحاولة
  static Future<T?> retryFunction<T>(
      Future<T> Function() function, {
        int maxRetries = 3,
        Duration delay = const Duration(seconds: 1),
      }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await function();
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(delay);
      }
    }
    return null;
  }

  /// فرز قائمة النصوص أبجدياً (دعم العربية)
  static List<String> sortArabicTexts(List<String> texts) {
    return texts..sort((a, b) {
      // إزالة التشكيل للمقارنة
      final cleanA = _removeArabicDiacritics(a);
      final cleanB = _removeArabicDiacritics(b);
      return cleanA.compareTo(cleanB);
    });
  }

  /// إزالة التشكيل من النص العربي
  static String _removeArabicDiacritics(String text) {
    return text.replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '');
  }

  /// منع إنشاء كائن من هذه الفئة
  AppUtils._();
}