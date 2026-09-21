import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_palette.dart';
import '../../../assets_manager.dart';
import '../../../core/helpers/statistics_helper.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/utils/app_links.dart';
import '../../../providers/app_provider.dart';
import '../../widgets/common/ad_banner.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_feedback.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/page_header.dart';
import 'ad_free_sheet.dart';
import 'child_safety_page.dart';
import 'privacy_policy_sheet.dart';

/// صفحة الإعدادات: نظرة عامة، المظهر، عن التطبيق، والبيانات
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  Future<void> _clearAll() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'مسح جميع البيانات',
      message: AppStrings.confirmClearData,
      confirmText: 'مسح الكل',
      destructive: true,
      icon: Icons.delete_forever_rounded,
    );
    if (!confirmed || !mounted) return;

    await runGuarded(
      context,
      AppScope.read(context).clearAll,
      success: AppStrings.dataCleared,
    );
  }

  Future<void> _contactUs() async {
    final opened = await AppLinks.email(
      subject: 'استفسار عن تطبيق ${AppStrings.appTitle}',
    );
    if (!opened && mounted) {
      AppSnack.error(context, 'لا يمكن فتح تطبيق البريد');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final hasData =
        controller.contacts.isNotEmpty || controller.messages.isNotEmpty;

    final sections = <Widget>[
      _BrandCard(packageInfo: _packageInfo),
      const _SectionTitle('نظرة عامة'),
      _StatsGrid(controller: controller),
      const _SectionTitle('المظهر'),
      _ThemeCard(controller: controller),
      ListenableBuilder(
        listenable: AdsService.instance,
        builder: (context, _) {
          final ads = AdsService.instance;
          if (!ads.canOfferReward) return const SizedBox.shrink();
          final until = ads.adFreeUntil;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('الإعلانات'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: until != null
                        ? Icons.check_circle_outline_rounded
                        : Icons.visibility_off_rounded,
                    title: until != null
                        ? 'الإعلانات مخفية'
                        : 'إخفاء الإعلانات',
                    subtitle: until != null
                        ? adFreeUntilLabel(context, until) +
                              (ads.canWatchMore ? ' · اضغط لزيادة المدة' : '')
                        : 'شاهد إعلاناً وأخفِ الإعلانات حتى 12 ساعة',
                    onTap: () => showAdFreeSheet(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      const _SectionTitle('عن التطبيق'),
      const _AboutCard(),
      const SizedBox(height: AppSpace.m),
      ListenableBuilder(
        listenable: AdsService.instance,
        builder: (context, _) => _SettingsGroup(
          children: [
            _SettingsTile(
              icon: Icons.privacy_tip_rounded,
              title: 'سياسة الخصوصية',
              subtitle: 'كيف نحمي بياناتك',
              onTap: () => showPrivacyPolicy(context),
            ),
            if (AdsService.instance.privacyOptionsRequired)
              _SettingsTile(
                icon: Icons.tune_rounded,
                title: 'خيارات الخصوصية والإعلانات',
                subtitle: 'غيّر اختيارك بخصوص الإعلانات',
                onTap: AdsService.instance.showPrivacyOptions,
              ),
            _SettingsTile(
              icon: Icons.child_care_rounded,
              title: 'معايير سلامة الأطفال',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ChildSafetyPage(),
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.mail_outline_rounded,
              title: 'تواصل معنا',
              subtitle: 'اقتراح أو مشكلة؟ راسلنا',
              onTap: _contactUs,
            ),
          ],
        ),
      ),
      const _SectionTitle('البيانات'),
      _SettingsGroup(
        children: [
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'مسح جميع البيانات',
            subtitle: 'حذف كل جهات الاتصال والرسائل نهائياً',
            danger: true,
            onTap: hasData ? _clearAll : null,
          ),
        ],
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            title: AppStrings.settings,
            subtitle: 'تحكّم في مظهر التطبيق وبياناتك',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < sections.length; i++)
                  FadeSlideIn(
                    playOnceKey: 'settings-section-$i',
                    delay: FadeSlideIn.stagger(i, stepMs: 45),
                    child: sections[i],
                  ),
              ],
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

// ==================== الأقسام ====================

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.packageInfo});

  final Future<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      gradient: p.brand,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.l),
            ),
            child: Image.asset(Assets.logoPng, fit: BoxFit.contain),
          ),
          const SizedBox(width: AppSpace.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appTitle,
                  style: context.text.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  AppStrings.appSubtitle,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<PackageInfo>(
                  future: packageInfo,
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    if (info == null) return const SizedBox(height: 22);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(AppRadius.s),
                      ),
                      child: Text(
                        'الإصدار ${info.version}',
                        style: context.text.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.m),
      child: Text(
        text,
        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final contactStats = StatisticsHelper.getContactStatistics(
      controller.contacts,
    );
    final messageStats = StatisticsHelper.getMessageStatistics(
      controller.messages,
    );
    final totalUsage = controller.messages.fold<int>(
      0,
      (sum, m) => sum + m.usageCount,
    );

    final tiles = [
      _StatTile(
        icon: Icons.people_alt_rounded,
        label: 'جهات الاتصال',
        value: contactStats.total,
        color: p.contacts.color,
      ),
      _StatTile(
        icon: Icons.chat_bubble_rounded,
        label: 'الرسائل المحفوظة',
        value: messageStats.total,
        color: p.messages.color,
      ),
      _StatTile(
        icon: Icons.verified_rounded,
        label: 'أرقام صحيحة',
        value: contactStats.validPhones,
        color: p.success,
      ),
      _StatTile(
        icon: Icons.trending_up_rounded,
        label: 'مرات الاستخدام',
        value: totalUsage,
        color: p.settings.color,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tiles[0]),
            const SizedBox(width: AppSpace.m),
            Expanded(child: tiles[1]),
          ],
        ),
        const SizedBox(height: AppSpace.m),
        Row(
          children: [
            Expanded(child: tiles[2]),
            const SizedBox(width: AppSpace.m),
            Expanded(child: tiles[3]),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.s),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: AppSpace.m),
          CountUp(
            value: value,
            style: context.text.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(color: p.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.m),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto_rounded),
              label: Text('تلقائي'),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_rounded),
              label: Text('فاتح'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_rounded),
              label: Text('داكن'),
            ),
          ],
          selected: {controller.themeMode},
          onSelectionChanged: (selection) =>
              controller.setThemeMode(selection.first),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  static const List<(IconData, String)> _features = [
    (Icons.rocket_launch_rounded, 'تقنيات حديثة ومتطورة'),
    (Icons.palette_rounded, 'تصميم عصري ومتجاوب'),
    (Icons.shield_rounded, 'أمان وخصوصية عالية'),
    (Icons.bolt_rounded, 'أداء سريع وموثوق'),
    (Icons.card_giftcard_rounded, 'مجاني بالكامل'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget block(String title, String body) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.text.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.accent.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: context.text.bodyMedium?.copyWith(
            color: p.inkSoft,
            height: 1.8,
          ),
        ),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          block(
            'رؤيتنا',
            'نساعد المستخدمين على التواصل بشكل أسرع من خلال ميزات متقدمة لإدارة المراسلات والأرقام.',
          ),
          const SizedBox(height: AppSpace.l),
          block(
            'مهمتنا',
            'تطوير تطبيقات عملية وسهلة الاستخدام تلبي احتياجات المستخدمين اليومية وتوفر تجربة استخدام مميزة ومريحة.',
          ),
          const SizedBox(height: AppSpace.l),
          Divider(color: p.border),
          const SizedBox(height: AppSpace.m),
          Text(
            'ما يميزنا',
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpace.m),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (icon, label) in _features)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: context.accent.color),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: context.text.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 68,
                endIndent: AppSpace.l,
                color: p.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onTap != null;
    final tone = danger ? p.danger : context.accent.color;

    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.l,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.s),
                ),
                child: Icon(icon, size: 20, color: tone),
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
                        color: danger ? p.danger : p.ink,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.text.bodySmall?.copyWith(
                          color: p.inkSoft,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: p.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}
