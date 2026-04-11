import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../services/attendance_service.dart';
import '../services/fee_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Detailed report screen for a single student
/// Shows: personal details, attendance stats, fee status
class StudentReportScreen extends StatelessWidget {
  final String studentId;

  const StudentReportScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final studentSvc = context.watch<StudentService>();
    final attendanceSvc = context.watch<AttendanceService>();
    final feeSvc = context.watch<FeeService>();

    final student = studentSvc.getStudentById(studentId);

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Report')),
        body: const Center(child: Text('Student not found')),
      );
    }

    final attendanceStats = attendanceSvc.getStudentAttendanceStats(studentId);
    final fee = feeSvc.getStudentFee(studentId);
    final attendancePercentage = Helpers.calculatePercentage(
      attendanceStats['present'] ?? 0,
      attendanceStats['total'] ?? 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with student info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          student.name.isNotEmpty
                              ? student.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        student.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roll No: ${student.rollNo} • ${student.className}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Student details card
                _SectionCard(
                  title: '👤 Student Details',
                  child: Column(
                    children: [
                      _DetailRow(label: 'Name', value: student.name),
                      _DetailRow(label: 'Roll No', value: '${student.rollNo}'),
                      _DetailRow(label: 'Class', value: student.className),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Attendance card
                _SectionCard(
                  title: '📅 Attendance',
                  child: Column(
                    children: [
                      // Attendance percentage circle
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getAttendanceColor(
                              attendancePercentage,
                            ).withValues(alpha: 0.1),
                            border: Border.all(
                              color: _getAttendanceColor(attendancePercentage),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              attendanceStats['total'] == 0
                                  ? 'N/A'
                                  : Helpers.formatPercentage(
                                      attendancePercentage,
                                    ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _getAttendanceColor(
                                  attendancePercentage,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: 'Total Days',
                        value: '${attendanceStats['total']}',
                      ),
                      _DetailRow(
                        label: 'Present Days',
                        value: '${attendanceStats['present']}',
                        valueColor: AppColors.present,
                      ),
                      _DetailRow(
                        label: 'Absent Days',
                        value: '${attendanceStats['absent']}',
                        valueColor: AppColors.absent,
                      ),
                      _DetailRow(
                        label: 'Attendance %',
                        value: attendanceStats['total'] == 0
                            ? 'N/A'
                            : Helpers.formatPercentage(attendancePercentage),
                        valueColor: _getAttendanceColor(attendancePercentage),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Fee card
                _SectionCard(
                  title: '💰 Fee Status',
                  child: fee == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No fee record found',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // Status badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getFeeColor(
                                    fee.status,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getFeeColor(fee.status),
                                  ),
                                ),
                                child: Text(
                                  fee.status,
                                  style: TextStyle(
                                    color: _getFeeColor(fee.status),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _DetailRow(
                              label: 'Total Fee',
                              value: Helpers.formatCurrency(fee.totalFee),
                            ),
                            _DetailRow(
                              label: 'Paid Amount',
                              value: Helpers.formatCurrency(fee.paidAmount),
                              valueColor: AppColors.paid,
                            ),
                            _DetailRow(
                              label: 'Remaining',
                              value: Helpers.formatCurrency(
                                fee.remainingAmount,
                              ),
                              valueColor: fee.remainingAmount > 0
                                  ? AppColors.unpaid
                                  : AppColors.paid,
                            ),
                          ],
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) return AppColors.paid;
    if (percentage >= 50) return AppColors.partial;
    return AppColors.unpaid;
  }

  Color _getFeeColor(String status) {
    switch (status) {
      case 'Paid':
        return AppColors.paid;
      case 'Partial':
        return AppColors.partial;
      default:
        return AppColors.unpaid;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subheading),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
