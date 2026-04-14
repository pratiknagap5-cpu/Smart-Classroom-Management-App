import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_service.dart';
import '../services/student_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/student_tile.dart';

class AbsentStudentsScreen extends StatelessWidget {
  const AbsentStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = Helpers.todayString();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Absent Today'),
        backgroundColor: AppColors.unpaid, // Using red for "Absent"
        foregroundColor: Colors.white,
      ),
      body: Consumer2<AttendanceService, StudentService>(
        builder: (context, attendanceSvc, studentSvc, _) {
          final absentRecords = attendanceSvc.getAbsentTodayRecords(today);

          if (absentRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 80, color: AppColors.unpaid.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No students marked absent yet', style: AppTextStyles.body),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: absentRecords.length,
            itemBuilder: (context, index) {
              final student = studentSvc.getStudentById(absentRecords[index].studentId);
              if (student == null) return const SizedBox.shrink();
              
              return StudentTile(student: student);
            },
          );
        },
      ),
    );
  }
}
