import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sendly/app/theme/app_theme.dart';
import 'package:sendly/core/helpers/emoji_art.dart';
import 'package:sendly/core/helpers/message_format.dart';
import 'package:sendly/presentation/widgets/format/formatted_field.dart';
import 'package:sendly/presentation/widgets/format/formatted_text.dart';

void main() {
  group('الرسومات بالرموز', () {
    test('كل رسمة شبكة منتظمة وضمن أقصى عرض يتسع في واتساب', () {
      for (final art in kEmojiArts) {
        expect(art.rows, isNotEmpty, reason: art.name);
        for (final row in art.rows) {
          expect(row.length, art.width, reason: '${art.name}: صف بعرض مختلف');
          expect(
            RegExp(r'^[#.]+$').hasMatch(row),
            isTrue,
            reason: '${art.name}: رموز غير مسموحة',
          );
        }
        expect(art.width, lessThanOrEqualTo(9), reason: art.name);
        expect(art.height, lessThanOrEqualTo(10), reason: art.name);
        expect(art.rows.join().contains('#'), isTrue, reason: art.name);
      }
    });

    test('رموز التعبئة والخلفيات فريدة ولا تتكرر', () {
      expect(
        EmojiArtPalette.fills.toSet().length,
        EmojiArtPalette.fills.length,
      );
      expect(
        EmojiArtPalette.backgrounds.toSet().length,
        EmojiArtPalette.backgrounds.length,
      );
      expect(kEmojiArts.map((a) => a.name).toSet().length, kEmojiArts.length);
    });

    test('render: كل سطر يحوي عدد خلايا العرض بالضبط ولا مسافات', () {
      for (final art in kEmojiArts) {
        final text = art.render(fill: '❤️', background: '⬜');
        final lines = text.split('\n');
        expect(lines.length, art.height, reason: art.name);
        for (final line in lines) {
          final cells =
              '❤️'.allMatches(line).length + '⬜'.allMatches(line).length;
          expect(cells, art.width, reason: art.name);
          expect(line.contains(' '), isFalse, reason: 'مسافة تُخلّ بالمحاذاة');
        }
      }
    });

    test(
      'رموز التعبئة والخلفيات الملوّنة لا تحوي علامات التنسيق ولا مسافات',
      () {
        for (final e in [
          ...EmojiArtPalette.fills,
          ...EmojiArtPalette.backgrounds.where(
            (b) => b != EmojiArtPalette.transparent,
          ),
        ]) {
          expect(RegExp(r'[*_~`\s]').hasMatch(e), isFalse, reason: e);
        }
      },
    );

    test('الخلفية الشفافة: كل سطر يبدأ بعلامة اتجاه وعدد خلاياه ثابت', () {
      const blank = EmojiArtPalette.transparent;
      for (final art in kEmojiArts) {
        final lines = art.render(fill: '❤️', background: blank).split('\n');
        for (final line in lines) {
          expect(line.startsWith('\u200E'), isTrue, reason: art.name);
          final body = line.substring(1);
          final cells =
              '❤️'.allMatches(body).length + blank.allMatches(body).length;
          expect(cells, art.width, reason: art.name);
          // لا مسافة عادية (ASCII) تنهار مع الخط المتناسب
          expect(body.contains(' '), isFalse, reason: art.name);
        }
      }
    });
  });

  group('MessageFormat.insertBlock', () {
    TextEditingValue value(String text, int offset) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );

    test('في رسالة فارغة: الكتلة ثم سطر جديد', () {
      final v = MessageFormat.insertBlock(value('', 0), 'A\nB');
      expect(v.text, 'A\nB\n');
      expect(v.selection.baseOffset, 4);
    });

    test('بعد نص على نفس السطر: تبدأ الكتلة على سطر جديد', () {
      final v = MessageFormat.insertBlock(value('مرحبا', 5), 'A\nB');
      expect(v.text, 'مرحبا\nA\nB\n');
    });

    test('في أول سطر فارغ: لا سطر زائد قبلها', () {
      final v = MessageFormat.insertBlock(value('مرحبا\n', 6), 'A');
      expect(v.text, 'مرحبا\nA\n');
    });

    test('قبل نص موجود: لا سطر مضاعف بعدها', () {
      final v = MessageFormat.insertBlock(value('\nتحية', 0), 'A');
      expect(v.text, 'A\nتحية');
    });
  });

  testWidgets('زر الرسومات يُدرج الرسمة المختارة في حقل الرسالة', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(800, 1800);
    addTearDown(tester.view.reset);

    final controller = FormattedTextController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SingleChildScrollView(
              child: FormattedField(
                controller: controller,
                decoration: const InputDecoration(),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.interests_rounded));
    await tester.pumpAndSettle();
    expect(find.text('رسومات بالرموز'), findsOneWidget);

    await tester.tap(find.text('إضافة إلى الرسالة'));
    await tester.pumpAndSettle();

    // الخلفية الافتراضية ⬜ (محاذاة مضمونة لأن كل خلية رمز)
    final expected = kEmojiArts.first.render(fill: '❤️', background: '⬜');
    expect(controller.text, '$expected\n');
  });
}
