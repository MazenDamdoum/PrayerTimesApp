// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get appSettings => 'إعدادات التطبيق';

  @override
  String get theme => 'المظهر';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get prayerSettings => 'إعدادات الصلاة';

  @override
  String get prayerNotifications => 'تنبيهات الصلاة';

  @override
  String get enabled => 'مفعل';

  @override
  String get disabled => 'معطل';

  @override
  String get officialTimetable => 'الجدول الرسمي 2025';

  @override
  String get viewPDF => 'عرض جمعية وندسور الإسلامية';

  @override
  String get about => 'حول';

  @override
  String get aboutWIA => 'حول تطبيق WIA';

  @override
  String get version => 'الإصدار 1.0.0';

  @override
  String get sendFeedback => 'إرسال ملاحظات';

  @override
  String get helpImprove => 'ساعدنا في التحسين';

  @override
  String get supportDevelopment => 'دعم التطوير';

  @override
  String get donated => 'متبرع';

  @override
  String yearsRemaining(String years) {
    return '$years سنوات مغطاة';
  }

  @override
  String get helpKeepRunning => 'ساعد في الحفاظ على تشغيل هذا التطبيق';

  @override
  String iosDevelopment(Object cost) {
    return 'تطوير iOS: \$$cost/سنة';
  }

  @override
  String serverCosts(Object cost) {
    return 'تكاليف الخادم: \$$cost/سنة';
  }

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String confirmLanguageChange(String language) {
    return 'تغيير اللغة إلى $language؟';
  }

  @override
  String get yes => 'نعم';

  @override
  String get cancel => 'إلغاء';

  @override
  String get prayerTimes => 'أوقات الصلاة';
}
