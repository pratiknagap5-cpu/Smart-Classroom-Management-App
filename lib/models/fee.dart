import 'package:hive/hive.dart';

part 'fee.g.dart';

@HiveType(typeId: 2)
class Fee extends HiveObject {
  @HiveField(0)
  final String studentId;

  @HiveField(1)
  double totalFee;

  @HiveField(2)
  double paidAmount;

  @HiveField(3)
  double remainingAmount;

  @HiveField(4)
  String status; // Paid / Partial / Unpaid

  Fee({
    required this.studentId,
    required this.totalFee,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
  });

  /// Auto-calculate remaining and status
  void recalculate() {
    remainingAmount = totalFee - paidAmount;
    if (remainingAmount < 0) remainingAmount = 0;
    if (paidAmount >= totalFee) {
      status = 'Paid';
    } else if (paidAmount > 0) {
      status = 'Partial';
    } else {
      status = 'Unpaid';
    }
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'totalFee': totalFee,
    'paidAmount': paidAmount,
    'remainingAmount': remainingAmount,
    'status': status,
  };

  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
    studentId: json['studentId'] as String,
    totalFee: (json['totalFee'] as num).toDouble(),
    paidAmount: (json['paidAmount'] as num).toDouble(),
    remainingAmount: (json['remainingAmount'] as num).toDouble(),
    status: json['status'] as String,
  );
}
