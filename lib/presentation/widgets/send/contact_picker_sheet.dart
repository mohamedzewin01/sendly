import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../../../data/models/contact.dart';
import '../../../providers/app_provider.dart';
import '../common/app_sheet.dart';
import '../common/gradient_avatar.dart';
import '../common/info_pill.dart';

/// يفتح قائمة جهات الاتصال المحفوظة ويرجع الجهة المختارة
Future<Contact?> showContactPicker(BuildContext context) {
  return showAppSheet<Contact>(
    context,
    builder: (_) => const _ContactPickerSheet(),
  );
}

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet();

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final all = AppScope.of(context).contacts;
    final contacts = all.where((c) => c.matches(_query)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final listHeight = math.min(380.0, MediaQuery.sizeOf(context).height * 0.5);

    return SheetScaffold(
      title: 'اختر جهة اتصال',
      subtitle: '${all.length} جهة محفوظة',
      child: Column(
        children: [
          if (all.length > 6) ...[
            SearchField(
              controller: _search,
              hint: 'ابحث بالاسم أو الرقم',
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
            const SizedBox(height: AppSpace.m),
          ],
          SizedBox(
            height: all.isEmpty ? 140 : listHeight,
            child: contacts.isEmpty
                ? Center(
                    child: Text(
                      all.isEmpty
                          ? 'لا توجد جهات اتصال محفوظة بعد'
                          : 'لا توجد نتائج مطابقة',
                      style: context.text.bodyMedium?.copyWith(
                        color: p.inkSoft,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        onTap: () => Navigator.of(context).pop(contact),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.m),
                        ),
                        leading: GradientAvatar(name: contact.name, size: 44),
                        title: Text(
                          contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              PhoneNumberFormatter.display(contact.phone),
                              style: context.text.bodySmall?.copyWith(
                                color: p.inkSoft,
                              ),
                            ),
                          ),
                        ),
                        trailing: contact.hasValidPhone
                            ? null
                            : InfoPill(
                                text: 'رقم غير صالح',
                                color: p.danger,
                                icon: Icons.warning_amber_rounded,
                              ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
