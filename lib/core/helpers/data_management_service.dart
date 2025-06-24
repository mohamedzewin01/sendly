// import 'dart:convert';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
//
// class DataManagementService {
//   // تصدير جهات الاتصال بتنسيق قابل للاستيراد
//   static Future<bool> exportContacts(List<Contact> contacts) async {
//     try {
//       if (contacts.isEmpty) {
//         throw Exception('لا توجد جهات اتصال للتصدير');
//       }
//
//       // إنشاء بنية البيانات للتصدير
//       final exportData = {
//         'app_name': 'WhatsApp Helper',
//         'export_version': '1.0.0',
//         'export_date': DateTime.now().toIso8601String(),
//         'data_type': 'contacts',
//         'total_count': contacts.length,
//         'contacts': contacts.map((contact) => {
//           'id': contact.id,
//           'name': contact.name,
//           'phone': contact.phone,
//           'created_at': contact.createdAt.toIso8601String(),
//           'updated_at': contact.updatedAt?.toIso8601String(),
//           'note': contact.note ?? '',
//           'tags': contact.tags,
//           'is_valid': contact.isValid,
//           'has_valid_phone': contact.hasValidPhone,
//           'display_phone': contact.displayPhone,
//           'carrier': contact.carrier,
//         }).toList(),
//       };
//
//       // تحويل البيانات إلى JSON منسق
//       final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
//
//       // إنشاء اسم الملف مع التاريخ
//       final timestamp = DateTime.now().toIso8601String().split('T')[0];
//       final fileName = 'contacts_backup_$timestamp.json';
//
//       // حفظ الملف
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');
//       await file.writeAsString(jsonString, encoding: utf8);
//
//       // مشاركة الملف
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'نسخة احتياطية من جهات الاتصال - ${contacts.length} جهة اتصال',
//         subject: 'تصدير جهات الاتصال - $timestamp',
//       );
//
//       return true;
//     } catch (e) {
//       print('خطأ في تصدير جهات الاتصال: $e');
//       return false;
//     }
//   }
//
//   // تصدير الرسائل بتنسيق قابل للاستيراد
//   static Future<bool> exportMessages(List<Message> messages) async {
//     try {
//       if (messages.isEmpty) {
//         throw Exception('لا توجد رسائل للتصدير');
//       }
//
//       // إنشاء بنية البيانات للتصدير
//       final exportData = {
//         'app_name': 'WhatsApp Helper',
//         'export_version': '1.0.0',
//         'export_date': DateTime.now().toIso8601String(),
//         'data_type': 'messages',
//         'total_count': messages.length,
//         'messages': messages.map((message) => {
//           'id': message.id,
//           'title': message.title,
//           'content': message.content,
//           'category': message.category.name,
//           'category_display': message.category.displayName,
//           'usage_count': message.usageCount,
//           'created_at': message.createdAt.toIso8601String(),
//           'updated_at': message.updatedAt?.toIso8601String(),
//           'tags': message.tags,
//           'length': message.length,
//           'word_count': message.wordCount,
//           'line_count': message.lineCount,
//           'is_arabic': message.isArabic,
//           'suggested_category': message.suggestedCategory.name,
//         }).toList(),
//       };
//
//       // تحويل البيانات إلى JSON منسق
//       final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
//
//       // إنشاء اسم الملف مع التاريخ
//       final timestamp = DateTime.now().toIso8601String().split('T')[0];
//       final fileName = 'messages_backup_$timestamp.json';
//
//       // حفظ الملف
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');
//       await file.writeAsString(jsonString, encoding: utf8);
//
//       // مشاركة الملف
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'نسخة احتياطية من الرسائل - ${messages.length} رسالة',
//         subject: 'تصدير الرسائل - $timestamp',
//       );
//
//       return true;
//     } catch (e) {
//       print('خطأ في تصدير الرسائل: $e');
//       return false;
//     }
//   }
//
//   // استيراد جهات الاتصال مع التحقق من التنسيق
//   static Future<ImportResult<Contact>> importContacts() async {
//     try {
//       // اختيار الملف
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//         dialogTitle: 'اختر ملف جهات الاتصال',
//       );
//
//       if (result == null || result.files.single.path == null) {
//         return ImportResult.cancelled();
//       }
//
//       // قراءة الملف
//       final file = File(result.files.single.path!);
//       final jsonString = await file.readAsString(encoding: utf8);
//
//       // تحليل JSON
//       final Map<String, dynamic> jsonData = jsonDecode(jsonString);
//
//       // التحقق من صحة التنسيق
//       final validation = _validateImportData(jsonData, 'contacts');
//       if (!validation.isValid) {
//         return ImportResult.error(validation.errorMessage!);
//       }
//
//       // استخراج جهات الاتصال
//       final List<dynamic> contactsData = jsonData['contacts'] as List<dynamic>;
//       final List<Contact> contacts = [];
//       final List<String> errors = [];
//
//       for (int i = 0; i < contactsData.length; i++) {
//         try {
//           final contactData = contactsData[i] as Map<String, dynamic>;
//           final contact = Contact(
//             id: contactData['id'] as String,
//             name: contactData['name'] as String,
//             phone: contactData['phone'] as String,
//             createdAt: contactData['created_at'] != null
//                 ? DateTime.parse(contactData['created_at'] as String)
//                 : DateTime.now(),
//             updatedAt: contactData['updated_at'] != null
//                 ? DateTime.parse(contactData['updated_at'] as String)
//                 : null,
//             note: contactData['note'] as String?,
//             tags: (contactData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
//           );
//           contacts.add(contact);
//         } catch (e) {
//           errors.add('خطأ في جهة الاتصال رقم ${i + 1}: ${e.toString()}');
//         }
//       }
//
//       return ImportResult.success(
//         data: contacts,
//         totalCount: contactsData.length,
//         successCount: contacts.length,
//         errorCount: errors.length,
//         errors: errors,
//         metadata: {
//           'export_date': jsonData['export_date'],
//           'app_version': jsonData['export_version'],
//         },
//       );
//
//     } catch (e) {
//       return ImportResult.error('خطأ في قراءة الملف: ${e.toString()}');
//     }
//   }
//
//   // استيراد الرسائل مع التحقق من التنسيق
//   static Future<ImportResult<Message>> importMessages() async {
//     try {
//       // اختيار الملف
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//         dialogTitle: 'اختر ملف الرسائل',
//       );
//
//       if (result == null || result.files.single.path == null) {
//         return ImportResult.cancelled();
//       }
//
//       // قراءة الملف
//       final file = File(result.files.single.path!);
//       final jsonString = await file.readAsString(encoding: utf8);
//
//       // تحليل JSON
//       final Map<String, dynamic> jsonData = jsonDecode(jsonString);
//
//       // التحقق من صحة التنسيق
//       final validation = _validateImportData(jsonData, 'messages');
//       if (!validation.isValid) {
//         return ImportResult.error(validation.errorMessage!);
//       }
//
//       // استخراج الرسائل
//       final List<dynamic> messagesData = jsonData['messages'] as List<dynamic>;
//       final List<Message> messages = [];
//       final List<String> errors = [];
//
//       for (int i = 0; i < messagesData.length; i++) {
//         try {
//           final messageData = messagesData[i] as Map<String, dynamic>;
//           final message = Message(
//             id: messageData['id'] as String,
//             title: messageData['title'] as String,
//             content: messageData['content'] as String,
//             category: MessageCategory.fromString(messageData['category'] as String? ?? 'general'),
//             usageCount: messageData['usage_count'] as int? ?? 0,
//             createdAt: messageData['created_at'] != null
//                 ? DateTime.parse(messageData['created_at'] as String)
//                 : DateTime.now(),
//             updatedAt: messageData['updated_at'] != null
//                 ? DateTime.parse(messageData['updated_at'] as String)
//                 : null,
//             tags: (messageData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
//           );
//           messages.add(message);
//         } catch (e) {
//           errors.add('خطأ في الرسالة رقم ${i + 1}: ${e.toString()}');
//         }
//       }
//
//       return ImportResult.success(
//         data: messages,
//         totalCount: messagesData.length,
//         successCount: messages.length,
//         errorCount: errors.length,
//         errors: errors,
//         metadata: {
//           'export_date': jsonData['export_date'],
//           'app_version': jsonData['export_version'],
//         },
//       );
//
//     } catch (e) {
//       return ImportResult.error('خطأ في قراءة الملف: ${e.toString()}');
//     }
//   }
//
//   // التحقق من صحة بيانات الاستيراد
//   static ValidationResult _validateImportData(Map<String, dynamic> data, String expectedType) {
//     try {
//       // التحقق من الحقول الأساسية
//       if (!data.containsKey('app_name') || data['app_name'] != 'WhatsApp Helper') {
//         return ValidationResult.invalid('الملف ليس من تطبيق مساعد الواتساب');
//       }
//
//       if (!data.containsKey('data_type') || data['data_type'] != expectedType) {
//         return ValidationResult.invalid('نوع البيانات غير صحيح. متوقع: $expectedType');
//       }
//
//       if (!data.containsKey('export_version')) {
//         return ValidationResult.invalid('إصدار التصدير غير محدد');
//       }
//
//       // التحقق من وجود البيانات
//       final dataKey = expectedType;
//       if (!data.containsKey(dataKey) || data[dataKey] is! List) {
//         return ValidationResult.invalid('البيانات غير موجودة أو بتنسيق خاطئ');
//       }
//
//       final List<dynamic> items = data[dataKey] as List<dynamic>;
//       if (items.isEmpty) {
//         return ValidationResult.invalid('الملف لا يحتوي على أي بيانات');
//       }
//
//       // التحقق من تطابق العدد
//       final expectedCount = data['total_count'] as int?;
//       if (expectedCount != null && expectedCount != items.length) {
//         return ValidationResult.warning(
//             'عدد العناصر لا يطابق العدد المتوقع. متوقع: $expectedCount، موجود: ${items.length}'
//         );
//       }
//
//       return ValidationResult.valid();
//     } catch (e) {
//       return ValidationResult.invalid('خطأ في التحقق من صحة الملف: ${e.toString()}');
//     }
//   }
//
//   // إنشاء نسخة احتياطية كاملة
//   static Future<bool> createFullBackup(List<Contact> contacts, List<Message> messages) async {
//     try {
//       // إنشاء بنية البيانات الكاملة
//       final backupData = {
//         'app_name': 'WhatsApp Helper',
//         'backup_version': '1.0.0',
//         'backup_date': DateTime.now().toIso8601String(),
//         'data_types': ['contacts', 'messages'],
//         'statistics': {
//           'total_contacts': contacts.length,
//           'total_messages': messages.length,
//           'valid_phones': contacts.where((c) => c.hasValidPhone).length,
//           'categories_used': Message.getCategoryStats(messages).keys.length,
//           'total_tags': {...Contact.getAllTags(contacts), ...Message.getAllTags(messages)}.length,
//         },
//         'contacts': contacts.map((contact) => {
//           'id': contact.id,
//           'name': contact.name,
//           'phone': contact.phone,
//           'created_at': contact.createdAt.toIso8601String(),
//           'updated_at': contact.updatedAt?.toIso8601String(),
//           'note': contact.note ?? '',
//           'tags': contact.tags,
//           'is_valid': contact.isValid,
//           'has_valid_phone': contact.hasValidPhone,
//           'display_phone': contact.displayPhone,
//           'carrier': contact.carrier,
//         }).toList(),
//         'messages': messages.map((message) => {
//           'id': message.id,
//           'title': message.title,
//           'content': message.content,
//           'category': message.category.name,
//           'category_display': message.category.displayName,
//           'usage_count': message.usageCount,
//           'created_at': message.createdAt.toIso8601String(),
//           'updated_at': message.updatedAt?.toIso8601String(),
//           'tags': message.tags,
//           'length': message.length,
//           'word_count': message.wordCount,
//           'line_count': message.lineCount,
//           'is_arabic': message.isArabic,
//           'suggested_category': message.suggestedCategory.name,
//         }).toList(),
//       };
//
//       // تحويل البيانات إلى JSON منسق
//       final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
//
//       // إنشاء اسم الملف مع التاريخ
//       final timestamp = DateTime.now().toIso8601String().split('T')[0];
//       final fileName = 'whatsapp_helper_full_backup_$timestamp.json';
//
//       // حفظ الملف
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');
//       await file.writeAsString(jsonString, encoding: utf8);
//
//       // مشاركة الملف
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'نسخة احتياطية كاملة - ${contacts.length} جهة اتصال، ${messages.length} رسالة',
//         subject: 'النسخة الاحتياطية الكاملة - $timestamp',
//       );
//
//       return true;
//     } catch (e) {
//       print('خطأ في إنشاء النسخة الاحتياطية: $e');
//       return false;
//     }
//   }
//
//   // استيراد نسخة احتياطية كاملة مع كشف التعارضات
//   static Future<ImportResult<dynamic>> importFullBackup(
//       List<Contact> existingContacts,
//       List<Message> existingMessages,
//       ) async {
//     try {
//       // اختيار الملف
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['json'],
//         dialogTitle: 'اختر ملف النسخة الاحتياطية الكاملة',
//       );
//
//       if (result == null || result.files.single.path == null) {
//         return ImportResult.cancelled();
//       }
//
//       // قراءة الملف
//       final file = File(result.files.single.path!);
//       final jsonString = await file.readAsString(encoding: utf8);
//
//       // تحليل JSON
//       final Map<String, dynamic> jsonData = jsonDecode(jsonString);
//
//       // التحقق من صحة التنسيق
//       if (!jsonData.containsKey('contacts') || !jsonData.containsKey('messages')) {
//         return ImportResult.error('ملف النسخة الاحتياطية غير صحيح');
//       }
//
//       // استيراد جهات الاتصال
//       final contactsResult = await _importContactsFromData(
//         jsonData['contacts'] as List<dynamic>,
//         existingContacts,
//       );
//
//       // استيراد الرسائل
//       final messagesResult = await _importMessagesFromData(
//         jsonData['messages'] as List<dynamic>,
//         existingMessages,
//       );
//
//       // دمج النتائج
//       final combinedData = {
//         'contacts': contactsResult.data ?? [],
//         'messages': messagesResult.data ?? [],
//         'contacts_conflicts': contactsResult.conflicts ?? [],
//         'messages_conflicts': messagesResult.conflicts ?? [],
//       };
//
//       return ImportResult.success(
//         data: combinedData,
//         totalCount: (contactsResult.totalCount) + (messagesResult.totalCount),
//         successCount: (contactsResult.successCount) + (messagesResult.successCount),
//         errorCount: (contactsResult.errorCount) + (messagesResult.errorCount),
//         errors: [...contactsResult.errors, ...messagesResult.errors],
//         metadata: {
//           'backup_date': jsonData['backup_date'],
//           'backup_version': jsonData['backup_version'],
//           'contacts_imported': contactsResult.successCount,
//           'messages_imported': messagesResult.successCount,
//           'total_conflicts': (contactsResult.conflicts?.length ?? 0) + (messagesResult.conflicts?.length ?? 0),
//         },
//       );
//
//     } catch (e) {
//       return ImportResult.error('خطأ في استيراد النسخة الاحتياطية: ${e.toString()}');
//     }
//   }
//
//   // دالة مساعدة لاستيراد جهات الاتصال مع كشف التعارضات
//   static Future<ConflictImportResult<Contact>> _importContactsFromData(
//       List<dynamic> contactsData,
//       List<Contact> existingContacts,
//       ) async {
//     final contacts = <Contact>[];
//     final conflicts = <DataConflict<Contact>>[];
//     final errors = <String>[];
//
//     for (int i = 0; i < contactsData.length; i++) {
//       try {
//         final contactData = contactsData[i] as Map<String, dynamic>;
//         final newContact = Contact(
//           id: contactData['id'] as String,
//           name: contactData['name'] as String,
//           phone: contactData['phone'] as String,
//           createdAt: contactData['created_at'] != null
//               ? DateTime.parse(contactData['created_at'] as String)
//               : DateTime.now(),
//           updatedAt: contactData['updated_at'] != null
//               ? DateTime.parse(contactData['updated_at'] as String)
//               : null,
//           note: contactData['note'] as String?,
//           tags: (contactData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
//         );
//
//         // البحث عن تعارضات
//         final existingContact = existingContacts.firstWhere(
//               (c) => c.id == newContact.id || c.phone == newContact.phone,
//           orElse: () => null as Contact,
//         );
//
//         if (existingContact != null) {
//           conflicts.add(DataConflict<Contact>(
//             existing: existingContact,
//             imported: newContact,
//             conflictType: existingContact.id == newContact.id
//                 ? ConflictType.duplicateId
//                 : ConflictType.duplicatePhone,
//           ));
//         } else {
//           contacts.add(newContact);
//         }
//       } catch (e) {
//         errors.add('خطأ في جهة الاتصال رقم ${i + 1}: ${e.toString()}');
//       }
//     }
//
//     return ConflictImportResult<Contact>(
//       data: contacts,
//       conflicts: conflicts,
//       totalCount: contactsData.length,
//       successCount: contacts.length,
//       errorCount: errors.length,
//       errors: errors,
//     );
//   }
//
//   // دالة مساعدة لاستيراد الرسائل مع كشف التعارضات
//   static Future<ConflictImportResult<Message>> _importMessagesFromData(
//       List<dynamic> messagesData,
//       List<Message> existingMessages,
//       ) async {
//     final messages = <Message>[];
//     final conflicts = <DataConflict<Message>>[];
//     final errors = <String>[];
//
//     for (int i = 0; i < messagesData.length; i++) {
//       try {
//         final messageData = messagesData[i] as Map<String, dynamic>;
//         final newMessage = Message(
//           id: messageData['id'] as String,
//           title: messageData['title'] as String,
//           content: messageData['content'] as String,
//           category: MessageCategory.fromString(messageData['category'] as String? ?? 'general'),
//           usageCount: messageData['usage_count'] as int? ?? 0,
//           createdAt: messageData['created_at'] != null
//               ? DateTime.parse(messageData['created_at'] as String)
//               : DateTime.now(),
//           updatedAt: messageData['updated_at'] != null
//               ? DateTime.parse(messageData['updated_at'] as String)
//               : null,
//           tags: (messageData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
//         );
//
//         // البحث عن تعارضات
//         final existingMessage = existingMessages.firstWhere(
//               (m) => m.id == newMessage.id || m.title == newMessage.title,
//           orElse: () => null as Message,
//         );
//
//         if (existingMessage != null) {
//           conflicts.add(DataConflict<Message>(
//             existing: existingMessage,
//             imported: newMessage,
//             conflictType: existingMessage.id == newMessage.id
//                 ? ConflictType.duplicateId
//                 : ConflictType.duplicateTitle,
//           ));
//         } else {
//           messages.add(newMessage);
//         }
//       } catch (e) {
//         errors.add('خطأ في الرسالة رقم ${i + 1}: ${e.toString()}');
//       }
//     }
//
//     return ConflictImportResult<Message>(
//       data: messages,
//       conflicts: conflicts,
//       totalCount: messagesData.length,
//       successCount: messages.length,
//       errorCount: errors.length,
//       errors: errors,
//     );
//   }
//
//   // إضافة دالة للتحقق من سلامة الملف قبل الاستيراد
//   static Future<FileValidationResult> validateImportFile(String filePath) async {
//     try {
//       final file = File(filePath);
//       final fileSize = await file.length();
//
//       // التحقق من حجم الملف (حد أقصى 50 ميجابايت)
//       if (fileSize > 50 * 1024 * 1024) {
//         return FileValidationResult.invalid('حجم الملف كبير جداً (أكثر من 50 ميجابايت)');
//       }
//
//       // قراءة الملف
//       final content = await file.readAsString(encoding: utf8);
//
//       // التحقق من صحة JSON
//       final Map<String, dynamic> jsonData = jsonDecode(content);
//
//       // التحقق من البنية الأساسية
//       if (!jsonData.containsKey('app_name') || jsonData['app_name'] != 'WhatsApp Helper') {
//         return FileValidationResult.invalid('الملف ليس من تطبيق مساعد الواتساب');
//       }
//
//       // إحصائيات الملف
//       final stats = {
//         'file_size': fileSize,
//         'export_date': jsonData['export_date'] ?? jsonData['backup_date'],
//         'export_version': jsonData['export_version'] ?? jsonData['backup_version'],
//         'data_type': jsonData['data_type'] ?? 'backup',
//         'contacts_count': 0,
//         'messages_count': 0,
//       };
//
//       if (jsonData.containsKey('contacts')) {
//         stats['contacts_count'] = (jsonData['contacts'] as List).length;
//       }
//
//       if (jsonData.containsKey('messages')) {
//         stats['messages_count'] = (jsonData['messages'] as List).length;
//       }
//
//       return FileValidationResult.valid(stats);
//
//     } catch (e) {
//       return FileValidationResult.invalid('خطأ في قراءة الملف: ${e.toString()}');
//     }
//   }
//
//   // دالة لإنشاء تقرير مفصل عن البيانات
//   static String generateDataReport(List<Contact> contacts, List<Message> messages) {
//     final buffer = StringBuffer();
//     final now = DateTime.now();
//
//     buffer.writeln('# تقرير البيانات - ${_formatReportDate(now)}');
//     buffer.writeln();
//
//     // إحصائيات عامة
//     buffer.writeln('## الإحصائيات العامة');
//     buffer.writeln('- **إجمالي جهات الاتصال:** ${contacts.length}');
//     buffer.writeln('- **إجمالي الرسائل:** ${messages.length}');
//     buffer.writeln('- **الأرقام الصحيحة:** ${contacts.where((c) => c.hasValidPhone).length}');
//     buffer.writeln('- **متوسط طول الرسائل:** ${messages.isEmpty ? 0 : messages.map((m) => m.length).reduce((a, b) => a + b) ~/ messages.length} حرف');
//     buffer.writeln();
//
//     // إحصائيات جهات الاتصال
//     if (contacts.isNotEmpty) {
//       buffer.writeln('## تفاصيل جهات الاتصال');
//
//       // التوزيع حسب شركات الاتصالات
//       final carrierStats = <String, int>{};
//       for (final contact in contacts) {
//         final carrier = contact.carrier;
//         carrierStats[carrier] = (carrierStats[carrier] ?? 0) + 1;
//       }
//
//       buffer.writeln('### التوزيع حسب شركات الاتصالات:');
//       carrierStats.entries.forEach((entry) {
//         buffer.writeln('- **${entry.key}:** ${entry.value}');
//       });
//       buffer.writeln();
//
//       // جهات الاتصال الحديثة
//       final recentContacts = contacts.where((c) =>
//           c.createdAt.isAfter(now.subtract(const Duration(days: 30)))
//       ).toList();
//       buffer.writeln('### جهات الاتصال الحديثة (آخر 30 يوم): ${recentContacts.length}');
//       buffer.writeln();
//     }
//
//     // إحصائيات الرسائل
//     if (messages.isNotEmpty) {
//       buffer.writeln('## تفاصيل الرسائل');
//
//       // التوزيع حسب التصنيفات
//       final categoryStats = Message.getCategoryStats(messages);
//       buffer.writeln('### التوزيع حسب التصنيفات:');
//       categoryStats.entries.forEach((entry) {
//         if (entry.value > 0) {
//           buffer.writeln('- **${entry.key.displayName}:** ${entry.value}');
//         }
//       });
//       buffer.writeln();
//
//       // أكثر الرسائل استخداماً
//       final mostUsed = Message.getMostUsed(messages, limit: 5);
//       if (mostUsed.isNotEmpty) {
//         buffer.writeln('### أكثر الرسائل استخداماً:');
//         mostUsed.forEach((message) {
//           buffer.writeln('- **${message.title}:** ${message.usageCount} مرة');
//         });
//         buffer.writeln();
//       }
//
//       // الرسائل الحديثة
//       final recentMessages = Message.getRecent(messages, days: 30);
//       buffer.writeln('### الرسائل الحديثة (آخر 30 يوم): ${recentMessages.length}');
//       buffer.writeln();
//     }
//
//     // التاجات المستخدمة
//     final allContactTags = getAllContactTags(contacts);
//     final allMessageTags = Message.getAllTags(messages);
//     final allTags = {...allContactTags, ...allMessageTags};
//
//     if (allTags.isNotEmpty) {
//       buffer.writeln('## التاجات المستخدمة');
//       buffer.writeln('- **إجمالي التاجات:** ${allTags.length}');
//       buffer.writeln('- **التاجات:** ${allTags.join(', ')}');
//       buffer.writeln();
//     }
//
//     // معلومات التقرير
//     buffer.writeln('---');
//     buffer.writeln('*تم إنشاء هذا التقرير بواسطة تطبيق مساعد الواتساب*');
//     buffer.writeln('*التاريخ: ${_formatReportDate(now)}*');
//
//     return buffer.toString();
//   }
//
//   // تنسيق التاريخ للتقرير
//   static String _formatReportDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }
//
//   // إنشاء وتصدير تقرير البيانات
//   static Future<bool> exportDataReport(List<Contact> contacts, List<Message> messages) async {
//     try {
//       final reportContent = generateDataReport(contacts, messages);
//       final timestamp = DateTime.now().toIso8601String().split('T')[0];
//       final fileName = 'data_report_$timestamp.md';
//
//       // حفظ الملف
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/$fileName');
//       await file.writeAsString(reportContent, encoding: utf8);
//
//       // مشاركة الملف
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'تقرير البيانات - ${contacts.length} جهة اتصال، ${messages.length} رسالة',
//         subject: 'تقرير البيانات - $timestamp',
//       );
//
//       return true;
//     } catch (e) {
//       print('خطأ في إنشاء التقرير: $e');
//       return false;
//     }
//   }
//
//   // إضافة دالة مساعدة للحصول على جميع التاجات من جهات الاتصال
//   static Set<String> getAllContactTags(List<Contact> contacts) {
//     final allTags = <String>{};
//     for (final contact in contacts) {
//       allTags.addAll(contact.tags);
//     }
//     return allTags;
//   }
// }
//
// // كلاس لنتيجة التحقق من صحة الملف
// class FileValidationResult {
//   final bool isValid;
//   final String? errorMessage;
//   final Map<String, dynamic>? fileStats;
//
//   FileValidationResult({
//     required this.isValid,
//     this.errorMessage,
//     this.fileStats,
//   });
//
//   factory FileValidationResult.valid(Map<String, dynamic> stats) {
//     return FileValidationResult(isValid: true, fileStats: stats);
//   }
//
//   factory FileValidationResult.invalid(String message) {
//     return FileValidationResult(isValid: false, errorMessage: message);
//   }
// }
// try {
// // إنشاء بنية البيانات الكاملة
// final backupData = {
// 'app_name': 'WhatsApp Helper',
// 'backup_version': '1.0.0',
// 'backup_date': DateTime.now().toIso8601String(),
// 'data_types': ['contacts', 'messages'],
// 'statistics': {
// 'total_contacts': contacts.length,
// 'total_messages': messages.length,
// },
// 'contacts': contacts.map((contact) => {
// 'id': contact.id,
// 'name': contact.name,
// 'phone': contact.phone,
// 'created_at': contact.createdAt.toIso8601String(),
// 'updated_at': contact.updatedAt?.toIso8601String(),
// 'note': contact.note ?? '',
// 'tags': contact.tags,
// 'is_valid': contact.isValid,
// 'has_valid_phone': contact.hasValidPhone,
// 'display_phone': contact.displayPhone,
// 'carrier': contact.carrier,
// }).toList(),
// 'messages': messages.map((message) => {
// 'id': message.id,
// 'title': message.title,
// 'content': message.content,
// 'category': message.category.name,
// 'category_display': message.category.displayName,
// 'usage_count': message.usageCount,
// 'created_at': message.createdAt.toIso8601String(),
// 'updated_at': message.updatedAt?.toIso8601String(),
// 'tags': message.tags,
// 'length': message.length,
// 'word_count': message.wordCount,
// 'line_count': message.lineCount,
// 'is_arabic': message.isArabic,
// 'suggested_category': message.suggestedCategory.name,
// }).toList(),
// };
//
// // تحويل البيانات إلى JSON منسق
// final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
//
// // إنشاء اسم الملف مع التاريخ
// final timestamp = DateTime.now().toIso8601String().split('T')[0];
// final fileName = 'whatsapp_helper_full_backup_$timestamp.json';
//
// // حفظ الملف
// final directory = await getApplicationDocumentsDirectory();
// final file = File('${directory.path}/$fileName');
// await file.writeAsString(jsonString, encoding: utf8);
//
// // مشاركة الملف
// await Share.shareXFiles(
// [XFile(file.path)],
// text: 'نسخة احتياطية كاملة - ${contacts.length} جهة اتصال، ${messages.length} رسالة',
// subject: 'النسخة الاحتياطية الكاملة - $timestamp',
// );
//
// return true;
// } catch (e) {
// print('خطأ في إنشاء النسخة الاحتياطية: $e');
// return false;
// }
// }
// }
//
// // كلاس لنتيجة الاستيراد
// class ImportResult<T> {
// final bool isSuccess;
// final bool isCancelled;
// final String? errorMessage;
// final List<T>? data;
// final int totalCount;
// final int successCount;
// final int errorCount;
// final List<String> errors;
// final Map<String, dynamic>? metadata;
// final List<DataConflict<T>>? conflicts;
//
// ImportResult({
// required this.isSuccess,
// this.isCancelled = false,
// this.errorMessage,
// this.data,
// this.totalCount = 0,
// this.successCount = 0,
// this.errorCount = 0,
// this.errors = const [],
// this.metadata,
// this.conflicts,
// });
//
// factory ImportResult.success({
// required data,
// required int totalCount,
// required int successCount,
// required int errorCount,
// List<String> errors = const [],
// Map<String, dynamic>? metadata,
// List<DataConflict<T>>? conflicts,
// }) {
// return ImportResult<T>(
// isSuccess: true,
// data: data is List<T> ? data : null,
// totalCount: totalCount,
// successCount: successCount,
// errorCount: errorCount,
// errors: errors,
// metadata: metadata,
// conflicts: conflicts,
// );
// }
//
// factory ImportResult.error(String message) {
// return ImportResult<T>(
// isSuccess: false,
// errorMessage: message,
// );
// }
//
// factory ImportResult.cancelled() {
// return ImportResult<T>(
// isSuccess: false,
// isCancelled: true,
// );
// }
//
// bool get hasConflicts => conflicts != null && conflicts!.isNotEmpty;
// }
//
// // كلاس للتعامل مع التعارضات في الاستيراد
// class ConflictImportResult<T> {
// final List<T>? data;
// final List<DataConflict<T>>? conflicts;
// final int totalCount;
// final int successCount;
// final int errorCount;
// final List<String> errors;
//
// ConflictImportResult({
// this.data,
// this.conflicts,
// this.totalCount = 0,
// this.successCount = 0,
// this.errorCount = 0,
// this.errors = const [],
// });
// }
//
// // تصنيف أنواع التعارضات
// enum ConflictType {
// duplicateId,
// duplicatePhone,
// duplicateTitle,
// duplicateContent,
// }
//
// // كلاس لتمثيل تعارض في البيانات
// class DataConflict<T> {
// final T existing;
// final T imported;
// final ConflictType conflictType;
//
// DataConflict({
// required this.existing,
// required this.imported,
// required this.conflictType,
// });
//
// String get conflictDescription {
// switch (conflictType) {
// case ConflictType.duplicateId:
// return 'معرف مكرر';
// case ConflictType.duplicatePhone:
// return 'رقم هاتف مكرر';
// case ConflictType.duplicateTitle:
// return 'عنوان مكرر';
// case ConflictType.duplicateContent:
// return 'محتوى مكرر';
// }
// }
// }
//
// // كلاس لنتيجة التحقق
// class ValidationResult {
// final bool isValid;
// final bool isWarning;
// final String? errorMessage;
//
// ValidationResult({
// required this.isValid,
// this.isWarning = false,
// this.errorMessage,
// });
//
// factory ValidationResult.valid() {
// return ValidationResult(isValid: true);
// }
//
// factory ValidationResult.invalid(String message) {
// return ValidationResult(isValid: false, errorMessage: message);
// }
//
// factory ValidationResult.warning(String message) {
// return ValidationResult(isValid: true, isWarning: true, errorMessage: message);
// }
// }