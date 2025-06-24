import 'package:flutter/material.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/app_strings.dart';
import '../../core/helpers/responsive_helper.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/contact.dart';
import '../../data/models/message.dart';
import '../widgets/common/custom_app_bar.dart';
import 'contacts/contacts_page.dart';
import 'messages/messages_page.dart';
import 'quick_send/quick_send_page.dart';
import 'bulk_send/bulk_send_page.dart';
import 'settings/settings_page.dart';

/// الصفحة الرئيسية للتطبيق
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // البيانات
  List<Contact> _contacts = [];
  List<Message> _messages = [];

  // الخدمات
  final StorageService _storageService = StorageService();
  final WhatsAppService _whatsappService = WhatsAppService();

  // حالة التحميل
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  /// تهيئة المتحكمات والرسوم المتحركة
  void _initializeControllers() {
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: AppConstants.slowAnimation,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// تحميل البيانات من التخزين المحلي
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final contacts = await _storageService.getContacts();
      final messages = await _storageService.getMessages();

      setState(() {
        _contacts = contacts;
        _messages = messages;
        _isLoading = false;
      });

      // بدء الرسم المتحرك بعد التحميل
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('فشل في تحميل البيانات: ${e.toString()}');
    }
  }

  /// إضافة جهة اتصال جديدة
  Future<void> _addContact(Contact contact) async {
    try {
      await _storageService.saveContact(contact);
      setState(() {
        _contacts.add(contact);
      });
      _showSuccessMessage(AppStrings.contactAdded);
    } catch (e) {
      _showErrorMessage('فشل في إضافة جهة الاتصال: ${e.toString()}');
    }
  }

  /// تحديث جهة اتصال
  Future<void> _updateContact(Contact contact) async {
    try {
      await _storageService.updateContact(contact);
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        setState(() {
          _contacts[index] = contact;
        });
        _showSuccessMessage(AppStrings.contactUpdated);
      }
    } catch (e) {
      _showErrorMessage('فشل في تحديث جهة الاتصال: ${e.toString()}');
    }
  }

  /// حذف جهة اتصال
  Future<void> _deleteContact(String contactId) async {
    try {
      await _storageService.deleteContact(contactId);
      setState(() {
        _contacts.removeWhere((c) => c.id == contactId);
      });
      _showSuccessMessage(AppStrings.contactDeleted);
    } catch (e) {
      _showErrorMessage('فشل في حذف جهة الاتصال: ${e.toString()}');
    }
  }

  /// إضافة رسالة جديدة
  Future<void> _addMessage(Message message) async {
    try {
      await _storageService.saveMessage(message);
      setState(() {
        _messages.add(message);
      });
      _showSuccessMessage(AppStrings.messageAdded);
    } catch (e) {
      _showErrorMessage('فشل في إضافة الرسالة: ${e.toString()}');
    }
  }

  /// تحديث رسالة
  Future<void> _updateMessage(Message message) async {
    try {
      await _storageService.updateMessage(message);
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message;
        });
        _showSuccessMessage(AppStrings.messageUpdated);
      }
    } catch (e) {
      _showErrorMessage('فشل في تحديث الرسالة: ${e.toString()}');
    }
  }

  /// حذف رسالة
  Future<void> _deleteMessage(String messageId) async {
    try {
      await _storageService.deleteMessage(messageId);
      setState(() {
        _messages.removeWhere((m) => m.id == messageId);
      });
      _showSuccessMessage(AppStrings.messageDeleted);
    } catch (e) {
      _showErrorMessage('فشل في حذف الرسالة: ${e.toString()}');
    }
  }

  /// إرسال رسالة عبر الواتساب
  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    try {
      await _whatsappService.sendMessage(phone, message);
      _showSuccessMessage(AppStrings.messageSent);
    } catch (e) {
      _showErrorMessage('فشل في إرسال الرسالة: ${e.toString()}');
    }
  }

  /// إرسال رسالة جماعية
  Future<void> _sendBulkMessage(List<Contact> contacts, String message) async {
    try {
      for (int i = 0; i < contacts.length; i++) {
        final contact = contacts[i];
        await _whatsappService.sendMessage(contact.phone, message);

        // تأخير بسيط بين الرسائل
        if (i < contacts.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      _showSuccessMessage('تم إرسال الرسالة إلى ${contacts.length} جهة اتصال');
    } catch (e) {
      _showErrorMessage('فشل في الإرسال الجماعي: ${e.toString()}');
    }
  }

  /// عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    AppUtils.showCustomSnackBar(context, message, isSuccess: true);
  }

  /// عرض رسالة خطأ
  void _showErrorMessage(String message) {
    AppUtils.showCustomSnackBar(context, message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAppHeader(),
                _buildTabBar(),
                Expanded(
                  child: _buildTabBarView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء شاشة التحميل
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(

        decoration: const BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: AppConstants.defaultPadding),
              Text(
                AppStrings.loading,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.bodyLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء رأس التطبيق
  Widget _buildAppHeader() {
    return CustomAppBar(
      title: AppStrings.appTitle,
      subtitle: AppStrings.appSubtitle,
      contactsCount: _contacts.length,
      messagesCount: _messages.length,
    );
  }

  /// بناء شريط التبويبات
  Widget _buildTabBar() {
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppConstants.whatsappGreen,
        unselectedLabelColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            AppConstants.bodySmall,
          ),
          fontWeight: FontWeight.bold,
        ),
        tabs: [
          _buildTab(Icons.send, AppStrings.quickSendTab),
          _buildTab(Icons.contacts, AppStrings.contactsTab),
          _buildTab(Icons.message, AppStrings.messagesTab),
          // _buildTab(Icons.group, AppStrings.bulkSendTab),
          _buildTab(Icons.settings, AppStrings.settingsTab),
        ],
      ),
    );
  }

  /// بناء تبويب واحد
  Widget _buildTab(IconData icon, String text) {
    final iconSize = ResponsiveHelper.getResponsiveIconSize(
      context,
      AppConstants.iconMedium,
    );

    return Tab(
      icon: Icon(icon, size: iconSize),
      text: text,
    );
  }

  /// بناء محتوى التبويبات
  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        QuickSendPage(
          messages: _messages,
          onSendMessage: _sendWhatsAppMessage,
          onUpdateMessage: _updateMessage,
        ),
        ContactsPage(
          contacts: _contacts,
          onAddContact: _addContact,
          onUpdateContact: _updateContact,
          onDeleteContact: _deleteContact,
          onSendMessage: _sendWhatsAppMessage,
        ),
        MessagesPage(
          messages: _messages,
          onAddMessage: _addMessage,
          onUpdateMessage: _updateMessage,
          onDeleteMessage: _deleteMessage,
          onSendMessage: _sendWhatsAppMessage,
          contacts: _contacts,
        ),

        // BulkSendPage(
        //   contacts: _contacts,
        //   onSendBulkMessage: _sendBulkMessage,
        // ),
        SettingsPage(
          contacts: _contacts,
          messages: _messages,
          onExportContacts: _exportContacts,
          onExportMessages: _exportMessages,
          onImportContacts: _importContacts,
          onImportMessages: _importMessages,
          onClearAllData: _clearAllData,
        ),
      ],
    );
  }

  /// تصدير جهات الاتصال
  Future<void> _exportContacts() async {
    try {
      final jsonData = Contact.toJsonList(_contacts);
      await AppUtils.copyToClipboard(context, jsonData.toString());
      _showSuccessMessage('تم نسخ بيانات جهات الاتصال إلى الحافظة');
    } catch (e) {
      _showErrorMessage('فشل في تصدير جهات الاتصال: ${e.toString()}');
    }
  }

  /// تصدير الرسائل
  Future<void> _exportMessages() async {
    try {
      final jsonData = Message.toJsonList(_messages);
      await AppUtils.copyToClipboard(context, jsonData.toString());
      _showSuccessMessage('تم نسخ بيانات الرسائل إلى الحافظة');
    } catch (e) {
      _showErrorMessage('فشل في تصدير الرسائل: ${e.toString()}');
    }
  }

  /// استيراد جهات الاتصال
  Future<void> _importContacts() async {
    _showErrorMessage('ميزة الاستيراد قيد التطوير');
  }

  /// استيراد الرسائل
  Future<void> _importMessages() async {
    _showErrorMessage('ميزة الاستيراد قيد التطوير');
  }

  /// مسح جميع البيانات
  Future<void> _clearAllData() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      'تأكيد الحذف',
      AppStrings.confirmClearData,
      confirmText: 'حذف الكل',
      isDestructive: true,
      icon: Icons.delete_forever,
    );

    if (confirmed == true) {
      try {
        await _storageService.clearAllData();
        setState(() {
          _contacts.clear();
          _messages.clear();
        });
        _showSuccessMessage(AppStrings.dataCleared);
      } catch (e) {
        _showErrorMessage('فشل في مسح البيانات: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}