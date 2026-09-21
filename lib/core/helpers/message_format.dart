import 'package:flutter/services.dart';

/// أنواع التنسيق النصي المدعومة داخل الرسالة
enum FormatStyle {
  bold('*'),
  italic('_'),
  strike('~'),
  mono('```');

  const FormatStyle(this.marker);

  /// العلامة التي تحيط بالنص (الصيغة الموحّدة المستخدمة في التطبيق)
  final String marker;
}

/// نطاق منسّق داخل النص: [start, end) يشمل العلامتين، و[contentStart, contentEnd) النص بينهما
class FormatSpan {
  const FormatSpan(
    this.style,
    this.start,
    this.end,
    this.contentStart,
    this.contentEnd,
  );

  final FormatStyle style;
  final int start;
  final int end;
  final int contentStart;
  final int contentEnd;

  int get markerLength => style.marker.length;
}

/// أدوات تنسيق الرسائل: تحليل العلامات وأوامر التحرير.
///
/// الرسالة تُحفظ بعلامات بسيطة: `*عريض*` `_مائل_` `~مشطوب~` و```خط ثابت```،
/// وهي الصيغة التي يفهمها تطبيق المراسلة الفورية مباشرة.
class MessageFormat {
  static const String bullet = '• ';
  static const String divider = '──────────';

  static final RegExp _alnum = RegExp(r'[\p{L}\p{N}]', unicode: true);
  static final RegExp _numbered = RegExp(r'^(\d+)[.)]\s');

  // ==================== التحليل ====================

  /// كل النطاقات المنسّقة (بما فيها المتداخلة) مرتبة حسب بدايتها
  static List<FormatSpan> parse(String text) {
    final out = <FormatSpan>[];
    _parseRange(text, 0, text.length, out);
    out.sort((a, b) => a.start.compareTo(b.start));
    return out;
  }

  static bool hasFormatting(String text) => parse(text).isNotEmpty;

  static void _parseRange(String text, int from, int to, List<FormatSpan> out) {
    var i = from;
    while (i < to) {
      final style = _openingAt(text, i, from, to);
      if (style == null) {
        i++;
        continue;
      }
      final close = _findClose(text, i, to, style);
      if (close == null) {
        i++;
        continue;
      }
      final len = style.marker.length;
      final span = FormatSpan(style, i, close + len, i + len, close);
      out.add(span);
      if (style != FormatStyle.mono) {
        _parseRange(text, span.contentStart, span.contentEnd, out);
      }
      i = span.end;
    }
  }

  static bool _isAlnum(String ch) => _alnum.hasMatch(ch);
  static bool _isSpace(String ch) => ch.trim().isEmpty;

  static FormatStyle? _openingAt(String text, int i, int from, int to) {
    // «```» قبل بقية العلامات
    for (final style in const [
      FormatStyle.mono,
      FormatStyle.bold,
      FormatStyle.italic,
      FormatStyle.strike,
    ]) {
      final m = style.marker;
      if (!text.startsWith(m, i)) continue;
      if (i > from && _isAlnum(text[i - 1])) return null;
      final next = i + m.length;
      if (next >= to) return null;
      final nextChar = text[next];
      if (style != FormatStyle.mono && (_isSpace(nextChar) || nextChar == m)) {
        return null;
      }
      return style;
    }
    return null;
  }

  static int? _findClose(String text, int open, int to, FormatStyle style) {
    final m = style.marker;
    for (var j = open + m.length + 1; j <= to - m.length; j++) {
      if (style != FormatStyle.mono && text[j] == '\n') return null;
      if (!text.startsWith(m, j)) continue;
      if (style != FormatStyle.mono && _isSpace(text[j - 1])) continue;
      final after = j + m.length;
      if (after < text.length && after < to && _isAlnum(text[after])) continue;
      return j;
    }
    return null;
  }

  // ==================== أوامر التحرير ====================

  /// الأنماط النشطة عند المؤشر أو التحديد (لتمييز الأزرار)
  static Set<FormatStyle> activeStyles(TextEditingValue v) {
    final sel = v.selection;
    if (!sel.isValid) return {};
    final a = sel.start, b = sel.end;
    return {
      for (final s in parse(v.text))
        if (a >= s.contentStart && b <= s.contentEnd) s.style,
    };
  }

  /// يفعّل/يلغي [style] على التحديد، أو على الكلمة عند المؤشر، أو يدرج علامتين جاهزتين للكتابة
  static TextEditingValue toggleStyle(TextEditingValue v, FormatStyle style) {
    final text = v.text;
    final m = style.marker;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: text.length);
    var a = sel.start, b = sel.end;
    final same = parse(text).where((s) => s.style == style).toList();

    if (a == b) {
      final inside = same.where(
        (s) => a >= s.contentStart && a <= s.contentEnd,
      );
      if (inside.isNotEmpty) return _unwrap(v, inside.first);

      final word = _wordAt(text, a);
      if (word == null) {
        return TextEditingValue(
          text: text.replaceRange(a, a, '$m$m'),
          selection: TextSelection.collapsed(offset: a + m.length),
        );
      }
      a = word.start;
      b = word.end;
    } else {
      while (a < b && _isSpace(text[a])) {
        a++;
      }
      while (b > a && _isSpace(text[b - 1])) {
        b--;
      }
      if (a == b) {
        return TextEditingValue(
          text: text.replaceRange(sel.end, sel.end, '$m$m'),
          selection: TextSelection.collapsed(offset: sel.end + m.length),
        );
      }
      final exact = same.where((s) => s.start == a && s.end == b);
      if (exact.isNotEmpty) return _unwrap(v, exact.first);
      final inside = same.where(
        (s) => a >= s.contentStart && b <= s.contentEnd,
      );
      if (inside.isNotEmpty) return _unwrap(v, inside.first);
    }

    return TextEditingValue(
      text:
          '${text.substring(0, a)}$m${text.substring(a, b)}$m${text.substring(b)}',
      selection: TextSelection(
        baseOffset: a + m.length,
        extentOffset: b + m.length,
      ),
    );
  }

  static TextEditingValue _unwrap(TextEditingValue v, FormatSpan span) {
    final text = v.text;
    final len = span.markerLength;
    final inner = text.substring(span.contentStart, span.contentEnd);
    int map(int o) {
      if (o <= span.start) return o;
      if (o >= span.end) return o - 2 * len;
      return (o - len).clamp(span.start, span.start + inner.length);
    }

    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: text.length);
    return TextEditingValue(
      text: text.substring(0, span.start) + inner + text.substring(span.end),
      selection: TextSelection(
        baseOffset: map(sel.baseOffset),
        extentOffset: map(sel.extentOffset),
      ),
    );
  }

  static ({int start, int end})? _wordAt(String text, int pos) {
    var s = pos, e = pos;
    while (s > 0 && _isAlnum(text[s - 1])) {
      s--;
    }
    while (e < text.length && _isAlnum(text[e])) {
      e++;
    }
    return s == e ? null : (start: s, end: e);
  }

  /// قائمة نقطية للأسطر المحددة (أو السطر الحالي)، وتُلغى إن كانت مطبّقة
  static TextEditingValue toggleBullets(TextEditingValue v) => _toggleLines(
    v,
    isApplied: (line) => line.startsWith(bullet),
    strip: (line) => line.substring(bullet.length),
    apply: (line, _) => bullet + _withoutListPrefix(line),
  );

  /// قائمة مرقّمة للأسطر المحددة (أو السطر الحالي)، وتُلغى إن كانت مطبّقة
  static TextEditingValue toggleNumbering(TextEditingValue v) => _toggleLines(
    v,
    isApplied: (line) => _numbered.hasMatch(line),
    strip: (line) => line.replaceFirst(_numbered, ''),
    apply: (line, index) => '${index + 1}. ${_withoutListPrefix(line)}',
  );

  static String _withoutListPrefix(String line) {
    if (line.startsWith(bullet)) return line.substring(bullet.length);
    return line.replaceFirst(_numbered, '');
  }

  static TextEditingValue _toggleLines(
    TextEditingValue v, {
    required bool Function(String line) isApplied,
    required String Function(String line) strip,
    required String Function(String line, int index) apply,
  }) {
    final text = v.text;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: text.length);
    var start = text.lastIndexOf('\n', sel.start == 0 ? 0 : sel.start - 1) + 1;
    if (sel.start == 0) start = 0;
    var endPos = sel.end;
    if (!sel.isCollapsed && endPos > 0 && text[endPos - 1] == '\n') endPos--;
    var end = text.indexOf('\n', endPos);
    if (end == -1) end = text.length;

    final lines = text.substring(start, end).split('\n');
    final filled = lines.where((l) => l.trim().isNotEmpty).toList();
    final allApplied = filled.isNotEmpty && filled.every(isApplied);

    var counter = 0;
    final result = [
      for (final line in lines)
        if (line.trim().isEmpty)
          line
        else if (allApplied)
          strip(line)
        else
          apply(line, counter++),
    ].join('\n');

    return TextEditingValue(
      text: text.replaceRange(start, end, result),
      selection: sel.isCollapsed
          ? TextSelection.collapsed(offset: start + result.length)
          : TextSelection(
              baseOffset: start,
              extentOffset: start + result.length,
            ),
    );
  }

  /// يدرج فاصلاً بين فقرتين عند المؤشر
  static TextEditingValue insertDivider(TextEditingValue v) {
    final text = v.text;
    final pos = v.selection.isValid ? v.selection.end : text.length;
    final before = pos > 0 && text[pos - 1] != '\n' ? '\n' : '';
    final after = pos < text.length && text[pos] != '\n' ? '\n' : '';
    return insertText(v, '$before$divider\n$after');
  }

  /// يستبدل التحديد بالنص [s] ويضع المؤشر بعده
  static TextEditingValue insertText(TextEditingValue v, String s) {
    final text = v.text;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: text.length);
    return TextEditingValue(
      text: text.replaceRange(sel.start, sel.end, s),
      selection: TextSelection.collapsed(offset: sel.start + s.length),
    );
  }

  /// يزيل علامات التنسيق من التحديد، أو من النص كله إن لم يكن هناك تحديد
  static TextEditingValue clearFormatting(TextEditingValue v) {
    final text = v.text;
    final sel = v.selection.isValid
        ? v.selection
        : TextSelection.collapsed(offset: text.length);
    final spans = parse(text)
        .where(
          (s) => sel.isCollapsed || (s.start < sel.end && s.end > sel.start),
        )
        .toList();
    if (spans.isEmpty) return v;

    final removals = <(int, int)>[
      for (final s in spans) ...[
        (s.start, s.markerLength),
        (s.contentEnd, s.markerLength),
      ],
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    int map(int o) {
      var shift = 0;
      for (final (start, len) in removals) {
        if (o >= start + len) {
          shift += len;
        } else if (o > start) {
          shift += o - start;
        }
      }
      return o - shift;
    }

    final buffer = StringBuffer();
    var cursor = 0;
    for (final (start, len) in removals) {
      buffer.write(text.substring(cursor, start));
      cursor = start + len;
    }
    buffer.write(text.substring(cursor));

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection(
        baseOffset: map(sel.baseOffset),
        extentOffset: map(sel.extentOffset),
      ),
    );
  }

  /// تنسيق تلقائي: عنوان عريض، قوائم منظّمة، وإزالة الفراغات الزائدة
  static TextEditingValue autoFormat(TextEditingValue v) {
    final listMarker = RegExp(r'^\s*(?:[-–—•·]|\*(?=\s))\s+(.*)$');
    final numberMarker = RegExp(r'^\s*(\d+)[.)\-]\s+(.*)$');

    var lines = v.text.split('\n').map((l) => l.trimRight()).toList();
    lines = [
      for (final line in lines)
        if (numberMarker.hasMatch(line))
          '${numberMarker.firstMatch(line)!.group(1)}. ${numberMarker.firstMatch(line)!.group(2)}'
        else if (listMarker.hasMatch(line))
          '$bullet${listMarker.firstMatch(line)!.group(1)}'
        else
          line,
    ];

    // إزالة الأسطر الفارغة المتكررة والفارغة في الأطراف
    final cleaned = <String>[];
    for (final line in lines) {
      if (line.trim().isEmpty &&
          (cleaned.isEmpty || cleaned.last.trim().isEmpty)) {
        continue;
      }
      cleaned.add(line);
    }
    while (cleaned.isNotEmpty && cleaned.last.trim().isEmpty) {
      cleaned.removeLast();
    }

    // العنوان: أول سطر قصير غير منسّق وبعده محتوى
    if (cleaned.length >= 2) {
      final first = cleaned.first.trim();
      final isList = first.startsWith(bullet) || _numbered.hasMatch(first);
      if (first.isNotEmpty &&
          first.length <= 60 &&
          !isList &&
          !hasFormatting(first)) {
        cleaned[0] = '*$first*';
      }
    }

    final result = cleaned.join('\n');
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  MessageFormat._();
}
