import 'package:url_launcher/url_launcher.dart';

import '../../app/constants/app_constants.dart';

/// روابط خارجية يستخدمها التطبيق
class AppLinks {
  /// يفتح تطبيق البريد برسالة جاهزة (لفريق الدعم افتراضياً). يرجع false إن تعذّر الفتح.
  static Future<bool> email({
    String subject = '',
    String body = '',
    String to = AppConstants.supportEmail,
  }) async {
    final query = [
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&');

    final uri = Uri(
      scheme: 'mailto',
      path: to,
      query: query.isEmpty ? null : query,
    );

    try {
      if (!await canLaunchUrl(uri)) return false;
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  AppLinks._();
}
