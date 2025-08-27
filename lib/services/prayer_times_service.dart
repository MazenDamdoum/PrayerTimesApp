import 'package:flutter/services.dart';
import 'dart:convert';

class PrayerTimesService {
  static List<Map<String, dynamic>>? _cachedPrayerTimes;
  static DateTime? _cachedDate;

  // Get prayer times for today's date
  static Future<List<Map<String, dynamic>>> getTodaysPrayerTimes() async {
    final today = DateTime.now();
    
    // Check if we have cached data for today
    if (_cachedPrayerTimes != null && 
        _cachedDate != null && 
        _isSameDay(_cachedDate!, today)) {
      return _cachedPrayerTimes!;
    }

    // Load fresh data
    try {
      final String response = await rootBundle.loadString('assets/prayer_times.json');
      final data = json.decode(response);
      
      // Format today's date to match your JSON structure
      final String todayKey = _formatDateKey(today);
      
      // Find today's prayer times in your data structure
      final todayData = _findPrayerTimesForDate(data, todayKey);
      
      if (todayData != null) {
        _cachedPrayerTimes = todayData;
        _cachedDate = today;
        return todayData;
      } else {
        // Fallback to default times if today's data not found
        return _getDefaultPrayerTimes();
      }
    } catch (e) {
      print('Error loading prayer times: $e');
      return _getDefaultPrayerTimes();
    }
  }

  // Get prayer times for a specific date
  static Future<List<Map<String, dynamic>>> getPrayerTimesForDate(DateTime date) async {
    try {
      final String response = await rootBundle.loadString('assets/prayer_times.json');
      final data = json.decode(response);
      
      final String dateKey = _formatDateKey(date);
      final dateData = _findPrayerTimesForDate(data, dateKey);
      
      return dateData ?? _getDefaultPrayerTimes();
    } catch (e) {
      print('Error loading prayer times for date: $e');
      return _getDefaultPrayerTimes();
    }
  }

  // Helper method to find prayer times for a specific date in your JSON structure
  static List<Map<String, dynamic>>? _findPrayerTimesForDate(Map<String, dynamic> data, String dateKey) {
    // Extract prayer times from nested JSON structure with 'adhan' times
    
    if (data.containsKey(dateKey)) {
      final dayData = data[dateKey];
      final times = dayData['times'];
      
      if (times != null) {
        return [
          {'prayer': 'Fajr', 'time': times['fajr']['adhan'] ?? '05:30'},
          {'prayer': 'Dhuhr', 'time': times['dhuhr']['adhan'] ?? '12:15'},
          {'prayer': 'Asr', 'time': times['asr']['adhan'] ?? '15:45'},
          {'prayer': 'Maghrib', 'time': times['maghrib']['adhan'] ?? '18:20'},
          {'prayer': 'Isha', 'time': times['isha']['adhan'] ?? '19:45'},
        ];
      }
    }
    
    return null;
  }

  // Format date to match your JSON keys (adjust based on your format)
  static String _formatDateKey(DateTime date) {
    // Adjust this format based on how dates are stored in your prayer_times.json
    // Common formats: "2025-01-15", "January 15", "15-01-2025", etc.
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Check if two dates are the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  // Fallback prayer times if data loading fails
  static List<Map<String, dynamic>> _getDefaultPrayerTimes() {
    return [
      {'prayer': 'Fajr', 'time': '05:30'},
      {'prayer': 'Dhuhr', 'time': '12:15'},
      {'prayer': 'Asr', 'time': '15:45'},
      {'prayer': 'Maghrib', 'time': '18:20'},
      {'prayer': 'Isha', 'time': '19:45'},
    ];
  }

  // Get next prayer time (useful for countdown displays)
  static Future<Map<String, dynamic>?> getNextPrayer() async {
    final prayerTimes = await getTodaysPrayerTimes();
    final now = DateTime.now();
    
    for (final prayer in prayerTimes) {
      final prayerTime = _parseTimeToToday(prayer['time']);
      if (prayerTime.isAfter(now)) {
        return prayer;
      }
    }
    
    // If no more prayers today, return tomorrow's Fajr
    final tomorrow = now.add(Duration(days: 1));
    final tomorrowPrayers = await getPrayerTimesForDate(tomorrow);
    return tomorrowPrayers.isNotEmpty ? tomorrowPrayers[0] : null;
  }

  // Helper to parse time string to today's DateTime
  static DateTime _parseTimeToToday(String timeStr) {
    final now = DateTime.now();
    
    // Handle both "HH:MM" and "H:MM AM/PM" formats
    if (timeStr.contains(' ')) {
      // Parse time string like "5:21 AM" or "1:33 PM"
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      
      // Convert to 24-hour format
      if (parts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return DateTime(now.year, now.month, now.day, hour, minute);
    } else {
      // Handle legacy "HH:MM" format
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
  }

  // Clear cache (useful when date changes)
  static void clearCache() {
    _cachedPrayerTimes = null;
    _cachedDate = null;
  }
}