import 'package:flutter/material.dart';

/// Hive box names
class HiveBoxes {
  static String students(String uid) => 'studentsBox_$uid';
  static String attendance(String uid) => 'attendanceBox_$uid';
  static String fees(String uid) => 'feesBox_$uid';
}

/// Class list from 1 to 10
class AppConstants {
  static const List<String> classList = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
  ];
}

/// App color palette
class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFFA5B4FC);

  // Accent
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentLight = Color(0xFFCFFAFE);

  // Status colors
  static const Color paid = Color(0xFF10B981); // Green
  static const Color partial = Color(0xFFF59E0B); // Amber
  static const Color unpaid = Color(0xFFEF4444); // Red

  // Present / Absent
  static const Color present = Color(0xFF10B981);
  static const Color absent = Color(0xFFEF4444);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Misc
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A000000);
}

/// Text styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
