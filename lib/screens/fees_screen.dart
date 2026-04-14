import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fee_service.dart';
import '../services/student_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/fee_tile.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pending Fees'),
        backgroundColor: const Color(0xFFF59E0B), // Warm yellow for "Pending Fees"
        foregroundColor: Colors.white,
      ),
      body: Consumer2<FeeService, StudentService>(
        builder: (context, feeSvc, studentSvc, _) {
          final pendingFees = feeSvc.getPendingFeeRecords();

          if (pendingFees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_rupee_rounded, size: 80, color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No pending fees found!', style: AppTextStyles.body),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingFees.length,
            itemBuilder: (context, index) {
              final student = studentSvc.getStudentById(pendingFees[index].studentId);
              if (student == null) return const SizedBox.shrink();
              
              return FeeTile(
                student: student,
                fee: pendingFees[index],
              );
            },
          );
        },
      ),
    );
  }
}
