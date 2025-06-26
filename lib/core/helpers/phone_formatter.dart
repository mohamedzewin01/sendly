// /// مساعد لتنسيق والتحقق من أرقام الهواتف السعودية
// class PhoneNumberFormatter {
//   // أنماط أرقام الهواتف السعودية
//   static final RegExp _saudiPhonePattern = RegExp(r'^\+9665\d{8}$');
//   static final RegExp _localPhonePattern = RegExp(r'^05\d{8}$');
//   static final RegExp _digitOnlyPattern = RegExp(r'[^\d+]');
//
//   /// تنسيق رقم الهاتف ليكون بالصيغة الدولية السعودية
//   static String format(String phone) {
//     if (phone.isEmpty) return phone;
//
//     // إزالة جميع الأحرف غير الرقمية عدا علامة +
//     String clean = phone.replaceAll(_digitOnlyPattern, '');
//
//     // إذا كان الرقم يبدأ بالرمز الدولي السعودي الكامل
//     if (clean.startsWith('+966')) {
//       return _formatWithCountryCode(clean);
//     }
//     // إذا كان يبدأ برقم 966 بدون +
//     else if (clean.startsWith('966')) {
//       return _formatWithCountryCode('+$clean');
//     }
//     // إذا كان يبدأ بـ 05 (الصيغة المحلية)
//     else if (clean.startsWith('05')) {
//       return '+966${clean.substring(1)}';
//     }
//     // إذا كان يبدأ بـ 5 مباشرة
//     else if (clean.startsWith('5') && clean.length >= 9) {
//       return '+966$clean';
//     }
//     // إضافة الرمز الدولي افتراضياً
//     else if (clean.length >= 8) {
//       return '+966$clean';
//     }
//
//     return phone; // إرجاع الرقم كما هو إذا لم يتطابق مع أي نمط
//   }
//
//   /// تنسيق الرقم مع التأكد من صحة رقم الدولة
//   static String _formatWithCountryCode(String phone) {
//     if (phone.length < 13) return phone;
//
//     // التأكد من أن الرقم يحتوي على 13 رقم بالضبط (+966 + 9 أرقام)
//     if (phone.length > 13) {
//       return phone.substring(0, 13);
//     }
//
//     return phone;
//   }
//
//   /// التحقق من صحة رقم الهاتف السعودي
//   static bool isValid(String phone) {
//     if (phone.isEmpty) return false;
//
//     final formatted = format(phone);
//     return _saudiPhonePattern.hasMatch(formatted);
//   }
//
//   /// عرض الرقم بتنسيق جميل وقابل للقراءة
//   static String display(String phone) {
//     final formatted = format(phone);
//
//     if (formatted.startsWith('+966') && formatted.length == 13) {
//       // تحويل +966501234567 إلى +966 50 123 4567
//       final number = formatted.substring(4); // إزالة +966
//       if (number.length == 9) {
//         return '+966 ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
//       }
//     }
//
//     return phone;
//   }
//
//   /// الحصول على رمز الدولة من الرقم
//   static String getCountryCode(String phone) {
//     final formatted = format(phone);
//     if (formatted.startsWith('+966')) {
//       return '+966';
//     }
//     return '+966'; // افتراضي للسعودية
//   }
//
//   /// الحصول على الرقم المحلي بدون رمز الدولة
//   static String getLocalNumber(String phone) {
//     final formatted = format(phone);
//     if (formatted.startsWith('+966') && formatted.length >= 8) {
//       return '0${formatted.substring(4)}'; // إضافة 0 في البداية للصيغة المحلية
//     }
//     return phone;
//   }
//
//   /// الحصول على الرقم بالصيغة الدولية بدون رمز +
//   static String getInternationalNumber(String phone) {
//     final formatted = format(phone);
//     if (formatted.startsWith('+')) {
//       return formatted.substring(1);
//     }
//     return formatted;
//   }
//
//   /// التحقق من نوع شبكة الاتصال (STC, Mobily, Zain, etc.)
//   static String getCarrier(String phone) {
//     final formatted = format(phone);
//     if (!isValid(formatted)) return 'غير معروف';
//
//     final localNumber = formatted.substring(4); // إزالة +966
//     if (localNumber.isEmpty) return 'غير معروف';
//
//     final prefix = localNumber.substring(0, 2);
//
//   //   switch (prefix) {
//   //     case '50':
//   //     case '53':
//   //     case '56':
//   //       return 'STC';
//   //     case '51':
//   //     case '54':
//   //       return 'Mobily';
//   //     case '55':
//   //     case '58':
//   //       return 'Zain';
//   //     case '57':
//   //       return 'Virgin Mobile';
//   //     case '59':
//   //       return 'Lebara';
//   //     default:
//   //       return 'أخرى';
//   //   }
//   // }
//     switch (prefix) {
//     // السعودية
//       case '50':
//       case '53':
//       case '56':
//         return 'STC';
//       case '51':
//       case '54':
//         return 'Mobily';
//       case '55':
//       case '58':
//         return 'Zain';
//       case '57':
//         return 'Virgin Mobile';
//       case '59':
//         return 'Lebara';
//
//     // مصر
//       case '10':
//       case '12':
//         return 'Vodafone Egypt';
//       case '11':
//         return 'Orange Egypt';
//       case '15':
//         return 'Etisalat Egypt';
//       case '14':
//         return 'WE';
//
//       default:
//         return 'أخرى';
//     }
//   }
//
//   /// تنظيف الرقم من جميع التنسيقات
//   static String clean(String phone) {
//     return phone.replaceAll(RegExp(r'[^\d]'), '');
//   }
//
//   /// التحقق من تطابق رقمين
//   static bool areEqual(String phone1, String phone2) {
//     return format(phone1) == format(phone2);
//   }
//
//   /// تحويل الرقم إلى رابط واتساب
//   static String toWhatsAppUrl(String phone, [String? message]) {
//     final formatted = getInternationalNumber(phone);
//     final baseUrl = 'https://wa.me/$formatted';
//
//     if (message != null && message.isNotEmpty) {
//       final encodedMessage = Uri.encodeComponent(message);
//       return '$baseUrl?text=$encodedMessage';
//     }
//
//     return baseUrl;
//   }
//
//   /// قائمة بأمثلة على أرقام صحيحة
//   static List<String> get validExamples => [
//     '+966501234567',
//     '+966551234567',
//     '+966541234567',
//   ];
//
//   /// قائمة بأمثلة على أرقام خاطئة
//   static List<String> get invalidExamples => [
//     '123456789',
//     '+1234567890',
//     '0512345',
//   ];
//
//   /// الحصول على رسالة خطأ للرقم غير الصحيح
//   static String getValidationError(String phone) {
//     if (phone.isEmpty) {
//       return 'رقم الهاتف مطلوب';
//     }
//
//     final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
//
//     if (clean.length < 9) {
//       return 'رقم الهاتف قصير جداً';
//     }
//
//     if (clean.length > 12) {
//       return 'رقم الهاتف طويل جداً';
//     }
//
//     final formatted = format(phone);
//     if (!isValid(formatted)) {
//       return 'رقم الهاتف غير صحيح. استخدم الصيغة: +966501234567';
//     }
//
//     return '';
//   }
//
//   /// منع إنشاء كائن من هذه الفئة
//   PhoneNumberFormatter._();
// }
/// مساعد لتنسيق والتحقق من أرقام الهواتف الدولية
// class PhoneNumberFormatter {
//   // خريطة رموز الدول مع أطوال أرقامها المتوقعة
//   static final Map<String, Map<String, dynamic>> _countryCodes = {
//     // الدول العربية
//     '+966': {'name': 'السعودية', 'length': [9], 'localPrefix': '0'},
//     '+971': {'name': 'الإمارات', 'length': [9], 'localPrefix': '0'},
//     '+968': {'name': 'عُمان', 'length': [8], 'localPrefix': '0'},
//     '+965': {'name': 'الكويت', 'length': [8], 'localPrefix': '0'},
//     '+973': {'name': 'البحرين', 'length': [8], 'localPrefix': '0'},
//     '+974': {'name': 'قطر', 'length': [8], 'localPrefix': '0'},
//     '+20': {'name': 'مصر', 'length': [10], 'localPrefix': '0'},
//     '+962': {'name': 'الأردن', 'length': [9], 'localPrefix': '0'},
//     '+961': {'name': 'لبنان', 'length': [8], 'localPrefix': '0'},
//     '+963': {'name': 'سوريا', 'length': [9], 'localPrefix': '0'},
//     '+964': {'name': 'العراق', 'length': [10], 'localPrefix': '0'},
//     '+967': {'name': 'اليمن', 'length': [9], 'localPrefix': '0'},
//     '+212': {'name': 'المغرب', 'length': [9], 'localPrefix': '0'},
//     '+213': {'name': 'الجزائر', 'length': [9], 'localPrefix': '0'},
//     '+216': {'name': 'تونس', 'length': [8], 'localPrefix': '0'},
//     '+218': {'name': 'ليبيا', 'length': [9], 'localPrefix': '0'},
//     '+249': {'name': 'السودان', 'length': [9], 'localPrefix': '0'},
//
//     // الدول الأوروبية والعالمية
//     '+1': {'name': 'أمريكا/كندا', 'length': [10], 'localPrefix': ''},
//     '+44': {'name': 'بريطانيا', 'length': [10, 11], 'localPrefix': '0'},
//     '+33': {'name': 'فرنسا', 'length': [9], 'localPrefix': '0'},
//     '+49': {'name': 'ألمانيا', 'length': [10, 11], 'localPrefix': '0'},
//     '+39': {'name': 'إيطاليا', 'length': [9, 10], 'localPrefix': '0'},
//     '+34': {'name': 'إسبانيا', 'length': [9], 'localPrefix': '0'},
//     '+7': {'name': 'روسيا', 'length': [10], 'localPrefix': '8'},
//     '+86': {'name': 'الصين', 'length': [11], 'localPrefix': '0'},
//     '+81': {'name': 'اليابان', 'length': [10, 11], 'localPrefix': '0'},
//     '+82': {'name': 'كوريا الجنوبية', 'length': [10, 11], 'localPrefix': '0'},
//     '+91': {'name': 'الهند', 'length': [10], 'localPrefix': '0'},
//     '+92': {'name': 'باكستان', 'length': [10], 'localPrefix': '0'},
//     '+98': {'name': 'إيران', 'length': [10], 'localPrefix': '0'},
//     '+90': {'name': 'تركيا', 'length': [10], 'localPrefix': '0'},
//     '+60': {'name': 'ماليزيا', 'length': [9, 10], 'localPrefix': '0'},
//     '+65': {'name': 'سنغافورة', 'length': [8], 'localPrefix': '0'},
//     '+852': {'name': 'هونغ كونغ', 'length': [8], 'localPrefix': '0'},
//     '+61': {'name': 'أستراليا', 'length': [9], 'localPrefix': '0'},
//     '+64': {'name': 'نيوزيلندا', 'length': [8, 9], 'localPrefix': '0'},
//   };
//
//   // مقدمات شركات الاتصال في السعودية
//   static final Map<String, String> _saudiCarriers = {
//     '50': 'STC', '53': 'STC', '56': 'STC',
//     '51': 'Mobily', '54': 'Mobily',
//     '55': 'Zain', '58': 'Zain',
//     '57': 'Virgin Mobile',
//     '59': 'Lebara',
//   };
//
//   // مقدمات شركات الاتصال في مصر
//   static final Map<String, String> _egyptCarriers = {
//     '10': 'Vodafone Egypt', '12': 'Vodafone Egypt',
//     '11': 'Orange Egypt',
//     '15': 'Etisalat Egypt',
//     '14': 'WE',
//   };
//
//   // مقدمات شركات الاتصال في الإمارات
//   static final Map<String, String> _uaeCarriers = {
//     '50': 'Etisalat', '52': 'Etisalat', '55': 'Etisalat', '56': 'Etisalat',
//     '54': 'du', '58': 'du',
//   };
//
//   static final RegExp _digitOnlyPattern = RegExp(r'[^\d+]');
//   static final RegExp _validPhonePattern = RegExp(r'^\+\d{7,15}$');
//
//   /// تنسيق رقم الهاتف ليكون بالصيغة الدولية
//   static String format(String phone) {
//     if (phone.isEmpty) return phone;
//
//     // إزالة جميع الأحرف غير الرقمية عدا علامة +
//     String clean = phone.replaceAll(_digitOnlyPattern, '');
//
//     // إذا كان الرقم يحتوي على + في البداية
//     if (clean.startsWith('+')) {
//       return _validateAndFormat(clean);
//     }
//
//     // إذا كان الرقم يبدأ برقم دولة بدون +
//     for (String countryCode in _countryCodes.keys) {
//       String codeWithoutPlus = countryCode.substring(1);
//       if (clean.startsWith(codeWithoutPlus)) {
//         return _validateAndFormat('+$clean');
//       }
//     }
//
//     // محاولة اكتشاف الدولة بناءً على الرقم المحلي (افتراضي للسعودية)
//     if (clean.startsWith('05') && clean.length == 10) {
//       return '+966${clean.substring(1)}';
//     }
//
//     if (clean.startsWith('5') && clean.length == 9) {
//       return '+966$clean';
//     }
//
//     // إذا لم يتم التعرف على نمط محدد، نضع رمز السعودية افتراضياً
//     if (clean.length >= 8 && clean.length <= 12) {
//       return '+966$clean';
//     }
//
//     return phone; // إرجاع الرقم كما هو إذا لم يتطابق مع أي نمط
//   }
//
//   /// التحقق من صحة وتنسيق الرقم
//   static String _validateAndFormat(String phone) {
//     if (!_validPhonePattern.hasMatch(phone)) {
//       return phone;
//     }
//
//     // البحث عن رمز الدولة المناسب
//     for (String countryCode in _countryCodes.keys) {
//       if (phone.startsWith(countryCode)) {
//         String number = phone.substring(countryCode.length);
//         List<int> validLengths = List<int>.from(_countryCodes[countryCode]!['length']);
//
//         if (validLengths.contains(number.length)) {
//           return phone;
//         }
//       }
//     }
//
//     return phone;
//   }
//
//   /// التحقق من صحة رقم الهاتف
//   static bool isValid(String phone) {
//     if (phone.isEmpty) return false;
//
//     final formatted = format(phone);
//
//     // التحقق من النمط العام
//     if (!_validPhonePattern.hasMatch(formatted)) {
//       return false;
//     }
//
//     // التحقق من رمز الدولة والطول
//     for (String countryCode in _countryCodes.keys) {
//       if (formatted.startsWith(countryCode)) {
//         String number = formatted.substring(countryCode.length);
//         List<int> validLengths = List<int>.from(_countryCodes[countryCode]!['length']);
//         return validLengths.contains(number.length);
//       }
//     }
//
//     return false;
//   }
//
//   /// عرض الرقم بتنسيق جميل وقابل للقراءة
//   static String display(String phone) {
//     final formatted = format(phone);
//
//     for (String countryCode in _countryCodes.keys) {
//       if (formatted.startsWith(countryCode)) {
//         String number = formatted.substring(countryCode.length);
//
//         // تنسيق خاص للسعودية
//         if (countryCode == '+966' && number.length == 9) {
//           return '$countryCode ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
//         }
//
//         // تنسيق عام للدول الأخرى
//         if (number.length >= 8) {
//           int mid = number.length ~/ 2;
//           return '$countryCode ${number.substring(0, mid)} ${number.substring(mid)}';
//         }
//
//         return '$countryCode $number';
//       }
//     }
//
//     return formatted;
//   }
//
//   /// الحصول على رمز الدولة من الرقم
//   static String getCountryCode(String phone) {
//     final formatted = format(phone);
//
//     for (String countryCode in _countryCodes.keys) {
//       if (formatted.startsWith(countryCode)) {
//         return countryCode;
//       }
//     }
//
//     return '+966'; // افتراضي للسعودية
//   }
//
//   /// الحصول على اسم الدولة
//   static String getCountryName(String phone) {
//     final countryCode = getCountryCode(phone);
//     return _countryCodes[countryCode]?['name'] ?? 'غير معروف';
//   }
//
//   /// الحصول على الرقم المحلي بدون رمز الدولة
//   static String getLocalNumber(String phone) {
//     final formatted = format(phone);
//
//     for (String countryCode in _countryCodes.keys) {
//       if (formatted.startsWith(countryCode)) {
//         String localPrefix = _countryCodes[countryCode]!['localPrefix'];
//         String number = formatted.substring(countryCode.length);
//
//         if (localPrefix.isNotEmpty) {
//           return '$localPrefix$number';
//         }
//         return number;
//       }
//     }
//
//     return phone;
//   }
//
//   /// الحصول على الرقم بالصيغة الدولية بدون رمز +
//   static String getInternationalNumber(String phone) {
//     final formatted = format(phone);
//     if (formatted.startsWith('+')) {
//       return formatted.substring(1);
//     }
//     return formatted;
//   }
//
//   /// التحقق من نوع شبكة الاتصال
//   static String getCarrier(String phone) {
//     final formatted = format(phone);
//     if (!isValid(formatted)) return 'غير معروف';
//
//     final countryCode = getCountryCode(formatted);
//     final number = formatted.substring(countryCode.length);
//
//     if (number.length < 2) return 'غير معروف';
//
//     final prefix = number.substring(0, 2);
//
//     switch (countryCode) {
//       case '+966': // السعودية
//         return _saudiCarriers[prefix] ?? 'أخرى';
//       case '+20': // مصر
//         return _egyptCarriers[prefix] ?? 'أخرى';
//       case '+971': // الإمارات
//         return _uaeCarriers[prefix] ?? 'أخرى';
//       default:
//         return 'غير محدد';
//     }
//   }
//
//   /// تنظيف الرقم من جميع التنسيقات
//   static String clean(String phone) {
//     return phone.replaceAll(RegExp(r'[^\d]'), '');
//   }
//
//   /// التحقق من تطابق رقمين
//   static bool areEqual(String phone1, String phone2) {
//     return format(phone1) == format(phone2);
//   }
//
//   /// تحويل الرقم إلى رابط واتساب
//   static String toWhatsAppUrl(String phone, [String? message]) {
//     final formatted = getInternationalNumber(phone);
//     final baseUrl = 'https://wa.me/$formatted';
//
//     if (message != null && message.isNotEmpty) {
//       final encodedMessage = Uri.encodeComponent(message);
//       return '$baseUrl?text=$encodedMessage';
//     }
//
//     return baseUrl;
//   }
//
//   /// تحويل الرقم إلى رابط اتصال
//   static String toCallUrl(String phone) {
//     return 'tel:${format(phone)}';
//   }
//
//   /// قائمة بأمثلة على أرقام صحيحة من دول مختلفة
//   static List<String> get validExamples => [
//     '+966501234567', // السعودية
//     '+971501234567', // الإمارات
//     '+201012345678', // مصر
//     '+14155552671',  // أمريكا
//     '+447911123456', // بريطانيا
//     '+8613800138000', // الصين
//   ];
//
//   /// قائمة بأمثلة على أرقام خاطئة
//   static List<String> get invalidExamples => [
//     '123456789',
//     '+123',
//     '05123',
//     '+9665012345678901', // طويل جداً
//   ];
//
//   /// الحصول على رسالة خطأ للرقم غير الصحيح
//   static String getValidationError(String phone) {
//     if (phone.isEmpty) {
//       return 'رقم الهاتف مطلوب';
//     }
//
//     final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
//
//     if (clean.length < 8) {
//       return 'رقم الهاتف قصير جداً';
//     }
//
//     if (clean.length > 16) {
//       return 'رقم الهاتف طويل جداً';
//     }
//
//     final formatted = format(phone);
//     if (!isValid(formatted)) {
//       return 'رقم الهاتف غير صحيح. تأكد من إدخال رمز الدولة';
//     }
//
//     return '';
//   }
//
//   /// الحصول على قائمة الدول المدعومة
//   static List<Map<String, dynamic>> getSupportedCountries() {
//     return _countryCodes.entries.map((entry) => {
//       'code': entry.key,
//       'name': entry.value['name'],
//     }).toList();
//   }
//
//   /// البحث عن دولة بالاسم
//   static String? findCountryCode(String countryName) {
//     for (var entry in _countryCodes.entries) {
//       if (entry.value['name'].toLowerCase().contains(countryName.toLowerCase())) {
//         return entry.key;
//       }
//     }
//     return null;
//   }
//
//   /// منع إنشاء كائن من هذه الفئة
//   PhoneNumberFormatter._();
// }
///
/// مساعد لتنسيق والتحقق من أرقام الهواتف الدولية
class PhoneNumberFormatter {
  // خريطة رموز الدول مع أطوال أرقامها المتوقعة
  static final Map<String, Map<String, dynamic>> _countryCodes = {
    // الدول العربية
    '+966': {'name': 'السعودية', 'length': [9], 'localPrefix': '0'},
    '+971': {'name': 'الإمارات', 'length': [9], 'localPrefix': '0'},
    '+968': {'name': 'عُمان', 'length': [8], 'localPrefix': '0'},
    '+965': {'name': 'الكويت', 'length': [8], 'localPrefix': '0'},
    '+973': {'name': 'البحرين', 'length': [8], 'localPrefix': '0'},
    '+974': {'name': 'قطر', 'length': [8], 'localPrefix': '0'},
    '+20': {'name': 'مصر', 'length': [10], 'localPrefix': '0'},
    '+962': {'name': 'الأردن', 'length': [9], 'localPrefix': '0'},
    '+961': {'name': 'لبنان', 'length': [8], 'localPrefix': '0'},
    '+963': {'name': 'سوريا', 'length': [9], 'localPrefix': '0'},
    '+964': {'name': 'العراق', 'length': [10], 'localPrefix': '0'},
    '+967': {'name': 'اليمن', 'length': [9], 'localPrefix': '0'},
    '+212': {'name': 'المغرب', 'length': [9], 'localPrefix': '0'},
    '+213': {'name': 'الجزائر', 'length': [9], 'localPrefix': '0'},
    '+216': {'name': 'تونس', 'length': [8], 'localPrefix': '0'},
    '+218': {'name': 'ليبيا', 'length': [9], 'localPrefix': '0'},
    '+249': {'name': 'السودان', 'length': [9], 'localPrefix': '0'},

    // الدول الأوروبية والعالمية
    '+1': {'name': 'أمريكا/كندا', 'length': [10], 'localPrefix': ''},
    '+44': {'name': 'بريطانيا', 'length': [10, 11], 'localPrefix': '0'},
    '+33': {'name': 'فرنسا', 'length': [9], 'localPrefix': '0'},
    '+49': {'name': 'ألمانيا', 'length': [10, 11], 'localPrefix': '0'},
    '+39': {'name': 'إيطاليا', 'length': [9, 10], 'localPrefix': '0'},
    '+34': {'name': 'إسبانيا', 'length': [9], 'localPrefix': '0'},
    '+7': {'name': 'روسيا', 'length': [10], 'localPrefix': '8'},
    '+86': {'name': 'الصين', 'length': [11], 'localPrefix': '0'},
    '+81': {'name': 'اليابان', 'length': [10, 11], 'localPrefix': '0'},
    '+82': {'name': 'كوريا الجنوبية', 'length': [10, 11], 'localPrefix': '0'},
    '+91': {'name': 'الهند', 'length': [10], 'localPrefix': '0'},
    '+92': {'name': 'باكستان', 'length': [10], 'localPrefix': '0'},
    '+98': {'name': 'إيران', 'length': [10], 'localPrefix': '0'},
    '+90': {'name': 'تركيا', 'length': [10], 'localPrefix': '0'},
    '+60': {'name': 'ماليزيا', 'length': [9, 10], 'localPrefix': '0'},
    '+65': {'name': 'سنغافورة', 'length': [8], 'localPrefix': '0'},
    '+852': {'name': 'هونغ كونغ', 'length': [8], 'localPrefix': '0'},
    '+61': {'name': 'أستراليا', 'length': [9], 'localPrefix': '0'},
    '+64': {'name': 'نيوزيلندا', 'length': [8, 9], 'localPrefix': '0'},
  };

  // مقدمات شركات الاتصال في السعودية
  static final Map<String, String> _saudiCarriers = {
    '50': 'STC', '53': 'STC', '56': 'STC',
    '51': 'Mobily', '54': 'Mobily',
    '55': 'Zain', '58': 'Zain',
    '57': 'Virgin Mobile',
    '59': 'Lebara',
  };

  // مقدمات شركات الاتصال في مصر
  static final Map<String, String> _egyptCarriers = {
    '10': 'Vodafone Egypt',
    '12': 'Orange Egypt',
    '11': 'Etisalat Egypt',
    '15': 'WE Egypt',

  };

  // مقدمات شركات الاتصال في الإمارات
  static final Map<String, String> _uaeCarriers = {
    '50': 'Etisalat', '52': 'Etisalat', '55': 'Etisalat', '56': 'Etisalat',
    '54': 'du', '58': 'du',
  };

  static final RegExp _digitOnlyPattern = RegExp(r'[^\d+]');
  static final RegExp _validPhonePattern = RegExp(r'^\+\d{7,15}$');

  /// تنسيق رقم الهاتف ليكون بالصيغة الدولية
  static String format(String phone) {
    if (phone.isEmpty) return phone;

    // إزالة جميع الأحرف غير الرقمية عدا علامة +
    String clean = phone.replaceAll(_digitOnlyPattern, '');

    // إذا كان الرقم يحتوي على + في البداية
    if (clean.startsWith('+')) {
      return _validateAndFormat(clean);
    }

    // البحث عن رمز الدولة بدون + (مرتبة حسب الطول لتجنب التداخل)
    List<String> sortedCodes = _countryCodes.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length)); // الأطول أولاً

    for (String countryCode in sortedCodes) {
      String codeWithoutPlus = countryCode.substring(1);
      if (clean.startsWith(codeWithoutPlus)) {
        String remainingNumber = clean.substring(codeWithoutPlus.length);
        List<int> validLengths = List<int>.from(_countryCodes[countryCode]!['length']);

        // التحقق من أن الرقم المتبقي له طول صحيح
        if (validLengths.contains(remainingNumber.length)) {
          return _validateAndFormat('+$clean');
        }
      }
    }

    // محاولة اكتشاف الأرقام المحلية الشائعة
    String detectedNumber = _detectLocalPatterns(clean);
    if (detectedNumber != clean) {
      return detectedNumber;
    }

    // إذا لم يتم التعرف على نمط محدد، نحاول إضافة رمز السعودية افتراضياً
    if (clean.length >= 8 && clean.length <= 12) {
      // تجربة إضافة رمز السعودية
      String withSaudiCode = '+966$clean';
      if (isValid(withSaudiCode)) {
        return withSaudiCode;
      }
    }

    return phone; // إرجاع الرقم كما هو إذا لم يتطابق مع أي نمط
  }

  /// اكتشاف الأنماط المحلية الشائعة
  static String _detectLocalPatterns(String clean) {
    // السعودية - أرقام تبدأ بـ 05
    if (clean.startsWith('05') && clean.length == 10) {
      return '+966${clean.substring(1)}';
    }

    // السعودية - أرقام تبدأ بـ 5
    if (clean.startsWith('5') && clean.length == 9) {
      return '+966$clean';
    }

    // مصر - أرقام تبدأ بـ 01
    if (clean.startsWith('01') && clean.length == 11) {
      return '+20${clean.substring(1)}';
    }

    // الإمارات - أرقام تبدأ بـ 05
    if (clean.startsWith('05') && clean.length == 9) {
      return '+971${clean.substring(1)}';
    }

    // أمريكا/كندا - أرقام من 10 أرقام بدون رمز دولة
    if (clean.length == 10 && !clean.startsWith('0')) {
      // التحقق من أن الرقم الأول ليس 0 أو 1
      if (!clean.startsWith('0') && !clean.startsWith('1')) {
        return '+1$clean';
      }
    }

    // أمريكا/كندا - أرقام تبدأ بـ 1
    if (clean.startsWith('1') && clean.length == 11) {
      return '+$clean';
    }

    // بريطانيا - أرقام تبدأ بـ 07
    if (clean.startsWith('07') && (clean.length == 11 || clean.length == 10)) {
      return '+44${clean.substring(1)}';
    }

    // ألمانيا - أرقام تبدأ بـ 0
    if (clean.startsWith('0') && clean.length >= 11 && clean.length <= 12) {
      return '+49${clean.substring(1)}';
    }

    // فرنسا - أرقام تبدأ بـ 0
    if (clean.startsWith('0') && clean.length == 10) {
      return '+33${clean.substring(1)}';
    }

    return clean; // لم يتم اكتشاف نمط
  }

  /// التحقق من صحة وتنسيق الرقم
  static String _validateAndFormat(String phone) {
    if (!_validPhonePattern.hasMatch(phone)) {
      return phone;
    }

    // البحث عن رمز الدولة المناسب
    for (String countryCode in _countryCodes.keys) {
      if (phone.startsWith(countryCode)) {
        String number = phone.substring(countryCode.length);
        List<int> validLengths = List<int>.from(_countryCodes[countryCode]!['length']);

        if (validLengths.contains(number.length)) {
          return phone;
        }
      }
    }

    return phone;
  }

  /// التحقق من صحة رقم الهاتف
  static bool isValid(String phone) {
    if (phone.isEmpty) return false;

    final formatted = format(phone);

    // التحقق من النمط العام
    if (!_validPhonePattern.hasMatch(formatted)) {
      return false;
    }

    // التحقق من رمز الدولة والطول
    for (String countryCode in _countryCodes.keys) {
      if (formatted.startsWith(countryCode)) {
        String number = formatted.substring(countryCode.length);
        List<int> validLengths = List<int>.from(_countryCodes[countryCode]!['length']);
        return validLengths.contains(number.length);
      }
    }

    return false;
  }

  /// عرض الرقم بتنسيق جميل وقابل للقراءة
  static String display(String phone) {
    final formatted = format(phone);

    for (String countryCode in _countryCodes.keys) {
      if (formatted.startsWith(countryCode)) {
        String number = formatted.substring(countryCode.length);

        // تنسيق خاص للسعودية
        if (countryCode == '+966' && number.length == 9) {
          return '$countryCode ${number.substring(0, 2)} ${number.substring(2, 5)} ${number.substring(5)}';
        }

        // تنسيق عام للدول الأخرى
        if (number.length >= 8) {
          int mid = number.length ~/ 2;
          return '$countryCode ${number.substring(0, mid)} ${number.substring(mid)}';
        }

        return '$countryCode $number';
      }
    }

    return formatted;
  }

  /// الحصول على رمز الدولة من الرقم
  static String getCountryCode(String phone) {
    final formatted = format(phone);

    for (String countryCode in _countryCodes.keys) {
      if (formatted.startsWith(countryCode)) {
        return countryCode;
      }
    }

    return '+966'; // افتراضي للسعودية
  }

  /// الحصول على اسم الدولة
  static String getCountryName(String phone) {
    final countryCode = getCountryCode(phone);
    return _countryCodes[countryCode]?['name'] ?? 'غير معروف';
  }

  /// الحصول على الرقم المحلي بدون رمز الدولة
  static String getLocalNumber(String phone) {
    final formatted = format(phone);

    for (String countryCode in _countryCodes.keys) {
      if (formatted.startsWith(countryCode)) {
        String localPrefix = _countryCodes[countryCode]!['localPrefix'];
        String number = formatted.substring(countryCode.length);

        if (localPrefix.isNotEmpty) {
          return '$localPrefix$number';
        }
        return number;
      }
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

  /// التحقق من نوع شبكة الاتصال
  static String getCarrier(String phone) {
    final formatted = format(phone);
    if (!isValid(formatted)) return 'غير معروف';

    final countryCode = getCountryCode(formatted);
    final number = formatted.substring(countryCode.length);

    if (number.length < 2) return 'غير معروف';

    final prefix = number.substring(0, 2);

    switch (countryCode) {
      case '+966': // السعودية
        return _saudiCarriers[prefix] ?? 'أخرى';
      case '+20': // مصر
        return _egyptCarriers[prefix] ?? 'أخرى';
      case '+971': // الإمارات
        return _uaeCarriers[prefix] ?? 'أخرى';
      default:
        return 'غير محدد';
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

  /// تحويل الرقم إلى رابط اتصال
  static String toCallUrl(String phone) {
    return 'tel:${format(phone)}';
  }

  /// قائمة بأمثلة على أرقام صحيحة من دول مختلفة (مع وبدون +)
  static List<String> get validExamples => [
    // مع علامة +
    '+966501234567', // السعودية
    '+971501234567', // الإمارات
    '+201012345678', // مصر
    '+14155552671',  // أمريكا
    '+447911123456', // بريطانيا
    '+8613800138000', // الصين

    // بدون علامة +
    '966501234567',  // السعودية
    '971501234567',  // الإمارات
    '201012345678',  // مصر
    '14155552671',   // أمريكا
    '447911123456',  // بريطانيا

    // أرقام محلية
    '0501234567',    // السعودية محلي
    '01012345678',   // مصر محلي
    '4155552671',    // أمريكا بدون 1
    '07911123456',   // بريطانيا محلي
  ];

  /// قائمة بأمثلة على أرقام خاطئة
  static List<String> get invalidExamples => [
    '123456789',
    '+123',
    '05123',
    '+9665012345678901', // طويل جداً
  ];

  /// الحصول على رسالة خطأ للرقم غير الصحيح
  static String getValidationError(String phone) {
    if (phone.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (clean.length < 8) {
      return 'رقم الهاتف قصير جداً';
    }

    if (clean.length > 16) {
      return 'رقم الهاتف طويل جداً';
    }

    final formatted = format(phone);
    if (!isValid(formatted)) {
      return 'رقم الهاتف غير صحيح. أمثلة صحيحة:\n'
          '• السعودية: 966501234567 أو 0501234567\n'
          '• مصر: 201012345678 أو 01012345678\n'
          '• أمريكا: 14155552671 أو 4155552671';
    }

    return '';
  }

  /// الحصول على قائمة الدول المدعومة
  static List<Map<String, dynamic>> getSupportedCountries() {
    return _countryCodes.entries.map((entry) => {
      'code': entry.key,
      'name': entry.value['name'],
    }).toList();
  }

  /// البحث عن دولة بالاسم
  static String? findCountryCode(String countryName) {
    for (var entry in _countryCodes.entries) {
      if (entry.value['name'].toLowerCase().contains(countryName.toLowerCase())) {
        return entry.key;
      }
    }
    return null;
  }

  /// منع إنشاء كائن من هذه الفئة
  PhoneNumberFormatter._();
}
