import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/message_format.dart';
import 'emoji_art_sheet.dart';
import 'emoji_sheet.dart';
import 'formatted_text.dart';

/// حقل كتابة الرسائل مع شريط تنسيق ذكي:
/// عريض/مائل/مشطوب/خط ثابت، قوائم، فاصل، رموز، تنسيق تلقائي، وتراجع/إعادة.
/// النص المنسّق يظهر بشكله الحقيقي أثناء الكتابة، وقائمة تحديد النص فيها أوامر التنسيق.
class FormattedField extends StatefulWidget {
  const FormattedField({
    super.key,
    required this.controller,
    required this.decoration,
    this.focusNode,
    this.style,
    this.minLines = 4,
    this.maxLines = 8,
    this.maxLength,
    this.validator,
  });

  final FormattedTextController controller;
  final InputDecoration decoration;
  final FocusNode? focusNode;
  final TextStyle? style;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final FormFieldValidator<String>? validator;

  @override
  State<FormattedField> createState() => _FormattedFieldState();
}

class _FormattedFieldState extends State<FormattedField> {
  final UndoHistoryController _undo = UndoHistoryController();
  late final FocusNode _ownFocus = FocusNode();

  FocusNode get _focus => widget.focusNode ?? _ownFocus;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  /// عند الضغط على الحقل نمرّر الصفحة بعد ظهور الكيبورد ليبقى شريط التنسيق ظاهراً تحته
  void _onFocusChanged() {
    if (!_focus.hasFocus) return;
    Future<void>.delayed(const Duration(milliseconds: 380), () {
      if (!mounted || !_focus.hasFocus) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _undo.dispose();
    _ownFocus.dispose();
    super.dispose();
  }

  void _apply(TextEditingValue Function(TextEditingValue value) edit) {
    final current = widget.controller.value;
    final next = edit(current);
    if (next == current) return;
    final limit = widget.maxLength;
    if (limit != null &&
        next.text.length > limit &&
        next.text.length > current.text.length) {
      return;
    }
    widget.controller.value = next;
    _focus.requestFocus();
    HapticFeedback.selectionClick();
  }

  Future<void> _pickEmoji() async {
    final emoji = await showEmojiSheet(context);
    if (emoji == null || !mounted) return;
    _apply((v) => MessageFormat.insertText(v, emoji));
  }

  Future<void> _pickArt() async {
    final art = await showEmojiArtSheet(context);
    if (art == null || !mounted) return;
    _apply((v) => MessageFormat.insertBlock(v, art));
  }

  Widget _contextMenu(BuildContext context, EditableTextState state) {
    final items = [...state.contextMenuButtonItems];
    if (!state.textEditingValue.selection.isCollapsed) {
      ContextMenuButtonItem format(String label, FormatStyle style) {
        return ContextMenuButtonItem(
          label: label,
          onPressed: () {
            state.hideToolbar();
            _apply((v) => MessageFormat.toggleStyle(v, style));
          },
        );
      }

      items.insertAll(0, [
        format('عريض', FormatStyle.bold),
        format('مائل', FormatStyle.italic),
        format('مشطوب', FormatStyle.strike),
      ]);
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: state.contextMenuAnchors,
      buttonItems: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focus,
          undoController: _undo,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: widget.style ?? context.text.bodyLarge?.copyWith(height: 1.6),
          decoration: widget.decoration,
          validator: widget.validator,
          contextMenuBuilder: _contextMenu,
        ),
        // الشريط تحت الحقل: قائمة تحديد النص تظهر فوق التحديد فلا تغطّي أزراره
        const SizedBox(height: AppSpace.s),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final active = MessageFormat.activeStyles(widget.controller.value);
            return ValueListenableBuilder<UndoHistoryValue>(
              valueListenable: _undo,
              builder: (context, undo, _) => _FormatToolbar(
                active: active,
                canUndo: undo.canUndo,
                canRedo: undo.canRedo,
                onStyle: (s) => _apply((v) => MessageFormat.toggleStyle(v, s)),
                onBullets: () => _apply(MessageFormat.toggleBullets),
                onNumbering: () => _apply(MessageFormat.toggleNumbering),
                onDivider: () => _apply(MessageFormat.insertDivider),
                onEmoji: _pickEmoji,
                onArt: _pickArt,
                onAuto: () => _apply(MessageFormat.autoFormat),
                onClear: () => _apply(MessageFormat.clearFormatting),
                onUndo: _undo.undo,
                onRedo: _undo.redo,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FormatToolbar extends StatelessWidget {
  const _FormatToolbar({
    required this.active,
    required this.canUndo,
    required this.canRedo,
    required this.onStyle,
    required this.onBullets,
    required this.onNumbering,
    required this.onDivider,
    required this.onEmoji,
    required this.onArt,
    required this.onAuto,
    required this.onClear,
    required this.onUndo,
    required this.onRedo,
  });

  final Set<FormatStyle> active;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<FormatStyle> onStyle;
  final VoidCallback onBullets;
  final VoidCallback onNumbering;
  final VoidCallback onDivider;
  final VoidCallback onEmoji;
  final VoidCallback onArt;
  final VoidCallback onAuto;
  final VoidCallback onClear;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget gap() => Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: p.border,
    );

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.accent.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: context.accent.color.withValues(alpha: 0.24)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FormatButton(
            icon: Icons.format_bold_rounded,
            tooltip: 'عريض',
            active: active.contains(FormatStyle.bold),
            onTap: () => onStyle(FormatStyle.bold),
          ),
          _FormatButton(
            icon: Icons.format_italic_rounded,
            tooltip: 'مائل',
            active: active.contains(FormatStyle.italic),
            onTap: () => onStyle(FormatStyle.italic),
          ),
          _FormatButton(
            icon: Icons.strikethrough_s_rounded,
            tooltip: 'يتوسطه خط',
            active: active.contains(FormatStyle.strike),
            onTap: () => onStyle(FormatStyle.strike),
          ),
          _FormatButton(
            icon: Icons.code_rounded,
            tooltip: 'خط ثابت',
            active: active.contains(FormatStyle.mono),
            onTap: () => onStyle(FormatStyle.mono),
          ),
          gap(),
          _FormatButton(
            icon: Icons.format_list_bulleted_rounded,
            tooltip: 'قائمة نقطية',
            onTap: onBullets,
          ),
          _FormatButton(
            icon: Icons.format_list_numbered_rounded,
            tooltip: 'قائمة مرقّمة',
            onTap: onNumbering,
          ),
          _FormatButton(
            icon: Icons.horizontal_rule_rounded,
            tooltip: 'فاصل',
            onTap: onDivider,
          ),
          gap(),
          _FormatButton(
            icon: Icons.emoji_emotions_outlined,
            tooltip: 'رموز تعبيرية',
            onTap: onEmoji,
          ),
          _FormatButton(
            icon: Icons.interests_rounded,
            tooltip: 'رسومات بالرموز',
            onTap: onArt,
          ),
          _FormatButton(
            icon: Icons.auto_fix_high_rounded,
            tooltip: 'تنسيق تلقائي',
            highlight: true,
            onTap: onAuto,
          ),
          _FormatButton(
            icon: Icons.format_clear_rounded,
            tooltip: 'مسح التنسيق',
            onTap: onClear,
          ),
          gap(),
          _FormatButton(
            icon: Icons.undo_rounded,
            tooltip: 'تراجع',
            onTap: canUndo ? onUndo : null,
          ),
          _FormatButton(
            icon: Icons.redo_rounded,
            tooltip: 'إعادة',
            onTap: canRedo ? onRedo : null,
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
    this.highlight = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onTap != null;
    final color = !enabled
        ? p.inkFaint.withValues(alpha: 0.5)
        : (active || highlight)
        ? context.accent.color
        : p.inkSoft;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: active,
        label: tooltip,
        child: InkWell(
          // لا نسحب التركيز من حقل الكتابة حتى تبقى لوحة المفاتيح والتحديد كما هما
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(AppRadius.s),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: active ? context.accent.soft : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Icon(icon, size: 21, color: color),
          ),
        ),
      ),
    );
  }
}
