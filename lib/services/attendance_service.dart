import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/attendance.dart';
import '../utils/constants.dart';

/// Service for managing attendance records via Hive
class AttendanceService extends ChangeNotifier {
  String? _uid;

  Box<Attendance> get _box {
    if (_uid == null) throw Exception("AttendanceService not initialized with UID");
    return Hive.box<Attendance>(HiveBoxes.attendance(_uid!));
  }

  /// Initialize the service
  Future<void> init(String uid) async {
    _uid = uid;
    final boxName = HiveBoxes.attendance(uid);
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Attendance>(boxName);
    }
  }

  /// Close box and clear memory
  Future<void> clear() async {
    _uid = null;
    notifyListeners();
  }

  /// Get attendance key (studentId_date)
  String _getKey(String studentId, String date) => '${studentId}_$date';

  /// Get attendance record for a student on a specific date
  Attendance? getAttendance(String studentId, String date) {
    final key = _getKey(studentId, date);
    return _box.get(key);
  }

  /// Get all attendance records for a specific class and date
  List<Attendance> getClassAttendance(String className, String date) {
    return _box.values
        .where((a) => a.className == className && a.date == date)
        .toList();
  }

  /// Save or update attendance for a single student
  Future<void> saveAttendance({
    required String studentId,
    required String className,
    required String date,
    required String status,
  }) async {
    final key = _getKey(studentId, date);
    final existing = _box.get(key);

    if (existing != null) {
      // Update existing record
      existing.status = status;
      await existing.save();
    } else {
      // Create new record
      final attendance = Attendance(
        studentId: studentId,
        className: className,
        date: date,
        status: status,
      );
      await _box.put(key, attendance);
    }
    notifyListeners();
  }

  /// Save attendance for multiple students at once (batch save)
  Future<void> saveBatchAttendance({
    required String className,
    required String date,
    required Map<String, String> studentStatuses, // studentId -> status
  }) async {
    for (final entry in studentStatuses.entries) {
      await saveAttendance(
        studentId: entry.key,
        className: className,
        date: date,
        status: entry.value,
      );
    }
    notifyListeners();
  }

  /// Check if attendance exists for a class on a date
  bool hasAttendance(String className, String date) {
    return _box.values.any((a) => a.className == className && a.date == date);
  }

  /// Get present count for a class on a date
  int getPresentCount(String className, String date) {
    return _box.values
        .where(
          (a) =>
              a.className == className &&
              a.date == date &&
              a.status == 'Present',
        )
        .length;
  }

  /// Get absent count for a class on a date
  int getAbsentCount(String className, String date) {
    return _box.values
        .where(
          (a) =>
              a.className == className &&
              a.date == date &&
              a.status == 'Absent',
        )
        .length;
  }

  /// Get total present today across all classes
  int getTotalPresentToday(String today) {
    return _box.values
        .where((a) => a.date == today && a.status == 'Present')
        .length;
  }

  /// Get total absent today across all classes
  int getTotalAbsentToday(String today) {
    return _box.values
        .where((a) => a.date == today && a.status == 'Absent')
        .length;
  }

  /// Get attendance stats for a student
  Map<String, int> getStudentAttendanceStats(String studentId) {
    final records = _box.values.where((a) => a.studentId == studentId).toList();
    final present = records.where((a) => a.status == 'Present').length;
    final absent = records.where((a) => a.status == 'Absent').length;
    return {'total': records.length, 'present': present, 'absent': absent};
  }

  /// Get all attendance records for a student
  List<Attendance> getStudentAttendanceRecords(String studentId) {
    return _box.values.where((a) => a.studentId == studentId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get all attendance records (for backup)
  List<Attendance> getAllAttendance() {
    return _box.values.toList();
  }

  /// Delete attendance records for a student
  Future<void> deleteStudentAttendance(String studentId) async {
    final keysToDelete = _box.keys.where((key) {
      final record = _box.get(key);
      return record != null && record.studentId == studentId;
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
    notifyListeners();
  }
}
