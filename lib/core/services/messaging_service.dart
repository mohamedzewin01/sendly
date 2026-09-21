import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../helpers/phone_formatter.dart';

/// يفتح تطبيق المراسلة الفورية برقم ورسالة جاهزة.
/// التطبيق لا يرسل شيئاً تلقائياً؛ المستخدم هو من يضغط «إرسال» داخل التطبيق المفتوح.
class MessagingService {
  static MessagingService? _instance;

  MessagingService._internal();

  factory MessagingService() {
    _instance ??= MessagingService._internal();
    return _instance!;
  }

  /// يفتح المحادثة مع [phone] والرسالة جاهزة. يرمي [MessagingException] عند الفشل.
  Future<bool> openMessagingApp(String phone, String message) async {
    final formattedPhone = PhoneNumberFormatter.format(phone);
    if (!PhoneNumberFormatter.isValid(formattedPhone)) {
      throw MessagingException('رقم الهاتف غير صحيح: $phone');
    }

    final uri = Uri.parse(_buildUrl(formattedPhone, message));

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw const MessagingException(_notInstalled);
      return true;
    } on MessagingException {
      rethrow;
    } catch (_) {
      throw const MessagingException(_notInstalled);
    }
  }

  static const String _notInstalled =
      'لا يمكن فتح تطبيق الرسائل الفورية. تأكد من تثبيته على جهازك';

  String _buildUrl(String phone, String message) {
    final digits = phone.startsWith('+') ? phone.substring(1) : phone;
    final text = Uri.encodeComponent(message);

    return Platform.isAndroid
        ? 'whatsapp://send?phone=+$digits&text=$text'
        : 'https://wa.me/$digits?text=$text';
  }
}

/// استثناء خاص بفتح تطبيق المراسلة
class MessagingException implements Exception {
  final String message;

  const MessagingException(this.message);

  @override
  String toString() => 'MessagingException: $message';
}
