import 'package:intl/intl.dart';

class EventDateUtils {
  // Format date to display in event list
  static String formatListDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  // Format date to display in event details
  static String formatDetailDate(DateTime date) {
    final DateFormat formatter = DateFormat('EEEE, MMMM d, yyyy');
    return formatter.format(date);
  }

  // Format time to display in event activities
  static String formatTime(DateTime time) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(time);
  }

  // Format date range for activities
  static String formatTimeRange(DateTime start, DateTime end) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  // Check if date is within next week
  static bool isWithinNextWeek(DateTime date) {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return date.isAfter(now) && date.isBefore(nextWeek);
  }
}