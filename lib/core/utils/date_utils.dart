import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _iso8601Format = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');
  static final DateFormat _dayMonthFormat = DateFormat('EEEE, MMM dd');
  
  /// Convert DateTime to ISO8601 string for storage
  static String toIso8601(DateTime dateTime) {
    return _iso8601Format.format(dateTime.toUtc());
  }
  
  /// Parse ISO8601 string to DateTime
  static DateTime fromIso8601(String iso8601String) {
    return DateTime.parse(iso8601String).toLocal();
  }
  
  /// Format date for display
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }
  
  /// Format time for display
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }
  
  /// Format date and time for display
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }
  
  /// Format day and month
  static String formatDayMonth(DateTime dateTime) {
    return _dayMonthFormat.format(dateTime);
  }
  
  /// Check if date is within window (±hours from now)
  static bool isWithinWindow(DateTime dateTime, int windowHours) {
    final now = DateTime.now();
    final start = dateTime.subtract(Duration(hours: windowHours));
    final end = dateTime.add(Duration(hours: windowHours));
    return now.isAfter(start) && now.isBefore(end);
  }
  
  /// Check if date is in the past
  static bool isPast(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }
  
  /// Check if date is in the future
  static bool isFuture(DateTime dateTime) {
    return dateTime.isAfter(DateTime.now());
  }
  
  /// Get start of day
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  
  /// Check if two dates are on the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

