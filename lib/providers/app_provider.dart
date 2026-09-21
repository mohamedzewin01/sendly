import 'package:flutter/material.dart';

import '../app/constants/app_constants.dart';
import '../core/helpers/phone_extractor.dart';
import '../core/services/messaging_service.dart';
import '../core/services/storage_service.dart';
import '../data/models/contact.dart';
import '../data/models/message.dart';

/// مصدر الحالة الوحيد للتطبيق: جهات الاتصال، الرسائل، الإعدادات، والإرسال.
class AppController extends ChangeNotifier {
  AppController({StorageService? storage, MessagingService? messaging})
    : _storage = storage ?? StorageService(),
      _messaging = messaging ?? MessagingService();

  final StorageService _storage;
  final MessagingService _messaging;

  List<Contact> _contacts = [];
  List<Message> _messages = [];
  bool _isLoading = true;
  ThemeMode _themeMode = ThemeMode.system;

  List<Contact> get contacts => _contacts;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;

  // ==================== التحميل ====================

  Future<void> load() async {
    try {
      _contacts = await _storage.getContacts();
      _messages = await _storage.getMessages();
      _themeMode = _parseThemeMode(
        await _storage.getSetting<String>(AppConstants.themeKey),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== جهات الاتصال ====================

  Future<void> addContact(Contact contact) async {
    await _storage.saveContact(contact);
    _contacts = [..._contacts, contact];
    notifyListeners();
  }

  Future<void> updateContact(Contact contact) async {
    await _storage.updateContact(contact);
    _contacts = [for (final c in _contacts) c.id == contact.id ? contact : c];
    notifyListeners();
  }

  /// يحذف جهة الاتصال ويرجعها لإتاحة التراجع.
  /// تُحدَّث القائمة فوراً (قبل الحفظ) حتى يختفي العنصر من الشاشة بلا تأخير.
  Future<Contact?> deleteContact(String id) async {
    final removed = _contacts.where((c) => c.id == id).firstOrNull;
    _contacts = _contacts.where((c) => c.id != id).toList();
    notifyListeners();
    await _storage.deleteContact(id);
    return removed;
  }

  // ==================== الرسائل ====================

  Future<void> addMessage(Message message) async {
    await _storage.saveMessage(message);
    _messages = [..._messages, message];
    notifyListeners();
  }

  Future<void> updateMessage(Message message) async {
    await _storage.updateMessage(message);
    _messages = [for (final m in _messages) m.id == message.id ? message : m];
    notifyListeners();
  }

  /// يحذف الرسالة ويرجعها لإتاحة التراجع (تُحدَّث القائمة فوراً قبل الحفظ)
  Future<Message?> deleteMessage(String id) async {
    final removed = _messages.where((m) => m.id == id).firstOrNull;
    _messages = _messages.where((m) => m.id != id).toList();
    notifyListeners();
    await _storage.deleteMessage(id);
    return removed;
  }

  /// يزيد عداد استخدام الرسالة (عند الإرسال أو النسخ)
  Future<void> recordMessageUsage(String messageId) async {
    final message = _messages.where((m) => m.id == messageId).firstOrNull;
    if (message == null) return;
    await updateMessage(message.incrementUsage());
  }

  // ==================== الإرسال ====================

  /// يفتح تطبيق المراسلة المختار للرقم والرسالة، ويرمي [MessagingException] عند الفشل
  Future<void> send({
    required String phone,
    required String message,
    String? templateId,
  }) async {
    final opened = await _messaging.openMessagingApp(phone, message);
    if (!opened) {
      throw const MessagingException('تعذّر فتح تطبيق المراسلة المحدد');
    }

    if (templateId != null) {
      await recordMessageUsage(templateId);
    }
  }

  // ==================== رقم مشارك من تطبيق آخر ====================

  ExtractedNumber? _incoming;

  /// يسجّل رقماً وصل من تطبيق آخر لتضعه صفحة الإرسال في خانة الرقم
  void receiveIncoming(ExtractedNumber number) {
    _incoming = number;
    notifyListeners();
  }

  /// يسلّم الرقم المشارك مرة واحدة فقط ثم يمسحه
  ExtractedNumber? takeIncoming() {
    final number = _incoming;
    _incoming = null;
    return number;
  }

  // ==================== الإعدادات ====================

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.setSetting(AppConstants.themeKey, mode.name);
  }

  Future<void> clearAll() async {
    await _storage.clearAllData();
    _contacts = [];
    _messages = [];
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  static ThemeMode _parseThemeMode(String? value) {
    return ThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}

/// يوفّر [AppController] لكل الشاشات
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  /// يقرأ الحالة ويعيد بناء الويدجت عند تغيّرها
  static AppController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }

  /// يقرأ الحالة بدون الاشتراك في التغييرات (للأوامر داخل الـ callbacks)
  static AppController read(BuildContext context) {
    return context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
  }
}
