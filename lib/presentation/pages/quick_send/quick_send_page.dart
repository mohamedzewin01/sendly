import 'package:flutter/material.dart';

import '../../../app/theme/app_palette.dart';
import '../../widgets/common/ad_banner.dart';
import '../../widgets/common/motion.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/send/send_composer.dart';

/// صفحة الإرسال السريع: راسل أي رقم دون حفظه في جهات الاتصال
class QuickSendPage extends StatelessWidget {
  const QuickSendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            title: 'إرسال سريع',
            subtitle: 'راسل أي رقم دون حفظه في جهات الاتصال',
          ),
          Padding(
            // هوامش أقل ليأخذ مربع الكتابة عرضاً أكبر
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 90),
              child: const SendComposer(
                acceptsIncoming: true,
                // إعلان بين الكارتين بمسافة واضحة عن أزرار «جهاتي» و«لصق» وعن شريط التنسيق
                betweenCards: AdBanner(
                  maxHeight: 60,
                  padding: EdgeInsets.fromLTRB(0, AppSpace.s, 0, AppSpace.l),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.l),
          FadeSlideIn(
            delay: const Duration(milliseconds: 220),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: p.inkFaint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يفتح التطبيق والرسالة جاهزة، وأنت من يضغط «إرسال». '
                      'لا يُرسل شيء تلقائياً.',
                      style: context.text.bodySmall?.copyWith(
                        color: p.inkFaint,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // إعلان ثانٍ في آخر الصفحة، بعيداً عن زر الإرسال حتى لا يُضغط بالخطأ
          const AdBanner(
            maxHeight: 60,
            padding: EdgeInsets.fromLTRB(
              AppSpace.xl,
              AppSpace.xl,
              AppSpace.xl,
              AppSpace.xl,
            ),
          ),
        ],
      ),
    );
  }
}
