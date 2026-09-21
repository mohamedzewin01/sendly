import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_palette.dart';
import '../../../data/models/contact.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/ad_banner.dart';
import '../../widgets/common/app_feedback.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/info_pill.dart';
import '../../widgets/common/list_controls.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/contact/contact_form_sheet.dart';
import '../../widgets/contact/contact_tile.dart';
import '../../widgets/send/send_sheet.dart';

enum _ContactSort {
  name('الاسم (أ - ي)'),
  newest('الأحدث أولاً'),
  oldest('الأقدم أولاً'),
  carrier('شركة الاتصالات');

  const _ContactSort(this.label);
  final String label;
}

/// صفحة جهات الاتصال المحفوظة
class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  _ContactSort _sort = _ContactSort.name;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Contact> _visible(List<Contact> all) {
    final filtered = all.where((c) => c.matches(_query)).toList();
    switch (_sort) {
      case _ContactSort.name:
        return Contact.sortAlphabetically(filtered);
      case _ContactSort.newest:
        return Contact.sortByDate(filtered, ascending: false);
      case _ContactSort.oldest:
        return Contact.sortByDate(filtered);
      case _ContactSort.carrier:
        return filtered..sort((a, b) {
          final byCarrier = a.carrier.compareTo(b.carrier);
          return byCarrier != 0 ? byCarrier : a.name.compareTo(b.name);
        });
    }
  }

  // ==================== الإجراءات ====================

  Future<void> _handleAction(Contact contact, ContactAction action) async {
    switch (action) {
      case ContactAction.call:
        final uri = Uri(scheme: 'tel', path: contact.phone);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else if (mounted) {
          AppSnack.error(context, 'لا يمكن إجراء الاتصال من هذا الجهاز');
        }
      case ContactAction.copy:
        await Clipboard.setData(ClipboardData(text: contact.phone));
        if (mounted) AppSnack.success(context, 'تم نسخ الرقم');
      case ContactAction.edit:
        await showContactForm(context, contact: contact);
      case ContactAction.delete:
        await _delete(contact);
    }
  }

  Future<void> _delete(Contact contact) async {
    final controller = AppScope.read(context);
    try {
      final removed = await controller.deleteContact(contact.id);
      if (!mounted || removed == null) return;
      AppSnack.success(
        context,
        'تم حذف ${contact.name}',
        actionLabel: 'تراجع',
        onAction: () => controller.addContact(removed),
      );
    } catch (e) {
      if (mounted) AppSnack.error(context, errorText(e));
    }
  }

  // ==================== البناء ====================

  @override
  Widget build(BuildContext context) {
    final all = AppScope.of(context).contacts;
    final contacts = _visible(all);
    final adSlots = ListAdSlots(contacts.length);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(
            title: AppStrings.contacts,
            subtitle: all.isEmpty
                ? 'احفظ الأرقام التي تراسلها كثيراً'
                : '${all.length} جهة محفوظة',
            trailing: HeaderIconButton(
              icon: Icons.person_add_alt_1_rounded,
              tooltip: AppStrings.addContact,
              onPressed: () => showContactForm(context),
            ),
          ),
        ),
        if (all.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.xl,
                0,
                AppSpace.xl,
                AppSpace.m,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      controller: _search,
                      hint: 'ابحث بالاسم أو الرقم',
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  SortMenuButton<_ContactSort>(
                    value: _sort,
                    options: _ContactSort.values,
                    labelOf: (option) => option.label,
                    onChanged: (v) => setState(() => _sort = v),
                  ),
                ],
              ),
            ),
          ),
        if (all.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: EmptyState(
                icon: Icons.contacts_rounded,
                title: AppStrings.noContacts,
                subtitle: 'أضف جهات الاتصال ليصبح الإرسال إليها بضغطة واحدة.',
                actionLabel: AppStrings.addContact,
                onAction: () => showContactForm(context),
              ),
            ),
          )
        else if (contacts.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'لا توجد نتائج',
                subtitle: 'جرّب كلمات بحث مختلفة.',
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.xl,
              0,
              AppSpace.xl,
              AppSpace.xxl,
            ),
            sliver: SliverList.builder(
              itemCount: adSlots.totalCount,
              itemBuilder: (context, position) {
                // بانر صغير بعد كل 3 جهات
                if (adSlots.isAd(position)) return const AdBanner.inList();

                final index = adSlots.itemIndex(position);
                final contact = contacts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.m),
                  child: FadeSlideIn(
                    key: ValueKey(contact.id),
                    playOnceKey: 'contact-${contact.id}',
                    delay: FadeSlideIn.stagger(index),
                    child: Dismissible(
                      key: ValueKey('dismiss-${contact.id}'),
                      direction: DismissDirection.startToEnd,
                      background: const DeleteSwipeBackground(),
                      onDismissed: (_) => _delete(contact),
                      child: ContactTile(
                        contact: contact,
                        onTap: () => showSendSheet(context, recipient: contact),
                        onAction: (action) => _handleAction(contact, action),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        // إعلان واحد في آخر القائمة، بعيداً عن أزرار الإرسال
        if (contacts.isNotEmpty) const SliverToBoxAdapter(child: AdBanner()),
      ],
    );
  }
}
