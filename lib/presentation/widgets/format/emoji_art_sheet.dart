import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/helpers/emoji_art.dart';
import '../../../core/helpers/text_art.dart';
import '../common/app_sheet.dart';
import '../common/gradient_button.dart';
import '../common/paper_surface.dart';

/// يفتح ورقة «رسومات بالرموز» ويرجع نص الرسمة المختارة جاهزاً للإدراج في الرسالة
Future<String?> showEmojiArtSheet(BuildContext context) {
  return showAppSheet<String>(context, builder: (_) => const _EmojiArtSheet());
}

class _EmojiArtSheet extends StatefulWidget {
  const _EmojiArtSheet();

  @override
  State<_EmojiArtSheet> createState() => _EmojiArtSheetState();
}

class _EmojiArtSheetState extends State<_EmojiArtSheet> {
  /// 0: رسومات بالرموز التعبيرية، 1: بالحروف والرموز، 2: اسمك في شكل
  int _mode = 0;
  int _textArt = 0;
  int _nameArt = 0;
  final TextEditingController _name = TextEditingController();
  int _art = 0;
  String _fill = '❤️';
  String _background = '⬜';

  TextArt get _nameResult => kNameArts[_nameArt].fill(_name.text);

  String get _text => switch (_mode) {
    0 => kEmojiArts[_art].render(fill: _fill, background: _background),
    1 => kTextArts[_textArt].render(),
    _ => _nameResult.render(),
  };

  /// معاينة الحروف بدون علامات الكتلة
  String get _plainText =>
      _mode == 1 ? kTextArts[_textArt].plain : _nameResult.plain;

  /// في وضع الاسم لا يمكن الإضافة قبل كتابة اسم
  bool get _canAdd => _mode != 2 || NameArt.clean(_name.text).isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _pickFill(String fill) {
    HapticFeedback.selectionClick();
    setState(() {
      _fill = fill;
      // الرسمة تختفي لو تطابق الرمزان، فنغيّر الخلفية تلقائياً
      if (_background == fill) {
        _background = EmojiArtPalette.backgrounds.firstWhere((b) => b != fill);
      }
    });
  }

  void _pickBackground(String background) {
    if (background == _fill) return;
    HapticFeedback.selectionClick();
    setState(() => _background = background);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = context.accent;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpace.l, bottom: AppSpace.s),
      child: Text(
        text,
        style: context.text.labelLarge?.copyWith(
          color: p.inkSoft,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return SheetScaffold(
      title: 'رسومات بالرموز',
      subtitle: 'اختر الرسمة ولونها وتدخل رسالتك جاهزة',
      footer: GradientButton(
        label: 'إضافة إلى الرسالة',
        icon: Icons.add_rounded,
        onPressed: _canAdd ? () => Navigator.of(context).pop(_text) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 0, label: Text('إيموجي')),
              ButtonSegment(value: 1, label: Text('حروف ورموز')),
              ButtonSegment(value: 2, label: Text('اسمك')),
            ],
            selected: {_mode},
            onSelectionChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _mode = v.first);
            },
          ),
          const SizedBox(height: AppSpace.m),
          // المعاينة: الرسمة كما ستظهر في الرسالة (من اليسار دائماً حتى لا ينقلب الشكل)
          Container(
            padding: const EdgeInsets.all(AppSpace.l),
            decoration: BoxDecoration(
              color: a.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.l),
              border: Border.all(color: a.color.withValues(alpha: 0.30)),
            ),
            child: Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _mode == 0
                      ? Text(
                          _text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, height: 1.2),
                        )
                      : Text(
                          _plainText,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 15,
                            height: 1.25,
                            color: p.ink,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (_mode == 0) ...[
            label('الرسمة'),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: [
                for (var i = 0; i < kEmojiArts.length; i++)
                  _ArtTile(
                    art: kEmojiArts[i],
                    selected: i == _art,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _art = i);
                    },
                  ),
              ],
            ),
            label('لون الرسمة'),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: [
                for (final fill in EmojiArtPalette.fills)
                  _EmojiChip(
                    emoji: fill,
                    selected: fill == _fill,
                    onTap: () => _pickFill(fill),
                  ),
              ],
            ),
            label('الخلفية'),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: [
                for (final background in EmojiArtPalette.backgrounds)
                  _EmojiChip(
                    emoji: background,
                    transparent: background == EmojiArtPalette.transparent,
                    selected: background == _background,
                    disabled: background == _fill,
                    onTap: () => _pickBackground(background),
                  ),
              ],
            ),
          ] else if (_mode == 1) ...[
            label('الرسمة'),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: [
                for (var i = 0; i < kTextArtPictureCount; i++)
                  _TextTile(
                    name: kTextArts[i].name,
                    selected: i == _textArt,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _textArt = i);
                    },
                  ),
              ],
            ),
            label('فواصل وزخارف'),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: [
                for (var i = kTextArtPictureCount; i < kTextArts.length; i++)
                  _TextTile(
                    name: kTextArts[i].name,
                    selected: i == _textArt,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _textArt = i);
                    },
                  ),
              ],
            ),
          ],
          if (_mode == 2) ...[
            label('الاسم'),
            TextField(
              controller: _name,
              maxLength: 20,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              decoration: paperFieldDecoration(
                context,
                hintText: 'مثال: Ali أو محمد',
                counterText: '',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            if (NameArt.hasArabic(_name.text))
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.s),
                child: Text(
                  'الاسم عربي: يبقى سطره مفتوحاً من اليمين لأن الحروف العربية ليست '
                  'أحادية العرض، وبقية الشكل يظهر كاملاً.',
                  style: context.text.bodySmall?.copyWith(
                    color: p.inkFaint,
                    height: 1.6,
                  ),
                ),
              ),
            label('الشكل'),
            Wrap(
              spacing: AppSpace.s,
              runSpacing: AppSpace.s,
              children: [
                for (var i = 0; i < kNameArts.length; i++)
                  _TextTile(
                    name: kNameArts[i].name,
                    selected: i == _nameArt,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _nameArt = i);
                    },
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpace.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: p.inkFaint),
              const SizedBox(width: AppSpace.s),
              Expanded(
                child: Text(
                  _mode == 0
                      ? 'الخلفيات ⬜ ⬛ 🤍 تظهر مضبوطة 100% على كل الأجهزة لأن كل خلية رمز. '
                            '«شفاف» تقريبي لأنه فراغات وعرضها يختلف بين الأجهزة. '
                            'الأبيض ⬜ يكاد يختفي على الفقاعة البيضاء في الوضع الفاتح. '
                            'لا تكتب الرسمة بتنسيق «كود».'
                      : _mode == 1
                      ? 'تُدرج داخل كتلة أحادية العرض (```) فيأخذ كل حرف نفس العرض '
                            'وتظهر مضبوطة في تطبيق المراسلة على كل الأجهزة. لا تعدّل داخلها بحروف عربية '
                            'ولا تنسخها لتطبيق آخر يعرضها بخط عادي.'
                      : 'الأسماء الإنجليزية تُضبط حواف الشكل تماماً. تُدرج داخل كتلة أحادية '
                            'العرض (```) فلا تنسخها لتطبيق يعرضها بخط عادي.',
                  style: context.text.bodySmall?.copyWith(
                    color: p.inkFaint,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.m),
        ],
      ),
    );
  }
}

/// بطاقة رسمة: مصغّرة مرسومة بمربعات صغيرة مع الاسم
class _ArtTile extends StatelessWidget {
  const _ArtTile({
    required this.art,
    required this.selected,
    required this.onTap,
  });

  final EmojiArt art;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = context.accent;

    return Semantics(
      button: true,
      selected: selected,
      label: art.name,
      child: Material(
        color: selected ? a.soft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.m),
          onTap: onTap,
          child: Container(
            width: 84,
            padding: const EdgeInsets.symmetric(vertical: AppSpace.m),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(
                color: selected ? a.color : p.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 52,
                  height: 44,
                  child: CustomPaint(
                    painter: _ArtThumbPainter(
                      art,
                      selected ? a.color : p.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s),
                Text(
                  art.name,
                  style: context.text.labelMedium?.copyWith(
                    color: selected ? a.color : p.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// يرسم مصغّرة الرسمة: مربع صغير مدوّر لكل خلية مملوءة
class _ArtThumbPainter extends CustomPainter {
  const _ArtThumbPainter(this.art, this.color);

  final EmojiArt art;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = (size.width / art.width).clamp(0.0, size.height / art.height);
    final left = (size.width - cell * art.width) / 2;
    final top = (size.height - cell * art.height) / 2;
    final paint = Paint()..color = color;
    final gap = cell * 0.12;

    for (var y = 0; y < art.height; y++) {
      final row = art.rows[y];
      for (var x = 0; x < art.width; x++) {
        if (row[x] != '#') continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              left + x * cell + gap,
              top + y * cell + gap,
              cell - gap * 2,
              cell - gap * 2,
            ),
            Radius.circular(cell * 0.25),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ArtThumbPainter old) =>
      old.art != art || old.color != color;
}

/// رمز قابل للاختيار (للّون أو الخلفية)
class _EmojiChip extends StatelessWidget {
  const _EmojiChip({
    required this.emoji,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.transparent = false,
  });

  final String emoji;
  final bool transparent;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = context.accent;

    return Opacity(
      opacity: disabled ? 0.35 : 1,
      child: Material(
        color: selected ? a.soft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.m),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.m),
          onTap: disabled ? null : onTap,
          child: Container(
            width: transparent ? 84 : 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(
                color: selected ? a.color : p.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: transparent
                ? Text(
                    'شفاف\n(تقريبي)',
                    textAlign: TextAlign.center,
                    style: context.text.labelMedium?.copyWith(
                      color: selected ? a.color : p.inkSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}

/// شريحة اسم رسمة بالحروف
class _TextTile extends StatelessWidget {
  const _TextTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = context.accent;

    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: Material(
        color: selected ? a.soft : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.l,
              vertical: AppSpace.m,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected ? a.color : p.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              name,
              style: context.text.labelLarge?.copyWith(
                color: selected ? a.color : p.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
