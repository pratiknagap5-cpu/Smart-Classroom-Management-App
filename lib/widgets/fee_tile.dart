import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/fee.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Fee list tile showing student's fee status with color coding
class FeeTile extends StatelessWidget {
  final Student student;
  final Fee? fee;
  final VoidCallback? onTap;

  const FeeTile({super.key, required this.student, this.fee, this.onTap});

  Color _getStatusColor() {
    if (fee == null) return AppColors.textLight;
    switch (fee!.status) {
      case 'Paid':
        return AppColors.paid;
      case 'Partial':
        return AppColors.partial;
      case 'Unpaid':
        return AppColors.unpaid;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getStatusIcon() {
    if (fee == null) return Icons.help_outline;
    switch (fee!.status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Partial':
        return Icons.warning_amber_rounded;
      case 'Unpaid':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Roll No: ${student.rollNo}',
                      style: AppTextStyles.caption,
                    ),
                    if (fee != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _FeeChip(
                            label:
                                'Total: ${Helpers.formatCurrency(fee!.totalFee)}',
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          _FeeChip(
                            label:
                                'Paid: ${Helpers.formatCurrency(fee!.paidAmount)}',
                            color: AppColors.paid,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Remaining amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      fee?.status ?? 'No Fee',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (fee != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${Helpers.formatCurrency(fee!.remainingAmount)}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _FeeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
