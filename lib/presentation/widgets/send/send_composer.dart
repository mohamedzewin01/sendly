import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/digits_formatter.dart';
import '../../../core/helpers/phone_formatter.dart';
import '../../../core/services/ads_service.dart';
import '../../../data/models/contact.dart';
import '../../../data/models/message.dart';
import '../../../providers/app_provider.dart';
import '../common/paper_surface.dart';
import '../common/app_feedback.dart';
import '../common/gradient_avatar.dart';
import '../common/gradient_button.dart';
import '../common/phone_insight.dart';
import '../format/formatted_field.dart';
import '../format/formatted_text.dart';
import '../format/message_preview.dart';
import '../contact/contact_form_sheet.dart';
import 'contact_picker_sheet.dart';
import 'template_chips.dart';

/// نموذج الإرسال الكامل: الرقم، الرسالة، القوالب، القناة، وزر الإرسال.
///
/// يُستخدم في صفحة «إرسال سريع» وداخل ورقة الإرسال من الجهات والرسائل.
class SendComposer extends StatefulWidget {
  const SendComposer({
    super.key,
    this.recipient,
    this.initialMessage,
    this.initialTemplateId,
    this.onSent,
    this.acceptsIncoming = false,
    this.betweenCards,
  });

  /// عنصر اختياري يُعرض بين كارت الرقم وكارت الرسالة (إعلان في صفحة الإرسال السريع فقط)
  final Widget? betweenCards;

  /// يستقبل الأرقام المشاركة من تطبيقات أخرى (صفحة الإرسال السريع فقط)
  final bool acceptsIncoming;

  /// جهة اتصال ثابتة (يُخفي حقل الرقم)
  final Contact? recipient;
  final String? initialMessage;
  final String? initialTemplateId;
  final VoidCallback? onSent;

  @override
  State<SendComposer> createState() => _SendComposerState();
}

class _SendComposerState extends State<SendComposer> {
  final TextEditingController _phone = TextEditingController();
  final FormattedTextController _message = FormattedTextController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _messageFocus = FocusNode();

  String? _templateId;
  String? _templateContent;
  Contact? _pickedContact;

  /// اسم ورقم قادمان من مشاركة (بطاقة اتصال) لعرضهما تحت الرقم
  String? _sharedName;
  String? _sharedPhone;

  String? _phoneError;
  String? _messageError;
  bool _sending = false;
  bool _sent = false;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _phone.text = widget.recipient?.phone ?? '';
    _message.text = widget.initialMessage ?? '';
    _templateId = widget.initialTemplateId;
    _templateContent = widget.initialMessage;

    _phone.addListener(_onPhoneChanged);
    _message.addListener(_onMessageChanged);
    _phoneFocus.addListener(_refresh);
    _messageFocus.addListener(_refresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.acceptsIncoming) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _consumeIncoming();
      });
    }
  }

  /// رقم وصل من تطبيق آخر: نضعه في الخانة (ونتعرف على الجهة إن كانت محفوظة)
  void _consumeIncoming() {
    final controller = AppScope.read(context);
    final incoming = controller.takeIncoming();
    if (incoming == null) return;

    final saved = controller.contacts
        .where((c) => PhoneNumberFormatter.areEqual(c.phone, incoming.phone))
        .firstOrNull;

    setState(() {
      _phone.text = incoming.phone;
      _pickedContact = saved;
      _sharedName = saved == null ? incoming.name : null;
      _sharedPhone = incoming.phone;
    });
    AppSnack.show(
      context,
      'تم إدراج الرقم من المشاركة',
      kind: SnackKind.success,
    );
  }

  /// هل الرقم صحيح وغير محفوظ كجهة اتصال بعد؟
  bool get _canSaveContact {
    final text = _phone.text.trim();
    if (text.length < 7 || widget.recipient != null) return false;
    final formatted = PhoneNumberFormatter.format(text);
    if (!PhoneNumberFormatter.isValid(formatted)) return false;
    return !AppScope.read(
      context,
    ).contacts.any((c) => PhoneNumberFormatter.areEqual(c.phone, formatted));
  }

  Future<void> _saveAsContact() async {
    _phoneFocus.unfocus();
    await showContactForm(
      context,
      initialName: _sharedName ?? _pickedContact?.name,
      initialPhone: _phone.text.trim(),
    );
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    _phone.dispose();
    _message.dispose();
    _phoneFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _onPhoneChanged() {
    if (_pickedContact != null && _phone.text != _pickedContact!.phone) {
      _pickedContact = null;
    }
    if (_sharedName != null && _phone.text != _sharedPhone) {
      _sharedName = null;
    }
    if (_phoneError != null) _phoneError = null;
    _refresh();
  }

  void _onMessageChanged() {
    if (_templateId != null && _message.text != _templateContent) {
      _templateId = null;
      _templateContent = null;
    }
    if (_messageError != null) _messageError = null;
    _refresh();
  }

  bool get _canSend =>
      _phone.text.trim().isNotEmpty && _message.text.trim().isNotEmpty;

  // ==================== الإجراءات ====================

  void _selectTemplate(Message message) {
    setState(() {
      _templateId = message.id;
      _templateContent = message.content;
      _message.value = TextEditingValue(
        text: message.content,
        selection: TextSelection.collapsed(offset: message.content.length),
      );
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = WesternDigitsFormatter.convert(data?.text ?? '');
    final match = RegExp(r'\+?\d[\d\s\-()]{6,}\d').firstMatch(text);

    if (!mounted) return;
    if (match == null) {
      AppSnack.show(context, 'لا يوجد رقم هاتف في الحافظة');
      return;
    }
    _phone.text = match.group(0)!.trim();
  }

  Future<void> _pickContact() async {
    _phoneFocus.unfocus();
    final contact = await showContactPicker(context);
    if (contact == null || !mounted) return;
    setState(() {
      _phone.text = contact.phone;
      _pickedContact = contact;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final phone = _phone.text.trim();
    final message = _message.text.trim();

    final phoneError = PhoneNumberFormatter.getValidationError(phone);
    final messageError = message.isEmpty
        ? 'اكتب نص الرسالة'
        : (message.length < 5 ? 'الرسالة قصيرة جداً' : null);

    if (phoneError.isNotEmpty || messageError != null) {
      setState(() {
        _phoneError = phoneError.isEmpty ? null : phoneError;
        _messageError = messageError;
      });
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() => _sending = true);
    final controller = AppScope.read(context);
    try {
      await controller.send(
        phone: phone,
        message: message,
        templateId: _templateId,
      );
      AdsService.instance.noteSendCompleted();
      if (!mounted) return;
      setState(() => _sent = true);
      widget.onSent?.call();
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _sent = false);
      });
    } catch (e) {
      if (mounted) AppSnack.error(context, errorText(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ==================== البناء ====================

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final messages = AppScope.of(context).messages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRecipientCard(context),
        const SizedBox(height: AppSpace.m),
        if (widget.betweenCards != null) widget.betweenCards!,
        _buildMessageCard(context, messages),
        const SizedBox(height: AppSpace.xl),
        GradientButton(
          label: _sent ? 'تم فتح التطبيق' : 'إرسال الآن',
          icon: _sent ? Icons.check_rounded : Icons.send_rounded,
          loading: _sending,
          gradient: _sent
              ? LinearGradient(
                  colors: [
                    p.success,
                    Color.lerp(p.success, Colors.black, 0.22)!,
                  ],
                )
              : null,
          onPressed: _canSend ? _submit : null,
        ),
      ],
    );
  }

  Widget _buildRecipientCard(BuildContext context) {
    final recipient = widget.recipient;

    if (recipient != null) {
      return PaperCard(
        builder: (context) {
          final p = context.palette;
          return Row(
            children: [
              GradientAvatar(name: recipient.name, size: 48),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        recipient.displayPhone,
                        style: context.text.bodyMedium?.copyWith(
                          color: p.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    return PaperCard(
      focused: _phoneFocus.hasFocus,
      hasError: _phoneError != null,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: PaperLabel('إلى', icon: Icons.call_rounded),
              ),
              const SizedBox(width: 8),
              // الأزرار تنزل لسطر ثانٍ تلقائياً على الشاشات الضيقة
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (_canSaveContact)
                      _MiniAction(
                        icon: Icons.person_add_alt_1_rounded,
                        label: 'حفظ',
                        onTap: _saveAsContact,
                      ),
                    _MiniAction(
                      icon: Icons.content_paste_rounded,
                      label: 'لصق',
                      onTap: _paste,
                    ),
                    _MiniAction(
                      icon: Icons.contacts_rounded,
                      label: 'جهاتي',
                      onTap: _pickContact,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.m),
          TextField(
            controller: _phone,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _messageFocus.requestFocus(),
            inputFormatters: [
              const WesternDigitsFormatter(),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
              LengthLimitingTextInputFormatter(20),
            ],
            style: context.text.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: context.palette.ink,
            ),
            decoration: _bareDecoration(
              context,
              '+966 5x xxx xxxx',
            ).copyWith(hintTextDirection: TextDirection.ltr),
          ),
          PhoneInsight(
            phone: _phone.text,
            extra: _pickedContact?.name ?? _sharedName,
          ),
          _FieldError(_phoneError),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, List<Message> messages) {
    return PaperCard(
      focused: _messageFocus.hasFocus,
      hasError: _messageError != null,
      // هوامش جانبية وسفلية أقل لتتسع مساحة الكتابة
      padding: const EdgeInsets.fromLTRB(
        AppSpace.m,
        AppSpace.m,
        AppSpace.m,
        AppSpace.m,
      ),
      builder: (context) {
        final a = context.accent;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PaperLabel('الرسالة', icon: Icons.edit_note_rounded),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: a.soft,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  // الأرقام تُعرض من اليسار دائماً: المكتوب / الأقصى
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${_message.text.length} / ${AppConstants.maxMessageLength}',
                      style: context.text.labelSmall?.copyWith(
                        color: a.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.m),
            FormattedField(
              controller: _message,
              focusNode: _messageFocus,
              minLines: 8,
              maxLines: 20,
              maxLength: AppConstants.maxMessageLength,
              decoration: _bareDecoration(
                context,
                'اكتب رسالتك هنا…',
              ).copyWith(counterText: ''),
            ),
            MessagePreview(text: _message.text),
            _FieldError(_messageError),
            const SizedBox(height: AppSpace.m),
            Divider(color: a.color.withValues(alpha: 0.12)),
            const SizedBox(height: AppSpace.m),
            TemplateChips(
              messages: messages,
              selectedId: _templateId,
              onSelected: _selectTemplate,
            ),
          ],
        );
      },
    );
  }

  InputDecoration _bareDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: false,
      isDense: true,
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.accent.soft,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.s),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: context.accent.color),
              const SizedBox(width: 5),
              Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: context.accent.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: AppSpace.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_rounded, size: 16, color: p.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message!,
                      style: context.text.bodySmall?.copyWith(
                        color: p.danger,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
