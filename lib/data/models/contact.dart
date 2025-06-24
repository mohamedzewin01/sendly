import 'dart:convert';
import '../../core/helpers/phone_formatter.dart';

/// نموذج البيانات لجهة الاتصال
class Contact {
  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? note;
  final List<String> tags;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
    this.updatedAt,
    this.note,
    this.tags = const [],
  });

  /// إنشاء جهة اتصال جديدة
  factory Contact.create({
    required String name,
    required String phone,
    String? note,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return Contact(
      id: now.millisecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: PhoneNumberFormatter.format(phone),
      createdAt: now,
      note: note?.trim(),
      tags: tags ?? [],
    );
  }

  /// تحويل من JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int? ??
            int.tryParse(json['id'] as String? ?? '0') ??
            DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      note: json['note'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'note': note,
      'tags': tags,
    };
  }

  /// تحويل إلى String JSON
  String toJsonString() => jsonEncode(toJson());

  /// إنشاء من String JSON
  factory Contact.fromJsonString(String jsonString) {
    return Contact.fromJson(jsonDecode(jsonString));
  }

  /// إنشاء نسخة محدثة
  Contact copyWith({
    String? name,
    String? phone,
    String? note,
    List<String>? tags,
  }) {
    return Contact(
      id: id,
      name: name ?? this.name,
      phone: phone != null ? PhoneNumberFormatter.format(phone) : this.phone,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  /// التحقق من صحة الرقم
  bool get hasValidPhone => PhoneNumberFormatter.isValid(phone);

  /// الحصول على الرقم منسق للعرض
  String get displayPhone => PhoneNumberFormatter.display(phone);

  /// الحصول على الرقم المحلي
  String get localPhone => PhoneNumberFormatter.getLocalNumber(phone);

  /// الحصول على شركة الاتصالات
  String get carrier => PhoneNumberFormatter.getCarrier(phone);

  /// الحصول على أول حرف من الاسم
  String get initials {
    if (name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// التحقق من وجود ملاحظة
  bool get hasNote => note != null && note!.isNotEmpty;

  /// التحقق من وجود تاجات
  bool get hasTags => tags.isNotEmpty;

  /// البحث في البيانات
  bool matches(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        phone.contains(query) ||
        displayPhone.contains(query) ||
        (note?.toLowerCase().contains(lowerQuery) ?? false) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  /// التحقق من المساواة
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, phone: $phone)';
  }

  /// تحويل إلى vCard format
  String toVCard() {
    final vcard = StringBuffer();
    vcard.writeln('BEGIN:VCARD');
    vcard.writeln('VERSION:3.0');
    vcard.writeln('FN:$name');
    vcard.writeln('TEL;TYPE=CELL:$phone');
    if (hasNote) {
      vcard.writeln('NOTE:$note');
    }
    vcard.writeln('END:VCARD');
    return vcard.toString();
  }

  /// إنشاء من vCard
  static Contact? fromVCard(String vcard) {
    try {
      final lines = vcard.split('\n');
      String? name;
      String? phone;
      String? note;

      for (final line in lines) {
        if (line.startsWith('FN:')) {
          name = line.substring(3).trim();
        } else if (line.startsWith('TEL')) {
          phone = line.split(':').last.trim();
        } else if (line.startsWith('NOTE:')) {
          note = line.substring(5).trim();
        }
      }

      if (name != null && phone != null) {
        return Contact.create(name: name, phone: phone, note: note);
      }
    } catch (e) {
      // تجاهل الأخطاء
    }
    return null;
  }

  /// إنشاء رابط الواتساب
  String createWhatsAppUrl([String? message]) {
    return PhoneNumberFormatter.toWhatsAppUrl(phone, message);
  }

  /// التحقق من صحة البيانات
  List<String> validate() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('الاسم مطلوب');
    } else if (name.trim().length < 2) {
      errors.add('الاسم قصير جداً');
    } else if (name.length > 50) {
      errors.add('الاسم طويل جداً');
    }

    if (phone.isEmpty) {
      errors.add('رقم الهاتف مطلوب');
    } else if (!hasValidPhone) {
      errors.add(PhoneNumberFormatter.getValidationError(phone));
    }

    if (note != null && note!.length > 500) {
      errors.add('الملاحظة طويلة جداً');
    }

    return errors;
  }

  /// التحقق من صحة البيانات
  bool get isValid => validate().isEmpty;

  /// إنشاء قائمة من JSON Array
  static List<Contact> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Contact.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// تحويل قائمة إلى JSON Array
  static List<Map<String, dynamic>> toJsonList(List<Contact> contacts) {
    return contacts.map((contact) => contact.toJson()).toList();
  }

  /// ترتيب القائمة أبجدياً
  static List<Contact> sortAlphabetically(List<Contact> contacts) {
    final sorted = List<Contact>.from(contacts);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// ترتيب القائمة حسب تاريخ الإنشاء
  static List<Contact> sortByDate(List<Contact> contacts, {bool ascending = true}) {
    final sorted = List<Contact>.from(contacts);
    if (ascending) {
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  /// تصفية حسب شركة الاتصالات
  static List<Contact> filterByCarrier(List<Contact> contacts, String carrier) {
    return contacts.where((contact) => contact.carrier == carrier).toList();
  }

  /// تصفية الأرقام الصحيحة فقط
  static List<Contact> filterValidPhones(List<Contact> contacts) {
    return contacts.where((contact) => contact.hasValidPhone).toList();
  }
}