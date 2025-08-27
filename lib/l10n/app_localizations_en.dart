// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get prayerSettings => 'Prayer Settings';

  @override
  String get prayerNotifications => 'Prayer Notifications';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get officialTimetable => 'Official 2025 Timetable';

  @override
  String get viewPDF => 'View Windsor Islamic Association PDF';

  @override
  String get about => 'About';

  @override
  String get aboutWIA => 'About WIA App';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get helpImprove => 'Help us improve';

  @override
  String get supportDevelopment => 'Support Development';

  @override
  String get donated => 'donated';

  @override
  String yearsRemaining(String years) {
    return '$years years covered';
  }

  @override
  String get helpKeepRunning => 'Help keep this app running';

  @override
  String iosDevelopment(Object cost) {
    return 'iOS Development: \$$cost/year';
  }

  @override
  String serverCosts(Object cost) {
    return 'Server Costs: \$$cost/year';
  }

  @override
  String get selectLanguage => 'Select Language';

  @override
  String confirmLanguageChange(String language) {
    return 'Change language to $language?';
  }

  @override
  String get yes => 'Yes';

  @override
  String get cancel => 'Cancel';

  @override
  String get prayerTimes => 'Prayer Times';
}
