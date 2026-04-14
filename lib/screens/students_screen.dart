import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../utils/constants.dart';
import '../widgets/student_tile.dart';
import 'add_edit_student_screen.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Students'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StudentService>(
        builder: (context, studentSvc, _) {
          final students = studentSvc.students;

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: AppColors.textLight.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No students added yet', style: AppTextStyles.body),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              return StudentTile(
                student: students[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditStudentScreen(student: students[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditStudentScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
