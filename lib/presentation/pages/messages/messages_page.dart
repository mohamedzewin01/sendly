import 'package:flutter/material.dart';

import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_palette.dart';
import '../../../data/models/message.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/ad_banner.dart';
import '../../widgets/common/app_feedback.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/info_pill.dart';
import '../../widgets/common/list_controls.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/message/category_style.dart';
import '../../widgets/message/message_card.dart';
import '../../widgets/message/message_details_sheet.dart';
import '../../widgets/message/message_form_sheet.dart';
import '../../widgets/send/send_sheet.dart';

enum _MessageSort {
  newest('الأحدث'),
  title('العنوان (أ - ي)'),
  usage('الأكثر استخداماً'),
  longest('الأطول');

  const _MessageSort(this.label);
  final String label;
}

/// صفحة الرسائل المحفوظة (القوالب)
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  MessageCategory? _category;
  _MessageSort _sort = _MessageSort.newest;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Message> _visible(List<Message> all) {
    final filtered = all
        .where(
          (m) =>
              (_category == null || m.category == _category) &&
              m.matches(_query),
        )
        .toList();
    switch (_sort) {
      case _MessageSort.newest:
        return Message.sortByDate(filtered, ascending: false);
      case _MessageSort.title:
        return Message.sortAlphabetically(filtered);
      case _MessageSort.usage:
        return Message.sortByUsage(filtered);
      case _MessageSort.longest:
        return Message.sortByLength(filtered, ascending: false);
    }
  }

  Future<void> _delete(Message message) async {
    final controller = AppScope.read(context);
    try {
      final removed = await controller.deleteMessage(message.id);
      if (!mounted || removed == null) return;
      AppSnack.success(
        context,
        'تم حذف «${message.title}»',
        actionLabel: 'تراجع',
        onAction: () => controller.addMessage(removed),
      );
    } catch (e) {
      if (mounted) AppSnack.error(context, errorText(e));
    }
  }

  void _handleAction(Message message, MessageAction action) {
    switch (action) {
      case MessageAction.edit:
        showMessageForm(context, message: message);
      case MessageAction.delete:
        _delete(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = AppScope.of(context).messages;
    final present = MessageCategory.values
        .where((c) => all.any((m) => m.category == c))
        .toList();
    // إذا اختفى التصنيف المحدد (بعد حذف آخر رسالة فيه) نعرض الكل
    final activeCategory = present.contains(_category) ? _category : null;
    final messages = _visible(all);
    final adSlots = ListAdSlots(messages.length);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(
            title: AppStrings.messages,
            subtitle: all.isEmpty
                ? 'قوالب جاهزة تختصر عليك الكتابة'
                : '${all.length} رسالة محفوظة',
            trailing: HeaderIconButton(
              icon: Icons.add_comment_rounded,
              tooltip: AppStrings.addMessage,
              onPressed: () => showMessageForm(context),
            ),
          ),
        ),
        if (all.isNotEmpty) ...[
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
                      hint: 'ابحث في الرسائل',
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                  SortMenuButton<_MessageSort>(
                    value: _sort,
                    options: _MessageSort.values,
                    labelOf: (option) => option.label,
                    onChanged: (v) => setState(() => _sort = v),
                  ),
                ],
              ),
            ),
          ),
          if (present.length > 1)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                  children: [
                    _FilterChip(
                      label: 'الكل',
                      selected: activeCategory == null,
                      onTap: () => setState(() => _category = null),
                    ),
                    for (final category in present) ...[
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: category.displayName,
                        icon: category.icon,
                        color: category.tone(context),
                        selected: activeCategory == category,
                        onTap: () => setState(() => _category = category),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpace.m)),
        ],
        if (all.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: AppStrings.noMessages,
                subtitle:
                    'احفظ رسائلك المتكررة مرة واحدة، ثم أرسلها لأي شخص بضغطة.',
                actionLabel: AppStrings.addMessage,
                onAction: () => showMessageForm(context),
              ),
            ),
          )
        else if (messages.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'لا توجد نتائج',
                subtitle: 'جرّب كلمات بحث أو تصنيفاً مختلفاً.',
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
                // بانر صغير بعد كل 3 رسائل
                if (adSlots.isAd(position)) return const AdBanner.inList();

                final index = adSlots.itemIndex(position);
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.m),
                  child: FadeSlideIn(
                    key: ValueKey(message.id),
                    playOnceKey: 'message-${message.id}',
                    delay: FadeSlideIn.stagger(index),
                    child: Dismissible(
                      key: ValueKey('dismiss-${message.id}'),
                      direction: DismissDirection.startToEnd,
                      background: const DeleteSwipeBackground(),
                      onDismissed: (_) => _delete(message),
                      child: MessageCard(
                        message: message,
                        onTap: () => showMessageDetails(context, message),
                        onSend: () => showSendSheet(
                          context,
                          initialMessage: message.content,
                          initialTemplateId: message.id,
                        ),
                        onCopy: () => copyMessage(context, message),
                        onAction: (action) => _handleAction(message, action),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        // إعلان واحد في آخر القائمة، بعيداً عن أزرار الإرسال
        if (messages.isNotEmpty) const SliverToBoxAdapter(child: AdBanner()),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tone = color ?? context.accent.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? tone.withValues(alpha: 0.14) : p.surface,
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: Border.all(
            color: selected ? tone : p.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? tone : p.inkSoft),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: selected ? tone : p.inkSoft,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
