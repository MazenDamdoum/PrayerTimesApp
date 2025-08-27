import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'prayer_times_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Prayer names for notifications
  static const List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Toronto')); // Windsor timezone

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    await initialize();
    
    // Request permissions for Android 13+ and iOS
    final result = await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    return result ?? true; // Default to true for iOS or if permission already granted
  }

  // Updated method that gets real prayer times from your data
  static Future<void> scheduleAllPrayerNotifications(bool preAdhanEnabled) async {
    await initialize();
    await cancelAllNotifications();

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!notificationsEnabled) return;

    try {
      // Get today's actual prayer times from your JSON data
      final prayerTimes = await PrayerTimesService.getTodaysPrayerTimes();
      
      for (int i = 0; i < prayerTimes.length; i++) {
        final prayer = prayerTimes[i];
        final prayerName = prayer['prayer'] ?? prayerNames[i];
        final timeStr = prayer['time'] as String;
        
        try {
          final scheduledTime = _parseTimeToToday(timeStr);
          
          // Schedule main prayer notification
          await _scheduleNotification(
            id: i * 2, // Even IDs for main prayers
            title: '$prayerName Prayer Time',
            body: 'It\'s time for $prayerName prayer',
            scheduledTime: scheduledTime,
            sound: 'athan_sound',
          );

          // Schedule 15-minute pre-Adhan notification if enabled
          if (preAdhanEnabled) {
            final preAdhanTime = scheduledTime.subtract(Duration(minutes: 15));
            if (preAdhanTime.isAfter(DateTime.now())) {
              await _scheduleNotification(
                id: i * 2 + 1, // Odd IDs for pre-Adhan alerts
                title: '$prayerName in 15 Minutes',
                body: 'Get ready for $prayerName prayer',
                scheduledTime: preAdhanTime,
                sound: 'notification_sound',
              );
            }
          }
        } catch (e) {
          print('Error scheduling notification for $prayerName: $e');
        }
      }
    } catch (e) {
      print('Error loading prayer times for notifications: $e');
      // Fallback to default times if loading fails
      await _scheduleDefaultNotifications(preAdhanEnabled);
    }
  }

  // Fallback method with default times if data loading fails
  static Future<void> _scheduleDefaultNotifications(bool preAdhanEnabled) async {
    final defaultTimes = [
      {'prayer': 'Fajr', 'time': '05:30'},
      {'prayer': 'Dhuhr', 'time': '12:15'},
      {'prayer': 'Asr', 'time': '15:45'},
      {'prayer': 'Maghrib', 'time': '18:20'},
      {'prayer': 'Isha', 'time': '19:45'},
    ];

    for (int i = 0; i < defaultTimes.length; i++) {
      final prayer = defaultTimes[i];
      final prayerName = prayer['prayer']!;
      final timeStr = prayer['time']!;
      
      try {
        final scheduledTime = _parseTimeToToday(timeStr);
        
        await _scheduleNotification(
          id: i * 2,
          title: '$prayerName Prayer Time',
          body: 'It\'s time for $prayerName prayer',
          scheduledTime: scheduledTime,
          sound: 'athan_sound',
        );

        if (preAdhanEnabled) {
          final preAdhanTime = scheduledTime.subtract(Duration(minutes: 15));
          if (preAdhanTime.isAfter(DateTime.now())) {
            await _scheduleNotification(
              id: i * 2 + 1,
              title: '$prayerName in 15 Minutes',
              body: 'Get ready for $prayerName prayer',
              scheduledTime: preAdhanTime,
              sound: 'notification_sound',
            );
          }
        }
      } catch (e) {
        print('Error scheduling default notification for $prayerName: $e');
      }
    }
  }

  static DateTime _parseTimeToToday(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If the time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }
    
    return scheduledTime;
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String sound,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_notifications',
      'Prayer Times',
      channelDescription: 'Notifications for Islamic prayer times',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> testNotification() async {
    await initialize();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_notifications',
      'Test Notifications',
      channelDescription: 'Test notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999,
      'Test Notification',
      'Prayer notifications are working correctly!',
      details,
    );
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}