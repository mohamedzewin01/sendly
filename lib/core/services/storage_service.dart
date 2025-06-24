import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/app_constants.dart';
import '../../data/models/contact.dart';
import '../../data/models/message.dart';

/// خدمة التخزين المحلي للتطبيق
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._internal();

  /// الحصول على المثيل الوحيد
  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// تهيئة الخدمة
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// الحصول على SharedPreferences
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== جهات الاتصال ====================

  /// حفظ جهة اتصال
  Future<void> saveContact(Contact contact) async {
    final prefs = await _preferences;
    final contacts = await getContacts();

    // التحقق من عدم وجود جهة اتصال بنفس المعرف
    contacts.removeWhere((c) => c.id == contact.id);
    contacts.add(contact);

    final jsonList = Contact.toJsonList(contacts);
    await prefs.setString(AppConstants.contactsKey, jsonEncode(jsonList));
  }

  /// تحديث جهة اتصال
  Future<void> updateContact(Contact contact) async {
    final contacts = await getContacts();
    final index = contacts.indexWhere((c) => c.id == contact.id);

    if (index != -1) {
      contacts[index] = contact;
      final prefs = await _preferences;
      final jsonList = Contact.toJsonList(contacts);
      await prefs.setString(AppConstants.contactsKey, jsonEncode(jsonList));
    } else {
      throw Exception('جهة الاتصال غير موجودة');
    }
  }

  /// حذف جهة اتصال
  Future<void> deleteContact(String contactId) async {
    final contacts = await getContacts();
    contacts.removeWhere((c) => c.id == contactId);

    final prefs = await _preferences;
    final jsonList = Contact.toJsonList(contacts);
    await prefs.setString(AppConstants.contactsKey, jsonEncode(jsonList));
  }

  /// الحصول على جميع جهات الاتصال
  Future<List<Contact>> getContacts() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(AppConstants.contactsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return Contact.fromJsonList(jsonList);
    } catch (e) {
      // في حالة الخطأ، إرجاع قائمة فارغة
      return [];
    }
  }

  /// الحصول على جهة اتصال بالمعرف
  Future<Contact?> getContactById(String id) async {
    final contacts = await getContacts();
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// البحث في جهات الاتصال
  Future<List<Contact>> searchContacts(String query) async {
    final contacts = await getContacts();
    if (query.isEmpty) return contacts;

    return contacts.where((contact) => contact.matches(query)).toList();
  }

  // ==================== الرسائل ====================

  /// حفظ رسالة
  Future<void> saveMessage(Message message) async {
    final prefs = await _preferences;
    final messages = await getMessages();

    // التحقق من عدم وجود رسالة بنفس المعرف
    messages.removeWhere((m) => m.id == message.id);
    messages.add(message);

    final jsonList = Message.toJsonList(messages);
    await prefs.setString(AppConstants.messagesKey, jsonEncode(jsonList));
  }

  /// تحديث رسالة
  Future<void> updateMessage(Message message) async {
    final messages = await getMessages();
    final index = messages.indexWhere((m) => m.id == message.id);

    if (index != -1) {
      messages[index] = message;
      final prefs = await _preferences;
      final jsonList = Message.toJsonList(messages);
      await prefs.setString(AppConstants.messagesKey, jsonEncode(jsonList));
    } else {
      throw Exception('الرسالة غير موجودة');
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    final messages = await getMessages();
    messages.removeWhere((m) => m.id == messageId);

    final prefs = await _preferences;
    final jsonList = Message.toJsonList(messages);
    await prefs.setString(AppConstants.messagesKey, jsonEncode(jsonList));
  }

  /// الحصول على جميع الرسائل
  Future<List<Message>> getMessages() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(AppConstants.messagesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return Message.fromJsonList(jsonList);
    } catch (e) {
      // في حالة الخطأ، إرجاع قائمة فارغة
      return [];
    }
  }

  /// الحصول على رسالة بالمعرف
  Future<Message?> getMessageById(String id) async {
    final messages = await getMessages();
    try {
      return messages.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// البحث في الرسائل
  Future<List<Message>> searchMessages(String query) async {
    final messages = await getMessages();
    if (query.isEmpty) return messages;

    return messages.where((message) => message.matches(query)).toList();
  }

  /// زيادة عداد استخدام الرسالة
  Future<void> incrementMessageUsage(String messageId) async {
    final message = await getMessageById(messageId);
    if (message != null) {
      final updatedMessage = message.incrementUsage();
      await updateMessage(updatedMessage);
    }
  }

  // ==================== الإعدادات ====================

  /// حفظ إعداد
  Future<void> setSetting(String key, dynamic value) async {
    final prefs = await _preferences;

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      // تحويل إلى JSON للأنواع المعقدة
      await prefs.setString(key, jsonEncode(value));
    }
  }

  /// الحصول على إعداد
  Future<T?> getSetting<T>(String key, [T? defaultValue]) async {
    final prefs = await _preferences;

    if (T == String) {
      return prefs.getString(key) as T? ?? defaultValue;
    } else if (T == int) {
      return prefs.getInt(key) as T? ?? defaultValue;
    } else if (T == double) {
      return prefs.getDouble(key) as T? ?? defaultValue;
    } else if (T == bool) {
      return prefs.getBool(key) as T? ?? defaultValue;
    } else if (T == List<String>) {
      return prefs.getStringList(key) as T? ?? defaultValue;
    } else {
      // محاولة فك تشفير JSON
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          return jsonDecode(jsonString) as T?;
        } catch (e) {
          return defaultValue;
        }
      }
      return defaultValue;
    }
  }

  /// حذف إعداد
  Future<void> removeSetting(String key) async {
    final prefs = await _preferences;
    await prefs.remove(key);
  }

  // ==================== البيانات العامة ====================

  /// مسح جميع البيانات
  Future<void> clearAllData() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  /// مسح جهات الاتصال فقط
  Future<void> clearContacts() async {
    final prefs = await _preferences;
    await prefs.remove(AppConstants.contactsKey);
  }

  /// مسح الرسائل فقط
  Future<void> clearMessages() async {
    final prefs = await _preferences;
    await prefs.remove(AppConstants.messagesKey);
  }

  /// الحصول على حجم البيانات المحفوظة (تقديري)
  Future<Map<String, int>> getDataSize() async {
    final prefs = await _preferences;
    final contacts = prefs.getString(AppConstants.contactsKey) ?? '';
    final messages = prefs.getString(AppConstants.messagesKey) ?? '';

    return {
      'contacts': contacts.length,
      'messages': messages.length,
      'total': contacts.length + messages.length,
    };
  }

  /// التحقق من وجود بيانات
  Future<bool> hasData() async {
    final contacts = await getContacts();
    final messages = await getMessages();
    return contacts.isNotEmpty || messages.isNotEmpty;
  }

  /// إنشاء نسخة احتياطية من جميع البيانات
  Future<Map<String, dynamic>> createBackup() async {
    final contacts = await getContacts();
    final messages = await getMessages();

    return {
      'contacts': Contact.toJsonList(contacts),
      'messages': Message.toJsonList(messages),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'version': AppConstants.appVersion,
    };
  }

  /// استعادة البيانات من نسخة احتياطية
  Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      final prefs = await _preferences;

      // استعادة جهات الاتصال
      if (backup.containsKey('contacts')) {
        final contactsJson = backup['contacts'] as List<dynamic>;
        final contacts = Contact.fromJsonList(contactsJson);
        final jsonList = Contact.toJsonList(contacts);
        await prefs.setString(AppConstants.contactsKey, jsonEncode(jsonList));
      }

      // استعادة الرسائل
      if (backup.containsKey('messages')) {
        final messagesJson = backup['messages'] as List<dynamic>;
        final messages = Message.fromJsonList(messagesJson);
        final jsonList = Message.toJsonList(messages);
        await prefs.setString(AppConstants.messagesKey, jsonEncode(jsonList));
      }
    } catch (e) {
      throw Exception('فشل في استعادة النسخة الاحتياطية: ${e.toString()}');
    }
  }

  /// الحصول على إحصائيات التخزين
  Future<Map<String, dynamic>> getStorageStats() async {
    final contacts = await getContacts();
    final messages = await getMessages();
    final dataSize = await getDataSize();

    return {
      'contactsCount': contacts.length,
      'messagesCount': messages.length,
      'validPhonesCount': contacts.where((c) => c.hasValidPhone).length,
      'totalCharacters': dataSize['total'],
      'averageMessageLength': messages.isNotEmpty
          ? messages.map((m) => m.length).reduce((a, b) => a + b) / messages.length
          : 0,
      'oldestContactDate': contacts.isNotEmpty
          ? contacts.map((c) => c.createdAt).reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      'newestContactDate': contacts.isNotEmpty
          ? contacts.map((c) => c.createdAt).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }

  /// تنظيف البيانات المتضررة
  Future<void> cleanupCorruptedData() async {
    try {
      // محاولة تحميل البيانات والتخلص من المتضررة
      final contacts = await getContacts();
      final messages = await getMessages();

      // إعادة حفظ البيانات الصحيحة فقط
      final validContacts = contacts.where((c) => c.isValid).toList();
      final validMessages = messages.where((m) => m.isValid).toList();

      final prefs = await _preferences;

      if (validContacts.length != contacts.length) {
        final jsonList = Contact.toJsonList(validContacts);
        await prefs.setString(AppConstants.contactsKey, jsonEncode(jsonList));
      }

      if (validMessages.length != messages.length) {
        final jsonList = Message.toJsonList(validMessages);
        await prefs.setString(AppConstants.messagesKey, jsonEncode(jsonList));
      }
    } catch (e) {
      // في حالة الفشل الكامل، مسح جميع البيانات
      await clearAllData();
    }
  }
}