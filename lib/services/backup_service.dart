import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/fee.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Service for exporting app data as JSON backup
class BackupService {
  /// Export all data as a JSON file and share it
  static Future<String> exportData() async {
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

      // Save to app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'classroom_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Smart Classroom Backup',
        text:
            'Classroom data backup - ${Helpers.formatDateReadable(DateTime.now())}',
      );

      return file.path;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }
}
