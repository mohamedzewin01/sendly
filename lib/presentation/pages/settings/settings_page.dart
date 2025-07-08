// import 'package:flutter/material.dart';
// import '../../../app/constants/app_constants.dart';
// import '../../../app/constants/app_strings.dart';
// import '../../../core/helpers/responsive_helper.dart';
// import '../../../core/helpers/statistics_helper.dart';
// import '../../../core/utils/app_utils.dart';
// import '../../../data/models/contact.dart';
// import '../../../data/models/message.dart';
//
// /// صفحة الإعدادات
// class SettingsPage extends StatefulWidget {
//   final List<Contact> contacts;
//   final List<Message> messages;
//   final VoidCallback onExportContacts;
//   final VoidCallback onExportMessages;
//   final VoidCallback onImportContacts;
//   final VoidCallback onImportMessages;
//   final VoidCallback onClearAllData;
//
//   const SettingsPage({
//     super.key,
//     required this.contacts,
//     required this.messages,
//     required this.onExportContacts,
//     required this.onExportMessages,
//     required this.onImportContacts,
//     required this.onImportMessages,
//     required this.onClearAllData,
//   });
//
//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }
//
// class _SettingsPageState extends State<SettingsPage>
//     with SingleTickerProviderStateMixin {
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//   }
//
//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       duration: AppConstants.normalAnimation,
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     ));
//
//     _animationController.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final padding = ResponsiveHelper.getResponsivePadding(context);
//     final isMobile = ResponsiveHelper.isMobile(context);
//
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFF8F9FA), Color(0xFFE8F5E8)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//       ),
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(padding),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildStatisticsSection(context, isMobile),
//               // const SizedBox(height: 24),
//               // _buildDataManagementSection(context, isMobile),
//               // const SizedBox(height: 24),
//               // _buildAppInfoSection(context, isMobile),
//               const SizedBox(height: 24),
//               _buildDangerZoneSection(context, isMobile),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// بناء قسم الإحصائيات
//   Widget _buildStatisticsSection(BuildContext context, bool isMobile) {
//     final contactStats = StatisticsHelper.getContactStatistics(widget.contacts);
//     final messageStats = StatisticsHelper.getMessageStatistics(widget.messages);
//     final appStats = StatisticsHelper.getAppUsageStatistics(widget.contacts, widget.messages);
//
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 20 : 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   gradient: AppConstants.whatsappGradient,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.analytics,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       AppStrings.appStatistics,
//                       style: TextStyle(
//                         fontSize: isMobile ? 18 : 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       'حالة البيانات: ${appStats.healthStatus}',
//                       style: TextStyle(
//                         color: AppUtils.getStatusColor(appStats.healthStatus.toLowerCase()),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//
//           // شبكة الإحصائيات
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: isMobile ? 2 : 4,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             childAspectRatio: isMobile ? 1.2 : 1.5,
//             children: [
//               _buildStatCard(
//                 'جهات الاتصال',
//                 contactStats.total.toString(),
//                 Icons.contacts,
//                 AppConstants.whatsappGreen,
//               ),
//               _buildStatCard(
//                 'الرسائل المحفوظة',
//                 messageStats.total.toString(),
//                 Icons.message,
//                 AppConstants.warningOrange,
//               ),
//               _buildStatCard(
//                 'أرقام صحيحة',
//                 contactStats.validPhones.toString(),
//                 Icons.phone,
//                 AppConstants.successGreen,
//               ),
//               _buildStatCard(
//                 'متوسط طول الرسالة',
//                 '${messageStats.averageLength} حرف',
//                 Icons.text_fields,
//                 AppConstants.infoBlue,
//               ),
//             ],
//           ),
//
//           if (contactStats.total > 0 || messageStats.total > 0) ...[
//             const SizedBox(height: 20),
//             _buildHealthIndicator(appStats),
//           ],
//         ],
//       ),
//     );
//   }
//
//   /// بناء مؤشر صحة البيانات
//   Widget _buildHealthIndicator(AppUsageStatistics stats) {
//     final healthColor = AppUtils.getStatusColor(stats.healthStatus.toLowerCase());
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: healthColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: healthColor.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             AppUtils.getStatusIcon(stats.healthStatus.toLowerCase()),
//             color: healthColor,
//             size: 24,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'صحة البيانات: ${stats.dataHealth}%',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: healthColor,
//                   ),
//                 ),
//                 LinearProgressIndicator(
//                   value: stats.dataHealth / 100,
//                   backgroundColor: healthColor.withOpacity(0.2),
//                   valueColor: AlwaysStoppedAnimation<Color>(healthColor),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// بناء بطاقة إحصائية
//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color, size: 32),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // /// بناء قسم إدارة البيانات
//   // Widget _buildDataManagementSection(BuildContext context, bool isMobile) {
//   //   return Container(
//   //     padding: EdgeInsets.all(isMobile ? 20 : 24),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.1),
//   //           blurRadius: 15,
//   //           offset: const Offset(0, 5),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Row(
//   //           children: [
//   //             Container(
//   //               padding: const EdgeInsets.all(12),
//   //               decoration: BoxDecoration(
//   //                 color: AppConstants.infoBlue.withOpacity(0.2),
//   //                 borderRadius: BorderRadius.circular(12),
//   //               ),
//   //               child: Icon(
//   //                 Icons.storage,
//   //                 color: AppConstants.infoBlue,
//   //                 size: 24,
//   //               ),
//   //             ),
//   //             const SizedBox(width: 16),
//   //             Text(
//   //               AppStrings.dataManagement,
//   //               style: TextStyle(
//   //                 fontSize: isMobile ? 18 : 20,
//   //                 fontWeight: FontWeight.bold,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //         const SizedBox(height: 20),
//   //
//   //         _buildActionTile(
//   //           'تصدير جهات الاتصال',
//   //           'حفظ جهات الاتصال في ملف JSON',
//   //           Icons.upload_file,
//   //           AppConstants.successGreen,
//   //           widget.onExportContacts,
//   //           enabled: widget.contacts.isNotEmpty,
//   //         ),
//   //
//   //         _buildActionTile(
//   //           'تصدير الرسائل',
//   //           'حفظ الرسائل المحفوظة في ملف JSON',
//   //           Icons.upload_file,
//   //           AppConstants.warningOrange,
//   //           widget.onExportMessages,
//   //           enabled: widget.messages.isNotEmpty,
//   //         ),
//   //
//   //         const Divider(height: 32),
//   //
//   //         _buildActionTile(
//   //           'استيراد جهات الاتصال',
//   //           'استيراد جهات الاتصال من ملف',
//   //           Icons.download_rounded,
//   //           AppConstants.infoBlue,
//   //           widget.onImportContacts,
//   //         ),
//   //
//   //         _buildActionTile(
//   //           'استيراد الرسائل',
//   //           'استيراد الرسائل من ملف',
//   //           Icons.download_rounded,
//   //           Colors.purple,
//   //           widget.onImportMessages,
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   /// بناء عنصر إجراء
//   Widget _buildActionTile(
//       String title,
//       String subtitle,
//       IconData icon,
//       Color color,
//       VoidCallback onTap, {
//         bool enabled = true,
//       }) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
//       leading: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: enabled ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           icon,
//           color: enabled ? color : Colors.grey,
//           size: 24,
//         ),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: enabled ? Colors.black87 : Colors.grey,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           color: enabled ? Colors.grey[600] : Colors.grey[400],
//         ),
//       ),
//       trailing: Icon(
//         Icons.arrow_forward_ios,
//         size: 16,
//         color: enabled ? Colors.grey : Colors.grey[300],
//       ),
//       onTap: enabled ? onTap : null,
//     );
//   }
//
// //   /// بناء قسم معلومات التطبيق
// //   Widget _buildAppInfoSection(BuildContext context, bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.all(isMobile ? 20 : 24),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 15,
// //             offset: const Offset(0, 5),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: AppConstants.whatsappGreen.withOpacity(0.2),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: const Icon(
// //                   Icons.info,
// //                   color: AppConstants.whatsappGreen,
// //                   size: 24,
// //                 ),
// //               ),
// //               const SizedBox(width: 16),
// //               Text(
// //                 AppStrings.appInfo,
// //                 style: TextStyle(
// //                   fontSize: isMobile ? 18 : 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 20),
// //
// //           _buildInfoRow('إصدار التطبيق', AppConstants.appVersion),
// //           _buildInfoRow('رقم البناء', AppConstants.appBuildNumber),
// //           _buildInfoRow('تاريخ التطوير', '2024'),
// //           _buildInfoRow('المطور', 'فريق التطوير'),
// //           _buildInfoRow('البريد الإلكتروني', AppConstants.supportEmail),
// //
// //           const SizedBox(height: 20),
// // /// Sandly
// //           // بطاقة الشكر
// //           Container(
// //             width: double.infinity,
// //             padding: const EdgeInsets.all(20),
// //             decoration: BoxDecoration(
// //               gradient: AppConstants.whatsappGradient,
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Column(
// //               children: [
// //                 const Icon(
// //                   Icons.favorite,
// //                   color: Colors.white,
// //                   size: 32,
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   AppStrings.thankYou,
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: isMobile ? 16 : 18,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   AppStrings.appreciateYourTrust,
// //                   style: TextStyle(
// //                     color: Colors.white.withOpacity(0.9),
// //                     fontSize: isMobile ? 14 : 16,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 16),
// //
// //                 // أزرار الإجراءات
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   children: [
// //                     _buildActionButton(
// //                       'قيم التطبيق',
// //                       Icons.star,
// //                           () => _rateApp(),
// //                     ),
// //                     _buildActionButton(
// //                       'شارك التطبيق',
// //                       Icons.share,
// //                           () => _shareApp(),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
//
//   /// بناء صف معلومات
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// بناء زر إجراء صغير
//   Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 18),
//       label: Text(text),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white.withOpacity(0.2),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//     );
//   }
//
//   /// بناء المنطقة الخطرة
//   Widget _buildDangerZoneSection(BuildContext context, bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 20 : 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
//         border: Border.all(color: AppConstants.errorRed.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: AppConstants.errorRed.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppConstants.errorRed.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.warning,
//                   color: AppConstants.errorRed,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 'المنطقة الخطرة',
//                 style: TextStyle(
//                   fontSize: isMobile ? 18 : 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppConstants.errorRed,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           Text(
//             'الإجراءات التالية لا يمكن التراجع عنها. يرجى التأكد قبل المتابعة.',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           _buildDangerAction(
//             'مسح جميع البيانات',
//             'حذف جميع جهات الاتصال والرسائل نهائياً',
//             Icons.delete_forever,
//             _confirmClearAllData,
//             enabled: widget.contacts.isNotEmpty || widget.messages.isNotEmpty,
//           ),
//
//           const SizedBox(height: 12),
//
//           _buildDangerAction(
//             'إعادة تعيين التطبيق',
//             'استعادة التطبيق لحالته الأولى',
//             Icons.restore,
//             _confirmResetApp,
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// بناء إجراء خطر
//   Widget _buildDangerAction(
//       String title,
//       String subtitle,
//       IconData icon,
//       VoidCallback onTap, {
//         bool enabled = true,
//       }) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: AppConstants.errorRed.withOpacity(0.3)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: enabled ? AppConstants.errorRed : Colors.grey,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: enabled ? AppConstants.errorRed : Colors.grey,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(
//             color: enabled ? Colors.grey[600] : Colors.grey[400],
//           ),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           size: 16,
//           color: enabled ? AppConstants.errorRed : Colors.grey[300],
//         ),
//         onTap: enabled ? onTap : null,
//       ),
//     );
//   }
//
//   /// تأكيد مسح جميع البيانات
//   void _confirmClearAllData() async {
//     final confirmed = await AppUtils.showConfirmDialog(
//       context,
//       'تأكيد الحذف',
//       AppStrings.confirmClearData,
//       confirmText: 'حذف جميع البيانات',
//       isDestructive: true,
//       icon: Icons.delete_forever,
//     );
//
//     if (confirmed == true) {
//       widget.onClearAllData();
//     }
//   }
//
//   /// تأكيد إعادة تعيين التطبيق
//   void _confirmResetApp() async {
//     final confirmed = await AppUtils.showConfirmDialog(
//       context,
//       'إعادة تعيين التطبيق',
//       'هل تريد إعادة تعيين التطبيق لحالته الأولى؟ سيتم حذف جميع البيانات والإعدادات.',
//       confirmText: 'إعادة تعيين',
//       isDestructive: true,
//       icon: Icons.restore,
//     );
//
//     if (confirmed == true) {
//       // تنفيذ إعادة التعيين
//       widget.onClearAllData();
//
//       AppUtils.showCustomSnackBar(
//         context,
//         'تم إعادة تعيين التطبيق بنجاح',
//         isSuccess: true,
//       );
//     }
//   }
//
//   /// تقييم التطبيق
//   void _rateApp() {
//     AppUtils.showCustomSnackBar(
//       context,
//       'ميزة التقييم قيد التطوير',
//       isWarning: true,
//     );
//   }
//
//   /// مشاركة التطبيق
//   void _shareApp() {
//     const shareText = '''
// 🌟 اكتشف تطبيق مساعد الواتساب!
//
// 📱 التطبيق الأفضل لإدارة وإرسال الرسائل عبر الواتساب:
// • إدارة جهات الاتصال بسهولة
// • حفظ الرسائل المتكررة
// • إرسال جماعي للرسائل
// • واجهة عصرية ومتجاوبة
//
// 💚 حمل التطبيق الآن واستمتع بإرسال الرسائل بطريقة احترافية!
//     ''';
//
//     AppUtils.copyToClipboard(context, shareText);
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }

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
                AppConstants.whatsappGreen,
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
                    colors: [AppConstants.whatsappGreen, AppConstants.whatsappDarkGreen],
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
                  AppConstants.whatsappGreen.withOpacity(0.05),
                  AppConstants.whatsappGreen.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.whatsappGreen.withOpacity(0.2),
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
                        color: AppConstants.whatsappGreen,
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
                        color: AppConstants.whatsappDarkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'نسعى لتسهيل التواصل عبر الواتساب من خلال توفير أدوات ذكية ومتطورة تساعد المستخدمين على إدارة رسائلهم وجهات اتصالهم بفعالية أكبر.',
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
                        color: AppConstants.whatsappGreen,
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
                        color: AppConstants.whatsappDarkGreen,
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
                          color: AppConstants.whatsappDarkGreen,
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
                  '• التطبيق لا يرسل الرسائل تلقائيًا، بل يفتح شاشة واتساب للمستخدم لإرسالها يدويًا\n'
                  '• التطبيق لا يجري المكالمات تلقائيًا، بل يفتح شاشة الاتصال فقط.\n'
                      '• عند إلغاء تثبيت التطبيق ستفقد جميع البيانات المحفوظة\n'
                      '• جميع البيانات تُخزّن محليًا على جهاز المستخدم، ولا يتم جمع أو مشاركة أي معلومات شخصية\n'
                      '• لا نطلب أي أذونات غير ضرورية من نظام التشغيل',
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

  // Widget _buildStatCard(String title, String value, IconData icon, Color color) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: color.withOpacity(0.3)),
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(icon, color: color, size: 32),
  //         const SizedBox(height: 8),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: color,
  //           ),
  //           textAlign: TextAlign.center,
  //           maxLines: 1,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           title,
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: Colors.grey[600],
  //           ),
  //           textAlign: TextAlign.center,
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
                'التطبيق لا يجمع أي بيانات شخصية من المستخدمين. جميع المعلومات التي تدخلها (جهات الاتصال والرسائل) تبقى محفوظة محلياً على جهازك فقط.',
              ),
              _buildPolicySection(
                '2. استخدام البيانات',
                'البيانات المحفوظة تُستخدم فقط لتقديم خدمات التطبيق (حفظ جهات الاتصال والرسائل). لا نقوم بتحليل أو معالجة هذه البيانات لأي أغراض أخرى.',
              ),
              _buildPolicySection(
                '3. مشاركة البيانات',
                'لا نشارك بياناتك مع أي طرف ثالث. التطبيق يعمل بشكل مستقل ولا يرسل أي معلومات خارج جهازك.',
              ),
              _buildPolicySection(
                '4. الأمان',
                'بياناتك محمية من خلال آليات الأمان المدمجة في نظام التشغيل. ننصح بحماية جهازك برقم سري أو بصمة.',
              ),
              _buildPolicySection(
                '5. حقوقك',
                'يمكنك حذف جميع بياناتك في أي وقت من خلال إعدادات التطبيق أو بإلغاء تثبيته.',
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

  /// مشاركة التطبيق
  void _shareApp() {
    const shareText = '''
🌟 اكتشف تطبيق مساعد الواتساب! 

📱 التطبيق الأفضل لإدارة وإرسال الرسائل عبر الواتساب:
• إدارة جهات الاتصال بسهولة
• حفظ الرسائل المتكررة
• إرسال جماعي للرسائل
• واجهة عصرية ومتجاوبة
• حماية كاملة للخصوصية

💚 حمل التطبيق الآن واستمتع بإرسال الرسائل بطريقة احترافية!

🔒 أمان تام: جميع بياناتك محفوظة محلياً على جهازك
    ''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: AppConstants.infoBlue),
            SizedBox(width: 8),
            Text('مشاركة التطبيق'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تم نسخ نص المشاركة. يمكنك الآن لصقه في أي تطبيق:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                shareText,
                style: const TextStyle(fontSize: 12),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              AppUtils.copyToClipboard(context, shareText);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('نسخ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.infoBlue,
              foregroundColor: Colors.white,
            ),
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
                      'تطبيق SandlyN مصمم خصيصًا لتسهيل إرسال الرسائل من خلال WhatsApp، '
                      'وحفظ الرسائل والأرقام على الجهاز محليًا، دون إرسالها مباشرة أو جمع بيانات حساسة.',
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
                const BulletItem(text: 'لا يتم إرسال الرسائل أو إجراء المكالمات تلقائيًا من التطبيق، بل يفتح WhatsApp أو شاشة الاتصال فقط.'),
                const BulletItem(text: 'لا يتم جمع أو تخزين أي معلومات شخصية حساسة على خوادم خارجية.'),
                const BulletItem(text: 'نوفّر آلية للإبلاغ عن أي إساءة استخدام داخل التطبيق.'),
                const BulletItem(text: 'نتعاون مع السلطات المختصة إذا تم الإبلاغ عن محتوى مخالف.'),
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
