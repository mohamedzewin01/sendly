import 'digits_formatter.dart';
import 'phone_formatter.dart';

/// رقم هاتف مستخرج من نص أو بطاقة اتصال مشاركة
class ExtractedNumber {
  const ExtractedNumber(this.phone, {this.name});

  /// الرقم بالصيغة الدولية (مثل +966501234567)
  final String phone;

  /// اسم صاحب الرقم إن كان موجوداً في بطاقة الاتصال
  final String? name;

  @override
  bool operator ==(Object other) =>
      other is ExtractedNumber && other.phone == phone && other.name == name;

  @override
  int get hashCode => Object.hash(phone, name);

  @override
  String toString() => 'ExtractedNumber($phone, $name)';
}

/// يستخرج أرقام الهواتف الصحيحة من النصوص المشاركة من تطبيقات أخرى
class PhoneExtractor {
  static final RegExp _candidate = RegExp(r'(?:\+|00)?\d[\d\s\-().]{5,}\d');
  static final RegExp _vcardTel = RegExp(
    r'^(?:[\w-]+\.)?TEL[^:]*:(.+)$',
    caseSensitive: false,
  );
  static final RegExp _vcardName = RegExp(
    r'^FN[^:]*:(.+)$',
    caseSensitive: false,
  );

  /// أرقام صحيحة داخل نص حر (رسالة، رابط، ملاحظة...)، بدون تكرار وبنفس ترتيب ظهورها
  static List<ExtractedNumber> fromText(String text) {
    final normalized = WesternDigitsFormatter.convert(text);
    final result = <ExtractedNumber>[];
    final seen = <String>{};

    for (final match in _candidate.allMatches(normalized)) {
      final formatted = _normalize(match.group(0)!);
      if (formatted != null && seen.add(formatted)) {
        result.add(ExtractedNumber(formatted));
      }
    }
    return result;
  }

  /// أرقام (مع الأسماء) من بطاقة اتصال vCard
  static List<ExtractedNumber> fromVCard(String vcard) {
    // فك الأسطر الطويلة المطوية (تبدأ بمسافة أو Tab)
    final text = vcard
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\n[ \t]'), '');

    final result = <ExtractedNumber>[];
    final seen = <String>{};
    String? name;
    var numbers = <String>[];

    void flush() {
      for (final raw in numbers) {
        final formatted = _normalize(raw);
        if (formatted != null && seen.add(formatted)) {
          result.add(ExtractedNumber(formatted, name: name));
        }
      }
      name = null;
      numbers = [];
    }

    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.toUpperCase().startsWith('BEGIN:VCARD')) {
        flush();
      } else if (_vcardName.hasMatch(trimmed)) {
        final value = _vcardName.firstMatch(trimmed)!.group(1)!.trim();
        if (value.isNotEmpty) name = value;
      } else if (_vcardTel.hasMatch(trimmed)) {
        numbers.add(_vcardTel.firstMatch(trimmed)!.group(1)!.trim());
      }
    }
    flush();
    return result;
  }

  /// يحوّل نصاً يحتمل أن يكون رقماً إلى الصيغة الدولية، أو null إن لم يكن صحيحاً
  static String? _normalize(String raw) {
    var digits = WesternDigitsFormatter.convert(
      raw,
    ).replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('00')) digits = '+${digits.substring(2)}';
    if (digits.length < 7) return null;

    final formatted = PhoneNumberFormatter.format(digits);
    return PhoneNumberFormatter.isValid(formatted) ? formatted : null;
  }

  PhoneExtractor._();
}
