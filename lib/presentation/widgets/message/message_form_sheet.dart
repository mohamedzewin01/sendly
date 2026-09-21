import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_palette.dart';
import '../../../data/models/message.dart';
import '../../../providers/app_provider.dart';
import '../common/app_feedback.dart';
import '../common/app_sheet.dart';
import '../common/gradient_button.dart';
import '../common/paper_surface.dart';
import '../format/formatted_field.dart';
import '../format/formatted_text.dart';
import 'category_style.dart';

/// يفتح نموذج إضافة رسالة (أو تعديل [message] إن وُجدت) ثم يحفظها
Future<void> showMessageForm(BuildContext context, {Message? message}) async {
  final result = await showAppSheet<Message>(
    context,
    builder: (_) => _MessageFormSheet(message: message),
  );
  if (result == null || !context.mounted) return;

  final controller = AppScope.read(context);
  final isNew = message == null;
  await runGuarded(
    context,
    () => isNew
        ? controller.addMessage(result)
        : controller.updateMessage(result),
    success: isNew ? AppStrings.messageAdded : AppStrings.messageUpdated,
  );
}

class _MessageFormSheet extends StatefulWidget {
  const _MessageFormSheet({this.message});

  final Message? message;

  @override
  State<_MessageFormSheet> createState() => _MessageFormSheetState();
}

class _MessageFormSheetState extends State<_MessageFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title = TextEditingController(
    text: widget.message?.title,
  );
  late final FormattedTextController _content = FormattedTextController(
    text: widget.message?.content,
  );

  late MessageCategory _category =
      widget.message?.category ?? MessageCategory.general;
  late bool _auto = widget.message == null;

  bool get _isEdit => widget.message != null;

  @override
  void initState() {
    super.initState();
    _content.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (!_auto) return;
    final text = _content.text.trim();
    if (text.isEmpty) return;
    final suggested = Message.create(
      title: _title.text,
      content: text,
    ).suggestedCategory;
    if (suggested != _category) setState(() => _category = suggested);
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'عنوان الرسالة مطلوب';
    if (title.length < 3) return 'العنوان قصير جداً';
    if (title.length > AppConstants.maxMessageTitleLength) {
      return 'العنوان طويل جداً';
    }
    return null;
  }

  String? _validateContent(String? value) {
    final content = value?.trim() ?? '';
    if (content.isEmpty) return 'محتوى الرسالة مطلوب';
    if (content.length < 10) return 'المحتوى قصير جداً (10 أحرف على الأقل)';
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    final title = _title.text.trim();
    final content = _content.text.trim();
    final message = _isEdit
        ? widget.message!.copyWith(
            title: title,
            content: content,
            category: _category,
          )
        : Message.create(title: title, content: content, category: _category);

    Navigator.of(context).pop(message);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SheetScaffold(
      title: _isEdit ? AppStrings.editMessage : AppStrings.addMessage,
      subtitle: 'احفظ الرسالة مرة واحدة واستخدمها متى شئت',
      footer: GradientButton(
        label: _isEdit ? 'حفظ التعديلات' : 'حفظ الرسالة',
        icon: Icons.check_rounded,
        onPressed: _save,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaperField(
              builder: (context) => TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                maxLength: AppConstants.maxMessageTitleLength,
                validator: _validateTitle,
                decoration: paperFieldDecoration(
                  context,
                  labelText: 'عنوان الرسالة',
                  prefixIcon: const Icon(Icons.title_rounded),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 14),
            PaperField(
              builder: (context) => FormattedField(
                controller: _content,
                minLines: 8,
                maxLines: 16,
                maxLength: AppConstants.maxMessageLength,
                validator: _validateContent,
                decoration: paperFieldDecoration(
                  context,
                  labelText: 'محتوى الرسالة',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.m),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'التصنيف',
                    style: context.text.labelLarge?.copyWith(
                      color: p.inkSoft,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  'تلقائي',
                  style: context.text.labelMedium?.copyWith(color: p.inkSoft),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: _auto,
                  onChanged: (v) {
                    setState(() => _auto = v);
                    if (v) _onContentChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpace.s),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in MessageCategory.values)
                  _CategoryChip(
                    category: category,
                    selected: category == _category,
                    onTap: () => setState(() {
                      _category = category;
                      _auto = false;
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final MessageCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = category.tone(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.m),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 17, color: selected ? color : p.inkSoft),
            const SizedBox(width: 6),
            Text(
              category.displayName,
              style: context.text.labelLarge?.copyWith(
                color: selected ? color : p.ink,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
