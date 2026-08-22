import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy h:mm a');

  static String formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return _shortDate.format(date);
  }

  static String formatIsoDate(DateTime date) {
    return _isoDate.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return _dateTime.format(date);
  }

  static DateTime? parseIsoDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static bool isOverdue(DateTime? dueDate, bool isDone) {
    if (dueDate == null || isDone) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isThisWeek(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final startDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDay = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
    
    return date.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
        date.isBefore(endDay.add(const Duration(seconds: 1)));
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays == 0 && difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
