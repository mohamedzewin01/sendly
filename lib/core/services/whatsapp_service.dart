import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import '../../core/helpers/phone_formatter.dart';
import '../../app/constants/app_constants.dart';

/// خدمة التعامل مع الواتساب
class WhatsAppService {
  static WhatsAppService? _instance;

  WhatsAppService._internal();

  /// الحصول على المثيل الوحيد
  factory WhatsAppService() {
    _instance ??= WhatsAppService._internal();
    return _instance!;
  }

  /// إرسال رسالة عبر الواتساب
  Future<bool> sendMessage(String phone, String message) async {
    try {
      // تنسيق رقم الهاتف
      final formattedPhone = PhoneNumberFormatter.format(phone);

      // التحقق من صحة الرقم
      if (!PhoneNumberFormatter.isValid(formattedPhone)) {
        throw WhatsAppException('رقم الهاتف غير صحيح: $phone');
      }

      // إنشاء رابط الواتساب
      final url = _createWhatsAppUrl(formattedPhone, message);

      // فتح الرابط
      return await _launchUrl(url);
    } catch (e) {
      throw WhatsAppException('فشل في إرسال الرسالة: ${e.toString()}');
    }
  }

  /// إرسال رسالة بدون نص (فتح المحادثة فقط)
  Future<bool> openChat(String phone) async {
    try {
      final formattedPhone = PhoneNumberFormatter.format(phone);

      if (!PhoneNumberFormatter.isValid(formattedPhone)) {
        throw WhatsAppException('رقم الهاتف غير صحيح: $phone');
      }

      final url = _createWhatsAppUrl(formattedPhone);

      return await _launchUrl(url);
    } catch (e) {
      throw WhatsAppException('فشل في فتح المحادثة: ${e.toString()}');
    }
  }

  /// إرسال رسائل متعددة (مع تأخير)
  Future<List<WhatsAppResult>> sendMultipleMessages(
      List<String> phones,
      String message, {
        Duration delay = const Duration(milliseconds: 500),
      }) async {
    final results = <WhatsAppResult>[];

    for (int i = 0; i < phones.length; i++) {
      final phone = phones[i];

      try {
        final success = await sendMessage(phone, message);
        results.add(WhatsAppResult(
          phone: phone,
          success: success,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        results.add(WhatsAppResult(
          phone: phone,
          success: false,
          error: e.toString(),
          timestamp: DateTime.now(),
        ));
      }

      // تأخير بين الرسائل (عدا الرسالة الأخيرة)
      if (i < phones.length - 1) {
        await Future.delayed(delay);
      }
    }

    return results;
  }

  /// التحقق من توفر الواتساب على الجهاز
  Future<bool> isWhatsAppAvailable() async {
    try {
      // إنشاء رابط اختبار بسيط
      final testUrl = Uri.parse('https://wa.me/');
      return await canLaunchUrl(testUrl);
    } catch (e) {
      return false;
    }
  }

  /// الحصول على معلومات الواتساب المتاحة
  Future<WhatsAppInfo> getWhatsAppInfo() async {
    final isAvailable = await isWhatsAppAvailable();

    return WhatsAppInfo(
      isAvailable: isAvailable,
      supportedSchemes: _getSupportedSchemes(),
      recommendedFormat: '+966XXXXXXXXX',
    );
  }

  /// إنشاء رابط الواتساب
  String _createWhatsAppUrl(String phone, [String? message]) {
    final cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
    final encodedMessage = Uri.encodeComponent(message ?? '');

    if (Platform.isAndroid) {
      return 'whatsapp://send?phone=+$cleanPhone&text=$encodedMessage';
    } else if (Platform.isIOS) {
      return 'https://wa.me/$cleanPhone?text=$encodedMessage';
    } else if (Platform.isWindows) {
      return 'https://wa.me/$cleanPhone/?text=$encodedMessage&app_absent=1';
    } else {
      return 'https://web.whatsapp.com/send?phone=$cleanPhone&text=$encodedMessage';
    }
  }

  ///
  // String _createWhatsAppUrl(String phone, [String? message]) {
  //   final cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
  //   final encodedMessage = message != null ? Uri.encodeComponent(message) : '';
  //
  //   // نستخدم whatsapp://send إن أمكن، لأنها أفضل للأجهزة اللي واتساب مش مرتبط فيها بـ wa.me
  //   if (message != null && message.isNotEmpty) {
  //     return 'whatsapp://send?phone=$cleanPhone&text=$encodedMessage';
  //   } else {
  //     return 'whatsapp://send?phone=$cleanPhone';
  //   }
  // }

  ///
  // String _createWhatsAppUrl(String phone, [String? message]) {
  //   // إزالة علامة + من بداية الرقم للرابط
  //   final cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
  //
  //   String url = '${AppConstants.whatsappBaseUrl}$cleanPhone';
  //
  //   if (message != null && message.isNotEmpty) {
  //     final encodedMessage = Uri.encodeComponent(message);
  //     url += '?text=$encodedMessage';
  //   }
  //
  //   return url;
  // }

  /// فتح الرابط
  Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      if (!await canLaunchUrl(uri)) {
        throw WhatsAppException('لا يمكن فتح الرابط: $url');
      }

      final result = await launchUrl(uri, mode: LaunchMode.externalApplication);
      return result;
    } catch (e) {
      throw WhatsAppException('فشل في فتح الواتساب: ${e.toString()}');
    }
  }

  ///
  // Future<bool> _launchUrl(String url) async {
  //   try {
  //     final uri = Uri.parse(url);
  //
  //     final canLaunch = await canLaunchUrl(uri);
  //     if (!canLaunch) {
  //       throw WhatsAppException('لا يمكن فتح الواتساب. تأكد من تثبيت التطبيق');
  //     }
  //
  //     return await launchUrl(
  //       uri,
  //       mode: LaunchMode.externalApplication,
  //     );
  //   } catch (e) {
  //     throw WhatsAppException('فشل في فتح الواتساب: ${e.toString()}');
  //   }
  // }

  /// الحصول على الصيغ المدعومة
  List<String> _getSupportedSchemes() {
    return [
      'https://wa.me/',
      'https://api.whatsapp.com/send',
      'whatsapp://send',
    ];
  }

  /// إنشاء رابط مشاركة
  String createShareUrl(String text) {
    final encodedText = Uri.encodeComponent(text);
    return 'https://wa.me/?text=$encodedText';
  }

  /// إنشاء رابط مجموعة (إذا كان متاحاً)
  String createGroupInviteUrl(String groupId) {
    return 'https://chat.whatsapp.com/$groupId';
  }

  /// تحليل رقم الهاتف والتحقق من صحته
  PhoneAnalysis analyzePhone(String phone) {
    final formatted = PhoneNumberFormatter.format(phone);
    final isValid = PhoneNumberFormatter.isValid(formatted);
    final carrier = PhoneNumberFormatter.getCarrier(formatted);
    final displayFormat = PhoneNumberFormatter.display(formatted);

    return PhoneAnalysis(
      originalPhone: phone,
      formattedPhone: formatted,
      displayPhone: displayFormat,
      isValid: isValid,
      carrier: carrier,
      countryCode: '+966',
    );
  }

  /// إنشاء رابط تجريبي للاختبار
  String createTestUrl() {
    return _createWhatsAppUrl('+966500000000', 'رسالة تجريبية من تطبيق مساعد الواتساب');
  }

  /// حفظ إحصائيات الإرسال
  void _logSendAttempt(String phone, bool success, [String? error]) {
    // يمكن إضافة منطق لحفظ إحصائيات الإرسال
    // مثل عدد الرسائل المرسلة، معدل النجاح، إلخ
    print('WhatsApp Send - Phone: $phone, Success: $success, Error: $error');
  }
}

/// نتيجة إرسال رسالة واتساب
class WhatsAppResult {
  final String phone;
  final bool success;
  final String? error;
  final DateTime timestamp;

  const WhatsAppResult({
    required this.phone,
    required this.success,
    this.error,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'WhatsAppResult(phone: $phone, success: $success, error: $error)';
  }
}

/// معلومات الواتساب على الجهاز
class WhatsAppInfo {
  final bool isAvailable;
  final List<String> supportedSchemes;
  final String recommendedFormat;

  const WhatsAppInfo({
    required this.isAvailable,
    required this.supportedSchemes,
    required this.recommendedFormat,
  });

  @override
  String toString() {
    return 'WhatsAppInfo(isAvailable: $isAvailable, schemes: ${supportedSchemes.length})';
  }
}

/// تحليل رقم الهاتف
class PhoneAnalysis {
  final String originalPhone;
  final String formattedPhone;
  final String displayPhone;
  final bool isValid;
  final String carrier;
  final String countryCode;

  const PhoneAnalysis({
    required this.originalPhone,
    required this.formattedPhone,
    required this.displayPhone,
    required this.isValid,
    required this.carrier,
    required this.countryCode,
  });

  @override
  String toString() {
    return 'PhoneAnalysis(original: $originalPhone, formatted: $formattedPhone, valid: $isValid)';
  }
}

/// استثناء خاص بالواتساب
class WhatsAppException implements Exception {
  final String message;

  const WhatsAppException(this.message);

  @override
  String toString() => 'WhatsAppException: $message';
}