import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sendly/app/app.dart';
import 'package:sendly/core/helpers/message_format.dart';
import 'package:sendly/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingValue v(String text, [int? base, int? extent]) => TextEditingValue(
  text: text,
  selection: TextSelection(
    baseOffset: base ?? text.length,
    extentOffset: extent ?? base ?? text.length,
  ),
);

void main() {
  group('تحليل العلامات', () {
    test('يتعرّف على الأنماط الأربعة', () {
      final spans = MessageFormat.parse('*عريض* _مائل_ ~مشطوب~ ```ثابت```');
      expect(spans.map((s) => s.style), [
        FormatStyle.bold,
        FormatStyle.italic,
        FormatStyle.strike,
        FormatStyle.mono,
      ]);
    });

    test('لا يعتبر النصوص العادية تنسيقاً', () {
      for (final text in [
        '2*3 = 6',
        'snake_case_name',
        'a * b * c',
        '** فارغ **',
        'سعر* 50',
      ]) {
        expect(MessageFormat.hasFormatting(text), isFalse, reason: text);
      }
    });

    test('التداخل بين نمطين', () {
      final spans = MessageFormat.parse('*_مهم_*');
      expect(spans.map((s) => s.style).toSet(), {
        FormatStyle.bold,
        FormatStyle.italic,
      });
    });

    test('لا يمتد التنسيق العادي عبر سطرين', () {
      expect(MessageFormat.hasFormatting('*سطر\nآخر*'), isFalse);
    });
  });

  group('أوامر التحرير', () {
    test('تعريض تحديد ثم إلغاؤه', () {
      final bold = MessageFormat.toggleStyle(
        v('قل مرحبا الآن', 3, 9),
        FormatStyle.bold,
      );
      expect(bold.text, 'قل *مرحبا* الآن');
      expect(bold.selection.textInside(bold.text), 'مرحبا');

      final back = MessageFormat.toggleStyle(bold, FormatStyle.bold);
      expect(back.text, 'قل مرحبا الآن');
      expect(back.selection.textInside(back.text), 'مرحبا');
    });

    test('المؤشر داخل كلمة يعرّض الكلمة كلها', () {
      final r = MessageFormat.toggleStyle(v('قل مرحبا', 5), FormatStyle.bold);
      expect(r.text, 'قل *مرحبا*');
    });

    test('مؤشر في مكان فارغ يدرج علامتين ويضع المؤشر بينهما', () {
      final r = MessageFormat.toggleStyle(v(''), FormatStyle.italic);
      expect(r.text, '__');
      expect(r.selection.baseOffset, 1);
    });

    test('المسافات على أطراف التحديد تبقى خارج العلامات', () {
      final r = MessageFormat.toggleStyle(
        v('أ  مرحبا  ب', 1, 10),
        FormatStyle.bold,
      );
      expect(r.text, 'أ  *مرحبا*  ب');
    });

    test('الأنماط النشطة عند المؤشر', () {
      final value = v('*_x_*', 2);
      expect(MessageFormat.activeStyles(value), {
        FormatStyle.bold,
        FormatStyle.italic,
      });
    });

    test('القائمة النقطية تُطبّق وتُلغى', () {
      final on = MessageFormat.toggleBullets(v('أ\nب', 0, 3));
      expect(on.text, '• أ\n• ب');
      expect(MessageFormat.toggleBullets(on).text, 'أ\nب');
    });

    test('القائمة المرقّمة تحلّ محل النقطية', () {
      final r = MessageFormat.toggleNumbering(v('• أ\n• ب', 0, 7));
      expect(r.text, '1. أ\n2. ب');
    });

    test('الفاصل يُدرج في سطر مستقل', () {
      expect(
        MessageFormat.insertDivider(v('مرحبا')).text,
        'مرحبا\n──────────\n',
      );
    });

    test('مسح التنسيق', () {
      expect(MessageFormat.clearFormatting(v('*أ* و _ب_')).text, 'أ و ب');
    });

    test('التنسيق التلقائي: عنوان وقوائم', () {
      final r = MessageFormat.autoFormat(
        v('عرض اليوم\n\n\n- بند أول\n2) بند ثان  \n'),
      );
      expect(r.text, '*عرض اليوم*\n\n• بند أول\n2. بند ثان');
    });
  });

  group('لوحة المفاتيح', () {
    Future<void> settle(WidgetTester t, [int ms = 900]) async {
      for (var i = 0; i < ms ~/ 50; i++) {
        await t.pump(const Duration(milliseconds: 50));
      }
    }

    Future<void> boot(WidgetTester tester) async {
      StorageService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const SendlyApp());
      await settle(tester);
    }

    testWidgets('الضغط على مساحة فاضية في الصفحة يخفي الكيبورد', (
      tester,
    ) async {
      await boot(tester);

      await tester.tap(find.byType(TextField).at(1));
      await settle(tester);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(find.text('راسل أي رقم دون حفظه في جهات الاتصال'));
      await settle(tester);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('الضغط على مساحة فاضية في نموذج الإضافة يخفي الكيبورد', (
      tester,
    ) async {
      await boot(tester);

      await tester.tap(find.byType(NavigationDestination).at(1));
      await settle(tester);
      await tester.tap(find.text('إضافة جهة اتصال'));
      await settle(tester);

      await tester.tap(find.byType(TextFormField).first);
      await settle(tester);
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(find.text('الاسم والرقم مطلوبان، والملاحظة اختيارية'));
      await settle(tester);
      expect(tester.testTextInput.isVisible, isFalse);
    });

    testWidgets('أزرار التنسيق لا تخفي الكيبورد ولا تسحب التركيز', (
      tester,
    ) async {
      await boot(tester);

      final field = find.byType(TextField).at(1);
      await tester.enterText(field, 'مرحبا بكم');
      final controller = tester.widget<TextField>(field).controller!;
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 5,
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.format_italic_rounded));
      await settle(tester);

      expect(controller.text, '_مرحبا_ بكم');
      expect(tester.testTextInput.isVisible, isTrue);
    });
  });

  group('الشاشة', () {
    Future<void> settle(WidgetTester t, [int ms = 900]) async {
      for (var i = 0; i < ms ~/ 50; i++) {
        await t.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('زر العريض يلفّ التحديد وتظهر المعاينة', (tester) async {
      StorageService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 2;
      tester.view.physicalSize = const Size(800, 1600);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const SendlyApp());
      await settle(tester);

      final field = find.byType(TextField).at(1);
      await tester.enterText(field, 'خصم كبير اليوم');
      final controller = tester.widget<TextField>(field).controller!;
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 8,
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.format_bold_rounded));
      await settle(tester);

      expect(controller.text, '*خصم كبير* اليوم');
      expect(find.text('معاينة'), findsOneWidget);
    });
  });
}
