import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/phone_extractor.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../common/app_sheet.dart';

/// عند احتواء المحتوى المشارك على أكثر من رقم، يختار المستخدم الرقم المطلوب
Future<ExtractedNumber?> showNumberChooser(
  BuildContext context,
  List<ExtractedNumber> numbers,
) {
  return showAppSheet<ExtractedNumber>(
    context,
    builder: (_) => SheetScaffold(
      title: 'اختر الرقم',
      subtitle: 'وجدنا ${numbers.length} أرقام في المحتوى المشارك',
      child: Column(
        children: [
          for (final number in numbers)
            Builder(
              builder: (context) {
                final p = context.palette;
                final country = PhoneNumberFormatter.getCountryName(
                  number.phone,
                );
                return ListTile(
                  onTap: () => Navigator.of(context).pop(number),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.accent.soft,
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                    child: Icon(
                      Icons.phone_rounded,
                      color: context.accent.color,
                      size: 22,
                    ),
                  ),
                  title: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        PhoneNumberFormatter.display(number.phone),
                        style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  subtitle: Text(
                    [
                      if (number.name != null) number.name!,
                      country,
                    ].join(' · '),
                    style: context.text.bodySmall?.copyWith(color: p.inkSoft),
                  ),
                );
              },
            ),
        ],
      ),
    ),
  );
}
