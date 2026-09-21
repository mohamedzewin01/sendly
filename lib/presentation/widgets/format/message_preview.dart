import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/message_format.dart';
import 'formatted_text.dart';

/// معاينة الرسالة بشكلها النهائي (تظهر فقط عند وجود تنسيق)
class MessagePreview extends StatelessWidget {
  const MessagePreview({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final show = MessageFormat.hasFormatting(text);

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpace.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: 15,
                        color: p.inkFaint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'معاينة',
                        style: context.text.labelMedium?.copyWith(
                          color: p.inkSoft,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.accent.soft,
                      borderRadius: const BorderRadiusDirectional.only(
                        topStart: Radius.circular(4),
                        topEnd: Radius.circular(18),
                        bottomStart: Radius.circular(18),
                        bottomEnd: Radius.circular(18),
                      ),
                    ),
                    child: FormattedText(
                      text,
                      style: context.text.bodyMedium?.copyWith(height: 1.7),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
