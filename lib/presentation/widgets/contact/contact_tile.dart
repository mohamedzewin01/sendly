import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../../../data/models/contact.dart';
import '../common/app_card.dart';
import '../common/gradient_avatar.dart';
import '../common/info_pill.dart';

enum ContactAction { call, copy, edit, delete }

/// بطاقة جهة الاتصال في القائمة
class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onAction,
  });

  final Contact contact;
  final VoidCallback onTap;
  final ValueChanged<ContactAction> onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final country = PhoneNumberFormatter.getCountryName(contact.phone);
    final carrier = contact.carrier;
    final showCarrier = !const {
      'غير معروف',
      'غير محدد',
      'أخرى',
    }.contains(carrier);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.m,
        AppSpace.m,
        AppSpace.s,
        AppSpace.m,
      ),
      child: Row(
        children: [
          GradientAvatar(name: contact.name, size: 52),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    contact.displayPhone,
                    style: context.text.bodyMedium?.copyWith(color: p.inkSoft),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (contact.hasValidPhone)
                      InfoPill(
                        text: showCarrier ? '$country · $carrier' : country,
                        icon: Icons.public_rounded,
                        color: context.accent.color,
                      )
                    else
                      InfoPill(
                        text: 'رقم غير صالح',
                        icon: Icons.warning_amber_rounded,
                        color: p.danger,
                      ),
                    if (contact.hasNote)
                      InfoPill(
                        text: contact.note!,
                        icon: Icons.sticky_note_2_outlined,
                        color: p.warning,
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<ContactAction>(
            tooltip: 'المزيد',
            icon: Icon(Icons.more_vert_rounded, color: p.inkFaint),
            onSelected: onAction,
            itemBuilder: (context) => [
              _item(context, ContactAction.call, Icons.call_rounded, 'اتصال'),
              _item(
                context,
                ContactAction.copy,
                Icons.copy_rounded,
                'نسخ الرقم',
              ),
              _item(context, ContactAction.edit, Icons.edit_rounded, 'تعديل'),
              _item(
                context,
                ContactAction.delete,
                Icons.delete_rounded,
                'حذف',
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<ContactAction> _item(
    BuildContext context,
    ContactAction action,
    IconData icon,
    String label, {
    bool danger = false,
  }) {
    final p = context.palette;
    final color = danger ? p.danger : p.ink;

    return PopupMenuItem<ContactAction>(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 20, color: danger ? p.danger : p.inkSoft),
          const SizedBox(width: 12),
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
