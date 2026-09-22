import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_theme.dart';
import '../../assets_manager.dart';
import '../../core/services/ads_service.dart';
import '../../core/services/incoming_share_service.dart';
import '../../core/utils/remote_config.dart';
import '../../providers/app_provider.dart';
import '../widgets/common/ad_banner.dart';
import '../widgets/common/app_feedback.dart';
import '../widgets/common/update_dialog.dart';
import '../widgets/send/number_chooser_sheet.dart';
import 'settings/ad_free_sheet.dart';
import 'contacts/contacts_page.dart';
import 'messages/messages_page.dart';
import 'quick_send/quick_send_page.dart';
import 'settings/settings_page.dart';

/// الصفحة الرئيسية: تبويبات التطبيق مع شريط تنقل سفلي قياسي
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const List<Widget> _pages = [
    QuickSendPage(),
    ContactsPage(),
    MessagesPage(),
    SettingsPage(),
  ];

  /// لون كل قسم (موحّد الآن بأزرق الشعار)
  static AccentColors _accentFor(AppPalette p, int index) =>
      [p.send, p.contacts, p.messages, p.settings][index];

  static const List<_Destination> _destinations = [
    _Destination('إرسال', Icons.send_outlined, Icons.send_rounded),
    _Destination(
      'الجهات',
      Icons.people_outline_rounded,
      Icons.people_alt_rounded,
    ),
    _Destination(
      'الرسائل',
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
    ),
    _Destination('الإعدادات', Icons.settings_outlined, Icons.settings_rounded),
  ];

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
    value: 1,
  );
  late final Animation<double> _enterCurve = CurvedAnimation(
    parent: _enter,
    curve: Curves.easeOutCubic,
  );

  final IncomingShareService _shareService = IncomingShareService();

  int _index = 0;

  static const int _settingsIndex = 3;

  /// أثناء التحديث الإجباري لا نتجاوز شاشة التحديث بسبب مشاركة قادمة
  bool _forceUpdateOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shareService.start(_onShared);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  /// وصل رقم أو نص من تطبيق آخر: نفتح صفحة الإرسال ونضع الرقم فيها
  Future<void> _onShared(IncomingShare share) async {
    if (!mounted || _forceUpdateOpen) return;
    final numbers = share.numbers;

    if (numbers.isEmpty) {
      AppSnack.show(context, 'لا يوجد رقم هاتف في المحتوى المشارك');
      return;
    }

    // إغلاق أي ورقة أو حوار مفتوح والرجوع لصفحة الإرسال
    Navigator.of(context).popUntil((route) => route.isFirst);
    _select(0);

    var chosen = numbers.first;
    if (numbers.length > 1) {
      final picked = await showNumberChooser(context, numbers);
      if (picked == null || !mounted) return;
      chosen = picked;
    }
    AppScope.read(context).receiveIncoming(chosen);
  }

  Future<void> _checkForUpdate() async {
    final update = await ForceUpdateChecker().check();
    if (!mounted || update == null) return;
    _forceUpdateOpen = update.forceUpdate;
    await showUpdateDialog(context, update);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // العودة من تطبيق المراسلة بعد الإرسال: نقطة انتقال طبيعية لإعلان بيني
      AdsService.instance.showInterstitialIfDue();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shareService.stop();
    _enter.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    setState(() => _index = index);
    _enter.forward(from: 0);

    if (index == _settingsIndex) {
      final ads = AdsService.instance;
      if (ads.shouldOfferRewardOnSettings) {
        // عرض اختياري لإعلان بمكافأة عند دخول الإعدادات (بحوار صريح وخيار الرفض)
        ads.markSettingsPromptShown();
        Future<void>.delayed(const Duration(milliseconds: 350), () {
          if (mounted) offerRewardIntro(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppScope.of(context).isLoading) return const _LoadingScreen();

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Stack(
            children: [
              _AccentGlow(accent: _accentFor(context.palette, _index)),
              SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpace.maxContentWidth,
                    ),
                    child: FadeTransition(
                      opacity: _enterCurve,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(_enterCurve),
                        child: IndexedStack(
                          index: _index,
                          children: [
                            for (var i = 0; i < _pages.length; i++)
                              ActiveTab(
                                active: i == _index,
                                child: AccentScope(
                                  accent: _accentFor(context.palette, i),
                                  child: _pages[i],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpace.maxContentWidth,
                ),
                child: AccentScope(
                  accent: _accentFor(context.palette, _index),
                  child: NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    destinations: [
                      for (final d in _destinations)
                        NavigationDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: d.label,
                          tooltip: d.label,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// توهّج لوني ناعم في أعلى الشاشة يتبدّل بسلاسة مع لون القسم
class _AccentGlow extends StatelessWidget {
  const _AccentGlow({required this.accent});

  final AccentColors accent;

  @override
  Widget build(BuildContext context) {
    final strength = context.isDark ? 0.20 : 0.10;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 360,
      child: IgnorePointer(
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: accent.glow),
          duration: const Duration(milliseconds: 500),
          builder: (context, color, _) {
            final glow = color ?? accent.glow;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.8, -1.1),
                  radius: 1.2,
                  colors: [
                    glow.withValues(alpha: strength),
                    glow.withValues(alpha: 0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.85, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Opacity(
            opacity: scale.clamp(0.0, 1.0),
            child: Transform.scale(scale: scale, child: child),
          ),
          child: Image.asset(Assets.logoPng, width: 110),
        ),
      ),
    );
  }
}
