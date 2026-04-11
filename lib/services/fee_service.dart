import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/fee.dart';
import '../utils/constants.dart';

/// Service for managing fee records via Hive
class FeeService extends ChangeNotifier {
  String? _uid;

  Box<Fee> get _box {
    if (_uid == null) throw Exception("FeeService not initialized with UID");
    return Hive.box<Fee>(HiveBoxes.fees(_uid!));
  }

  /// Initialize the service
  Future<void> init(String uid) async {
    _uid = uid;
    final boxName = HiveBoxes.fees(uid);
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Fee>(boxName);
    }
  }

  /// Close box and clear memory
  Future<void> clear() async {
    _uid = null;
    notifyListeners();
  }

  /// Get fee record for a student
  Fee? getStudentFee(String studentId) {
    return _box.get(studentId);
  }

  /// Save or update fee for a student
  Future<void> saveFee({
    required String studentId,
    required double totalFee,
    required double paidAmount,
  }) async {
    final existing = _box.get(studentId);

    if (existing != null) {
      existing.totalFee = totalFee;
      existing.paidAmount = paidAmount;
      existing.recalculate();
      await existing.save();
    } else {
      final fee = Fee(
        studentId: studentId,
        totalFee: totalFee,
        paidAmount: paidAmount,
        remainingAmount: totalFee - paidAmount,
        status: paidAmount >= totalFee
            ? 'Paid'
            : paidAmount > 0
            ? 'Partial'
            : 'Unpaid',
      );
      fee.recalculate();
      await _box.put(studentId, fee);
    }
    notifyListeners();
  }

  /// Get total fees pending across all students
  double getTotalPending() {
    double pending = 0;
    for (final fee in _box.values) {
      pending += fee.remainingAmount;
    }
    return pending;
  }

  /// Get total fees collected across all students
  double getTotalCollected() {
    double collected = 0;
    for (final fee in _box.values) {
      collected += fee.paidAmount;
    }
    return collected;
  }

  /// Get class-wise fee summary
  Map<String, double> getClassFeeSummary(
    String className,
    List<String> studentIds,
  ) {
    double totalCollected = 0;
    double totalPending = 0;
    double totalFees = 0;

    for (final id in studentIds) {
      final fee = _box.get(id);
      if (fee != null) {
        totalFees += fee.totalFee;
        totalCollected += fee.paidAmount;
        totalPending += fee.remainingAmount;
      }
    }

    return {
      'totalFees': totalFees,
      'totalCollected': totalCollected,
      'totalPending': totalPending,
    };
  }

  /// Get number of students with pending fees
  int getPendingFeeCount() {
    return _box.values.where((f) => f.status != 'Paid').length;
  }

  /// Get all fee records (for backup)
  List<Fee> getAllFees() {
    return _box.values.toList();
  }

  /// Delete fee record for a student
  Future<void> deleteStudentFee(String studentId) async {
    await _box.delete(studentId);
    notifyListeners();
  }
}
