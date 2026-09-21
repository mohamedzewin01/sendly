import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/services/ads_service.dart';

/// يخبر الويدجت التي تحته هل القسم الحالي هو الظاهر للمستخدم الآن،
/// حتى لا تُطلب إعلانات لأقسام لم يفتحها بعد.
class ActiveTab extends InheritedWidget {
  const ActiveTab({super.key, required this.active, required super.child});

  final bool active;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ActiveTab>()?.active ?? true;

  @override
  bool updateShouldNotify(ActiveTab oldWidget) => active != oldWidget.active;
}

/// إعلان بانر واحد يتكيّف مع عرض الشاشة. لا يحجز أي مساحة حتى يُحمَّل بنجاح،
/// ولا يُطلب إلا بعد موافقة المستخدم وعند فتح القسم الذي يحويه.
class AdBanner extends StatefulWidget {
  const AdBanner({
    super.key,
    this.maxHeight = 100,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpace.xl,
      AppSpace.xl,
      AppSpace.xl,
      AppSpace.xxl,
    ),
  });

  /// بانر صغير يتوسّط عناصر قائمة: ارتفاع أقل ومسافة رأسية فقط (القائمة تضيف الهوامش الجانبية)
  const AdBanner.inList({super.key})
    : maxHeight = 60,
      padding = const EdgeInsets.only(bottom: AppSpace.m);

  /// أقصى ارتفاع للإعلان بالنقاط
  final int maxHeight;

  /// المسافة حول الإعلان: تبقى كافية لإبعاده عن الأزرار المجاورة
  final EdgeInsets padding;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _ad;
  AdSize? _size;
  bool _loaded = false;
  bool _requested = false;
  int _attempt = 0;
  Timer? _retry;

  /// فترات الانتظار قبل إعادة المحاولة عند فشل الطلب (بلا إلحاح على الخادم)
  static const List<Duration> _retryDelays = [
    Duration(seconds: 20),
    Duration(seconds: 60),
    Duration(minutes: 3),
  ];

  @override
  void initState() {
    super.initState();
    AdsService.instance.addListener(_onAdsChanged);
  }

  void _onAdsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AdsService.instance.removeListener(_onAdsChanged);
    _retry?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _load(int width) async {
    if (_requested) return;
    _requested = true;

    // بانر متكيّف داخل المحتوى بارتفاع أقصى صغير حتى لا يزاحم القائمة
    final requested = AdSize.getInlineAdaptiveBannerAdSize(
      width,
      widget.maxHeight,
    );

    adsLog(
      'banner request #${_attempt + 1}: width=$width unit=${AdsService.instance.bannerUnitId}',
    );
    final ad = BannerAd(
      adUnitId: AdsService.instance.bannerUnitId,
      size: requested,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          final actual = await (ad as BannerAd).getPlatformAdSize();
          if (!mounted) {
            ad.dispose();
            return;
          }
          adsLog('banner loaded: ${actual?.width}x${actual?.height}');
          setState(() {
            _size = actual ?? requested;
            _loaded = true;
          });
          // داخل القوائم: نُبقي الإعلان المحمَّل حياً عند التمرير حتى لا يُطلب من جديد
          updateKeepAlive();
        },
        onAdFailedToLoad: (ad, error) {
          adsLog('banner failed: code=${error.code} ${error.message}');
          ad.dispose();
          if (!mounted) return;
          setState(() => _ad = null);
          _scheduleRetry(width);
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  /// يعيد الطلب بعد مهلة، حتى لا يبقى المكان فارغاً طوال الجلسة بسبب فشل عابر (شبكة أو لا إعلان متاح)
  void _scheduleRetry(int width) {
    if (_attempt >= _retryDelays.length) return;
    final delay = _retryDelays[_attempt++];
    _retry?.cancel();
    _retry = Timer(delay, () {
      if (!mounted) return;
      _requested = false;
      _load(width);
    });
  }

  @override
  bool get wantKeepAlive => _loaded;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ads = AdsService.instance;
    if (!ads.canShowBanners || !ActiveTab.of(context)) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - widget.padding.horizontal)
            .truncate();
        if (!_requested && width > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _load(width);
          });
        }

        final ad = _ad;
        final size = _size;
        if (!_loaded || ad == null || size == null) {
          return const SizedBox.shrink();
        }

        final p = context.palette;
        return Padding(
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إعلان',
                style: context.text.labelSmall?.copyWith(color: p.inkFaint),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: size.width.toDouble(),
                height: size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// يوزّع إعلاناً بعد كل [every] عناصر داخل قائمة، بحد أقصى [maxSlots] إعلانات
/// حتى لا تكثر الطلبات في القوائم الطويلة. لا يُوضع إعلان بعد آخر عنصر
/// لأن نهاية الصفحة فيها إعلان أصلاً.
class ListAdSlots {
  ListAdSlots(this.itemCount, {this.every = 3, this.maxSlots = 6})
    : slots = itemCount <= 0
          ? 0
          : (((itemCount - 1) ~/ every) < maxSlots
                ? (itemCount - 1) ~/ every
                : maxSlots);

  final int itemCount;
  final int every;
  final int maxSlots;
  final int slots;

  int get totalCount => itemCount + slots;

  /// هل الموضع [position] في القائمة المدمجة مخصّص لإعلان؟
  bool isAd(int position) =>
      position < slots * (every + 1) && (position + 1) % (every + 1) == 0;

  /// رقم العنصر الحقيقي المقابل للموضع [position] (لغير مواضع الإعلانات)
  int itemIndex(int position) {
    final before = position ~/ (every + 1);
    return position - (before < slots ? before : slots);
  }
}
