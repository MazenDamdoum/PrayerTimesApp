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
      // Schedule notifications for today
      await _scheduleNotificationsForDate(DateTime.now(), preAdhanEnabled);
      
      // Schedule notifications for tomorrow to ensure continuity
      final tomorrow = DateTime.now().add(Duration(days: 1));
      await _scheduleNotificationsForDate(tomorrow, preAdhanEnabled, startIdFrom: 100);
      
    } catch (e) {
      print('Error loading prayer times for notifications: $e');
      // Fallback to default times if loading fails
      await _scheduleDefaultNotifications(preAdhanEnabled);
    }
  }

  // Helper method to schedule notifications for a specific date
  static Future<void> _scheduleNotificationsForDate(DateTime date, bool preAdhanEnabled, {int startIdFrom = 0}) async {
    try {
      // Get prayer times for the specified date
      final prayerTimes = await PrayerTimesService.getPrayerTimesForDate(date);
      
      for (int i = 0; i < prayerTimes.length; i++) {
        final prayer = prayerTimes[i];
        final prayerName = prayer['prayer'] ?? prayerNames[i];
        final timeStr = prayer['time'] as String;
        
        try {
          final scheduledTime = _parseTimeToDateTime(timeStr, date);
          
          // Only schedule if the time is in the future
          if (scheduledTime.isAfter(DateTime.now())) {
            // Schedule main prayer notification
            await _scheduleNotification(
              id: startIdFrom + i * 2, // Even IDs for main prayers
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
                  id: startIdFrom + i * 2 + 1, // Odd IDs for pre-Adhan alerts
                  title: '$prayerName in 15 Minutes',
                  body: 'Get ready for $prayerName prayer',
                  scheduledTime: preAdhanTime,
                  sound: 'notification_sound',
                );
              }
            }
          }
        } catch (e) {
          print('Error scheduling notification for $prayerName: $e');
        }
      }
    } catch (e) {
      print('Error loading prayer times for date ${date.toString()}: $e');
    }
  }

  // Helper method to parse time string to a specific date
  static DateTime _parseTimeToDateTime(String timeStr, DateTime date) {
    // Parse time string like "5:21 AM" or "1:33 PM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    // Convert to 24-hour format
    if (parts.length > 1) {
      if (parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
    }
    
    return DateTime(date.year, date.month, date.day, hour, minute);
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
    
    // Parse time string like "5:21 AM" or "1:33 PM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    
    // Convert to 24-hour format
    if (parts.length > 1) {
      if (parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
    }
    
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

  // Method to reschedule notifications for the next day
  static Future<void> scheduleNextDayNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final preAdhanEnabled = prefs.getBool('pre_adhan_enabled') ?? false;
    
    // Schedule notifications for tomorrow (starting from ID 200 to avoid conflicts)
    final tomorrow = DateTime.now().add(Duration(days: 1));
    await _scheduleNotificationsForDate(tomorrow, preAdhanEnabled, startIdFrom: 200);
    
    print('Scheduled notifications for next day: ${tomorrow.toString().split(' ')[0]}');
  }

  // Debug method to check scheduled notifications
  static Future<void> printScheduledNotifications() async {
    final pending = await getPendingNotifications();
    print('Currently scheduled notifications: ${pending.length}');
    
    for (final notification in pending) {
      print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
    }
    
    if (pending.isEmpty) {
      print('No notifications are currently scheduled. Check if:');
      print('1. Notifications are enabled in settings');
      print('2. Prayer times are being loaded correctly');
      print('3. App has notification permissions');
    }
  }

  // Method to refresh notifications (useful when settings change)
  static Future<void> refreshNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    final preAdhanEnabled = prefs.getBool('pre_adhan_enabled') ?? false;
    
    if (notificationsEnabled) {
      await scheduleAllPrayerNotifications(preAdhanEnabled);
      print('Notifications refreshed successfully');
    } else {
      await cancelAllNotifications();
      print('All notifications cancelled - notifications disabled');
    }
  }
}