import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Helper utilities for the app
class Helpers {
  static const _uuid = Uuid();

  /// Generate a unique ID
  static String generateId() => _uuid.v4();

  /// Format date to yyyy-MM-dd string
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Format date to readable string (e.g., "11 Apr 2026")
  static String formatDateReadable(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date from string to readable
  static String formatDateStringReadable(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Get today's date as yyyy-MM-dd string
  static String todayString() {
    return formatDate(DateTime.now());
  }

  /// Parse date string to DateTime
  static DateTime? parseDate(String dateStr) {
    return DateTime.tryParse(dateStr);
  }

  /// Format currency (Indian Rupee)
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  /// Calculate percentage
  static double calculatePercentage(int value, int total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }

  /// Format percentage string
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
}
