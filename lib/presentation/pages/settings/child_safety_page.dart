import 'package:flutter/material.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_palette.dart';
import '../../../core/utils/app_links.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_feedback.dart';

/// صفحة معايير سلامة الأطفال
class ChildSafetyPage extends StatelessWidget {
  const ChildSafetyPage({super.key});

  static const List<String> _commitments = [
    'لا يسمح التطبيق بأي محتوى ضار أو مسيء موجه للأطفال.',
    'التطبيق لا يحتوي على أي ميزات تتيح التفاعل بين المستخدمين أو نشر محتوى.',
    'لا يتم إرسال الرسائل أو إجراء المكالمات تلقائيًا، بل يتم فتح شاشة التطبيق المناسب فقط.',
    'لا يتم جمع أو تخزين أي معلومات شخصية حساسة على خوادم خارجية.',
    'نوفّر آلية للإبلاغ عن أي إساءة استخدام داخل التطبيق.',
    'نتعاون مع الجهات المختصة في حال الإبلاغ عن محتوى مخالف، ونبلّغ المركز الوطني للأطفال المفقودين والمستغَلين (NCMEC) أو الجهة الإقليمية المختصة عن أي مواد استغلال مؤكدة.',
  ];

  Future<void> _contact(BuildContext context) async {
    final opened = await AppLinks.email(
      to: AppConstants.childSafetyEmail,
      subject: 'استفسار بشأن سياسة الأطفال',
      body: 'مرحبًا فريق ${AppStrings.appTitle}،',
    );
    if (!opened && context.mounted) {
      AppSnack.error(context, 'لا يمكن فتح تطبيق البريد');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('معايير سلامة الأطفال'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: context.text.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpace.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.xl),
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: p.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                          child: Icon(
                            Icons.child_care_rounded,
                            color: p.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpace.m),
                        Expanded(
                          child: Text(
                            'معايير سلامة الأطفال - ${AppStrings.appTitle}',
                            style: context.text.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.l),
                    Text(
                      'نحن نأخذ سلامة جميع المستخدمين على محمل الجد، وخاصة الأطفال. '
                      'تم تصميم تطبيق ${AppStrings.appTitle} لتسهيل إرسال الرسائل وحفظ الأرقام محليًا على الجهاز، '
                      'دون إرسالها تلقائيًا أو جمع أي بيانات حساسة.',
                      style: context.text.bodyLarge?.copyWith(height: 1.8),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    Text(
                      'التزاماتنا تجاه سلامة الأطفال:',
                      style: context.text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: p.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.m),
                    for (final item in _commitments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: p.success,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item,
                                style: context.text.bodyMedium?.copyWith(
                                  height: 1.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpace.l),
                    Text(
                      'للتواصل معنا بشأن سلامة الأطفال أو الإبلاغ عن أي محتوى غير لائق:',
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: AppSpace.m),
                    InkWell(
                      onTap: () => _contact(context),
                      borderRadius: BorderRadius.circular(AppRadius.s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 20,
                              color: p.primary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppConstants.childSafetyEmail,
                                style: context.text.bodyLarge?.copyWith(
                                  color: p.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: p.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
