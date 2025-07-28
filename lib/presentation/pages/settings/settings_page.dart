
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/helpers/statistics_helper.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/contact.dart';
import '../../../data/models/message.dart';

/// صفحة الإعدادات
class SettingsPage extends StatefulWidget {
  final List<Contact> contacts;
  final List<Message> messages;
  final VoidCallback onExportContacts;
  final VoidCallback onExportMessages;
  final VoidCallback onImportContacts;
  final VoidCallback onImportMessages;
  final VoidCallback onClearAllData;

  const SettingsPage({
    super.key,
    required this.contacts,
    required this.messages,
    required this.onExportContacts,
    required this.onExportMessages,
    required this.onImportContacts,
    required this.onImportMessages,
    required this.onClearAllData,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.normalAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FA), Color(0xFFE8F5E8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsSection(context, isMobile),
              const SizedBox(height: 24),
              _buildAboutUsSection(context, isMobile),
              const SizedBox(height: 24),
              _buildPrivacyPolicySection(context, isMobile),
              const SizedBox(height: 24),
              _buildDangerZoneSection(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء قسم الإحصائيات
  Widget _buildStatisticsSection(BuildContext context, bool isMobile) {
    final contactStats = StatisticsHelper.getContactStatistics(widget.contacts);
    final messageStats = StatisticsHelper.getMessageStatistics(widget.messages);
    final appStats = StatisticsHelper.getAppUsageStatistics(widget.contacts, widget.messages);

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppConstants.appGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appStatistics,
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Text(
                    //   'حالة البيانات: ${appStats.healthStatus}',
                    //   style: TextStyle(
                    //     color: AppUtils.getStatusColor(appStats.healthStatus.toLowerCase()),
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // شبكة الإحصائيات
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 1.2 : 1.5,
            children: [
              _buildStatCard(
                'جهات الاتصال',
                contactStats.total.toString(),
                Icons.contacts,
                AppConstants.appGreen,
              ),
              _buildStatCard(
                'الرسائل المحفوظة',
                messageStats.total.toString(),
                Icons.message,
                AppConstants.warningOrange,
              ),
              // _buildStatCard(
              //   'أرقام صحيحة',
              //   contactStats.validPhones.toString(),
              //   Icons.phone,
              //   AppConstants.successGreen,
              // ),
              // _buildStatCard(
              //   'متوسط طول الرسالة',
              //   '${messageStats.averageLength} حرف',
              //   Icons.text_fields,
              //   AppConstants.infoBlue,
              // ),
            ],
          ),

          // if (contactStats.total > 0 || messageStats.total > 0) ...[
          //   const SizedBox(height: 20),
          //   _buildHealthIndicator(appStats),
          // ],
        ],
      ),
    );
  }

  /// بناء قسم "من نحن"
  Widget _buildAboutUsSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConstants.appGreen, AppConstants.appDarkGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'من نحن',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // محتوى من نحن
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.appGreen.withOpacity(0.05),
                  AppConstants.appGreen.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.appGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.appGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'رؤيتنا',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.appDarkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "نساعد المستخدمين على التواصل بشكل أسرع من خلال ميزات متقدمة لإدارة المراسلات والأرقام.",
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.appGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.ad_units_sharp,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'مهمتنا',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.appDarkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'تطوير تطبيقات عملية وسهلة الاستخدام تلبي احتياجات المستخدمين اليومية وتوفر تجربة استخدام مميزة ومريحة.',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // المميزات الرئيسية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌟 ما يميزنا:',
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.appDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem('🚀', 'تقنيات حديثة ومتطورة'),
                      _buildFeatureItem('🎨', 'تصميم عصري ومتجاوب'),
                      _buildFeatureItem('🔒', 'أمان وخصوصية عالية'),
                      _buildFeatureItem('⚡', 'أداء سريع وموثوق'),
                      _buildFeatureItem('🆓', 'مجاني بالكامل'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),




          // أزرار التواصل
          Row(
            children: [
              // Expanded(
              //   child: _buildContactButton(
              //     'تقييم التطبيق',
              //     Icons.star,
              //     AppConstants.warningOrange,
              //     _rateApp,
              //   ),
              // ),
              Expanded(
                child: _buildContactButton('سلامة الطفل', Icons.child_care,  AppConstants.infoBlue, (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChildrenSafetyPolicyPage()));
                }),
              ),
              // const SizedBox(width: 12),
              // Expanded(
              //   child: _buildContactButton(
              //     'مشاركة التطبيق',
              //     Icons.share,
              //     AppConstants.infoBlue,
              //     _shareApp,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء قسم سياسة الخصوصية
  Widget _buildPrivacyPolicySection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppConstants.infoBlue, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.privacy_tip,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سياسة الخصوصية',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'حماية بياناتك أولويتنا',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // نقاط سياسة الخصوصية
          _buildPrivacySection(
            '🔒 حماية البيانات',
            'جميع بياناتك محفوظة محلياً على جهازك ولا يتم رفعها إلى أي خوادم خارجية.',
            AppConstants.successGreen,
          ),

          const SizedBox(height: 16),

          _buildPrivacySection(
            '📱 البيانات المحلية',
            'التطبيق يحفظ جهات الاتصال والرسائل في ذاكرة الجهاز فقط ولا يشاركها مع أطراف ثالثة.',
            AppConstants.infoBlue,
          ),

          const SizedBox(height: 16),

          _buildPrivacySection(
            '🚫 عدم التتبع',
            'لا نجمع أي معلومات شخصية ولا نتتبع استخدامك للتطبيق.',
            AppConstants.warningOrange,
          ),

          const SizedBox(height: 16),

          _buildPrivacySection(
            '🔄 التحديثات',
            'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر وسنخبرك بأي تغييرات مهمة.',
            Colors.purple,
          ),

          const SizedBox(height: 20),

          // تفاصيل إضافية
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.infoBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.infoBlue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppConstants.infoBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'معلومات مهمة',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.infoBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• يوفّر التطبيق طريقة لبدء المحادثات يدويًا دون إرسال الرسائل تلقائيًا.\n'
                      '• لا يُجري التطبيق مكالمات تلقائيًا، بل يفتح شاشة الاتصال فقط.\n'
                      '• عند إزالة تثبيت التطبيق، ستفقد جميع البيانات المخزنة.\n'
                      '• جميع البيانات تُخزَّن محليًا على جهاز المستخدم، ولا يتم جمع أو مشاركة أي معلومات شخصية.\n'
                      ,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    color: AppConstants.infoBlue.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // زر عرض السياسة الكاملة
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showFullPrivacyPolicy(context),
              icon: const Icon(Icons.article_outlined),
              label: const Text('عرض السياسة الكاملة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.infoBlue,
                side: BorderSide(color: AppConstants.infoBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء مؤشر صحة البيانات
  // Widget _buildHealthIndicator(AppUsageStatistics stats) {
  //   final healthColor = AppUtils.getStatusColor(stats.healthStatus.toLowerCase());
  //
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: healthColor.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: healthColor.withOpacity(0.3)),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           AppUtils.getStatusIcon(stats.healthStatus.toLowerCase()),
  //           color: healthColor,
  //           size: 24,
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'صحة البيانات: ${stats.dataHealth}%',
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: healthColor,
  //                 ),
  //               ),
  //               LinearProgressIndicator(
  //                 value: stats.dataHealth / 100,
  //                 backgroundColor: healthColor.withOpacity(0.2),
  //                 valueColor: AlwaysStoppedAnimation<Color>(healthColor),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// بناء بطاقة إحصائية
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth, // ياخذ العرض المتاح له
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.08, // حجم ديناميكي
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.08, // حجم ديناميكي
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  /// بناء عنصر ميزة
  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء زر تواصل
  Widget _buildContactButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// بناء قسم الخصوصية
  Widget _buildPrivacySection(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// عرض السياسة الكاملة
  void _showFullPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip, color: AppConstants.infoBlue),
            SizedBox(width: 8),
            Text('سياسة الخصوصية الكاملة'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPolicySection(
                '1. جمع البيانات',
                'لا يجمع التطبيق أي بيانات شخصية من المستخدمين. جميع المعلومات التي تدخلها (مثل جهات الاتصال أو الرسائل) تُخزَّن محليًا على جهازك فقط.',
              ),
              _buildPolicySection(
                '2. استخدام البيانات',
                'تُستخدم البيانات المحفوظة فقط لتقديم خدمات التطبيق، مثل حفظ جهات الاتصال والرسائل. لا يتم تحليلها أو معالجتها لأي أغراض أخرى.',
              ),
              _buildPolicySection(
                '3. مشاركة البيانات',
                'لا تتم مشاركة أي بيانات مع أطراف خارجية. التطبيق يعمل بشكل مستقل ولا يرسل أي معلومات إلى خوادم خارجية.',
              ),
              _buildPolicySection(
                '4. الأمان',
                'يتم تأمين بياناتك من خلال آليات الحماية الموجودة في نظام التشغيل. نوصي باستخدام رقم سري أو بصمة لحماية جهازك.',
              ),
              _buildPolicySection(
                '5. حقوقك',
                'يمكنك حذف جميع بياناتك في أي وقت من خلال إعدادات التطبيق أو عند إلغاء تثبيته من الجهاز.',
              ),
            ],


          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  /// بناء قسم في السياسة
  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.infoBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  /// بناء المنطقة الخطرة
  Widget _buildDangerZoneSection(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: AppConstants.errorRed.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.errorRed.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.errorRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning,
                  color: AppConstants.errorRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'مسح وإعادة تعيين',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'الإجراءات التالية لا يمكن التراجع عنها. يرجى التأكد قبل المتابعة.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          _buildDangerAction(
            'مسح جميع البيانات',
            'حذف جميع جهات الاتصال والرسائل نهائياً',
            Icons.delete_forever,
            _confirmClearAllData,
            enabled: widget.contacts.isNotEmpty || widget.messages.isNotEmpty,
          ),

          const SizedBox(height: 12),

          _buildDangerAction(
            'إعادة تعيين التطبيق',
            'استعادة التطبيق لحالته الأولى',
            Icons.restore,
            _confirmResetApp,
          ),
        ],
      ),
    );
  }

  /// بناء إجراء خطر
  Widget _buildDangerAction(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap, {
        bool enabled = true,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.errorRed.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? AppConstants.errorRed : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: enabled ? AppConstants.errorRed : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: enabled ? AppConstants.errorRed : Colors.grey[300],
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }

  /// تأكيد مسح جميع البيانات
  void _confirmClearAllData() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      'تأكيد الحذف',
      AppStrings.confirmClearData,
      confirmText: 'حذف جميع البيانات',
      isDestructive: true,
      icon: Icons.delete_forever,
    );

    if (confirmed == true) {
      widget.onClearAllData();
    }
  }

  /// تأكيد إعادة تعيين التطبيق
  void _confirmResetApp() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      'إعادة تعيين التطبيق',
      'هل تريد إعادة تعيين التطبيق لحالته الأولى؟ سيتم حذف جميع البيانات والإعدادات.',
      confirmText: 'إعادة تعيين',
      isDestructive: true,
      icon: Icons.restore,
    );

    if (confirmed == true) {
      // تنفيذ إعادة التعيين
      widget.onClearAllData();

      AppUtils.showCustomSnackBar(
        context,
        'تم إعادة تعيين التطبيق بنجاح',
        isSuccess: true,
      );
    }
  }

  /// تقييم التطبيق
  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: AppConstants.warningOrange),
            SizedBox(width: 8),
            Text('تقييم التطبيق'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'هل أعجبك التطبيق؟ نحن نقدر تقييمك وملاحظاتك!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AppUtils.showCustomSnackBar(
                      context,
                      'شكراً لتقييمك! تم أخذ تقييمك بعين الاعتبار',
                      isSuccess: true,
                    );
                  },
                  icon: Icon(
                    Icons.star,
                    color: AppConstants.warningOrange,
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}





class ChildrenSafetyPolicyPage extends StatelessWidget {
  const ChildrenSafetyPolicyPage({super.key});

  // دالة لفتح البريد الإلكتروني
  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mohammedzewin01@gmail.com',
      query: Uri.encodeFull('subject=استفسار بشأن سياسة الأطفال&body=مرحبًا فريق SandlyN،'),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      debugPrint('لا يمكن فتح تطبيق البريد.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.indigo.shade700,
          title: const Text(
            'معايير سلامة الأطفال',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView(
              children: [
                const Text(
                  'معايير سلامة الأطفال - SandlyN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                    'نحن نأخذ سلامة جميع المستخدمين على محمل الجد، وخاصة الأطفال. '
                        'تم تصميم تطبيق SandlyN لتسهيل إرسال الرسائل وحفظ الأرقام محليًا على الجهاز، '
                        'دون إرسالها تلقائيًا أو جمع أي بيانات حساسة.'
,
                    style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 24),
                const Text(
                  'التزاماتنا تجاه سلامة الأطفال:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 12),
                const BulletItem(text: 'لا يسمح التطبيق بأي محتوى ضار أو مسيء موجه للأطفال.'),
                const BulletItem(text: 'التطبيق لا يحتوي على أي ميزات تتيح التفاعل بين المستخدمين أو نشر محتوى.'),
                const BulletItem(text: 'لا يتم إرسال الرسائل أو إجراء المكالمات تلقائيًا، بل يتم فتح شاشة التطبيق المناسب فقط.'),
                const BulletItem(text: 'لا يتم جمع أو تخزين أي معلومات شخصية حساسة على خوادم خارجية.'),
                const BulletItem(text: 'نوفّر آلية للإبلاغ عن أي إساءة استخدام داخل التطبيق.'),
                const BulletItem(text: 'نتعاون مع الجهات المختصة في حال الإبلاغ عن محتوى مخالف.'),

                const SizedBox(height: 24),
                const Text(
                  'للتواصل معنا بشأن سلامة الأطفال أو الإبلاغ عن أي محتوى غير لائق:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _launchEmail,
                  child: const Text(
                    '📧 mohammedzewin01@gmail.com',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
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

class BulletItem extends StatelessWidget {
  final String text;
  const BulletItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 20,
              color: Colors.indigo,
              height: 1.6,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
