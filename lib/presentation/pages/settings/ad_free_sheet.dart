import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_palette.dart';
import '../../../core/services/ads_service.dart';
import '../../widgets/common/app_feedback.dart';
import '../../widgets/common/app_sheet.dart';
import '../../widgets/common/gradient_button.dart';

/// يفتح ورقة «إخفاء الإعلانات»: يختار المستخدم عدد الإعلانات (1 أو 2 أو 3)
/// فيشاهدها تباعاً ويحصل على مدة أطول بلا إعلانات.
Future<void> showAdFreeSheet(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _AdFreeSheet());
}

/// عرض إعلان بمكافأة عند أول دخول للإعدادات: شاشة تمهيدية بعدّاد 5 ثوانٍ وزر «لا شكراً»
/// (النمط الذي تشترطه Google للإعلانات البينية بمكافأة)، ثم الإعلان إن لم يرفض المستخدم.
Future<void> offerRewardIntro(BuildContext context) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (_) => const _RewardIntroDialog(),
  );
  if (go != true || !context.mounted) return;

  final earned = await AdsService.instance.watchAdToHideAds();
  if (!context.mounted || !earned) return;
  final tier = AdsService.instance.adFreeTier;
  final duration = AdsService.rewardTiers[tier - 1];
  AppSnack.success(
    context,
    'تم! الإعلانات مخفية ${arabicDurationLabel(duration)}',
  );
}

class _RewardIntroDialog extends StatefulWidget {
  const _RewardIntroDialog();

  @override
  State<_RewardIntroDialog> createState() => _RewardIntroDialogState();
}

class _RewardIntroDialogState extends State<_RewardIntroDialog> {
  static const int _seconds = 5;

  late int _left = _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _left--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final duration = AdsService.rewardTiers.first;

    return AlertDialog(
      icon: Icon(Icons.visibility_off_rounded, color: p.primary, size: 30),
      title: Text('أخفِ الإعلانات ${arabicDurationLabel(duration)}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'شاهد إعلاناً واحداً وتختفي الإعلانات من التطبيق ${arabicDurationLabel(duration)}.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium?.copyWith(color: p.inkSoft),
          ),
          const SizedBox(height: AppSpace.l),
          Text(
            'يبدأ الإعلان خلال $_left',
            style: context.text.labelLarge?.copyWith(
              color: p.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('لا شكراً'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('شاهد الآن'),
        ),
      ],
    );
  }
}

/// مدة بالعربية: «نصف ساعة» / «ساعة» / «ساعة ونصف» / «ساعتان» / «45 دقيقة»
String arabicDurationLabel(Duration d) {
  final minutes = d.inMinutes;
  if (minutes == 30) return 'نصف ساعة';
  if (minutes < 60) return '$minutes دقيقة';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return arabicHoursLabel(h);
  if (h == 1 && m == 30) return 'ساعة ونصف';
  return '${arabicHoursLabel(h)} و$m دقيقة';
}

/// «ساعة» / «ساعتان» / «3 ساعات» / «12 ساعة»
String arabicHoursLabel(int hours) {
  if (hours == 1) return 'ساعة';
  if (hours == 2) return 'ساعتان';
  if (hours >= 3 && hours <= 10) return '$hours ساعات';
  return '$hours ساعة';
}

/// عدد الإعلانات كفاعل: «إعلان واحد» / «إعلانان» / «3 إعلانات»
String adsCountLabel(int n) {
  if (n == 1) return 'إعلان واحد';
  if (n == 2) return 'إعلانان';
  return '$n إعلانات';
}

/// عدد الإعلانات كمفعول به بعد «شاهد»: «إعلاناً واحداً» / «إعلانين» / «3 إعلانات»
String adsCountObject(int n) {
  if (n == 1) return 'إعلاناً واحداً';
  if (n == 2) return 'إعلانين';
  return '$n إعلانات';
}

/// المدة المتبقية بشكل مختصر: «2 س و10 د» أو «45 د»
String formatAdFreeRemaining(Duration d) {
  final totalMinutes = d.inMinutes < 1 ? 1 : d.inMinutes;
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (h == 0) return '$m د';
  if (m == 0) return '$h س';
  return '$h س و$m د';
}

/// «حتى الساعة 9:45 م» (مع «غداً» إن كان اليوم التالي)
String adFreeUntilLabel(BuildContext context, DateTime until) {
  final time = TimeOfDay.fromDateTime(until).format(context);
  final now = DateTime.now();
  final sameDay =
      until.year == now.year &&
      until.month == now.month &&
      until.day == now.day;
  return sameDay ? 'حتى الساعة $time' : 'حتى الساعة $time غداً';
}

class _AdFreeSheet extends StatefulWidget {
  const _AdFreeSheet();

  @override
  State<_AdFreeSheet> createState() => _AdFreeSheetState();
}

class _AdFreeSheetState extends State<_AdFreeSheet> {
  /// ثواني الشاشة التمهيدية قبل كل إعلان لاحق (يمكن الإيقاف خلالها)
  static const int _introSeconds = 5;

  /// المستوى المختار (1 إلى 3) أو null فيؤخذ المستوى التالي تلقائياً
  int? _target;

  bool _running = false;
  bool _failed = false;
  bool _stop = false;
  int _done = 0;
  int _need = 0;
  int? _countdown;

  @override
  void dispose() {
    _stop = true;
    super.dispose();
  }

  /// المستوى المطلوب الوصول إليه بناءً على اختيار المستخدم والمستوى الحالي
  int _effectiveTarget(int tier) {
    final max = AdsService.rewardTiers.length;
    final chosen = _target;
    if (chosen != null && chosen > tier) return chosen;
    return tier + 1 > max ? max : tier + 1;
  }

  Future<void> _start() async {
    final ads = AdsService.instance;
    final need = _effectiveTarget(ads.adFreeTier) - ads.adFreeTier;
    if (need <= 0) return;

    setState(() {
      _running = true;
      _failed = false;
      _stop = false;
      _done = 0;
      _need = need;
    });

    for (var i = 0; i < need; i++) {
      if (i > 0) {
        // شاشة تمهيدية بعدّ تنازلي قبل كل إعلان لاحق، مع «لا شكراً» للإيقاف
        for (var s = _introSeconds; s > 0; s--) {
          if (!mounted || _stop) break;
          setState(() => _countdown = s);
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        if (!mounted) return;
        setState(() => _countdown = null);
        if (_stop) break;
      }

      final earned = await ads.watchAdToHideAds();
      if (!mounted) return;
      if (!earned) {
        setState(() => _failed = true);
        break;
      }
      HapticFeedback.mediumImpact();
      setState(() => _done = i + 1);
    }

    if (!mounted) return;
    final gained = _done;
    setState(() {
      _running = false;
      _countdown = null;
      _target = null;
    });
    if (gained > 0) {
      final tier = ads.adFreeTier;
      final duration = AdsService.rewardTiers[tier - 1];
      AppSnack.success(
        context,
        'تم! الإعلانات مخفية ${arabicDurationLabel(duration)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdsService.instance,
      builder: (context, _) {
        final p = context.palette;
        final ads = AdsService.instance;
        final tier = ads.adFreeTier;
        final until = ads.adFreeUntil;
        final tiers = AdsService.rewardTiers;
        final canMore = ads.canWatchMore;

        final target = _effectiveTarget(tier);
        final need = target - tier;
        final String buttonLabel = canMore
            ? 'شاهد ${adsCountObject(need)} · ${arabicDurationLabel(tiers[target - 1])}'
            : 'تم';

        return SheetScaffold(
          title: 'إخفاء الإعلانات',
          subtitle: 'اختر عدد الإعلانات، وكلما زادت زادت مدة الراحة',
          footer: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientButton(
                label: buttonLabel,
                icon: canMore
                    ? Icons.play_circle_fill_rounded
                    : Icons.check_rounded,
                loading: _running,
                onPressed: canMore ? _start : () => Navigator.of(context).pop(),
              ),
              if (_failed) ...[
                const SizedBox(height: AppSpace.s),
                Text(
                  _done > 0
                      ? 'تعذّر عرض الإعلان التالي، وتحتفظ بما كسبته.'
                      : 'الإعلان غير متاح الآن، حاول لاحقاً',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall?.copyWith(color: p.danger),
                ),
              ],
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (until != null)
                _StatusBanner(
                  text:
                      '${adFreeUntilLabel(context, until)} · متبقي ${formatAdFreeRemaining(until.difference(DateTime.now()))}',
                ),
              if (_running)
                _RunPanel(
                  index: _done + 1,
                  total: _need,
                  countdown: _countdown,
                  onStop: () => setState(() => _stop = true),
                ),
              for (var i = 0; i < tiers.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.s),
                  child: _TierTile(
                    title: adsCountLabel(i + 1),
                    subtitle: (tier > 0 && i + 1 > tier)
                        ? 'المتبقي: ${adsCountLabel(i + 1 - tier)}'
                        : null,
                    reward: arabicDurationLabel(tiers[i]),
                    number: i + 1,
                    done: tier > i,
                    selected: canMore && i + 1 == target,
                    onTap: (!_running && canMore && i + 1 > tier)
                        ? () => setState(() => _target = i + 1)
                        : null,
                  ),
                ),
              const SizedBox(height: AppSpace.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: p.inkFaint),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(
                      canMore
                          ? 'المشاهدة اختيارية بالكامل. بين كل إعلان وآخر يمكنك الإيقاف '
                                'وتحتفظ بالمدة التي كسبتها.'
                          : 'وصلت لأقصى مدة. تعود الإعلانات تلقائياً بعد انتهائها.',
                      style: context.text.bodySmall?.copyWith(
                        color: p.inkFaint,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// لوحة التقدم أثناء المشاهدة: «الإعلان 1 من 2» وعدّاد الإعلان التالي مع زر إيقاف
class _RunPanel extends StatelessWidget {
  const _RunPanel({
    required this.index,
    required this.total,
    required this.countdown,
    required this.onStop,
  });

  final int index;
  final int total;
  final int? countdown;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = context.accent;
    final progress = ((index - 1) / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.m),
      padding: const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(
        color: a.soft,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الإعلان $index من $total',
            style: context.text.titleSmall?.copyWith(
              color: a.color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.s),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: p.surface.withValues(alpha: 0.6),
              color: a.color,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          if (countdown != null) ...[
            Text(
              'الإعلان التالي يبدأ خلال $countdown',
              style: context.text.bodyMedium?.copyWith(color: p.ink),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onStop,
                child: const Text('لا شكراً، أكتفي بما كسبت'),
              ),
            ),
          ] else
            Text(
              'جارٍ تحميل الإعلان…',
              style: context.text.bodyMedium?.copyWith(color: p.inkSoft),
            ),
        ],
      ),
    );
  }
}

/// شريط الحالة: يوضح حتى متى الإعلانات مخفية
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.m),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.m,
        vertical: AppSpace.m,
      ),
      decoration: BoxDecoration(
        color: p.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 20, color: p.success),
          const SizedBox(width: AppSpace.s),
          Expanded(
            child: Text(
              text,
              style: context.text.labelLarge?.copyWith(
                color: p.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// باقة واحدة: منجزة (علامة صح)، أو مختارة (مميّزة)، أو قابلة للاختيار (باهتة)
class _TierTile extends StatelessWidget {
  const _TierTile({
    required this.title,
    required this.reward,
    required this.number,
    required this.done,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String reward;
  final int number;
  final bool done;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final a = context.accent;

    final Color border = done
        ? p.success.withValues(alpha: 0.45)
        : selected
        ? a.color
        : p.border;
    final Color fill = done
        ? p.success.withValues(alpha: 0.08)
        : selected
        ? a.soft
        : Colors.transparent;
    final Color accentOfState = done
        ? p.success
        : selected
        ? a.color
        : p.inkSoft;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: '$title، بلا إعلانات $reward',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.m),
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.m,
              vertical: AppSpace.m,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(color: border, width: selected ? 1.6 : 1),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: done
                        ? p.success
                        : selected
                        ? a.color
                        : p.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: done
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('done'),
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '$number',
                            key: ValueKey('n$number$selected'),
                            style: context.text.labelLarge?.copyWith(
                              color: selected ? Colors.white : p.inkSoft,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: done || selected ? p.ink : p.inkSoft,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: context.text.bodySmall?.copyWith(
                            color: p.inkFaint,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.m,
                    vertical: AppSpace.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentOfState.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Text(
                    'بلا إعلانات $reward',
                    style: context.text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accentOfState,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
