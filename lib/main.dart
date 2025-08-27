import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Request notification permissions
  await NotificationService.requestPermissions();
  
  // Automatically schedule prayer notifications on app startup
  try {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    final preAdhanEnabled = prefs.getBool('pre_adhan_enabled') ?? false;
    
    if (notificationsEnabled) {
      await NotificationService.scheduleAllPrayerNotifications(preAdhanEnabled);
      print('Prayer notifications scheduled automatically on app startup');
    }
  } catch (e) {
    print('Error scheduling notifications on startup: $e');
  }
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  // Add the missing static method
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  void changeTheme(bool isDarkMode) async {
    setState(() {
      _isDarkMode = isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WIA Prayer Times',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}