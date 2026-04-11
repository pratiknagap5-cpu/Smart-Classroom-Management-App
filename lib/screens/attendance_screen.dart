import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../services/attendance_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/class_selector.dart';
import '../widgets/attendance_tile.dart';
import 'add_edit_student_screen.dart';

/// Attendance marking screen: select class → date → mark students
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedClass = AppConstants.classList.first;
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _statuses = {}; // studentId -> status
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingAttendance();
  }

  void _loadExistingAttendance() {
    final attendanceSvc = context.read<AttendanceService>();
    final studentSvc = context.read<StudentService>();
    final dateStr = Helpers.formatDate(_selectedDate);
    final students = studentSvc.getStudentsByClass(_selectedClass);

    _statuses.clear();
    for (final student in students) {
      final record = attendanceSvc.getAttendance(student.id, dateStr);
      _statuses[student.id] = record?.status ?? 'Present';
    }
    if (mounted) setState(() {});
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadExistingAttendance();
    }
  }

  void _markAllPresent() {
    final studentSvc = context.read<StudentService>();
    final students = studentSvc.getStudentsByClass(_selectedClass);
    setState(() {
      for (final s in students) {
        _statuses[s.id] = 'Present';
      }
    });
  }

  Future<void> _saveAttendance() async {
    if (_statuses.isEmpty) return;

    setState(() => _isSaving = true);

    final attendanceSvc = context.read<AttendanceService>();
    final dateStr = Helpers.formatDate(_selectedDate);

    await attendanceSvc.saveBatchAttendance(
      className: _selectedClass,
      date: dateStr,
      studentStatuses: _statuses,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attendance saved for $_selectedClass on ${Helpers.formatDateReadable(_selectedDate)}',
        ),
        backgroundColor: AppColors.paid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _markAllPresent,
            tooltip: 'Mark All Present',
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditStudentScreen(initialClass: _selectedClass),
                ),
              );
              _loadExistingAttendance();
            },
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Expanded(
                  child: ClassSelector(
                    selectedClass: _selectedClass,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedClass = value);
                        _loadExistingAttendance();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Helpers.formatDateReadable(_selectedDate),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Attendance summary bar
          Consumer2<StudentService, AttendanceService>(
            builder: (context, studentSvc, attendanceSvc, _) {
              final students = studentSvc.getStudentsByClass(_selectedClass);
              final present = _statuses.values
                  .where((s) => s == 'Present')
                  .length;
              final absent = _statuses.values
                  .where((s) => s == 'Absent')
                  .length;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                      label: 'Total',
                      value: '${students.length}',
                      color: AppColors.primary,
                    ),
                    _StatChip(
                      label: 'Present',
                      value: '$present',
                      color: AppColors.present,
                    ),
                    _StatChip(
                      label: 'Absent',
                      value: '$absent',
                      color: AppColors.absent,
                    ),
                  ],
                ),
              );
            },
          ),

          // Student list
          Expanded(
            child: Consumer<StudentService>(
              builder: (context, studentSvc, _) {
                final students = studentSvc.getStudentsByClass(_selectedClass);

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No students in $_selectedClass',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return AttendanceTile(
                      student: student,
                      status: _statuses[student.id] ?? 'Present',
                      onStatusChanged: (status) {
                        setState(() {
                          _statuses[student.id] = status;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Attendance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
