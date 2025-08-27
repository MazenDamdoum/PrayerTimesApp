import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/notification_service.dart';
import 'about_wia_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationCoverage {
  static const double _yearlyGoal = 90.0;
  
  static double calculateCoverage(double donationAmount) {
    return donationAmount / _yearlyGoal;
  }
  
  static String formatCoverage(double coverageYears) {
    if (coverageYears <= 0) {
      return '0 months';
    } else if (coverageYears < 1) {
      final months = (coverageYears * 12).round();
      return '$months month${months != 1 ? 's' : ''}';
    } else {
      final years = coverageYears.floor();
      final remainingMonths = ((coverageYears - years) * 12).round();
      if (remainingMonths == 0) {
        return '$years year${years != 1 ? 's' : ''}';
      } else {
        return '$years year${years != 1 ? 's' : ''} $remainingMonths month${remainingMonths != 1 ? 's' : ''}';
      }
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool preAdhanNotificationsEnabled = false;
  bool isDarkMode = false;
  bool is24HourFormat = false;
  String selectedLanguage = 'English';
  double currentDonations = 0.0;
  double yearlyIOSCost = 90.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    NotificationService.initialize();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      preAdhanNotificationsEnabled = prefs.getBool('pre_adhan_enabled') ?? false;
      isDarkMode = prefs.getBool('dark_mode') ?? false;
      is24HourFormat = prefs.getBool('24_hour_format') ?? false;
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
      currentDonations = prefs.getDouble('current_donations') ?? 0.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setBool('pre_adhan_enabled', preAdhanNotificationsEnabled);
    await prefs.setBool('dark_mode', isDarkMode);
    await prefs.setBool('24_hour_format', is24HourFormat);
    await prefs.setString('selected_language', selectedLanguage);
    await prefs.setDouble('current_donations', currentDonations);
  }

  double get donationProgress {
    if (currentDonations <= 0) return 0.0;
    return (currentDonations / yearlyIOSCost).clamp(0.0, 1.0);
  }

  String get coverageDisplay {
    final coverage = DonationCoverage.calculateCoverage(currentDonations);
    return DonationCoverage.formatCoverage(coverage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.green[700]
            : Colors.green[600],
        elevation: 4,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('App Settings'),
          _buildSettingsGroup([
            _buildDarkModeToggle(),
            _buildLanguageSelector(),
            _build24HourFormatToggle(),
          ]),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Prayer Notifications'),
          _buildSettingsGroup([
            _buildNotificationToggle(),
            _buildPreAdhanNotificationToggle(),
            _buildPrayerTimesReference(),
          ]),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('About'),
          _buildSettingsGroup([
            _buildAboutTile(),
            _buildFeedbackTile(),
          ]),
          
          const SizedBox(height: 16),
          
          _buildDonateNowBar(),
          
          const SizedBox(height: 16),
          
          _buildDonationSection(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.green[300]
              : Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]!
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int index = entry.key;
          Widget child = entry.value;
          
          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!.withOpacity(0.5)
                      : Colors.grey[200]!.withOpacity(0.5),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
      title: Text(
        'Dark Mode',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: isDarkMode,
        activeThumbColor: Colors.green[600],
        onChanged: (value) async {
          setState(() {
            isDarkMode = value;
          });
          await _saveSettings();
          
          // Change app theme
          final myAppState = MyApp.of(context);
          if (myAppState != null) {
            myAppState.changeTheme(value);
          }
        },
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.language_outlined,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
      title: Text(
        'Language',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        selectedLanguage,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]
            : Colors.grey[400],
      ),
      onTap: () {
        _showLanguageDialog();
      },
    );
  }

  Widget _build24HourFormatToggle() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.access_time,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
      title: Text(
        '24-Hour Format',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        is24HourFormat ? '24-hour time format' : '12-hour time format',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: is24HourFormat,
        activeThumbColor: Colors.green[600],
        onChanged: (value) async {
          setState(() {
            is24HourFormat = value;
          });
          await _saveSettings();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? 'Switched to 24-hour format'
                    : 'Switched to 12-hour format',
              ),
              backgroundColor: Colors.green[600],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.notifications_outlined,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
      title: Text(
        'Prayer Notifications',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        notificationsEnabled ? 'Notifications at prayer times' : 'Disabled',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: notificationsEnabled,
        activeThumbColor: Colors.green[600],
        onChanged: (value) async {
          if (value) {
            // Request notification permissions
            final hasPermission = await NotificationService.requestPermissions();
            if (!hasPermission) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enable notifications in device settings'),
                  backgroundColor: Colors.red[600],
                ),
              );
              return;
            }
          }

          setState(() {
            notificationsEnabled = value;
            if (!value) {
              preAdhanNotificationsEnabled = false;
              NotificationService.cancelAllNotifications();
            }
          });
          await _saveSettings();
          
          if (value) {
            _scheduleNotifications();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Prayer notifications enabled'),
                backgroundColor: Colors.green[600],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPreAdhanNotificationToggle() {
    return ListTile(
      enabled: notificationsEnabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.notifications_active_outlined,
        color: notificationsEnabled && preAdhanNotificationsEnabled 
            ? Colors.green[600] 
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[600]
                : Colors.grey[400]),
      ),
      title: Text(
        '15-Min Pre-Adhan Alert',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: notificationsEnabled 
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[800])
              : Colors.grey,
        ),
      ),
      subtitle: Text(
        preAdhanNotificationsEnabled && notificationsEnabled 
            ? 'Alert 15 minutes before each prayer' 
            : 'Disabled',
        style: TextStyle(
          fontSize: 14,
          color: notificationsEnabled 
              ? (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600])
              : Colors.grey,
        ),
      ),
      trailing: Switch(
        value: preAdhanNotificationsEnabled && notificationsEnabled,
        activeThumbColor: Colors.green[600],
        onChanged: notificationsEnabled ? (value) async {
          setState(() {
            preAdhanNotificationsEnabled = value;
          });
          await _saveSettings();
          _scheduleNotifications();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value 
                  ? '15-minute pre-Adhan alerts enabled' 
                  : '15-minute pre-Adhan alerts disabled'),
              backgroundColor: Colors.green[600],
            ),
          );
        } : null,
      ),
    );
  }

  // Schedule notifications based on current prayer times from actual data
  void _scheduleNotifications() async {
    if (!notificationsEnabled) return;

    try {
      // This now gets real prayer times from your JSON data
      await NotificationService.scheduleAllPrayerNotifications(preAdhanNotificationsEnabled);
      
      print('Prayer notifications scheduled successfully');
    } catch (e) {
      print('Error scheduling notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling notifications. Please try again.'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  Widget _buildPrayerTimesReference() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.schedule_outlined,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
      title: Text(
        'Official 2025 Timetable',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        'View Windsor Islamic Association PDF',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.open_in_new,
        size: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]
            : Colors.grey[400],
      ),
      onTap: () {
        _showPrayerTimesDialog();
      },
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.info_outline,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
      title: Text(
        'About WIA',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        'Windsor Islamic Association',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]
            : Colors.grey[400],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutWIAScreen()),
        );
      },
    );
  }

  Widget _buildFeedbackTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        Icons.feedback_outlined,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]
            : Colors.grey[600],
      ),
      title: Text(
        'Send Feedback',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800],
        ),
      ),
      subtitle: Text(
        'Help us improve',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]
            : Colors.grey[400],
      ),
      onTap: () {
        _launchFeedbackForm();
      },
    );
  }

  Widget _buildDonateNowBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          _showDonateDialog();
        },
        icon: const Icon(Icons.favorite, size: 20),
        label: const Text(
          'Donate Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildDonationSection() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: Theme.of(context).brightness == Brightness.dark
            ? [Colors.green[800]!.withOpacity(0.6), Colors.green[900]!.withOpacity(0.4)]
            : [Colors.green[50]!, Colors.green[100]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.green[600]!
            : Colors.green[300]!,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.green[900]!.withOpacity(0.4)
              : Colors.green[200]!.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
          spreadRadius: 3,
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          'Support Development',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.green[200] 
                : Colors.green[800],
          ),
        ),
        const SizedBox(height: 20),
        
        // Fixed progress indicator with text overlay
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[700] 
                      : Colors.green[100],
                ),
              ),
              
              // Progress indicator
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: donationProgress,
                  strokeWidth: 8,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[600] 
                      : Colors.green[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).brightness == Brightness.dark 
                        ? Colors.green[400]! 
                        : Colors.green[600]!,
                  ),
                ),
              ),
              
              // Centered text content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${currentDonations.toInt()}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.green[300] 
                          : Colors.green[700],
                    ),
                  ),
                  Text(
                    'donated',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.green[400] 
                          : Colors.green[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          currentDonations > 0 ? '$coverageDisplay covered' : 'Help keep this app running',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.green[300] 
                : Colors.green[700],
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'iOS Developer Tools: \$${yearlyIOSCost.toInt()}/year',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.green[400] 
                : Colors.green[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        if (currentDonations > 0)
          Text(
            '\$${currentDonations.toInt()} ÷ \$${yearlyIOSCost.toInt()} = ${DonationCoverage.calculateCoverage(currentDonations).toStringAsFixed(1)} years',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.green[400] 
                  : Colors.green[600],
            ),
            textAlign: TextAlign.center,
          )
        else
          Text(
            'Goal: \$${yearlyIOSCost.toInt()} = 1 year of development',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.green[400] 
                  : Colors.green[600],
            ),
            textAlign: TextAlign.center,
          ),
      ],
    ),
  );
}

  // Launch feedback form in external browser
  Future<void> _launchFeedbackForm() async {
    final Uri feedbackUrl = Uri.parse('https://forms.gle/CMDuaJLNnQ7mwEq38');
    
    try {
      if (await canLaunchUrl(feedbackUrl)) {
        await launchUrl(
          feedbackUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open feedback form'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening feedback form'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  void _showDonateDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Choose Donation Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Donate to WIA option
            ListTile(
              leading: Icon(Icons.mosque, color: Colors.green[600]),
              title: const Text('Donate to WIA'),
              subtitle: const Text('Support Windsor Islamic Association'),
              onTap: () {
                Navigator.pop(context);
                // Open the WIA donation link
                launchUrl(Uri.parse('https://ca.mohid.co/on/windsor/wia/masjid/online/donation'));
              },
            ),
            const Divider(),
            // App Development option
            ListTile(
              leading: Icon(Icons.developer_mode, color: Colors.green[600]),
              title: const Text('App Development'),
              subtitle: const Text('Support app maintenance and updates'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coming soon'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'English',
                  groupValue: selectedLanguage,
                  activeColor: Colors.green[600],
                  onChanged: (String? value) {
                    _changeLanguage('en', 'English');
                  },
                ),
              ),
              ListTile(
                title: const Text('العربية'),
                leading: Radio<String>(
                  value: 'العربية',
                  groupValue: selectedLanguage,
                  activeColor: Colors.green[600],
                  onChanged: (String? value) {
                    _changeLanguage('ar', 'العربية');
                  },
                ),
              ),
              ListTile(
                title: const Text('اردو'),
                leading: Radio<String>(
                  value: 'اردو', 
                  groupValue: selectedLanguage,
                  activeColor: Colors.green[600],
                  onChanged: (String? value) {
                    _changeLanguage('ur', 'اردو');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(String languageCode, String languageName) async {
    String confirmText = languageCode == 'ar' ? 'تغيير اللغة إلى العربية؟' :
                         languageCode == 'ur' ? 'زبان اردو میں تبدیل کریں؟' :
                         'Change language to English?';
    
    String yesText = languageCode == 'ar' ? 'نعم' :
                     languageCode == 'ur' ? 'ہاں' : 'Yes';
    
    String cancelText = languageCode == 'ar' ? 'إلغاء' :
                        languageCode == 'ur' ? 'منسوخ' : 'Cancel';

showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(confirmText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  selectedLanguage = languageName;
                });
                await _saveSettings();
                Navigator.pop(context);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language changed to $languageName')),
                );
              },
              child: Text(yesText),
            ),
          ],
        );
      },
    );
  }

  void _showPrayerTimesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Official Prayer Times'),
          content: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              children: [
                const TextSpan(
                  text: 'All prayer times in this app are sourced from the Windsor Islamic Association\'s official 2025 timetable. '
                      'For the complete PDF document, please ',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final Uri url = Uri.parse('https://windsorislamicassociation.com/prayer-times');
                      
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open website'),
                              backgroundColor: Colors.red[600],
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error opening website'),
                            backgroundColor: Colors.red[600],
                          ),
                        );
                      }
                    },
                    child: Text(
                      'visit',
                      style: TextStyle(
                        color: Colors.blue[600],
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                  text: ' the mosque or check their official announcements.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}