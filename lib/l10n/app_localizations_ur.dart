// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get settings => 'سیٹنگز';

  @override
  String get appSettings => 'ایپ سیٹنگز';

  @override
  String get theme => 'تھیم';

  @override
  String get lightMode => 'لائٹ موڈ';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get language => 'زبان';

  @override
  String get prayerSettings => 'نماز سیٹنگز';

  @override
  String get prayerNotifications => 'نماز اطلاعات';

  @override
  String get enabled => 'فعال';

  @override
  String get disabled => 'غیر فعال';

  @override
  String get officialTimetable => 'سرکاری ٹائم ٹیبل 2025';

  @override
  String get viewPDF => 'ونڈسر اسلامک ایسوسی ایشن PDF دیکھیں';

  @override
  String get about => 'کے بارے میں';

  @override
  String get aboutWIA => 'WIA ایپ کے بارے میں';

  @override
  String get version => 'ورژن 1.0.0';

  @override
  String get sendFeedback => 'رائے بھیجیں';

  @override
  String get helpImprove => 'بہتر بنانے میں مدد کریں';

  @override
  String get supportDevelopment => 'ڈیویلپمنٹ کی مدد کریں';

  @override
  String get donated => 'عطیہ';

  @override
  String yearsRemaining(String years) {
    return '$years سال باقی';
  }

  @override
  String get helpKeepRunning => 'اس ایپ کو چلانے میں مدد کریں';

  @override
  String iosDevelopment(Object cost) {
    return 'iOS ڈیویلپمنٹ: \$$cost/سال';
  }

  @override
  String serverCosts(Object cost) {
    return 'سرور کی لاگت: \$$cost/سال';
  }

  @override
  String get selectLanguage => 'زبان منتخب کریں';

  @override
  String confirmLanguageChange(String language) {
    return 'زبان $language میں تبدیل کریں؟';
  }

  @override
  String get yes => 'ہاں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get prayerTimes => 'نماز کے اوقات';
}
