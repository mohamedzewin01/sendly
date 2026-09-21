import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/remote_config.dart';

/// تسجيل تشخيصي للإعلانات (يظهر في وضع التطوير فقط)
void adsLog(String message) {
  if (kDebugMode) debugPrint('[ADS] $message');
}

/// إدارة الإعلانات (Google AdMob): موافقة المستخدم أولاً ثم تهيئة المكتبة.
///
/// - لا تُطلب أي إعلانات قبل اكتمال رسالة الموافقة (UMP) حيث يلزم القانون.
/// - في نسخ التطوير تُستخدم معرّفات Google التجريبية، وفي الإصدار المنشور المعرّف الحقيقي.
/// - إعلان واحد فقط (بانر) داخل القوائم بعيداً عن أزرار الضغط.
class AdsService extends ChangeNotifier {
  AdsService._();

  static final AdsService instance = AdsService._();

  // معرّف التطبيق في AdMob (ca-app-pub-7679264832786592~6603635398) موجود في AndroidManifest.xml
  static const String _bannerUnitRelease =
      'ca-app-pub-7679264832786592/6976725391';

  /// وحدة البانر التجريبية الرسمية من Google (للتطوير فقط)
  static const String _bannerUnitTest =
      'ca-app-pub-3940256099942544/9214589741';

  /// الإعلان البيني (يظهر بعد العودة من تطبيق المراسلة، بتكرار محدود)
  static const String _interstitialRelease =
      'ca-app-pub-7679264832786592/8974001648';
  static const String _interstitialTest =
      'ca-app-pub-3940256099942544/1033173712';

  /// الإعلان البيني مقابل مكافأة (اختياري من الإعدادات لإخفاء الإعلانات يوماً)
  static const String _rewardedInterstitialRelease =
      'ca-app-pub-7679264832786592/1718328151';
  static const String _rewardedInterstitialTest =
      'ca-app-pub-3940256099942544/5354046379';

  // مفاتيح Firebase Remote Config (نوعها Boolean)
  static const String _keyEnabled = 'ads_enabled';
  static const String _keyTestMode = 'ads_test_mode';

  /// أقصى انتظار لقيم Remote Config عند التشغيل، بعدها تُستخدم آخر قيم محفوظة أو الافتراضية
  static const Duration _remoteTimeout = Duration(seconds: 6);

  bool _enabled = true;
  bool _testMode = false;

  /// هل الإعلان التجريبي هو المعروض؟ (نسخ التطوير دائماً، أو عند تفعيل ads_test_mode من Firebase)
  bool get isTestMode => !kReleaseMode || _testMode;

  /// معرّف وحدة البانر: تجريبي في التطوير أو عند تشغيل وضع الاختبار عن بُعد،
  /// حتى لا تُحتسب نقرات على إعلاناتك الحقيقية أثناء التجربة
  String get bannerUnitId => isTestMode ? _bannerUnitTest : _bannerUnitRelease;

  String get interstitialUnitId =>
      isTestMode ? _interstitialTest : _interstitialRelease;

  String get rewardedInterstitialUnitId =>
      isTestMode ? _rewardedInterstitialTest : _rewardedInterstitialRelease;

  bool _started = false;
  bool _ready = false;
  bool _privacyOptionsRequired = false;

  /// هل اكتملت الموافقة والتهيئة ويمكن طلب الإعلانات؟
  bool get isReady => _ready && _enabled;

  /// هل تُعرض البانرات الآن؟ (جاهزة ولم يختر المستخدم إخفاء الإعلانات)
  bool get canShowBanners => isReady && !adFree;

  /// هل يجب توفير زر «خيارات الخصوصية» للمستخدم (مطلوب في بعض المناطق)؟
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// يبدأ الموافقة ثم التهيئة. آمن للاستدعاء أكثر من مرة، ولا يعطّل تشغيل التطبيق.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      adsLog('start');
      await _restoreAdFree();
      await _loadRemoteFlags();
      adsLog('flags: enabled=$_enabled testMode=$_testMode unit=$bannerUnitId');
      // إيقاف الإعلانات عن بُعد: لا موافقة ولا تهيئة ولا أي طلب
      if (!_enabled) return;

      await _gatherConsent();
      await _initializeIfAllowed();
      await _refreshPrivacyOptions();
      adsLog('ready=$_ready');
    } catch (e) {
      adsLog('start failed: $e');
    }
  }

  /// يقرأ مفاتيح التحكم من Firebase. عند تعذّر الاتصال تُستخدم آخر قيم محفوظة،
  /// وإن لم توجد فالافتراضي: الإعلانات مفعّلة وبالمعرّف الحقيقي.
  Future<void> _loadRemoteFlags() async {
    try {
      final config = FirebaseRemoteConfig.instance;
      await config.setDefaults({_keyEnabled: true, _keyTestMode: false});
      await RemoteConfigSync.ensure().timeout(_remoteTimeout);
      _enabled = config.getBool(_keyEnabled);
      _testMode = config.getBool(_keyTestMode);
    } catch (e) {
      debugPrint('Ads remote flags unavailable: $e');
    }
  }

  /// يعرض نموذج خيارات الخصوصية لتغيير اختيار الإعلانات
  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (error != null) debugPrint('Privacy options error: ${error.message}');
      if (!done.isCompleted) done.complete();
    });
    await done.future;
    await _initializeIfAllowed();
    await _refreshPrivacyOptions();
  }

  Future<void> _gatherConsent() async {
    final done = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (error != null) debugPrint('Consent form error: ${error.message}');
          if (!done.isCompleted) done.complete();
        });
      },
      (FormError error) {
        debugPrint('Consent info error: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );

    await done.future;
    adsLog('consent step done');
  }

  Future<void> _initializeIfAllowed() async {
    if (_ready) return;
    final canRequest = await ConsentInformation.instance.canRequestAds();
    adsLog('canRequestAds=$canRequest');
    if (!canRequest) return;

    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(maxAdContentRating: MaxAdContentRating.pg),
    );
    final status = await MobileAds.instance.initialize();
    adsLog('MobileAds initialized (${status.adapterStatuses.length} adapters)');
    _ready = true;
    notifyListeners();
    _loadInterstitial();
  }

  // ==================== إخفاء الإعلانات مقابل مشاهدة إعلان ====================

  static const String _prefsAdFreeUntil = 'ads_free_until_ms';
  static const String _prefsAdFreeTier = 'ads_free_tier';

  /// مدة إخفاء الإعلانات حسب عدد الإعلانات المشاهَدة: إعلان ← 3 ساعات، إعلانان ← 6، ثلاثة ← 12.
  /// كل إعلان اختياري بضغطة من المستخدم، ويحتفظ بما كسبه إن توقف.
  static const List<Duration> rewardTiers = [
    Duration(hours: 3),
    Duration(hours: 6),
    Duration(hours: 12),
  ];

  DateTime? _adFreeUntil;
  int _adFreeTier = 0;

  /// هل اختار المستخدم إخفاء الإعلانات ولا تزال المدة سارية؟
  bool get adFree => _adFreeUntil?.isAfter(DateTime.now()) ?? false;

  /// وقت انتهاء فترة إخفاء الإعلانات (أو null إن لم تكن فعّالة)
  DateTime? get adFreeUntil => adFree ? _adFreeUntil : null;

  /// عدد الإعلانات التي شاهدها المستخدم في الفترة السارية (0 إن لم توجد فترة سارية)
  int get adFreeTier => adFree ? _adFreeTier : 0;

  /// هل يمكنه مشاهدة إعلان آخر لزيادة المدة؟
  bool get canWatchMore => adFreeTier < rewardTiers.length;

  Future<void> _restoreAdFree() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt(_prefsAdFreeUntil);
      if (ms != null) _adFreeUntil = DateTime.fromMillisecondsSinceEpoch(ms);
      _adFreeTier = prefs.getInt(_prefsAdFreeTier) ?? 0;
    } catch (e) {
      adsLog('restore ad-free failed: $e');
    }
  }

  /// يمنح مستوى المكافأة [tier] (1 إلى 3): المدة تُحسب من الآن ولا تتراكم فوق المتبقي
  Future<void> _grantAdFree(int tier) async {
    _adFreeTier = tier;
    _adFreeUntil = DateTime.now().add(rewardTiers[tier - 1]);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _prefsAdFreeUntil,
        _adFreeUntil!.millisecondsSinceEpoch,
      );
      await prefs.setInt(_prefsAdFreeTier, _adFreeTier);
    } catch (e) {
      adsLog('save ad-free failed: $e');
    }
    notifyListeners();
  }

  /// هل الإعلان بمكافأة متاح للعرض (الإعلانات مفعّلة وجاهزة)؟
  bool get canOfferReward => _ready && _enabled;

  /// يحمّل ويعرض إعلاناً بينياً بمكافأة بعد موافقة المستخدم الصريحة،
  /// وعند مشاهدته ينتقل لمستوى المكافأة التالي (3 ثم 6 ثم 12 ساعة بلا إعلانات).
  /// يرجع true إن نال المكافأة.
  Future<bool> watchAdToHideAds() async {
    if (!canOfferReward || !canWatchMore) return false;

    final loaded = Completer<RewardedInterstitialAd?>();
    var timedOut = false;
    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // وصل بعد انتهاء المهلة: لا فائدة منه فنتخلص منه
          if (timedOut) {
            ad.dispose();
            return;
          }
          loaded.complete(ad);
        },
        onAdFailedToLoad: (error) {
          adsLog('rewarded failed: code=${error.code} ${error.message}');
          if (!loaded.isCompleted) loaded.complete(null);
        },
      ),
    );

    final ad = await loaded.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        timedOut = true;
        return null;
      },
    );
    if (ad == null) return false;

    var earned = false;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        adsLog('rewarded show failed: ${error.message}');
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => earned = true);
    await closed.future;

    if (earned) await _grantAdFree(adFreeTier + 1);
    return earned;
  }

  // ==================== الإعلان البيني ====================

  /// إعلان بيني بعد كل عملية إرسال (عند العودة من تطبيق المراسلة)
  static const int _sendsPerInterstitial = 1;

  /// أقل فاصل بين إعلانين بينيين بعد الإرسال (يمنع تكرارها عند إرسال رسائل متتالية بسرعة)
  static const Duration _minInterstitialGap = Duration(seconds: 60);

  /// نعتبر المستخدم عائداً من تطبيق المراسلة إن رجع خلال هذه المدة من الإرسال
  static const Duration _returnWindow = Duration(minutes: 10);

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  int _sendsSinceInterstitial = 0;
  DateTime? _lastInterstitialAt;
  DateTime? _lastSendAt;

  /// إعلان بيني عند التنقل بين الأقسام أكثر من 5 مرات، بفاصل دقيقتين على الأقل
  final TabAdPacing _tabPacing = TabAdPacing(
    threshold: 5,
    minGap: const Duration(minutes: 2),
  );

  /// هل عُرض عرض الإعلان بمكافأة عند أول دخول للإعدادات في هذه الجلسة؟
  bool _settingsPromptShown = false;

  void _loadInterstitial() {
    if (_interstitial != null || _loadingInterstitial || !_ready || !_enabled) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
          adsLog('interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          adsLog('interstitial failed: code=${error.code} ${error.message}');
        },
      ),
    );
  }

  /// يُستدعى بعد فتح تطبيق المراسلة بنجاح
  void noteSendCompleted() {
    _sendsSinceInterstitial++;
    _lastSendAt = DateTime.now();
    _loadInterstitial();
  }

  /// يُستدعى عند عودة المستخدم للتطبيق. يعرض إعلاناً بينياً فقط عند اكتمال الشروط:
  /// عاد بعد إرسال، ومرّ فاصل كافٍ على آخر إعلان، ولم يُخفِ المستخدم الإعلانات.
  /// لا يُعرض عند فتح التطبيق ولا أثناء الكتابة.
  Future<void> showInterstitialIfDue() async {
    final sentAt = _lastSendAt;
    if (sentAt == null) return;
    _lastSendAt = null;

    final now = DateTime.now();
    if (now.difference(sentAt) > _returnWindow) return;
    if (!_ready || !_enabled || adFree) return;
    if (_sendsSinceInterstitial < _sendsPerInterstitial) return;
    final last = _lastInterstitialAt;
    if (last != null && now.difference(last) < _minInterstitialGap) return;

    if (await _showLoadedInterstitial()) _sendsSinceInterstitial = 0;
  }

  /// يُستدعى عند كل انتقال بين أقسام التطبيق؛ يعرض إعلاناً بينياً بعد أكثر من 5 انتقالات
  Future<void> onTabSwitched() async {
    if (!_ready || !_enabled || adFree) return;
    if (!_tabPacing.registerSwitch(DateTime.now())) return;

    // نمهل حركة الانتقال لتكتمل حتى لا يقاطعها الإعلان
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _showLoadedInterstitial();
  }

  Future<bool> _showLoadedInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }
    _interstitial = null;
    _commitInterstitialShown(DateTime.now());

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        adsLog('interstitial show failed: ${error.message}');
        ad.dispose();
        _loadInterstitial();
      },
    );
    await ad.show();
    return true;
  }

  void _commitInterstitialShown(DateTime now) {
    _lastInterstitialAt = now;
    _tabPacing.commitShown(now);
  }

  // ==================== عرض المكافأة عند دخول الإعدادات ====================

  /// هل نعرض شاشة الإعلان بمكافأة الآن؟ عند أول دخول للإعدادات في الجلسة فقط،
  /// وليس لمن أخفى الإعلانات بالفعل.
  bool get shouldOfferRewardOnSettings =>
      canOfferReward && !adFree && canWatchMore && !_settingsPromptShown;

  void markSettingsPromptShown() {
    _settingsPromptShown = true;
    _tabPacing.reset(); // لا نُتبعه بإعلان بيني عند الانتقال نفسه
  }

  /// جلسة جديدة (المستخدم فتح التطبيق بعد غياب): يعود العرض عند أول دخول للإعدادات
  void startNewSession() {
    _settingsPromptShown = false;
    _tabPacing.reset();
  }

  Future<void> _refreshPrivacyOptions() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    final required = status == PrivacyOptionsRequirementStatus.required;
    if (required != _privacyOptionsRequired) {
      _privacyOptionsRequired = required;
      notifyListeners();
    }
  }
}

/// يعدّ الانتقالات بين الأقسام ويقرّر متى يحين إعلان بيني:
/// بعد أكثر من [threshold] انتقالات، وبفاصل [minGap] على الأقل من آخر إعلان.
class TabAdPacing {
  TabAdPacing({required this.threshold, required this.minGap});

  final int threshold;
  final Duration minGap;

  int _switches = 0;
  DateTime? _lastShownAt;

  /// يسجّل انتقالاً جديداً ويرجع true إن حان وقت الإعلان
  bool registerSwitch(DateTime now) {
    _switches++;
    if (_switches <= threshold) return false;
    final last = _lastShownAt;
    if (last != null && now.difference(last) < minGap) return false;
    return true;
  }

  /// يُستدعى عند عرض أي إعلان بيني فعلاً: يصفّر العدّاد ويبدأ الفاصل
  void commitShown(DateTime now) {
    _lastShownAt = now;
    _switches = 0;
  }

  void reset() => _switches = 0;
}
