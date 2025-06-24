import 'dart:convert';
import 'dart:ui';
import '../../core/utils/app_utils.dart';

/// تصنيفات الرسائل
enum MessageCategory {
  general('عام'),
  business('عمل'),
  personal('شخصي'),
  marketing('تسويق'),
  support('دعم فني'),
  announcement('إعلان'),
  greeting('تحية'),
  reminder('تذكير');

  const MessageCategory(this.displayName);
  final String displayName;

  static MessageCategory fromString(String value) {
    return MessageCategory.values.firstWhere(
          (category) => category.name == value,
      orElse: () => MessageCategory.general,
    );
  }
}

/// نموذج البيانات للرسالة
class Message {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final MessageCategory category;
  final int usageCount;

  const Message({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.category = MessageCategory.general,
    this.usageCount = 0,
  });

  /// إنشاء رسالة جديدة
  factory Message.create({
    required String title,
    required String content,
    List<String>? tags,
    MessageCategory category = MessageCategory.general,
  }) {
    final now = DateTime.now();
    return Message(
      id: now.millisecondsSinceEpoch.toString(),
      title: title.trim(),
      content: content.trim(),
      createdAt: now,
      tags: tags ?? [],
      category: category,
    );
  }

  /// تحويل من JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int? ??
            int.tryParse(json['id'] as String? ?? '0') ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      category: MessageCategory.fromString(
        json['category'] as String? ?? 'general',
      ),
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'tags': tags,
      'category': category.name,
      'usageCount': usageCount,
    };
  }

  /// تحويل إلى String JSON
  String toJsonString() => jsonEncode(toJson());

  /// إنشاء من String JSON
  factory Message.fromJsonString(String jsonString) {
    return Message.fromJson(jsonDecode(jsonString));
  }

  /// إنشاء نسخة محدثة
  Message copyWith({
    String? title,
    String? content,
    List<String>? tags,
    MessageCategory? category,
    int? usageCount,
  }) {
    return Message(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tags: tags ?? this.tags,
      category: category ?? this.category,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  /// زيادة عداد الاستخدام
  Message incrementUsage() {
    return copyWith(usageCount: usageCount + 1);
  }

  /// طول المحتوى
  int get length => content.length;

  /// مدة القراءة المقدرة
  Duration get estimatedReadingTime => AppUtils.estimateReadingTime(content);

  /// التحقق من كون المحتوى عربي
  bool get isArabic => AppUtils.isArabicText(content);

  /// اتجاه النص
  TextDirection get textDirection => AppUtils.getTextDirection(content);

  /// معاينة مختصرة للمحتوى
  String preview([int maxLength = 100]) {
    return AppUtils.truncateText(content, maxLength);
  }

  /// التحقق من وجود تاجات
  bool get hasTags => tags.isNotEmpty;

  /// البحث في البيانات
  bool matches(String query) {
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        content.toLowerCase().contains(lowerQuery) ||
        category.displayName.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  /// التحقق من المساواة
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message(id: $id, title: $title, length: $length)';
  }

  /// التحقق من صحة البيانات
  List<String> validate() {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('عنوان الرسالة مطلوب');
    } else if (title.trim().length < 3) {
      errors.add('عنوان الرسالة قصير جداً');
    } else if (title.length > 100) {
      errors.add('عنوان الرسالة طويل جداً');
    }

    if (content.trim().isEmpty) {
      errors.add('محتوى الرسالة مطلوب');
    } else if (content.trim().length < 10) {
      errors.add('محتوى الرسالة قصير جداً');
    } else if (content.length > 4096) {
      errors.add('محتوى الرسالة طويل جداً');
    }

    return errors;
  }

  /// التحقق من صحة البيانات
  bool get isValid => validate().isEmpty;

  /// عدد الكلمات
  int get wordCount {
    return content.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  /// عدد الأسطر
  int get lineCount {
    return content.split('\n').length;
  }

  /// تصنيف تلقائي للرسالة بناءً على المحتوى
  MessageCategory get suggestedCategory {
    final lowerContent = content.toLowerCase();
    final lowerTitle = title.toLowerCase();

    // كلمات مفتاحية للتصنيف
    final businessKeywords = ['شركة', 'عمل', 'مشروع', 'اجتماع', 'موظف', 'راتب', 'وظيفة'];
    final marketingKeywords = ['عرض', 'خصم', 'تسويق', 'منتج', 'بيع', 'شراء', 'إعلان'];
    final supportKeywords = ['مساعدة', 'دعم', 'مشكلة', 'حل', 'استفسار', 'خدمة'];
    final greetingKeywords = ['مرحبا', 'أهلا', 'صباح', 'مساء', 'تحية', 'سلام'];
    final reminderKeywords = ['تذكير', 'موعد', 'اجتماع', 'مهمة', 'ميعاد'];

    final allText = '$lowerTitle $lowerContent';

    if (businessKeywords.any((keyword) => allText.contains(keyword))) {
      return MessageCategory.business;
    } else if (marketingKeywords.any((keyword) => allText.contains(keyword))) {
      return MessageCategory.marketing;
    } else if (supportKeywords.any((keyword) => allText.contains(keyword))) {
      return MessageCategory.support;
    } else if (greetingKeywords.any((keyword) => allText.contains(keyword))) {
      return MessageCategory.greeting;
    } else if (reminderKeywords.any((keyword) => allText.contains(keyword))) {
      return MessageCategory.reminder;
    }

    return MessageCategory.general;
  }

  /// تحويل إلى تنسيق Markdown
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln();
    buffer.writeln(content);

    if (hasTags) {
      buffer.writeln();
      buffer.writeln('**التاجات:** ${tags.join(', ')}');
    }

    buffer.writeln();
    buffer.writeln('**التصنيف:** ${category.displayName}');
    buffer.writeln('**تاريخ الإنشاء:** ${AppUtils.formatDateTime(createdAt)}');
    buffer.writeln('**عدد مرات الاستخدام:** $usageCount');

    return buffer.toString();
  }

  /// إنشاء قائمة من JSON Array
  static List<Message> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// تحويل قائمة إلى JSON Array
  static List<Map<String, dynamic>> toJsonList(List<Message> messages) {
    return messages.map((message) => message.toJson()).toList();
  }

  /// ترتيب القائمة أبجدياً
  static List<Message> sortAlphabetically(List<Message> messages) {
    final sorted = List<Message>.from(messages);
    sorted.sort((a, b) => a.title.compareTo(b.title));
    return sorted;
  }

  /// ترتيب القائمة حسب تاريخ الإنشاء
  static List<Message> sortByDate(List<Message> messages, {bool ascending = true}) {
    final sorted = List<Message>.from(messages);
    if (ascending) {
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  /// ترتيب حسب عدد مرات الاستخدام
  static List<Message> sortByUsage(List<Message> messages, {bool ascending = false}) {
    final sorted = List<Message>.from(messages);
    if (ascending) {
      sorted.sort((a, b) => a.usageCount.compareTo(b.usageCount));
    } else {
      sorted.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    }
    return sorted;
  }

  /// ترتيب حسب طول المحتوى
  static List<Message> sortByLength(List<Message> messages, {bool ascending = true}) {
    final sorted = List<Message>.from(messages);
    if (ascending) {
      sorted.sort((a, b) => a.length.compareTo(b.length));
    } else {
      sorted.sort((a, b) => b.length.compareTo(a.length));
    }
    return sorted;
  }

  /// تصفية حسب التصنيف
  static List<Message> filterByCategory(List<Message> messages, MessageCategory category) {
    return messages.where((message) => message.category == category).toList();
  }

  /// تصفية حسب التاج
  static List<Message> filterByTag(List<Message> messages, String tag) {
    return messages.where((message) => message.tags.contains(tag)).toList();
  }

  /// الحصول على أكثر الرسائل استخداماً
  static List<Message> getMostUsed(List<Message> messages, {int limit = 10}) {
    final sorted = sortByUsage(messages);
    return sorted.take(limit).toList();
  }

  /// الحصول على الرسائل الحديثة
  static List<Message> getRecent(List<Message> messages, {int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return messages.where((message) => message.createdAt.isAfter(cutoffDate)).toList();
  }

  /// الحصول على جميع التاجات المستخدمة
  static Set<String> getAllTags(List<Message> messages) {
    final allTags = <String>{};
    for (final message in messages) {
      allTags.addAll(message.tags);
    }
    return allTags;
  }

  /// الحصول على إحصائيات التصنيفات
  static Map<MessageCategory, int> getCategoryStats(List<Message> messages) {
    final stats = <MessageCategory, int>{};
    for (final category in MessageCategory.values) {
      stats[category] = messages.where((m) => m.category == category).length;
    }
    return stats;
  }
}