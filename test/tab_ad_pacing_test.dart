import 'package:flutter_test/flutter_test.dart';
import 'package:sendly/core/services/ads_service.dart';

void main() {
  group('TabAdPacing', () {
    final t0 = DateTime(2026, 1, 1, 12);

    TabAdPacing make() =>
        TabAdPacing(threshold: 5, minGap: const Duration(minutes: 2));

    test('لا إعلان في أول 5 انتقالات، ويحين عند السادس', () {
      final pacing = make();
      for (var i = 1; i <= 5; i++) {
        expect(pacing.registerSwitch(t0), isFalse, reason: 'انتقال $i');
      }
      expect(pacing.registerSwitch(t0), isTrue);
    });

    test('بعد عرض إعلان يبدأ العدّ من جديد', () {
      final pacing = make();
      for (var i = 0; i < 6; i++) {
        pacing.registerSwitch(t0);
      }
      pacing.commitShown(t0);
      for (var i = 1; i <= 5; i++) {
        expect(
          pacing.registerSwitch(t0.add(const Duration(minutes: 5))),
          isFalse,
        );
      }
      expect(pacing.registerSwitch(t0.add(const Duration(minutes: 5))), isTrue);
    });

    test('لا إعلان قبل مرور الفاصل حتى لو تجاوز العدّ الحد', () {
      final pacing = make()..commitShown(t0);
      for (var i = 0; i < 10; i++) {
        expect(
          pacing.registerSwitch(t0.add(const Duration(seconds: 30))),
          isFalse,
        );
      }
      // بعد الفاصل يحين الإعلان فوراً لأن العدّ متراكم
      expect(pacing.registerSwitch(t0.add(const Duration(minutes: 3))), isTrue);
    });

    test('reset يصفّر العدّ', () {
      final pacing = make();
      for (var i = 0; i < 5; i++) {
        pacing.registerSwitch(t0);
      }
      pacing.reset();
      expect(pacing.registerSwitch(t0), isFalse);
    });
  });
}
