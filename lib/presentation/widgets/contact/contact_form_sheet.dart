import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/digits_formatter.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../../../data/models/contact.dart';
import '../../../providers/app_provider.dart';
import '../common/app_feedback.dart';
import '../common/app_sheet.dart';
import '../common/gradient_button.dart';
import '../common/paper_surface.dart';
import '../common/phone_insight.dart';

/// يفتح نموذج إضافة جهة اتصال (أو تعديل [contact] إن وُجدت) ثم يحفظها
Future<void> showContactForm(
  BuildContext context, {
  Contact? contact,
  String? initialName,
  String? initialPhone,
}) async {
  final result = await showAppSheet<Contact>(
    context,
    builder: (_) => _ContactFormSheet(
      contact: contact,
      initialName: initialName,
      initialPhone: initialPhone,
    ),
  );
  if (result == null || !context.mounted) return;

  final controller = AppScope.read(context);
  final isNew = contact == null;
  await runGuarded(
    context,
    () => isNew
        ? controller.addContact(result)
        : controller.updateContact(result),
    success: isNew ? AppStrings.contactAdded : AppStrings.contactUpdated,
  );
}

class _ContactFormSheet extends StatefulWidget {
  const _ContactFormSheet({this.contact, this.initialName, this.initialPhone});

  final Contact? contact;

  /// قيم أولية عند إضافة جهة جديدة (مثل رقم مشارك من تطبيق آخر)
  final String? initialName;
  final String? initialPhone;

  @override
  State<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<_ContactFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.contact?.name ?? widget.initialName,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.contact?.phone ?? widget.initialPhone,
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.contact?.note,
  );

  bool get _isEdit => widget.contact != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'الاسم مطلوب';
    if (name.length < 2) return 'الاسم قصير جداً';
    if (name.length > AppConstants.maxContactNameLength) {
      return 'الاسم طويل جداً';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final error = PhoneNumberFormatter.getValidationError(value?.trim() ?? '');
    return error.isEmpty ? null : error;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final note = _note.text.trim();

    final contact = _isEdit
        ? widget.contact!.copyWith(name: name, phone: phone, note: note)
        : Contact.create(name: name, phone: phone, note: note);

    Navigator.of(context).pop(contact);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: _isEdit ? AppStrings.editContact : AppStrings.addContact,
      subtitle: 'الاسم والرقم مطلوبان، والملاحظة اختيارية',
      footer: GradientButton(
        label: _isEdit ? 'حفظ التعديلات' : 'إضافة جهة الاتصال',
        icon: Icons.check_rounded,
        onPressed: _save,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            PaperField(
              builder: (context) => TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLength: AppConstants.maxContactNameLength,
                validator: _validateName,
                decoration: paperFieldDecoration(
                  context,
                  labelText: 'الاسم',
                  prefixIcon: const Icon(Icons.person_rounded),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 14),
            PaperField(
              builder: (context) => TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                textInputAction: TextInputAction.next,
                validator: _validatePhone,
                inputFormatters: [
                  const WesternDigitsFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: paperFieldDecoration(
                  context,
                  labelText: 'رقم الهاتف',
                  hintText: '+966 5x xxx xxxx',
                  hintTextDirection: TextDirection.ltr,
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _phone,
              builder: (context, value, _) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: PhoneInsight(phone: value.text),
              ),
            ),
            const SizedBox(height: 14),
            PaperField(
              builder: (context) => TextFormField(
                controller: _note,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
                decoration: paperFieldDecoration(
                  context,
                  labelText: 'ملاحظة (اختياري)',
                  prefixIcon: const Icon(Icons.sticky_note_2_rounded),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
