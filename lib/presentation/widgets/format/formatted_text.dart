import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/helpers/message_format.dart';

/// يحوّل نصاً بعلامات التنسيق إلى مقاطع منسّقة (عريض، مائل، مشطوب، خط ثابت)
class FormatRenderer {
  /// عند [showMarkers] تبقى العلامات ظاهرة بلون باهت (للحقل القابل للتعديل)،
  /// وإلا تُحذف (للمعاينة والبطاقات). [composing] لتسطير نص الإدخال الجاري.
  static List<InlineSpan> spans(
    String text,
    TextStyle base, {
    required bool showMarkers,
    Color? markerColor,
    Color? monoBackground,
    TextRange? composing,
  }) {
    final n = text.length;
    if (n == 0) return const [];

    final bold = List.filled(n, false);
    final italic = List.filled(n, false);
    final strike = List.filled(n, false);
    final mono = List.filled(n, false);
    final marker = List.filled(n, false);

    for (final s in MessageFormat.parse(text)) {
      final len = s.markerLength;
      for (var i = s.start; i < s.start + len; i++) {
        marker[i] = true;
      }
      for (var i = s.contentEnd; i < s.contentEnd + len; i++) {
        marker[i] = true;
      }
      final flags = switch (s.style) {
        FormatStyle.bold => bold,
        FormatStyle.italic => italic,
        FormatStyle.strike => strike,
        FormatStyle.mono => mono,
      };
      for (var i = s.contentStart; i < s.contentEnd; i++) {
        flags[i] = true;
      }
    }

    bool inComposing(int i) =>
        composing != null && i >= composing.start && i < composing.end;

    bool same(int a, int b) =>
        marker[a] == marker[b] &&
        bold[a] == bold[b] &&
        italic[a] == italic[b] &&
        strike[a] == strike[b] &&
        mono[a] == mono[b] &&
        inComposing(a) == inComposing(b);

    final out = <InlineSpan>[];
    var i = 0;
    while (i < n) {
      if (marker[i] && !showMarkers) {
        i++;
        continue;
      }
      var j = i + 1;
      while (j < n && same(i, j) && !(marker[j] && !showMarkers)) {
        j++;
      }

      TextStyle style = base;
      if (marker[i]) {
        style = base.copyWith(
          color: markerColor ?? base.color?.withValues(alpha: 0.35),
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        );
      } else {
        style = base.copyWith(
          fontWeight: bold[i] ? FontWeight.w800 : null,
          fontStyle: italic[i] ? FontStyle.italic : null,
          decoration: strike[i] ? TextDecoration.lineThrough : null,
          fontFamily: mono[i] ? 'monospace' : null,
          fontFamilyFallback: mono[i] ? const [AppTheme.fontFamily] : null,
          backgroundColor: mono[i] ? monoBackground : null,
        );
      }
      if (inComposing(i)) {
        style = style.copyWith(
          decoration: TextDecoration.combine([
            if (style.decoration != null) style.decoration!,
            TextDecoration.underline,
          ]),
        );
      }

      out.add(TextSpan(text: text.substring(i, j), style: style));
      i = j;
    }
    return out;
  }
}

/// نص للعرض يطبّق تنسيق الرسالة (بدون إظهار العلامات)
class FormattedText extends StatelessWidget {
  const FormattedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textDirection,
    this.selectable = false,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDirection? textDirection;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = DefaultTextStyle.of(context).style.merge(style);
    final span = TextSpan(
      style: base,
      children: FormatRenderer.spans(
        text,
        base,
        showMarkers: false,
        monoBackground: p.surfaceAlt,
      ),
    );

    if (selectable) {
      return SelectableText.rich(
        span,
        textDirection: textDirection,
        maxLines: maxLines,
      );
    }
    return Text.rich(
      span,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// متحكم نص يلوّن المحتوى أثناء الكتابة: العلامات باهتة والنص المنسّق بشكله الحقيقي
class FormattedTextController extends TextEditingController {
  FormattedTextController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = style ?? const TextStyle();
    final p = context.palette;
    final composing = withComposing && value.isComposingRangeValid
        ? value.composing
        : null;

    return TextSpan(
      style: base,
      children: FormatRenderer.spans(
        text,
        base,
        showMarkers: true,
        markerColor: p.inkFaint,
        monoBackground: p.surfaceAlt,
        composing: composing,
      ),
    );
  }
}
