import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../helpers/phone_extractor.dart';

/// محتوى مشترك وصل من تطبيق آخر
class IncomingShare {
  const IncomingShare({required this.text, required this.isVCard});

  final String text;
  final bool isVCard;

  /// الأرقام الصحيحة داخل المحتوى
  List<ExtractedNumber> get numbers {
    if (isVCard) {
      final fromCard = PhoneExtractor.fromVCard(text);
      if (fromCard.isNotEmpty) return fromCard;
    }
    return PhoneExtractor.fromText(text);
  }
}

/// يستقبل الأرقام والنصوص المشاركة من تطبيقات أخرى (مشاركة أو تحديد نص).
/// الاستقبال نفسه في `MainActivity` على أندرويد ولا يحتاج أي صلاحيات.
class IncomingShareService {
  static const MethodChannel _channel = MethodChannel('sendly/incoming');

  /// يبدأ الاستماع، ويسلّم المشاركة التي فتحت التطبيق (إن وُجدت) والمشاركات اللاحقة
  Future<void> start(ValueChanged<IncomingShare> onShare) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onShare') _deliver(call.arguments, onShare);
    });

    try {
      final initial = await _channel.invokeMethod<Object?>('getInitialShare');
      _deliver(initial, onShare);
    } on MissingPluginException {
      // منصة بدون استقبال مشاركة (مثل الاختبارات)
    } on PlatformException catch (e) {
      debugPrint('Incoming share error: $e');
    }
  }

  void stop() => _channel.setMethodCallHandler(null);

  void _deliver(Object? arguments, ValueChanged<IncomingShare> onShare) {
    if (arguments is! Map) return;
    final text = arguments['text'];
    if (text is! String || text.trim().isEmpty) return;

    onShare(IncomingShare(text: text, isVCard: arguments['type'] == 'vcard'));
  }
}
