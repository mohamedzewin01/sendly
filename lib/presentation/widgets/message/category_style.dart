import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../data/models/message.dart';

/// لون وأيقونة كل تصنيف من تصنيفات الرسائل
extension MessageCategoryStyle on MessageCategory {
  Color get color => switch (this) {
    MessageCategory.general => const Color(0xFF64719A),
    MessageCategory.business => const Color(0xFF2F5BEA),
    MessageCategory.personal => const Color(0xFF0E9F6E),
    MessageCategory.marketing => const Color(0xFFE4572E),
    MessageCategory.support => const Color(0xFF7A5CF0),
    MessageCategory.announcement => const Color(0xFFD98E04),
    MessageCategory.greeting => const Color(0xFFD9468F),
    MessageCategory.reminder => const Color(0xFF0A86B8),
  };

  /// اللون المناسب للوضع الحالي: أفتح في الداكن ليبقى مقروءاً
  Color tone(BuildContext context) =>
      context.isDark ? Color.lerp(color, Colors.white, 0.32)! : color;

  IconData get icon => switch (this) {
    MessageCategory.general => Icons.chat_bubble_outline_rounded,
    MessageCategory.business => Icons.work_outline_rounded,
    MessageCategory.personal => Icons.person_outline_rounded,
    MessageCategory.marketing => Icons.local_offer_outlined,
    MessageCategory.support => Icons.headset_mic_outlined,
    MessageCategory.announcement => Icons.campaign_outlined,
    MessageCategory.greeting => Icons.waving_hand_outlined,
    MessageCategory.reminder => Icons.alarm_rounded,
  };
}
