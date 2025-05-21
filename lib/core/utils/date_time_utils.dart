import 'package:intl/intl.dart';

/// Utility class for date and time operations
class DateTimeUtils {
  /// Format date as a short string (e.g., "Today", "Tomorrow", "May 15")
  static String formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
      // For dates within the current year, omit the year
      final format = date.year == now.year
          ? DateFormat('MMM d')  // e.g., "May 15"
          : DateFormat('MMM d, y');  // e.g., "May 15, 2023"
      return format.format(date);
    }
  }
  
  /// Format date for input (yyyy-MM-dd)
  static String formatDateForInput(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Parse date from input (yyyy-MM-dd)
  static DateTime? parseDateFromInput(String input) {
    try {
      return DateFormat('yyyy-MM-dd').parse(input);
    } catch (e) {
      return null;
    }
  }
  
  /// Format time (HH:mm)
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  /// Format time including seconds (HH:mm:ss)
  static String formatTimeWithSeconds(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }
  
  /// Format date and time (e.g., "May 15, 2023 at 14:30")
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y \'at\' HH:mm').format(dateTime);
  }
  
  /// Get start of day (midnight)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Get end of day (23:59:59.999)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    // Adjust to Monday (1 = Monday, 7 = Sunday in DateTime.weekday)
    final diff = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: diff)));
  }
  
  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    // Adjust to Sunday
    final diff = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: diff)));
  }
  
  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  /// Get relative time string (e.g., "2 hours ago", "just now")
  static String getRelativeTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return formatDateShort(dateTime);
    }
  }
} 