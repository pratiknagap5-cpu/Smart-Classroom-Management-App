import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/fee.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/file_saver.dart'
    if (dart.library.io) '../utils/file_saver_mobile.dart'
    if (dart.library.html) '../utils/file_saver_web.dart';

/// Service for exporting app data as JSON backup
class BackupService {
  /// Export all data as a JSON file and share it
  static Future<void> exportData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final studentsBox = Hive.box<Student>(HiveBoxes.students(uid));
      final attendanceBox = Hive.box<Attendance>(HiveBoxes.attendance(uid));
      final feesBox = Hive.box<Fee>(HiveBoxes.fees(uid));

      final data = {
        'exportDate': Helpers.formatDateReadable(DateTime.now()),
        'appName': 'Smart Classroom Management App',
        'students': studentsBox.values.map((s) => s.toJson()).toList(),
        'attendance': attendanceBox.values.map((a) => a.toJson()).toList(),
        'fees': feesBox.values.map((f) => f.toJson()).toList(),
        'summary': {
          'totalStudents': studentsBox.length,
          'totalAttendanceRecords': attendanceBox.length,
          'totalFeeRecords': feesBox.length,
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'classroom_backup_$timestamp.json';

      // Save using platform-specific implementation
      final saver = getFileSaver();
      await saver.saveAndShare(fileName, jsonString);
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
}
