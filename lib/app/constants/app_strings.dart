/// النصوص الثابتة للتطبيق
class AppStrings {
  // معلومات التطبيق
  static const String appTitle = 'SendlyN';
  static const String appSubtitle = 'إرسال الرسائل بسهولة وسرعة';
  static const String appDescription = 'تطبيق يساعدك في إرسال الرسائل عبر الواتساب بطريقة سهلة ومنظمة';

  // التبويبات الرئيسية
  static const String contactsTab = 'الجهات';
  static const String messagesTab = 'الرسائل';
  static const String quickSendTab = 'إرسال سريع';
  static const String bulkSendTab = 'إرسال جماعي';
  static const String settingsTab = 'الإعدادات';

  // جهات الاتصال
  static const String contacts = 'جهات الاتصال';
  static const String addContact = 'إضافة جهة اتصال';
  static const String editContact = 'تعديل جهة الاتصال';
  static const String deleteContact = 'حذف جهة الاتصال';
  static const String contactName = 'الاسم';
  static const String contactPhone = 'رقم الهاتف';
  static const String noContacts = 'لا توجد جهات اتصال';
  static const String contactAdded = 'تم إضافة جهة الاتصال بنجاح';
  static const String contactUpdated = 'تم تحديث جهة الاتصال بنجاح';
  static const String contactDeleted = 'تم حذف جهة الاتصال بنجاح';
  static const String phoneHint = 'أدخل رقم الجوال ';
  static const String nameHint = 'أدخل اسم جهة الاتصال';

  // الرسائل
  static const String messages = 'الرسائل';
  static const String savedMessages = 'الرسائل المحفوظة';
  static const String addMessage = 'إضافة رسالة';
  static const String editMessage = 'تعديل الرسالة';
  static const String deleteMessage = 'حذف الرسالة';
  static const String messageTitle = 'عنوان الرسالة';
  static const String messageContent = 'محتوى الرسالة';
  static const String noMessages = 'لا توجد رسائل محفوظة';
  static const String messageAdded = 'تم إضافة الرسالة بنجاح';
  static const String messageUpdated = 'تم تحديث الرسالة بنجاح';
  static const String messageDeleted = 'تم حذف الرسالة بنجاح';
  static const String messageTitleHint = 'أدخل عنوان الرسالة';
  static const String messageContentHint = 'اكتب محتوى الرسالة هنا...';

  // الإرسال السريع
  static const String quickSend = 'إرسال سريع';
  static const String quickSendDescription = 'أرسل رسالة لأي رقم بسرعة';
  static const String sendMessage = 'إرسال الرسالة';
  static const String sendViaWhatsApp = 'إرسال عبر الواتساب';
  static const String messageText = 'نص الرسالة';
  static const String phoneNumber = 'رقم الهاتف';
  static const String tapToUse = 'اضغط للاستخدام';
  static const String messageSent = 'تم إرسال الرسالة بنجاح';

  // الإرسال الجماعي
  static const String bulkSend = 'إرسال جماعي';
  static const String bulkSendDescription = 'أرسل رسالة واحدة لعدة جهات اتصال';
  static const String selectContacts = 'اختيار جهات الاتصال';
  static const String selectAll = 'اختيار الكل';
  static const String unselectAll = 'إلغاء الكل';
  static const String sendToSelected = 'إرسال للمحددين';
  static const String contactsSelected = 'جهة اتصال محددة';
  static const String bulkMessageHint = 'اكتب الرسالة التي تريد إرسالها لجميع جهات الاتصال المحددة';

  // الإعدادات
  static const String settings = 'الإعدادات';
  static const String appStatistics = 'إحصائيات التطبيق';
  static const String dataManagement = 'إدارة البيانات';
  static const String appInfo = 'معلومات التطبيق';
  static const String exportContacts = 'تصدير جهات الاتصال';
  static const String exportMessages = 'تصدير الرسائل';
  static const String importContacts = 'استيراد جهات الاتصال';
  static const String importMessages = 'استيراد الرسائل';
  static const String clearAllData = 'مسح جميع البيانات';
  static const String appVersion = 'إصدار التطبيق';
  static const String developer = 'المطور';
  static const String support = 'الدعم';

  // الرسائل العامة
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String confirm = 'تأكيد';
  static const String yes = 'نعم';
  static const String no = 'لا';
  static const String ok = 'موافق';
  static const String done = 'تم';
  static const String loading = 'جاري التحميل...';
  static const String error = 'خطأ';
  static const String success = 'نجح';
  static const String warning = 'تحذير';
  static const String info = 'معلومات';

  // رسائل التحقق
  static const String fieldRequired = 'هذا الحقل مطلوب';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String invalidName = 'الاسم غير صحيح';
  static const String messageEmpty = 'الرسالة فارغة';
  static const String titleEmpty = 'العنوان فارغ';
  static const String noContactsSelected = 'لم يتم اختيار أي جهة اتصال';
  static const String fillAllFields = 'يرجى ملء جميع الحقول';

  // رسائل التأكيد
  static const String confirmDelete = 'هل تريد حذف هذا العنصر؟';
  static const String confirmDeleteContact = 'هل تريد حذف جهة الاتصال؟';
  static const String confirmDeleteMessage = 'هل تريد حذف الرسالة؟';
  static const String confirmClearData = 'هل تريد مسح جميع البيانات؟ لن يمكن التراجع عن هذا الإجراء.';
  static const String actionCannotBeUndone = 'لا يمكن التراجع عن هذا الإجراء';

  // رسائل النجاح
  static const String dataCopiedToClipboard = 'تم نسخ البيانات إلى الحافظة';
  static const String whatsappOpened = 'تم فتح الواتساب بنجاح';
  static const String dataExported = 'تم تصدير البيانات بنجاح';
  static const String dataCleared = 'تم مسح جميع البيانات بنجاح';

  // رسائل الخطأ
  static const String cantOpenWhatsApp = 'لا يمكن فتح الواتساب';
  static const String exportFailed = 'فشل في تصدير البيانات';
  static const String importFailed = 'فشل في استيراد البيانات';
  static const String unexpectedError = 'حدث خطأ غير متوقع';
  static const String networkError = 'خطأ في الاتصال';
  static const String permissionDenied = 'تم رفض الإذن';

  // إحصائيات
  static const String totalContacts = 'إجمالي جهات الاتصال';
  static const String totalMessages = 'إجمالي الرسائل';
  static const String validPhones = 'أرقام صحيحة';
  static const String averageMessageLength = 'متوسط طول الرسالة';
  static const String character = 'حرف';
  static const String recentlyAdded = 'مضاف حديثاً';

  // حالات فارغة
  static const String noDataAvailable = 'لا توجد بيانات متاحة';
  static const String addFirstContact = 'أضف أول جهة اتصال';
  static const String addFirstMessage = 'أضف أول رسالة';
  static const String startByAddingContacts = 'ابدأ بإضافة جهات اتصال من تبويب "الجهات"';
  static const String startByAddingMessages = 'ابدأ بإضافة رسائل من تبويب "الرسائل"';

  // ميزات قيد التطوير
  static const String featureUnderDevelopment = 'هذه الميزة قيد التطوير';
  static const String comingSoon = 'قريباً';

  // شكر وتقدير
  static const String thankYou = 'شكراً لاستخدام التطبيق!';
  static const String appreciateYourTrust = 'نحن نقدر ثقتكم بنا';
  static const String rateApp = 'قيم التطبيق';
  static const String shareApp = 'شارك التطبيق';

  // منع إنشاء كائن من هذه الفئة
  AppStrings._();
}