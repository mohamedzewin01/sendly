/// مساعد لتنسيق والتحقق من أرقام الهواتف السعودية
class PhoneNumberFormatter {
  // أنماط أرقام الهواتف السعودية
  static final RegExp _saudiPhonePattern = RegExp(r'^\+9665\d{8}$');
  static final RegExp _localPhonePattern = RegExp(r'^05\d{8}$');
  static final RegExp _digitOnlyPattern = RegExp(r'[^\d+]');

  /// تنسيق رقم الهاتف ليكون بالصيغة الدولية السعودية
  static String format(String phone) {
    if (phone.isEmpty) return phone;

    // إزالة جميع الأحرف غير الرقمية عدا علامة +
    String clean = phone.replaceAll(_digitOnlyPattern, '');

    // إذا كان الرقم يبدأ بالرمز الدولي السعودي الكامل
    if (clean.startsWith('+966')) {
      return _formatWithCountryCode(clean);
    }
    // إذا كان يبدأ برقم 966 بدون +
    else if (clean.startsWith('966')) {
      return _formatWithCountryCode('+$clean');
    }
    // إذا كان يبدأ بـ 05 (الصيغة المحلية)
    else if (clean.startsWith('05')) {
      return '+966${clean.substring(1)}';
    }
    // إذا كان يبدأ بـ 5 مباشرة
    else if (clean.startsWith('5') && clean.length >= 9) {
      return '+966$clean';
    }
    // إضافة الرمز الدولي افتراضياً
    else if (clean.length >= 8) {
      return '+966$clean';
    }

    return phone; // إرجاع الرقم كما هو إذا لم يتطابق مع أي نمط
  }

  /// تنسيق الرقم مع التأكد من صحة رقم الدولة
  static String _formatWithCountryCode(String phone) {
    if (phone.length < 13) return phone;

    // التأكد من أن الرقم يحتوي على 13 رقم بالضبط (+966 + 9 أرقام)
    if (phone.length > 13) {
      return phone.substring(0, 13);
    }

    return phone;
  }

  /// التحقق من صحة رقم الهاتف السعودي
  static bool isValid(String phone) {
    if (phone.isEmpty) return false;

    final formatted = format(phone);
    return _saudiPhonePattern.hasMatch(formatted);
  }

  /// عرض الرقم بتنسيق جميل وقابل للقراءة
  static String display(String phone) {
    final formatted = format(phone);

    if (formatted.startsWith('+966') && formatted.length == 13) {
      // تحويل +966501234567 إلى +966 50 123 4567
      final number = formatted.substring(4); // إزالة +966
      if (number.length == 9) {
        return '+966 ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
      }
    }

    return phone;
  }

  /// الحصول على رمز الدولة من الرقم
  static String getCountryCode(String phone) {
    final formatted = format(phone);
    if (formatted.startsWith('+966')) {
      return '+966';
    }
    return '+966'; // افتراضي للسعودية
  }

  /// الحصول على الرقم المحلي بدون رمز الدولة
  static String getLocalNumber(String phone) {
    final formatted = format(phone);
    if (formatted.startsWith('+966') && formatted.length >= 8) {
      return '0${formatted.substring(4)}'; // إضافة 0 في البداية للصيغة المحلية
    }
    return phone;
  }

  /// الحصول على الرقم بالصيغة الدولية بدون رمز +
  static String getInternationalNumber(String phone) {
    final formatted = format(phone);
    if (formatted.startsWith('+')) {
      return formatted.substring(1);
    }
    return formatted;
  }

  /// التحقق من نوع شبكة الاتصال (STC, Mobily, Zain, etc.)
  static String getCarrier(String phone) {
    final formatted = format(phone);
    if (!isValid(formatted)) return 'غير معروف';

    final localNumber = formatted.substring(4); // إزالة +966
    if (localNumber.isEmpty) return 'غير معروف';

    final prefix = localNumber.substring(0, 2);

    switch (prefix) {
      case '50':
      case '53':
      case '56':
        return 'STC';
      case '51':
      case '54':
        return 'Mobily';
      case '55':
      case '58':
        return 'Zain';
      case '57':
        return 'Virgin Mobile';
      case '59':
        return 'Lebara';
      default:
        return 'أخرى';
    }
  }

  /// تنظيف الرقم من جميع التنسيقات
  static String clean(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// التحقق من تطابق رقمين
  static bool areEqual(String phone1, String phone2) {
    return format(phone1) == format(phone2);
  }

  /// تحويل الرقم إلى رابط واتساب
  static String toWhatsAppUrl(String phone, [String? message]) {
    final formatted = getInternationalNumber(phone);
    final baseUrl = 'https://wa.me/$formatted';

    if (message != null && message.isNotEmpty) {
      final encodedMessage = Uri.encodeComponent(message);
      return '$baseUrl?text=$encodedMessage';
    }

    return baseUrl;
  }

  /// قائمة بأمثلة على أرقام صحيحة
  static List<String> get validExamples => [
    '+966501234567',
    '+966551234567',
    '+966541234567',
  ];

  /// قائمة بأمثلة على أرقام خاطئة
  static List<String> get invalidExamples => [
    '123456789',
    '+1234567890',
    '0512345',
  ];

  /// الحصول على رسالة خطأ للرقم غير الصحيح
  static String getValidationError(String phone) {
    if (phone.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (clean.length < 9) {
      return 'رقم الهاتف قصير جداً';
    }

    if (clean.length > 12) {
      return 'رقم الهاتف طويل جداً';
    }

    final formatted = format(phone);
    if (!isValid(formatted)) {
      return 'رقم الهاتف غير صحيح. استخدم الصيغة: +966501234567';
    }

    return '';
  }

  /// منع إنشاء كائن من هذه الفئة
  PhoneNumberFormatter._();
}