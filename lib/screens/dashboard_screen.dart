import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../services/attendance_service.dart';
import '../services/fee_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/summary_card.dart';
import 'student_list_screen.dart';
import 'attendance_screen.dart';
import 'attendance_report_screen.dart';
import 'fee_list_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

/// Main dashboard with summary cards and navigation grid
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = Helpers.todayString();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Teacher! 👋',
                          style: AppTextStyles.heading.copyWith(fontSize: 26),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatDateReadable(DateTime.now()),
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Summary cards
              Consumer3<StudentService, AttendanceService, FeeService>(
                builder: (context, studentSvc, attendanceSvc, feeSvc, _) {
                  return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        SummaryCard(
                          icon: Icons.people_alt_rounded,
                          label: 'Total Students',
                          value: '${studentSvc.totalStudents}',
                          color: const Color(0xFF3B82F6), // Light blue
                        ),
                        SummaryCard(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Present Today',
                          value: '${attendanceSvc.getTotalPresentToday(today)}',
                          color: const Color(0xFF10B981), // Soft green
                        ),
                        SummaryCard(
                          icon: Icons.cancel_outlined,
                          label: 'Absent Today',
                          value: '${attendanceSvc.getTotalAbsentToday(today)}',
                          color: const Color(0xFFEF4444), // Light red
                        ),
                        SummaryCard(
                          icon: Icons.currency_rupee_rounded,
                          label: 'Fees Pending',
                          value: Helpers.formatCurrency(feeSvc.getTotalPending()),
                          color: const Color(0xFFF59E0B), // Warm yellow
                        ),
                      ],
                    );
                },
              ),
              const SizedBox(height: 32),

              // Navigation section
              const Text('Quick Actions', style: AppTextStyles.subheading),
              const SizedBox(height: 16),

              _buildNavGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavGrid(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.people_alt_rounded,
        label: 'Students',
        color: AppColors.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentListScreen()),
        ),
      ),
      _NavItem(
        icon: Icons.calendar_today_rounded,
        label: 'Attendance',
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceScreen()),
        ),
      ),
      _NavItem(
        icon: Icons.currency_rupee_rounded,
        label: 'Fees',
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FeeListScreen()),
        ),
      ),
      _NavItem(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceReportScreen()),
        ),
      ),
      _NavItem(
        icon: Icons.search_rounded,
        label: 'Search',
        color: const Color(0xFF06B6D4),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ),
      ),
      _NavItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        color: const Color(0xFF64748B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: item.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: item.color.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: item.color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
