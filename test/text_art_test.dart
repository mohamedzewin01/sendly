import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sendly/app/theme/app_theme.dart';
import 'package:sendly/core/helpers/message_format.dart';
import 'package:sendly/core/helpers/text_art.dart';
import 'package:sendly/presentation/widgets/format/formatted_field.dart';
import 'package:sendly/presentation/widgets/format/formatted_text.dart';

void main() {
  group('الرسومات بالحروف', () {
    test('كل رسمة ضمن أقصى عرض ولا تحوي أسطراً فارغة أو فراغات ختامية', () {
      for (final art in kTextArts) {
        expect(art.lines, isNotEmpty, reason: art.name);
        expect(art.lines.length, lessThanOrEqualTo(12), reason: art.name);
        expect(
          art.width,
          lessThanOrEqualTo(TextArt.maxWidth),
          reason: art.name,
        );
        for (final line in art.lines) {
          expect(line.trim(), isNotEmpty, reason: '${art.name}: سطر فارغ');
          expect(line, isNot(endsWith(' ')), reason: '${art.name}: فراغ ختامي');
          expect(
            line.contains('`'),
            isFalse,
            reason: '${art.name}: علامة كتلة',
          );
          // حروف لاتينية ورموز فقط: العربية داخل الكتلة الأحادية تخلّ بالتوازي
          expect(
            RegExp(r'^[\x20-\x7E£]+$').hasMatch(line),
            isTrue,
            reason: '${art.name}: حرف غير مسموح',
          );
        }
      }
    });

    test('render: كتلة أحادية العرض وكل سطر يبدأ بعلامة اتجاه', () {
      for (final art in kTextArts) {
        final text = art.render();
        expect(text.startsWith('```'), isTrue, reason: art.name);
        expect(text.endsWith('```'), isTrue, reason: art.name);
        final body = text.substring(3, text.length - 3).split('\n');
        expect(body.length, art.lines.length, reason: art.name);
        for (var i = 0; i < body.length; i++) {
          expect(body[i], '‎${art.lines[i]}', reason: art.name);
        }
      }
    });

    test('التطبيق يتعرّف على الرسمة كتلة أحادية واحدة تغطي النص كله', () {
      for (final art in kTextArts) {
        final spans = MessageFormat.parse(art.render());
        expect(spans.length, 1, reason: art.name);
        expect(spans.first.style, FormatStyle.mono, reason: art.name);
        expect(spans.first.start, 0, reason: art.name);
        expect(spans.first.end, art.render().length, reason: art.name);
      }
    });

    test('عدد الرسومات قبل الفواصل صحيح', () {
      expect(kTextArtPictureCount, lessThan(kTextArts.length));
      // الفواصل سطر واحد
      for (var i = kTextArtPictureCount; i < kTextArts.length; i++) {
        expect(kTextArts[i].lines.length, 1, reason: kTextArts[i].name);
      }
    });
  });

  group('اسمك في شكل', () {
    const names = [
      'Ali',
      'MOHAMED ALI',
      'محمد',
      'عبد الرحمن بن محمد الكبير جداً',
      'A very very long english name indeed',
    ];

    test('كل الأسطر ضمن أقصى عرض مهما طال الاسم', () {
      for (final art in kNameArts) {
        for (final name in names) {
          final result = art.fill(name);
          expect(
            result.width,
            lessThanOrEqualTo(TextArt.maxWidth),
            reason: '${art.name} / $name',
          );
          expect(result.render().startsWith('```'), isTrue);
        }
      }
    });

    test('الأسماء الإنجليزية: الإطارات المغلقة مستطيل تام العرض', () {
      for (final art in kNameArts.where((a) => a.right.isNotEmpty)) {
        for (final name in ['Ali', 'MOHAMED ALI', 'A B']) {
          final lines = art.fill(name).lines;
          final widths = lines.map((l) => l.length).toSet();
          // كل الأسطر بنفس العرض ما عدا أسطر أعرض قليلاً في القوالب المتدرجة (القلب)
          if (art.name == 'قلب باسمك') {
            final nameLine = lines[3];
            expect(nameLine.length, 20, reason: name);
            expect(nameLine.endsWith('/'), isTrue);
            continue;
          }
          expect(widths.length, 1, reason: '${art.name} / $name: $widths');
        }
      }
    });

    test('الاسم العربي: يبقى سطره بلا حد أيمن وباقي الشكل كاملاً', () {
      final result = kNameArts.first.fill('محمد');
      expect(result.lines.first, '+--------------------+');
      expect(result.lines.last, '+--------------------+');
      expect(result.lines[1].startsWith('|'), isTrue);
      expect(result.lines[1].endsWith('|'), isFalse);
      expect(result.lines[1].contains('محمد'), isTrue);
    });

    test(
      'الاسم الفارغ يُعرض «NAME» للمعاينة، والتنظيف يزيل علامات الكتلة والأسطر',
      () {
        expect(kNameArts.first.fill('').plain.contains('NAME'), isTrue);
        expect(NameArt.clean('a```b\n  c'), 'a b c');
      },
    );

    test('تُعرَف الكتلة أحادية العرض في التطبيق', () {
      for (final art in kNameArts) {
        final spans = MessageFormat.parse(art.fill('Ali').render());
        expect(spans.length, 1, reason: art.name);
        expect(spans.first.style, FormatStyle.mono, reason: art.name);
      }
    });
  });

  testWidgets('وضع «اسمك» يُدرج الاسم داخل الشكل في الرسالة', (tester) async {
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

    await tester.tap(find.text('اسمك'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ali');
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة إلى الرسالة'));
    await tester.pumpAndSettle();

    expect(controller.text, '${kNameArts.first.fill('Ali').render()}\n');
  });

  testWidgets('وضع الحروف والرموز يُدرج كتلة أحادية العرض في الرسالة', (
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

    await tester.tap(find.text('حروف ورموز'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة إلى الرسالة'));
    await tester.pumpAndSettle();

    expect(controller.text, '${kTextArts.first.render()}\n');
  });
}
