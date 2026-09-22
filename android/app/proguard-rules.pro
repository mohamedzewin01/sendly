# قواعد R8 لتطبيق «رسالة».
# Flutter وFirebase وAdMob تضيف قواعد مستهلكيها تلقائياً؛ هذه للحالات الناقصة فقط.

# فلاتر يشير لكلاسات Play Core الاختيارية (التحميل المؤجل) وهي غير مضمّنة عمداً
-dontwarn com.google.android.play.core.**

# نحتفظ بالخصائص التي تحتاجها المكتبات (توقيعات الأنواع والتعليقات التوضيحية)
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# قناة المشاركة الواردة في MainActivity (لا انعكاس، لكن نحفظ الكلاس للوضوح في التقارير)
-keep class com.example.sendly.MainActivity { *; }
