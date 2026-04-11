import 'package:flutter/material.dart';
import '../models/student.dart';
import '../utils/constants.dart';

/// Attendance row for a student with Present/Absent toggle
class AttendanceTile extends StatelessWidget {
  final Student student;
  final String status; // 'Present' or 'Absent'
  final ValueChanged<String> onStatusChanged;

  const AttendanceTile({
    super.key,
    required this.student,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'Present';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPresent
              ? AppColors.present.withValues(alpha: 0.3)
              : AppColors.absent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Student info
          CircleAvatar(
            radius: 18,
            backgroundColor: isPresent
                ? AppColors.present.withValues(alpha: 0.1)
                : AppColors.absent.withValues(alpha: 0.1),
            child: Text(
              '${student.rollNo}',
              style: TextStyle(
                color: isPresent ? AppColors.present : AppColors.absent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Roll No: ${student.rollNo}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          // Present / Absent toggle buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusButton(
                label: '✅',
                isActive: isPresent,
                activeColor: AppColors.present,
                onTap: () => onStatusChanged('Present'),
              ),
              const SizedBox(width: 8),
              _StatusButton(
                label: '❌',
                isActive: !isPresent,
                activeColor: AppColors.absent,
                onTap: () => onStatusChanged('Absent'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.15)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(label, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
