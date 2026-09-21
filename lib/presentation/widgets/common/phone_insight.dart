import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/phone_formatter.dart';

/// يعرض تحقق فوري من الرقم: الدولة وشركة الاتصالات والصيغة الدولية
class PhoneInsight extends StatelessWidget {
  const PhoneInsight({super.key, required this.phone, this.extra});

  final String phone;

  /// نص إضافي (مثل اسم جهة الاتصال المختارة)
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final text = phone.trim();
    Widget child = const SizedBox.shrink();

    if (text.length >= 7) {
      final formatted = PhoneNumberFormatter.format(text);
      if (PhoneNumberFormatter.isValid(formatted)) {
        child = _ValidRow(
          key: ValueKey(formatted),
          formatted: formatted,
          extra: extra,
        );
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ValidRow extends StatelessWidget {
  const _ValidRow({super.key, required this.formatted, this.extra});

  final String formatted;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final country = PhoneNumberFormatter.getCountryName(formatted);
    final carrier = PhoneNumberFormatter.getCarrier(formatted);
    final showCarrier = !const {
      'غير معروف',
      'غير محدد',
      'أخرى',
    }.contains(carrier);
    final parts = [
      if (extra != null && extra!.isNotEmpty) extra!,
      country,
      if (showCarrier) carrier,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.s),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: p.success),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              parts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                color: p.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              PhoneNumberFormatter.display(formatted),
              style: context.text.bodySmall?.copyWith(color: p.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}
