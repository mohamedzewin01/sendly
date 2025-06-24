import '../../data/models/contact.dart';
import '../../data/models/message.dart';
import 'phone_formatter.dart';

/// مساعد لحساب الإحصائيات المختلفة للتطبيق
class StatisticsHelper {
  /// حساب إحصائيات جهات الاتصال
  static ContactStatistics getContactStatistics(List<Contact> contacts) {
    if (contacts.isEmpty) {
      return ContactStatistics.empty();
    }

    int validPhones = 0;
    int recentlyAdded = 0;
    Map<String, int> carrierCount = {};

    final now = DateTime.now();

    for (final contact in contacts) {
      // عد الأرقام الصحيحة
      if (PhoneNumberFormatter.isValid(contact.phone)) {
        validPhones++;

        // عد حسب الشركة
        final carrier = PhoneNumberFormatter.getCarrier(contact.phone);
        carrierCount[carrier] = (carrierCount[carrier] ?? 0) + 1;
      }

      // عد المضافة حديثاً (آخر 7 أيام)
      try {
        final timestamp = int.parse(contact.id);
        final addedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (now.difference(addedDate).inDays <= 7) {
          recentlyAdded++;
        }
      } catch (e) {
        // تجاهل الأخطاء في تحليل التاريخ
      }
    }

    return ContactStatistics(
      total: contacts.length,
      validPhones: validPhones,
      invalidPhones: contacts.length - validPhones,
      recentlyAdded: recentlyAdded,
      carrierDistribution: carrierCount,
    );
  }

  /// حساب إحصائيات الرسائل
  static MessageStatistics getMessageStatistics(List<Message> messages) {
    if (messages.isEmpty) {
      return MessageStatistics.empty();
    }

    List<int> lengths = messages.map((m) => m.content.length).toList();
    lengths.sort();

    int recentlyAdded = 0;
    int arabicMessages = 0;
    int englishMessages = 0;

    final now = DateTime.now();

    for (final message in messages) {
      // عد المضافة حديثاً
      try {
        final timestamp = int.parse(message.id);
        final addedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (now.difference(addedDate).inDays <= 7) {
          recentlyAdded++;
        }
      } catch (e) {
        // تجاهل الأخطاء
      }

      // تحديد اللغة
      if (_isArabicText(message.content)) {
        arabicMessages++;
      } else {
        englishMessages++;
      }
    }

    return MessageStatistics(
      total: messages.length,
      averageLength: (lengths.reduce((a, b) => a + b) / lengths.length).round(),
      shortestLength: lengths.first,
      longestLength: lengths.last,
      recentlyAdded: recentlyAdded,
      arabicMessages: arabicMessages,
      englishMessages: englishMessages,
    );
  }

  /// حساب إحصائيات الاستخدام العام
  static AppUsageStatistics getAppUsageStatistics(
      List<Contact> contacts,
      List<Message> messages,
      ) {
    final contactStats = getContactStatistics(contacts);
    final messageStats = getMessageStatistics(messages);

    return AppUsageStatistics(
      totalContacts: contactStats.total,
      totalMessages: messageStats.total,
      validPhones: contactStats.validPhones,
      averageMessageLength: messageStats.averageLength,
      dataHealth: _calculateDataHealth(contactStats, messageStats),
    );
  }

  /// تحديد ما إذا كان النص عربي
  static bool _isArabicText(String text) {
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    final arabicMatches = arabicPattern.allMatches(text).length;
    final totalChars = text.length;

    return arabicMatches > (totalChars * 0.3); // إذا كان 30% من النص عربي
  }

  /// حساب صحة البيانات (نسبة مئوية)
  static int _calculateDataHealth(
      ContactStatistics contactStats,
      MessageStatistics messageStats,
      ) {
    int score = 0;
    int maxScore = 0;

    // نقاط للجهات
    if (contactStats.total > 0) {
      maxScore += 40;

      // نقاط للأرقام الصحيحة
      final validPhoneRatio = contactStats.validPhones / contactStats.total;
      score += (validPhoneRatio * 30).round();

      // نقاط لوجود جهات اتصال
      if (contactStats.total >= 5) score += 10;
    }

    // نقاط للرسائل
    if (messageStats.total > 0) {
      maxScore += 60;

      // نقاط لوجود رسائل
      if (messageStats.total >= 3) score += 20;

      // نقاط لطول الرسائل المناسب
      if (messageStats.averageLength >= 50 && messageStats.averageLength <= 1000) {
        score += 20;
      }

      // نقاط للتنوع
      if (messageStats.total >= 10) score += 20;
    }

    return maxScore > 0 ? ((score / maxScore) * 100).round() : 0;
  }

  /// الحصول على توصيات لتحسين البيانات
  static List<String> getDataRecommendations(
      List<Contact> contacts,
      List<Message> messages,
      ) {
    final recommendations = <String>[];
    final contactStats = getContactStatistics(contacts);
    final messageStats = getMessageStatistics(messages);

    // توصيات للجهات
    if (contactStats.total == 0) {
      recommendations.add('ابدأ بإضافة جهات اتصال للاستفادة من الإرسال الجماعي');
    } else if (contactStats.total < 5) {
      recommendations.add('أضف المزيد من جهات الاتصال لتحقيق أقصى استفادة');
    }

    if (contactStats.invalidPhones > 0) {
      recommendations.add('راجع أرقام الهواتف غير الصحيحة وصححها');
    }

    // توصيات للرسائل
    if (messageStats.total == 0) {
      recommendations.add('احفظ رسائلك المفضلة لإعادة استخدامها بسهولة');
    } else if (messageStats.total < 3) {
      recommendations.add('أضف المزيد من الرسائل المحفوظة لتوفير الوقت');
    }

    if (messageStats.averageLength < 20) {
      recommendations.add('اكتب رسائل أكثر تفصيلاً لتحقيق تأثير أفضل');
    } else if (messageStats.averageLength > 1500) {
      recommendations.add('اختصر رسائلك الطويلة لتحسين القراءة');
    }

    return recommendations;
  }

  /// منع إنشاء كائن من هذه الفئة
  StatisticsHelper._();
}

/// إحصائيات جهات الاتصال
class ContactStatistics {
  final int total;
  final int validPhones;
  final int invalidPhones;
  final int recentlyAdded;
  final Map<String, int> carrierDistribution;

  const ContactStatistics({
    required this.total,
    required this.validPhones,
    required this.invalidPhones,
    required this.recentlyAdded,
    required this.carrierDistribution,
  });

  factory ContactStatistics.empty() {
    return const ContactStatistics(
      total: 0,
      validPhones: 0,
      invalidPhones: 0,
      recentlyAdded: 0,
      carrierDistribution: {},
    );
  }

  double get validPhonePercentage =>
      total > 0 ? (validPhones / total * 100) : 0;

  String get mostUsedCarrier {
    if (carrierDistribution.isEmpty) return 'غير محدد';

    return carrierDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// إحصائيات الرسائل
class MessageStatistics {
  final int total;
  final int averageLength;
  final int shortestLength;
  final int longestLength;
  final int recentlyAdded;
  final int arabicMessages;
  final int englishMessages;

  const MessageStatistics({
    required this.total,
    required this.averageLength,
    required this.shortestLength,
    required this.longestLength,
    required this.recentlyAdded,
    required this.arabicMessages,
    required this.englishMessages,
  });

  factory MessageStatistics.empty() {
    return const MessageStatistics(
      total: 0,
      averageLength: 0,
      shortestLength: 0,
      longestLength: 0,
      recentlyAdded: 0,
      arabicMessages: 0,
      englishMessages: 0,
    );
  }

  double get arabicPercentage =>
      total > 0 ? (arabicMessages / total * 100) : 0;

  String get preferredLanguage =>
      arabicMessages > englishMessages ? 'العربية' : 'الإنجليزية';
}

/// إحصائيات استخدام التطبيق
class AppUsageStatistics {
  final int totalContacts;
  final int totalMessages;
  final int validPhones;
  final int averageMessageLength;
  final int dataHealth; // من 0 إلى 100

  const AppUsageStatistics({
    required this.totalContacts,
    required this.totalMessages,
    required this.validPhones,
    required this.averageMessageLength,
    required this.dataHealth,
  });

  String get healthStatus {
    if (dataHealth >= 80) return 'ممتاز';
    if (dataHealth >= 60) return 'جيد';
    if (dataHealth >= 40) return 'متوسط';
    if (dataHealth >= 20) return 'ضعيف';
    return 'يحتاج تحسين';
  }

  bool get isHealthy => dataHealth >= 60;
  bool get hasData => totalContacts > 0 || totalMessages > 0;
}