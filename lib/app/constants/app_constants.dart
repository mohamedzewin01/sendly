/// ثوابت التطبيق غير المرئية (مفاتيح التخزين والحدود والروابط)
class AppConstants {
  // قيود وحدود
  static const int maxContactsPerBulkSend = 100;
  static const int maxMessageLength = 4096;
  static const int maxContactNameLength = 50;
  static const int maxMessageTitleLength = 100;

  // مفاتيح التخزين المحلي
  static const String contactsKey = 'contacts';
  static const String messagesKey = 'messages';
  static const String settingsKey = 'settings';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';

  // روابط ومعرفات
  static const String supportEmail = 'mohammedzewin01@gmail.com';

  /// جهة الاتصال الخاصة بمعايير سلامة الأطفال (نفسها المسجّلة في Play Console)
  static const String childSafetyEmail = 'eng.mo.zewin@gmail.com';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  AppConstants._();
}
