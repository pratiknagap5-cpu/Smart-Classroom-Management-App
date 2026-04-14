import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/attendance_service.dart';
import '../services/student_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/student_tile.dart';

class PresentStudentsScreen extends StatelessWidget {
  const PresentStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = Helpers.todayString();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Present Today'),
        backgroundColor: AppColors.paid, // Using green for "Present"
        foregroundColor: Colors.white,
      ),
      body: Consumer2<AttendanceService, StudentService>(
        builder: (context, attendanceSvc, studentSvc, _) {
          final presentRecords = attendanceSvc.getPresentTodayRecords(today);

          if (presentRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: AppColors.paid.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No students marked present yet', style: AppTextStyles.body),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: presentRecords.length,
            itemBuilder: (context, index) {
              final student = studentSvc.getStudentById(presentRecords[index].studentId);
              if (student == null) return const SizedBox.shrink();
              
              return StudentTile(student: student);
            },
          );
        },
      ),
    );
  }
}
