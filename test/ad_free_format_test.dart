import 'package:flutter_test/flutter_test.dart';
import 'package:sendly/core/services/ads_service.dart';
import 'package:sendly/presentation/pages/settings/ad_free_sheet.dart';

void main() {
  group('مستويات إخفاء الإعلانات', () {
    test('إعلان ← 3 ساعات، إعلانان ← 6، ثلاثة ← 12', () {
      expect(AdsService.rewardTiers.map((d) => d.inHours).toList(), [3, 6, 12]);
    });

    test('لا مكافأة بلا مشاهدة ولا يمكن الزيادة بلا فترة سارية', () {
      final ads = AdsService.instance;
      expect(ads.adFree, isFalse);
      expect(ads.adFreeTier, 0);
      expect(ads.canWatchMore, isTrue);
    });
  });

  group('تنسيق النصوص', () {
    test('تسمية الساعات بالعربية', () {
      expect(arabicHoursLabel(1), 'ساعة');
      expect(arabicHoursLabel(2), 'ساعتان');
      expect(arabicHoursLabel(3), '3 ساعات');
      expect(arabicHoursLabel(6), '6 ساعات');
      expect(arabicHoursLabel(12), '12 ساعة');
    });

    test('عدد الإعلانات بصيغتي الفاعل والمفعول', () {
      expect(adsCountLabel(1), 'إعلان واحد');
      expect(adsCountLabel(2), 'إعلانان');
      expect(adsCountLabel(3), '3 إعلانات');
      expect(adsCountObject(1), 'إعلاناً واحداً');
      expect(adsCountObject(2), 'إعلانين');
      expect(adsCountObject(3), '3 إعلانات');
    });

    test('المدة المتبقية', () {
      expect(
        formatAdFreeRemaining(const Duration(hours: 2, minutes: 10)),
        '2 س و10 د',
      );
      expect(formatAdFreeRemaining(const Duration(hours: 3)), '3 س');
      expect(formatAdFreeRemaining(const Duration(minutes: 45)), '45 د');
      expect(formatAdFreeRemaining(const Duration(seconds: 10)), '1 د');
    });
  });
}
