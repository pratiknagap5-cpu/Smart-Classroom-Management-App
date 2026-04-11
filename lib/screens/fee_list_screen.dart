import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../services/fee_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/class_selector.dart';
import '../widgets/fee_tile.dart';
import 'fee_update_screen.dart';

/// Fee list screen showing students with fee status for a selected class
class FeeListScreen extends StatefulWidget {
  const FeeListScreen({super.key});

  @override
  State<FeeListScreen> createState() => _FeeListScreenState();
}

class _FeeListScreenState extends State<FeeListScreen> {
  String _selectedClass = AppConstants.classList.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fee Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Class selector
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.05),
            child: ClassSelector(
              selectedClass: _selectedClass,
              onChanged: (value) {
                if (value != null) setState(() => _selectedClass = value);
              },
            ),
          ),

          // Class fee summary
          Consumer2<StudentService, FeeService>(
            builder: (context, studentSvc, feeSvc, _) {
              final students = studentSvc.getStudentsByClass(_selectedClass);
              final studentIds = students.map((s) => s.id).toList();
              final summary = feeSvc.getClassFeeSummary(
                _selectedClass,
                studentIds,
              );

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Total Fees',
                      value: Helpers.formatCurrency(summary['totalFees'] ?? 0),
                      icon: Icons.account_balance_wallet,
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _SummaryItem(
                      label: 'Collected',
                      value: Helpers.formatCurrency(
                        summary['totalCollected'] ?? 0,
                      ),
                      icon: Icons.check_circle_outline,
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _SummaryItem(
                      label: 'Pending',
                      value: Helpers.formatCurrency(
                        summary['totalPending'] ?? 0,
                      ),
                      icon: Icons.pending_actions,
                    ),
                  ],
                ),
              );
            },
          ),

          // Student fee list
          Expanded(
            child: Consumer2<StudentService, FeeService>(
              builder: (context, studentSvc, feeSvc, _) {
                final students = studentSvc.getStudentsByClass(_selectedClass);

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.money_off,
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

                // Sort: unpaid first, then partial, then paid
                final sortedStudents = List.of(students)
                  ..sort((a, b) {
                    final feeA = feeSvc.getStudentFee(a.id);
                    final feeB = feeSvc.getStudentFee(b.id);
                    final orderMap = {'Unpaid': 0, 'Partial': 1, 'Paid': 2};
                    final orderA = orderMap[feeA?.status] ?? -1;
                    final orderB = orderMap[feeB?.status] ?? -1;
                    return orderA.compareTo(orderB);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: sortedStudents.length,
                  itemBuilder: (context, index) {
                    final student = sortedStudents[index];
                    final fee = feeSvc.getStudentFee(student.id);

                    return FeeTile(
                      student: student,
                      fee: fee,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FeeUpdateScreen(
                            student: student,
                            existingFee: fee,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
