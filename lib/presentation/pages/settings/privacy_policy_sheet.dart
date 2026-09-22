import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../widgets/common/app_sheet.dart';

/// يفتح سياسة الخصوصية (ملخص + النص الكامل)
Future<void> showPrivacyPolicy(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _PrivacySheet());
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();

  static const List<(IconData, String, String)> _highlights = [
    (
      Icons.lock_rounded,
      'حماية البيانات',
      'جهات اتصالك ورسائلك محفوظة محلياً على جهازك ولا يتم رفعها إلى أي خوادم.',
    ),
    (
      Icons.phone_android_rounded,
      'البيانات المحلية',
      'التطبيق يحفظ جهات الاتصال والرسائل في ذاكرة الجهاز فقط ولا يشاركها مع أطراف ثالثة.',
    ),
    (
      Icons.visibility_off_rounded,
      'لا نتتبع نشاطك',
      'لا نجمع معلومات شخصية ولا نستخدم أدوات تحليلات. جهات اتصالك ورسائلك لا تُستخدم أبداً في الإعلانات.',
    ),
    (
      Icons.campaign_rounded,
      'الإعلانات',
      'يعرض التطبيق إعلانات عبر Google AdMob: بانرات صغيرة داخل الصفحات والقوائم، وإعلاناً بينياً بعد العودة من تطبيق المراسلة (لا يظهر عند فتح التطبيق ولا أثناء الكتابة)، وعرضاً اختيارياً بمكافأة عند فتح الإعدادات لإخفاء الإعلانات فترة، مع خيار الرفض دائماً. '
          'ويمكنك اختيارياً مشاهدة إعلان أو إعلانين أو ثلاثة من الإعدادات لإخفاء الإعلانات نصف ساعة أو ساعة أو ساعتين. '
          'قد تستخدم Google معرّف الإعلانات في جهازك وبيانات تقنية عامة (عنوان IP، نوع الجهاز، إصدار النظام) لعرض الإعلانات وقياسها ومنع الاحتيال. '
          'في الدول التي تشترط ذلك (الاتحاد الأوروبي والمملكة المتحدة وسويسرا) نطلب موافقتك أولاً، ويمكنك تغيير اختيارك من الإعدادات ← «خيارات الخصوصية والإعلانات». '
          'ويمكنك في أي وقت إعادة تعيين معرّف الإعلانات أو إيقاف تخصيصها من إعدادات جهازك ← Google ← الإعلانات.',
    ),
    (
      Icons.system_update_rounded,
      'التحقق من التحديثات',
      'عند فتح التطبيق يتصل بخدمة Firebase Remote Config من Google ليعرف إن كان هناك إصدار أحدث. '
          'تُرسَل معلومات تقنية عامة فقط (رمز الدولة، اللغة، المنطقة الزمنية، إصدار النظام، معرّف التطبيق، ومعرّف تثبيت من Firebase) '
          'ولا تتضمن جهات اتصالك أو رسائلك.',
    ),
    (
      Icons.update_rounded,
      'تحديثات السياسة',
      'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر وسنخبرك بأي تغييرات مهمة.',
    ),
  ];

  static const List<(String, String)> _sections = [
    (
      '1. جمع البيانات',
      'لا يجمع التطبيق بياناتك الشخصية. جميع المعلومات التي تدخلها (مثل جهات الاتصال أو الرسائل) تُخزَّن محليًا على جهازك فقط. '
          'يقتصر الاتصال بالإنترنت على التحقق من وجود تحديث للتطبيق وعرض الإعلانات كما هو موضح أعلاه.',
    ),
    (
      '2. استخدام البيانات',
      'تُستخدم البيانات المحفوظة فقط لتقديم خدمات التطبيق، مثل حفظ جهات الاتصال والرسائل. لا يتم تحليلها أو معالجتها لأي أغراض أخرى.',
    ),
    (
      '3. مشاركة البيانات',
      'لا تتم مشاركة جهات اتصالك أو رسائلك مع أي طرف. المعلومات التقنية الخاصة بالتحقق من التحديثات (Firebase) وبعرض الإعلانات (AdMob) تعالجها Google وفق سياسة الخصوصية الخاصة بها.',
    ),
    (
      '4. الأمان',
      'يتم تأمين بياناتك من خلال آليات الحماية الموجودة في نظام التشغيل. نوصي باستخدام رقم سري أو بصمة لحماية جهازك.',
    ),
    (
      '5. حقوقك',
      'يمكنك حذف جميع بياناتك في أي وقت من خلال إعدادات التطبيق أو عند إلغاء تثبيته من الجهاز.',
    ),
  ];

  static const String _notes =
      '• يوفّر التطبيق طريقة لبدء المحادثات يدويًا دون إرسال الرسائل تلقائيًا.\n'
      '• لا يُجري التطبيق مكالمات تلقائيًا، بل يفتح شاشة الاتصال فقط.\n'
      '• عند إزالة تثبيت التطبيق، ستفقد جميع البيانات المخزنة.\n'
      '• جميع بيانات جهات الاتصال والرسائل تُخزَّن محليًا على جهاز المستخدم، ولا تُشارَك مع أي طرف.';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SheetScaffold(
      title: 'سياسة الخصوصية',
      subtitle: 'حماية بياناتك أولويتنا',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (icon, title, body) in _highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.l),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.s),
                    ),
                    child: Icon(icon, size: 20, color: p.primary),
                  ),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: context.text.bodyMedium?.copyWith(
                            color: p.inkSoft,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpace.l),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: p.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'معلومات مهمة',
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s),
                Text(
                  _notes,
                  style: context.text.bodyMedium?.copyWith(
                    color: p.inkSoft,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Text(
            'السياسة الكاملة',
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpace.m),
          for (final (title, body) in _sections)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: p.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: context.text.bodyMedium?.copyWith(height: 1.8),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
