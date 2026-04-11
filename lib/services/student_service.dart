import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/student.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Service for managing student CRUD operations via Hive
class StudentService extends ChangeNotifier {
  String? _uid;

  Box<Student> get _box {
    if (_uid == null) throw Exception("StudentService not initialized with UID");
    return Hive.box<Student>(HiveBoxes.students(_uid!));
  }

  List<Student> _students = [];
  List<Student> get students => _students;

  /// Initialize the service and load students
  Future<void> init(String uid) async {
    _uid = uid;
    final boxName = HiveBoxes.students(uid);
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Student>(boxName);
    }
    _loadStudents();
  }

  /// Close box and clear memory
  Future<void> clear() async {
    _students.clear();
    _uid = null;
    notifyListeners();
  }

  /// Load all students from Hive
  void _loadStudents() {
    _students = _box.values.toList();
    _students.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    notifyListeners();
  }

  /// Get students filtered by class
  List<Student> getStudentsByClass(String className) {
    return _students.where((s) => s.className == className).toList()
      ..sort((a, b) => a.rollNo.compareTo(b.rollNo));
  }

  /// Get a single student by ID
  Student? getStudentById(String id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Check if roll number already exists in a class
  bool isRollNoDuplicate(int rollNo, String className, {String? excludeId}) {
    return _students.any(
      (s) =>
          s.rollNo == rollNo && s.className == className && s.id != excludeId,
    );
  }

  /// Add a new student
  Future<bool> addStudent({
    required String name,
    required int rollNo,
    required String className,
  }) async {
    // Check for duplicate roll number
    if (isRollNoDuplicate(rollNo, className)) {
      return false;
    }

    final student = Student(
      id: Helpers.generateId(),
      name: name.trim(),
      rollNo: rollNo,
      className: className,
    );

    await _box.put(student.id, student);
    _loadStudents();
    return true;
  }

  /// Update an existing student
  Future<bool> updateStudent({
    required String id,
    required String name,
    required int rollNo,
    required String className,
  }) async {
    // Check for duplicate roll number (excluding current student)
    if (isRollNoDuplicate(rollNo, className, excludeId: id)) {
      return false;
    }

    final student = _box.get(id);
    if (student == null) return false;

    student.name = name.trim();
    student.rollNo = rollNo;
    student.className = className;
    await student.save();
    _loadStudents();
    return true;
  }

  /// Delete a student by ID
  Future<void> deleteStudent(String id) async {
    await _box.delete(id);
    _loadStudents();
  }

  /// Search students by name or roll number
  List<Student> searchStudents(String query, {String? className}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return className != null ? getStudentsByClass(className) : _students;
    }

    return _students.where((s) {
      final matchesQuery =
          s.name.toLowerCase().contains(q) || s.rollNo.toString().contains(q);
      final matchesClass = className == null || s.className == className;
      return matchesQuery && matchesClass;
    }).toList();
  }

  /// Get total student count
  int get totalStudents => _students.length;

  /// Get student count by class
  int getStudentCount(String className) {
    return _students.where((s) => s.className == className).length;
  }
}
