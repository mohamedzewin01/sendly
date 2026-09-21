import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sendly/app/app.dart';
import 'package:sendly/core/helpers/digits_formatter.dart';
import 'package:sendly/core/helpers/phone_extractor.dart';
import 'package:sendly/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final int _now = DateTime.now().millisecondsSinceEpoch;

final Map<String, Object> _seed = {
  'contacts': jsonEncode([
    {
      'id': '$_now',
      'name': 'أحمد محمد',
      'phone': '+966501234567',
      'createdAt': _now,
      'note': 'عميل مهم',
      'tags': <String>[],
    },
  ]),
  'messages': jsonEncode([
    {
      'id': '${_now - 1}',
      'title': 'ترحيب بالعميل',
      'content': 'أهلاً بك! يسعدنا خدمتك، تفضّل بأي استفسار وسنرد عليك.',
      'createdAt': _now - 1,
      'category': 'greeting',
      'usageCount': 3,
      'tags': <String>[],
    },
  ]),
};

Future<void> settle(WidgetTester tester, [int ms = 900]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  StorageService.resetForTesting();
  SharedPreferences.setMockInitialValues(prefs);
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(800, 1600);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const SendlyApp());
  await settle(tester);
}

/// يفتح تبويباً من شريط التنقل السفلي (الأيقونة تحدد أي تبويب)
Future<void> openTab(WidgetTester tester, IconData icon) async {
  final index = {
    Icons.send_rounded: 0,
    Icons.people_alt_rounded: 1,
    Icons.chat_bubble_rounded: 2,
    Icons.settings_rounded: 3,
  }[icon]!;
  await tester.tap(find.byType(NavigationDestination).at(index));
  await settle(tester);
}

TextField fieldAt(WidgetTester tester, int index) =>
    tester.widget<TextField>(find.byType(TextField).at(index));

void main() {
  group('الإرسال السريع', () {
    testWidgets('يتحقق من الرقم والرسالة قبل الإرسال', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).at(0), '123');
      await tester.enterText(find.byType(TextField).at(1), 'مرحباً بك');
      await settle(tester);
      await tester.ensureVisible(find.text('إرسال الآن'));
      await tester.tap(find.text('إرسال الآن'));
      await settle(tester);

      expect(find.textContaining('قصير جداً'), findsOneWidget);
    });

    testWidgets('زر الإرسال معطّل حتى تُملأ الحقول', (tester) async {
      await pumpApp(tester);

      await tester.ensureVisible(find.text('إرسال الآن'));
      await tester.tap(find.text('إرسال الآن'));
      await settle(tester);

      expect(find.textContaining('قصير جداً'), findsNothing);
      expect(find.text('اكتب نص الرسالة'), findsNothing);
    });

    testWidgets('يعرض الدولة والشركة للرقم الصحيح ويحوّل الأرقام العربية', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField).at(0), '٠٥٠١٢٣٤٥٦٧');
      await settle(tester);

      expect(fieldAt(tester, 0).controller!.text, '0501234567');
      expect(find.textContaining('السعودية'), findsOneWidget);
    });

    testWidgets('اختيار قالب يملأ نص الرسالة', (tester) async {
      await pumpApp(tester, prefs: _seed);

      await tester.tap(find.text('ترحيب بالعميل'));
      await settle(tester);

      expect(
        fieldAt(tester, 1).controller!.text,
        'أهلاً بك! يسعدنا خدمتك، تفضّل بأي استفسار وسنرد عليك.',
      );
    });

    testWidgets('لا يوجد اختيار قنوات ولا أسماء تطبيقات في الواجهة', (
      tester,
    ) async {
      await pumpApp(tester);

      for (final text in [
        'دردشة',
        'رسالة نصية',
        'أرسل عبر',
        'واتساب',
        'تليجرام',
      ]) {
        expect(find.textContaining(text), findsNothing, reason: text);
      }
      expect(find.text('إرسال الآن'), findsOneWidget);
    });
  });

  group('جهات الاتصال', () {
    testWidgets('حالة فارغة ثم إضافة جهة اتصال', (tester) async {
      await pumpApp(tester);
      await openTab(tester, Icons.people_alt_rounded);

      expect(find.text('لا توجد جهات اتصال'), findsOneWidget);

      await tester.tap(find.text('إضافة جهة اتصال'));
      await settle(tester);

      // التحقق يمنع الحفظ بدون بيانات
      await tester.tap(find.text('إضافة جهة الاتصال'));
      await settle(tester);
      expect(find.text('الاسم مطلوب'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'سارة علي');
      await tester.enterText(find.byType(TextFormField).at(1), '01012345678');
      await settle(tester);
      await tester.tap(find.text('إضافة جهة الاتصال'));
      await settle(tester, 1500);

      expect(find.text('سارة علي'), findsOneWidget);
      expect(find.text('تم إضافة جهة الاتصال بنجاح'), findsOneWidget);
    });

    testWidgets('الحذف مع التراجع', (tester) async {
      await pumpApp(tester, prefs: _seed);
      await openTab(tester, Icons.people_alt_rounded);

      expect(find.text('أحمد محمد'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await settle(tester);
      await tester.tap(find.text('حذف'));
      await settle(tester, 1200);

      expect(find.text('أحمد محمد'), findsNothing);
      expect(find.text('تراجع'), findsOneWidget);

      await tester.tap(find.text('تراجع'));
      await settle(tester, 1200);

      expect(find.text('أحمد محمد'), findsOneWidget);
    });

    testWidgets('البحث يصفّي القائمة', (tester) async {
      await pumpApp(tester, prefs: _seed);
      await openTab(tester, Icons.people_alt_rounded);

      await tester.enterText(find.byType(TextField).first, 'لا يوجد');
      await settle(tester);

      expect(find.text('لا توجد نتائج'), findsOneWidget);
    });
  });

  group('الرسائل', () {
    testWidgets('إضافة رسالة جديدة بتصنيف تلقائي', (tester) async {
      await pumpApp(tester);
      await openTab(tester, Icons.chat_bubble_rounded);

      expect(find.text('لا توجد رسائل محفوظة'), findsOneWidget);

      await tester.tap(find.text('إضافة رسالة'));
      await settle(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'عرض الجمعة');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'خصم كبير على المنتجات هذا الأسبوع فقط',
      );
      await settle(tester);
      await tester.tap(find.text('حفظ الرسالة'));
      await settle(tester, 1500);

      expect(find.text('عرض الجمعة'), findsOneWidget);
      expect(find.text('تسويق'), findsWidgets);
    });

    testWidgets('فتح تفاصيل الرسالة', (tester) async {
      await pumpApp(tester, prefs: _seed);
      await openTab(tester, Icons.chat_bubble_rounded);

      await tester.tap(find.text('ترحيب بالعميل'));
      await settle(tester);

      expect(find.text('نسخ'), findsNothing); // زر النسخ أيقونة فقط
      expect(find.byIcon(Icons.copy_rounded), findsWidgets);
      expect(find.text('إرسال'), findsWidgets);
    });
  });

  group('الإعدادات', () {
    testWidgets('تبديل المظهر إلى الداكن', (tester) async {
      await pumpApp(tester, prefs: _seed);
      await openTab(tester, Icons.settings_rounded);

      await tester.tap(find.text('داكن'));
      await settle(tester, 1200);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('مسح جميع البيانات', (tester) async {
      await pumpApp(tester, prefs: _seed);
      await openTab(tester, Icons.settings_rounded);

      await tester.scrollUntilVisible(
        find.text('مسح جميع البيانات'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('مسح جميع البيانات'));
      await settle(tester);
      await tester.tap(find.text('مسح الكل'));
      await settle(tester, 1200);

      await openTab(tester, Icons.people_alt_rounded);
      expect(find.text('لا توجد جهات اتصال'), findsOneWidget);
    });
  });

  group('استقبال رقم مشارك من تطبيق آخر', () {
    const channel = MethodChannel('sendly/incoming');

    void mockInitialShare(WidgetTester tester, Map<String, String>? payload) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (call) async => call.method == 'getInitialShare' ? payload : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
    }

    Future<void> sendWarmShare(
      WidgetTester tester,
      String text, {
      String type = 'text',
    }) async {
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
          MethodCall('onShare', {'type': type, 'text': text}),
        ),
        (_) {},
      );
      await settle(tester, 1200);
    }

    testWidgets('تشغيل بارد: المشاركة تفتح التطبيق وتضع الرقم', (tester) async {
      mockInitialShare(tester, {
        'type': 'text',
        'text': 'كلّمني على ٠٥٠١٢٣٤٥٦٧',
      });
      await pumpApp(tester);
      await settle(tester, 600);

      expect(fieldAt(tester, 0).controller!.text, '+966501234567');
      expect(find.text('تم إدراج الرقم من المشاركة'), findsOneWidget);
      expect(find.text('حفظ'), findsOneWidget); // الرقم غير محفوظ كجهة
    });

    testWidgets('التطبيق مفتوح على تبويب آخر: يرجع للإرسال ويضع الرقم', (
      tester,
    ) async {
      mockInitialShare(tester, null);
      await pumpApp(tester, prefs: _seed);
      await openTab(tester, Icons.settings_rounded);

      await sendWarmShare(tester, 'رقم العميل: +20 101 234 5678');

      expect(fieldAt(tester, 0).controller!.text, '+201012345678');
    });

    testWidgets('بطاقة اتصال: يظهر الاسم ويُملأ الرقم', (tester) async {
      mockInitialShare(tester, null);
      await pumpApp(tester);

      await sendWarmShare(
        tester,
        'BEGIN:VCARD\nVERSION:3.0\nFN:خالد أحمد\n'
        'TEL;TYPE=CELL:0501234567\nEND:VCARD',
        type: 'vcard',
      );

      expect(fieldAt(tester, 0).controller!.text, '+966501234567');
      expect(find.textContaining('خالد أحمد'), findsOneWidget);
    });

    testWidgets('رقم محفوظ مسبقاً: يُعرض اسم الجهة ولا يظهر زر الحفظ', (
      tester,
    ) async {
      mockInitialShare(tester, null);
      await pumpApp(tester, prefs: _seed);

      await sendWarmShare(tester, '0501234567');

      expect(find.textContaining('أحمد محمد'), findsOneWidget);
      expect(find.text('حفظ'), findsNothing);
    });

    testWidgets('أكثر من رقم: تظهر قائمة اختيار', (tester) async {
      mockInitialShare(tester, null);
      await pumpApp(tester);

      await sendWarmShare(tester, '0501234567 أو 01012345678');
      expect(find.text('اختر الرقم'), findsOneWidget);

      await tester.tap(find.textContaining('مصر'));
      await settle(tester, 1200);

      expect(fieldAt(tester, 0).controller!.text, '+201012345678');
    });

    testWidgets('نص بدون رقم: رسالة توضيحية', (tester) async {
      mockInitialShare(tester, null);
      await pumpApp(tester);

      await sendWarmShare(tester, 'مرحباً بدون أي رقم');

      expect(find.text('لا يوجد رقم هاتف في المحتوى المشارك'), findsOneWidget);
      expect(fieldAt(tester, 0).controller!.text, isEmpty);
    });

    test('استخراج الأرقام من نص حر (أرقام عربية ودولية وبدون تكرار)', () {
      final numbers = PhoneExtractor.fromText(
        'اتصل ٠٥٠١٢٣٤٥٦٧ أو +20 101 234 5678 أو 0501234567 مرة أخرى، وطلب رقم 42',
      );
      expect(numbers.map((n) => n.phone), ['+966501234567', '+201012345678']);
    });

    test('استخراج الأرقام من بطاقة اتصال مع الاسم', () {
      final numbers = PhoneExtractor.fromVCard(
        'BEGIN:VCARD\r\nVERSION:3.0\r\nN:أحمد;خالد;;;\r\nFN:خالد أحمد\r\n'
        'TEL;TYPE=CELL:0501234567\r\nitem1.TEL;TYPE=HOME:+971501234567\r\n'
        'END:VCARD',
      );
      expect(numbers, const [
        ExtractedNumber('+966501234567', name: 'خالد أحمد'),
        ExtractedNumber('+971501234567', name: 'خالد أحمد'),
      ]);
    });

    test('نص بدون رقم صالح يرجع قائمة فارغة', () {
      expect(PhoneExtractor.fromText('مرحباً بالعالم 12345'), isEmpty);
    });
  });

  test('WesternDigitsFormatter يحوّل الأرقام العربية والفارسية', () {
    expect(WesternDigitsFormatter.convert('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    expect(WesternDigitsFormatter.convert('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    expect(WesternDigitsFormatter.convert('+966 ٥٠'), '+966 50');
  });
}
