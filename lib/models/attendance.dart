import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 1)
class Attendance extends HiveObject {
  @HiveField(0)
  final String studentId;

  @HiveField(1)
  final String className;

  @HiveField(2)
  final String date; // Format: yyyy-MM-dd

  @HiveField(3)
  String status; // Present / Absent

  Attendance({
    required this.studentId,
    required this.className,
    required this.date,
    required this.status,
  });

  /// Composite key: studentId_date
  @override
  String get key => '${studentId}_$date';

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'className': className,
    'date': date,
    'status': status,
  };

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    studentId: json['studentId'] as String,
    className: json['className'] as String,
    date: json['date'] as String,
    status: json['status'] as String,
  );
}
