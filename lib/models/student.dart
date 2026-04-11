import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int rollNo;

  @HiveField(3)
  String className;

  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.className,
  });

  /// Convert to JSON map for backup/export
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rollNo': rollNo,
    'className': className,
  };

  /// Create from JSON map
  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as String,
    name: json['name'] as String,
    rollNo: json['rollNo'] as int,
    className: json['className'] as String,
  );
}
