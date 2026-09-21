import 'package:flutter/material.dart';

import '../../../data/models/contact.dart';
import '../common/app_feedback.dart';
import '../common/app_sheet.dart';
import 'send_composer.dart';

/// يفتح ورقة الإرسال. عند تمرير [recipient] يكون الرقم ثابتاً،
/// وعند تمرير [initialMessage] تُملأ الرسالة مسبقاً.
Future<void> showSendSheet(
  BuildContext context, {
  Contact? recipient,
  String? initialMessage,
  String? initialTemplateId,
}) {
  return showAppSheet<void>(
    context,
    builder: (sheetContext) => SheetScaffold(
      title: 'إرسال رسالة',
      subtitle: recipient == null
          ? 'اكتب الرقم أو اختره من جهاتك'
          : 'اختر الرسالة ثم أرسل',
      child: SendComposer(
        recipient: recipient,
        initialMessage: initialMessage,
        initialTemplateId: initialTemplateId,
        onSent: () {
          Navigator.of(sheetContext).pop();
          if (context.mounted) {
            AppSnack.success(context, 'تم فتح تطبيق المراسلة');
          }
        },
      ),
    ),
  );
}
