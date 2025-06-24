import 'package:flutter/material.dart';
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
              _buildDataManagementSection(context, isMobile),
              const SizedBox(height: 24),
              _buildAppInfoSection(context, isMobile),
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
                  gradient: AppConstants.whatsappGradient,
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
                    Text(
                      'حالة البيانات: ${appStats.healthStatus}',
                      style: TextStyle(
                        color: AppUtils.getStatusColor(appStats.healthStatus.toLowerCase()),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                AppConstants.whatsappGreen,
              ),
              _buildStatCard(
                'الرسائل المحفوظة',
                messageStats.total.toString(),
                Icons.message,
                AppConstants.warningOrange,
              ),
              _buildStatCard(
                'أرقام صحيحة',
                contactStats.validPhones.toString(),
                Icons.phone,
                AppConstants.successGreen,
              ),
              _buildStatCard(
                'متوسط طول الرسالة',
                '${messageStats.averageLength} حرف',
                Icons.text_fields,
                AppConstants.infoBlue,
              ),
            ],
          ),

          if (contactStats.total > 0 || messageStats.total > 0) ...[
            const SizedBox(height: 20),
            _buildHealthIndicator(appStats),
          ],
        ],
      ),
    );
  }

  /// بناء مؤشر صحة البيانات
  Widget _buildHealthIndicator(AppUsageStatistics stats) {
    final healthColor = AppUtils.getStatusColor(stats.healthStatus.toLowerCase());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: healthColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: healthColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            AppUtils.getStatusIcon(stats.healthStatus.toLowerCase()),
            color: healthColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صحة البيانات: ${stats.dataHealth}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: healthColor,
                  ),
                ),
                LinearProgressIndicator(
                  value: stats.dataHealth / 100,
                  backgroundColor: healthColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة إحصائية
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
                fontSize: 18,
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
                fontSize: 12,
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
  }

  /// بناء قسم إدارة البيانات
  Widget _buildDataManagementSection(BuildContext context, bool isMobile) {
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
                  color: AppConstants.infoBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storage,
                  color: AppConstants.infoBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppStrings.dataManagement,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildActionTile(
            'تصدير جهات الاتصال',
            'حفظ جهات الاتصال في ملف JSON',
            Icons.upload_file,
            AppConstants.successGreen,
            widget.onExportContacts,
            enabled: widget.contacts.isNotEmpty,
          ),

          _buildActionTile(
            'تصدير الرسائل',
            'حفظ الرسائل المحفوظة في ملف JSON',
            Icons.upload_file,
            AppConstants.warningOrange,
            widget.onExportMessages,
            enabled: widget.messages.isNotEmpty,
          ),

          const Divider(height: 32),

          _buildActionTile(
            'استيراد جهات الاتصال',
            'استيراد جهات الاتصال من ملف',
            Icons.download_rounded,
            AppConstants.infoBlue,
            widget.onImportContacts,
          ),

          _buildActionTile(
            'استيراد الرسائل',
            'استيراد الرسائل من ملف',
            Icons.download_rounded,
            Colors.purple,
            widget.onImportMessages,
          ),
        ],
      ),
    );
  }

  /// بناء عنصر إجراء
  Widget _buildActionTile(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap, {
        bool enabled = true,
      }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled ? color : Colors.grey,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: enabled ? Colors.black87 : Colors.grey,
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
        color: enabled ? Colors.grey : Colors.grey[300],
      ),
      onTap: enabled ? onTap : null,
    );
  }

  /// بناء قسم معلومات التطبيق
  Widget _buildAppInfoSection(BuildContext context, bool isMobile) {
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
                  color: AppConstants.whatsappGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info,
                  color: AppConstants.whatsappGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppStrings.appInfo,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildInfoRow('إصدار التطبيق', AppConstants.appVersion),
          _buildInfoRow('رقم البناء', AppConstants.appBuildNumber),
          _buildInfoRow('تاريخ التطوير', '2024'),
          _buildInfoRow('المطور', 'فريق التطوير'),
          _buildInfoRow('البريد الإلكتروني', AppConstants.supportEmail),

          const SizedBox(height: 20),
/// Sandly
          // بطاقة الشكر
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppConstants.whatsappGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.thankYou,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appreciateYourTrust,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      'قيم التطبيق',
                      Icons.star,
                          () => _rateApp(),
                    ),
                    _buildActionButton(
                      'شارك التطبيق',
                      Icons.share,
                          () => _shareApp(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء صف معلومات
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء زر إجراء صغير
  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                'المنطقة الخطرة',
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
    AppUtils.showCustomSnackBar(
      context,
      'ميزة التقييم قيد التطوير',
      isWarning: true,
    );
  }

  /// مشاركة التطبيق
  void _shareApp() {
    const shareText = '''
🌟 اكتشف تطبيق مساعد الواتساب! 

📱 التطبيق الأفضل لإدارة وإرسال الرسائل عبر الواتساب:
• إدارة جهات الاتصال بسهولة
• حفظ الرسائل المتكررة
• إرسال جماعي للرسائل
• واجهة عصرية ومتجاوبة

💚 حمل التطبيق الآن واستمتع بإرسال الرسائل بطريقة احترافية!
    ''';

    AppUtils.copyToClipboard(context, shareText);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}