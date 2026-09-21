import 'package:flutter_test/flutter_test.dart';
import 'package:sendly/presentation/widgets/common/ad_banner.dart';

void main() {
  group('ListAdSlots', () {
    test('لا إعلانات في قائمة قصيرة (3 عناصر أو أقل)', () {
      for (final n in [0, 1, 2, 3]) {
        final slots = ListAdSlots(n);
        expect(slots.slots, 0, reason: 'n=$n');
        expect(slots.totalCount, n);
      }
    });

    test('إعلان بعد كل 3 عناصر وليس بعد آخر عنصر', () {
      final slots = ListAdSlots(4);
      expect(slots.totalCount, 5);
      expect(
        [for (var i = 0; i < 5; i++) slots.isAd(i)],
        [false, false, false, true, false],
      );

      // 6 عناصر بالضبط: إعلان واحد بين الثلاثة الأولى والثلاثة التالية فقط
      final six = ListAdSlots(6);
      expect(six.totalCount, 7);
      expect(six.isAd(3), isTrue);
      expect(six.isAd(6), isFalse);
    });

    test('كل عنصر يظهر مرة واحدة وبنفس الترتيب لأي طول قائمة', () {
      for (var n = 0; n <= 60; n++) {
        final slots = ListAdSlots(n);
        final shown = <int>[
          for (var i = 0; i < slots.totalCount; i++)
            if (!slots.isAd(i)) slots.itemIndex(i),
        ];
        expect(shown, [for (var i = 0; i < n; i++) i], reason: 'n=$n');
      }
    });

    test('الحد الأقصى للإعلانات في القوائم الطويلة', () {
      final slots = ListAdSlots(200);
      expect(slots.slots, 6);
      final ads = [
        for (var i = 0; i < slots.totalCount; i++)
          if (slots.isAd(i)) i,
      ];
      expect(ads, [3, 7, 11, 15, 19, 23]);
    });
  });
}
