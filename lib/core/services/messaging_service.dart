// import 'dart:io';
//
// import 'package:url_launcher/url_launcher.dart';
// import '../../core/helpers/phone_formatter.dart';
// import '../../app/constants/app_constants.dart';
//
// /// خدمة التعامل مع الواتساب
// class MessagingService  {
//   static MessagingService ? _instance;
//
//   MessagingService ._internal();
//
//   /// الحصول على المثيل الوحيد
//   factory MessagingService () {
//     _instance ??= MessagingService ._internal();
//     return _instance!;
//   }
//
//   /// إرسال رسالة عبر الواتساب
//   Future<bool> openMessagingApp(String phone, String message) async {
//     try {
//       // تنسيق رقم الهاتف
//       final formattedPhone = PhoneNumberFormatter.format(phone);
//
//       // التحقق من صحة الرقم
//       if (!PhoneNumberFormatter.isValid(formattedPhone)) {
//         throw WhatsAppException('رقم الهاتف غير صحيح: $phone');
//       }
//
//       // إنشاء رابط الواتساب
//       final url = _createWhatsAppUrl(formattedPhone, message);
//
//       // فتح الرابط
//       return await _launchUrl(url);
//     } catch (e) {
//       throw WhatsAppException('فشل في إرسال الرسالة: ${e.toString()}');
//     }
//   }
//
//   /// إرسال رسالة بدون نص (فتح المحادثة فقط)
//   Future<bool> openChat(String phone) async {
//     try {
//       final formattedPhone = PhoneNumberFormatter.format(phone);
//
//       if (!PhoneNumberFormatter.isValid(formattedPhone)) {
//         throw WhatsAppException('رقم الهاتف غير صحيح: $phone');
//       }
//
//       final url = _createWhatsAppUrl(formattedPhone);
//
//       return await _launchUrl(url);
//     } catch (e) {
//       throw WhatsAppException('فشل في فتح المحادثة: ${e.toString()}');
//     }
//   }
//
//   /// إرسال رسائل متعددة (مع تأخير)
//   Future<List<WhatsAppResult>> sendMultipleMessages(
//       List<String> phones,
//       String message, {
//         Duration delay = const Duration(milliseconds: 500),
//       }) async {
//     final results = <WhatsAppResult>[];
//
//     for (int i = 0; i < phones.length; i++) {
//       final phone = phones[i];
//
//       try {
//         final success = await openMessagingApp(phone, message);
//         results.add(WhatsAppResult(
//           phone: phone,
//           success: success,
//           timestamp: DateTime.now(),
//         ));
//       } catch (e) {
//         results.add(WhatsAppResult(
//           phone: phone,
//           success: false,
//           error: e.toString(),
//           timestamp: DateTime.now(),
//         ));
//       }
//
//       // تأخير بين الرسائل (عدا الرسالة الأخيرة)
//       if (i < phones.length - 1) {
//         await Future.delayed(delay);
//       }
//     }
//
//     return results;
//   }
//
//   /// التحقق من توفر الواتساب على الجهاز
//   Future<bool> isWhatsAppAvailable() async {
//     try {
//       // إنشاء رابط اختبار بسيط
//       final testUrl = Uri.parse('https://wa.me/');
//       return await canLaunchUrl(testUrl);
//     } catch (e) {
//       return false;
//     }
//   }
//
//   /// الحصول على معلومات الواتساب المتاحة
//   Future<WhatsAppInfo> getWhatsAppInfo() async {
//     final isAvailable = await isWhatsAppAvailable();
//
//     return WhatsAppInfo(
//       isAvailable: isAvailable,
//       supportedSchemes: _getSupportedSchemes(),
//       recommendedFormat: '+966XXXXXXXXX',
//     );
//   }
//
//   /// إنشاء رابط الواتساب
//   String _createWhatsAppUrl(String phone, [String? message]) {
//     final cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
//     final encodedMessage = Uri.encodeComponent(message ?? '');
//
//     if (Platform.isAndroid) {
//       return 'whatsapp://send?phone=+$cleanPhone&text=$encodedMessage';
//     } else if (Platform.isIOS) {
//       return 'https://wa.me/$cleanPhone?text=$encodedMessage';
//     } else if (Platform.isWindows) {
//       return 'https://wa.me/$cleanPhone/?text=$encodedMessage&app_absent=1';
//     } else {
//       return 'https://web.whatsapp.com/send?phone=$cleanPhone&text=$encodedMessage';
//     }
//   }
//
//   ///
//   // String _createWhatsAppUrl(String phone, [String? message]) {
//   //   final cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
//   //   final encodedMessage = message != null ? Uri.encodeComponent(message) : '';
//   //
//   //   // نستخدم whatsapp://send إن أمكن، لأنها أفضل للأجهزة اللي واتساب مش مرتبط فيها بـ wa.me
//   //   if (message != null && message.isNotEmpty) {
//   //     return 'whatsapp://send?phone=$cleanPhone&text=$encodedMessage';
//   //   } else {
//   //     return 'whatsapp://send?phone=$cleanPhone';
//   //   }
//   // }
//
//   ///
//   // String _createWhatsAppUrl(String phone, [String? message]) {
//   //   // إزالة علامة + من بداية الرقم للرابط
//   //   final cleanPhone = phone.startsWith('+') ? phone.substring(1) : phone;
//   //
//   //   String url = '${AppConstants.whatsappBaseUrl}$cleanPhone';
//   //
//   //   if (message != null && message.isNotEmpty) {
//   //     final encodedMessage = Uri.encodeComponent(message);
//   //     url += '?text=$encodedMessage';
//   //   }
//   //
//   //   return url;
//   // }
//
//   /// فتح الرابط
//   Future<bool> _launchUrl(String url) async {
//     try {
//       final uri = Uri.parse(url);
//
//       if (!await canLaunchUrl(uri)) {
//         throw WhatsAppException('لا يمكن فتح الرابط: $url');
//       }
//
//       final result = await launchUrl(uri, mode: LaunchMode.externalApplication);
//       return result;
//     } catch (e) {
//       throw WhatsAppException('فشل في فتح الواتساب: ${e.toString()}');
//     }
//   }
//
//   ///
//   // Future<bool> _launchUrl(String url) async {
//   //   try {
//   //     final uri = Uri.parse(url);
//   //
//   //     final canLaunch = await canLaunchUrl(uri);
//   //     if (!canLaunch) {
//   //       throw WhatsAppException('لا يمكن فتح الواتساب. تأكد من تثبيت التطبيق');
//   //     }
//   //
//   //     return await launchUrl(
//   //       uri,
//   //       mode: LaunchMode.externalApplication,
//   //     );
//   //   } catch (e) {
//   //     throw WhatsAppException('فشل في فتح الواتساب: ${e.toString()}');
//   //   }
//   // }
//
//   /// الحصول على الصيغ المدعومة
//   List<String> _getSupportedSchemes() {
//     return [
//       'https://wa.me/',
//       'https://api.whatsapp.com/send',
//       'whatsapp://send',
//     ];
//   }
//
//   /// إنشاء رابط مشاركة
//   String createShareUrl(String text) {
//     final encodedText = Uri.encodeComponent(text);
//     return 'https://wa.me/?text=$encodedText';
//   }
//
//   /// إنشاء رابط مجموعة (إذا كان متاحاً)
//   String createGroupInviteUrl(String groupId) {
//     return 'https://chat.whatsapp.com/$groupId';
//   }
//
//   /// تحليل رقم الهاتف والتحقق من صحته
//   PhoneAnalysis analyzePhone(String phone) {
//     final formatted = PhoneNumberFormatter.format(phone);
//     final isValid = PhoneNumberFormatter.isValid(formatted);
//     final carrier = PhoneNumberFormatter.getCarrier(formatted);
//     final displayFormat = PhoneNumberFormatter.display(formatted);
//
//     return PhoneAnalysis(
//       originalPhone: phone,
//       formattedPhone: formatted,
//       displayPhone: displayFormat,
//       isValid: isValid,
//       carrier: carrier,
//       countryCode: '+966',
//     );
//   }
//
//   /// إنشاء رابط تجريبي للاختبار
//   String createTestUrl() {
//     return _createWhatsAppUrl('+966500000000', 'رسالة تجريبية من تطبيق مساعد الواتساب');
//   }
//
//   /// حفظ إحصائيات الإرسال
//   void _logSendAttempt(String phone, bool success, [String? error]) {
//     // يمكن إضافة منطق لحفظ إحصائيات الإرسال
//     // مثل عدد الرسائل المرسلة، معدل النجاح، إلخ
//     print('WhatsApp Send - Phone: $phone, Success: $success, Error: $error');
//   }
// }
//
// /// نتيجة إرسال رسالة واتساب
// class WhatsAppResult {
//   final String phone;
//   final bool success;
//   final String? error;
//   final DateTime timestamp;
//
//   const WhatsAppResult({
//     required this.phone,
//     required this.success,
//     this.error,
//     required this.timestamp,
//   });
//
//   @override
//   String toString() {
//     return 'WhatsAppResult(phone: $phone, success: $success, error: $error)';
//   }
// }
//
// /// معلومات الواتساب على الجهاز
// class WhatsAppInfo {
//   final bool isAvailable;
//   final List<String> supportedSchemes;
//   final String recommendedFormat;
//
//   const WhatsAppInfo({
//     required this.isAvailable,
//     required this.supportedSchemes,
//     required this.recommendedFormat,
//   });
//
//   @override
//   String toString() {
//     return 'WhatsAppInfo(isAvailable: $isAvailable, schemes: ${supportedSchemes.length})';
//   }
// }
//
// /// تحليل رقم الهاتف
// class PhoneAnalysis {
//   final String originalPhone;
//   final String formattedPhone;
//   final String displayPhone;
//   final bool isValid;
//   final String carrier;
//   final String countryCode;
//
//   const PhoneAnalysis({
//     required this.originalPhone,
//     required this.formattedPhone,
//     required this.displayPhone,
//     required this.isValid,
//     required this.carrier,
//     required this.countryCode,
//   });
//
//   @override
//   String toString() {
//     return 'PhoneAnalysis(original: $originalPhone, formatted: $formattedPhone, valid: $isValid)';
//   }
// }
//
// /// استثناء خاص بالواتساب
// class WhatsAppException implements Exception {
//   final String message;
//
//   const WhatsAppException(this.message);
//
//   @override
//   String toString() => 'WhatsAppException: $message';
// }


import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import '../../core/helpers/phone_formatter.dart';
import '../../app/constants/app_constants.dart';

/// أنواع تطبيقات المراسلة المدعومة
enum MessagingPlatform {
  whatsapp,
  telegram,
  sms,
  auto, // يختار التطبيق المناسب تلقائياً
}

/// خدمة التعامل مع تطبيقات المراسلة المختلفة
class MessagingService {
  static MessagingService? _instance;

  MessagingService._internal();

  /// الحصول على المثيل الوحيد
  factory MessagingService() {
    _instance ??= MessagingService._internal();
    return _instance!;
  }

  /// إرسال رسالة عبر المنصة المحددة (الواتساب افتراضياً للتوافق مع الكود الحالي)
  Future<bool> openMessagingApp(String phone, String message,
      {MessagingPlatform platform = MessagingPlatform.whatsapp}) async {
    try {
      // تنسيق رقم الهاتف
      final formattedPhone = PhoneNumberFormatter.format(phone);

      // التحقق من صحة الرقم
      if (!PhoneNumberFormatter.isValid(formattedPhone)) {
        throw MessagingException('رقم الهاتف غير صحيح: $phone');
      }

      // اختيار المنصة المناسبة
      final selectedPlatform = platform == MessagingPlatform.auto
          ? await _getBestAvailablePlatform()
          : platform;

      // إنشاء الرابط حسب المنصة
      final url = _createPlatformUrl(selectedPlatform, formattedPhone, message);

      // فتح الرابط
      return await _launchUrl(url, selectedPlatform);
    } catch (e) {
      throw MessagingException('فشل في إرسال الرسالة: ${e.toString()}');
    }
  }

  /// إرسال رسالة بدون نص (فتح المحادثة فقط)
  Future<bool> openChat(String phone,
      {MessagingPlatform platform = MessagingPlatform.whatsapp}) async {
    try {
      final formattedPhone = PhoneNumberFormatter.format(phone);

      if (!PhoneNumberFormatter.isValid(formattedPhone)) {
        throw MessagingException('رقم الهاتف غير صحيح: $phone');
      }

      final selectedPlatform = platform == MessagingPlatform.auto
          ? await _getBestAvailablePlatform()
          : platform;

      final url = _createPlatformUrl(selectedPlatform, formattedPhone);

      return await _launchUrl(url, selectedPlatform);
    } catch (e) {
      throw MessagingException('فشل في فتح المحادثة: ${e.toString()}');
    }
  }

  /// إرسال رسائل متعددة (مع تأخير)
  Future<List<MessagingResult>> sendMultipleMessages(
      List<String> phones,
      String message, {
        MessagingPlatform platform = MessagingPlatform.whatsapp,
        Duration delay = const Duration(milliseconds: 500),
      }) async {
    final results = <MessagingResult>[];

    for (int i = 0; i < phones.length; i++) {
      final phone = phones[i];

      try {
        final success = await openMessagingApp(phone, message, platform: platform);
        results.add(MessagingResult(
          phone: phone,
          platform: platform,
          success: success,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        results.add(MessagingResult(
          phone: phone,
          platform: platform,
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

  /// إرسال رسالة عبر عدة منصات
  Future<List<MessagingResult>> sendToMultiplePlatforms(
      String phone,
      String message,
      List<MessagingPlatform> platforms) async {
    final results = <MessagingResult>[];

    for (final platform in platforms) {
      try {
        final success = await openMessagingApp(phone, message, platform: platform);
        results.add(MessagingResult(
          phone: phone,
          platform: platform,
          success: success,
          timestamp: DateTime.now(),
        ));
      } catch (e) {
        results.add(MessagingResult(
          phone: phone,
          platform: platform,
          success: false,
          error: e.toString(),
          timestamp: DateTime.now(),
        ));
      }
    }

    return results;
  }

  /// التحقق من توفر منصة معينة على الجهاز
  Future<bool> isPlatformAvailable(MessagingPlatform platform) async {
    try {
      final testUrl = _getTestUrl(platform);
      final uri = Uri.parse(testUrl);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// التحقق من توفر الواتساب (للتوافق مع الكود الحالي)
  Future<bool> isWhatsAppAvailable() async {
    return await isPlatformAvailable(MessagingPlatform.whatsapp);
  }

  /// الحصول على المنصات المتاحة على الجهاز
  Future<List<MessagingPlatform>> getAvailablePlatforms() async {
    final available = <MessagingPlatform>[];

    for (final platform in MessagingPlatform.values) {
      if (platform != MessagingPlatform.auto) {
        if (await isPlatformAvailable(platform)) {
          available.add(platform);
        }
      }
    }

    return available;
  }

  /// الحصول على أفضل منصة متاحة
  Future<MessagingPlatform> _getBestAvailablePlatform() async {
    // ترتيب الأولوية: واتساب، تليجرام، رسائل نصية
    const priority = [
      MessagingPlatform.whatsapp,
      MessagingPlatform.telegram,
      MessagingPlatform.sms,
    ];

    for (final platform in priority) {
      if (await isPlatformAvailable(platform)) {
        return platform;
      }
    }

    // إذا لم تتوفر أي منصة، نرجع الواتساب كافتراضي
    return MessagingPlatform.whatsapp;
  }

  /// الحصول على معلومات المراسلة المختلفة
  Future<MessagingInfo> getMessagingInfo() async {
    final availablePlatforms = await getAvailablePlatforms();
    final isWhatsAppAvailable = availablePlatforms.contains(MessagingPlatform.whatsapp);

    return MessagingInfo(
      availablePlatforms: availablePlatforms,
      isWhatsAppAvailable: isWhatsAppAvailable, // للتوافق مع الكود الحالي
      supportedSchemes: _getAllSupportedSchemes(),
      recommendedFormat: '+966XXXXXXXXX',
    );
  }

  /// إنشاء رابط حسب المنصة
  String _createPlatformUrl(MessagingPlatform platform, String phone, [String? message]) {
    switch (platform) {
      case MessagingPlatform.whatsapp:
        return _createWhatsAppUrl(phone, message);
      case MessagingPlatform.telegram:
        return _createTelegramUrl(phone, message);
      case MessagingPlatform.sms:
        return _createSMSUrl(phone, message);
      case MessagingPlatform.auto:
      // لن يصل هنا لأننا نحول auto إلى منصة محددة قبل الوصول هنا
        return _createWhatsAppUrl(phone, message);
    }
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

  /// إنشاء رابط التليجرام
  String _createTelegramUrl(String phone, [String? message]) {
    final encodedMessage = Uri.encodeComponent(message ?? '');

    if (Platform.isAndroid || Platform.isIOS) {
      return message != null && message.isNotEmpty
          ? 'https://t.me/$phone?text=$encodedMessage'
          : 'https://t.me/$phone';
    } else {
      return message != null && message.isNotEmpty
          ? 'https://web.telegram.org/k/#/im?p=@$phone&text=$encodedMessage'
          : 'https://web.telegram.org/k/#/im?p=@$phone';
    }
  }

  // String _createTelegramUrl(String phone, [String? message]) {
  //   final cleanPhone = phone.startsWith('+') ? phone : '+$phone';
  //   final encodedMessage = Uri.encodeComponent(message ?? '');
  //
  //   if (Platform.isAndroid || Platform.isIOS) {
  //     // للموبايل: نستخدم رابط web أولاً، وإذا فشل سيفتح التطبيق تلقائياً
  //     if (message != null && message.isNotEmpty) {
  //       return 'https://t.me/$cleanPhone?text=$encodedMessage';
  //     } else {
  //       return 'https://t.me/$cleanPhone';
  //     }
  //   } else {
  //     // للكمبيوتر: نستخدم web telegram
  //     if (message != null && message.isNotEmpty) {
  //       return 'https://web.telegram.org/#/im?p=$cleanPhone&text=$encodedMessage';
  //     } else {
  //       return 'https://web.telegram.org/#/im?p=$cleanPhone';
  //     }
  //   }
  // }

  /// إنشاء رابط الرسائل النصية
  String _createSMSUrl(String phone, [String? message]) {
    final cleanPhone = phone.startsWith('+') ? phone : '+$phone';
    final encodedMessage = Uri.encodeComponent(message ?? '');

    if (Platform.isAndroid) {
      return 'sms:$cleanPhone?body=$encodedMessage';
    } else if (Platform.isIOS) {
      return 'sms:$cleanPhone&body=$encodedMessage';
    } else {
      // للمنصات الأخرى نستخدم الصيغة العامة
      return 'sms:$cleanPhone?body=$encodedMessage';
    }
  }

  /// الحصول على رابط اختبار لمنصة معينة
  String _getTestUrl(MessagingPlatform platform) {
    switch (platform) {
      case MessagingPlatform.whatsapp:
        return 'https://wa.me/';
      case MessagingPlatform.telegram:
      // للتليجرام نستخدم رابط يعمل على جميع المنصات
        return 'https://t.me/';
      case MessagingPlatform.sms:
        return 'sms:';
      case MessagingPlatform.auto:
        return 'https://wa.me/';
    }
  }

  /// فتح الرابط حسب المنصة
  Future<bool> _launchUrl(String url, MessagingPlatform platform) async {
    try {
      final uri = Uri.parse(url);

      // التحقق من إمكانية فتح الرابط
      if (!await canLaunchUrl(uri)) {
        String platformName;
        switch (platform) {
          case MessagingPlatform.whatsapp:
            platformName = 'الواتساب';
            break;
          case MessagingPlatform.telegram:
            platformName = 'التليجرام';
            break;
          case MessagingPlatform.sms:
            platformName = 'تطبيق الرسائل النصية';
            break;
          case MessagingPlatform.auto:
            platformName = 'التطبيق المطلوب';
            break;
        }
        throw MessagingException('لا يمكن فتح $platformName. تأكد من تثبيت التطبيق');
      }

      // فتح الرابط
      final result = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      return result;
    } catch (e) {
      throw MessagingException('فشل في فتح التطبيق: ${e.toString()}');
    }
  }

  /// الحصول على جميع الصيغ المدعومة
  List<String> _getAllSupportedSchemes() {
    return [
      // WhatsApp
      'https://wa.me/',
      'https://api.whatsapp.com/send',
      'whatsapp://send',
      // Telegram
      'https://t.me/',
      'tg://msg',
      // SMS
      'sms:',
    ];
  }

  /// الحصول على الصيغ المدعومة (للتوافق مع الكود الحالي)
  List<String> _getSupportedSchemes() {
    return [
      'https://wa.me/',
      'https://api.whatsapp.com/send',
      'whatsapp://send',
    ];
  }

  /// إنشاء رابط مشاركة عام
  String createShareUrl(String text, {MessagingPlatform platform = MessagingPlatform.whatsapp}) {
    final encodedText = Uri.encodeComponent(text);

    switch (platform) {
      case MessagingPlatform.whatsapp:
        return 'https://wa.me/?text=$encodedText';
      case MessagingPlatform.telegram:
        return 'https://t.me/share/url?text=$encodedText';
      case MessagingPlatform.sms:
        return 'sms:?body=$encodedText';
      case MessagingPlatform.auto:
        return 'https://wa.me/?text=$encodedText';
    }
  }

  /// إنشاء رابط مجموعة
  String createGroupInviteUrl(String groupId, {MessagingPlatform platform = MessagingPlatform.whatsapp}) {
    switch (platform) {
      case MessagingPlatform.whatsapp:
        return 'https://chat.whatsapp.com/$groupId';
      case MessagingPlatform.telegram:
        return 'https://t.me/$groupId';
      case MessagingPlatform.sms:
        return ''; // الرسائل النصية لا تدعم المجموعات
      case MessagingPlatform.auto:
        return 'https://chat.whatsapp.com/$groupId';
    }
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
  String createTestUrl({MessagingPlatform platform = MessagingPlatform.whatsapp}) {
    switch (platform) {
      case MessagingPlatform.whatsapp:
        return _createWhatsAppUrl('+966500000000', 'رسالة تجريبية من تطبيق مساعد المراسلة - واتساب');
      case MessagingPlatform.telegram:
        return _createTelegramUrl('+966500000000', 'رسالة تجريبية من تطبيق مساعد المراسلة - تليجرام');
      case MessagingPlatform.sms:
        return _createSMSUrl('+966500000000', 'رسالة تجريبية من تطبيق مساعد المراسلة - رسائل نصية');
      case MessagingPlatform.auto:
        return _createWhatsAppUrl('+966500000000', 'رسالة تجريبية من تطبيق مساعد المراسلة');
    }
  }

  /// حفظ إحصائيات الإرسال
  void _logSendAttempt(String phone, MessagingPlatform platform, bool success, [String? error]) {
    print('Messaging Send - Phone: $phone, Platform: ${platform.name}, Success: $success, Error: $error');
  }

  // ===== دوال للتوافق مع الكود القديم =====

  /// للتوافق مع الكود الحالي - معلومات الواتساب
  Future<WhatsAppInfo> getWhatsAppInfo() async {
    final messagingInfo = await getMessagingInfo();
    return WhatsAppInfo(
      isAvailable: messagingInfo.isWhatsAppAvailable,
      supportedSchemes: _getSupportedSchemes(),
      recommendedFormat: messagingInfo.recommendedFormat,
    );
  }

  /// للتوافق مع الكود الحالي - إرسال رسائل متعددة واتساب
  Future<List<WhatsAppResult>> sendMultipleWhatsAppMessages(
      List<String> phones,
      String message, {
        Duration delay = const Duration(milliseconds: 500),
      }) async {
    final results = await sendMultipleMessages(
        phones,
        message,
        platform: MessagingPlatform.whatsapp,
        delay: delay
    );

    return results.map((result) => WhatsAppResult(
      phone: result.phone,
      success: result.success,
      error: result.error,
      timestamp: result.timestamp,
    )).toList();
  }
}

/// نتيجة إرسال رسالة عبر منصة معينة
class MessagingResult {
  final String phone;
  final MessagingPlatform platform;
  final bool success;
  final String? error;
  final DateTime timestamp;

  const MessagingResult({
    required this.phone,
    required this.platform,
    required this.success,
    this.error,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'MessagingResult(phone: $phone, platform: ${platform.name}, success: $success, error: $error)';
  }
}

/// معلومات المراسلة المتاحة
class MessagingInfo {
  final List<MessagingPlatform> availablePlatforms;
  final bool isWhatsAppAvailable; // للتوافق مع الكود الحالي
  final List<String> supportedSchemes;
  final String recommendedFormat;

  const MessagingInfo({
    required this.availablePlatforms,
    required this.isWhatsAppAvailable,
    required this.supportedSchemes,
    required this.recommendedFormat,
  });

  @override
  String toString() {
    return 'MessagingInfo(platforms: ${availablePlatforms.length}, whatsapp: $isWhatsAppAvailable)';
  }
}

/// نتيجة إرسال رسالة واتساب (للتوافق مع الكود الحالي)
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

/// معلومات الواتساب على الجهاز (للتوافق مع الكود الحالي)
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

/// استثناء خاص بالمراسلة
class MessagingException implements Exception {
  final String message;

  const MessagingException(this.message);

  @override
  String toString() => 'MessagingException: $message';
}

/// استثناء خاص بالواتساب (للتوافق مع الكود الحالي)
class WhatsAppException implements Exception {
  final String message;

  const WhatsAppException(this.message);

  @override
  String toString() => 'WhatsAppException: $message';
}