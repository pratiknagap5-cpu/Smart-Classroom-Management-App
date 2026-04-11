import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../models/fee.dart';
import '../services/fee_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';

/// Screen to update fee for a specific student
class FeeUpdateScreen extends StatefulWidget {
  final Student student;
  final Fee? existingFee;

  const FeeUpdateScreen({super.key, required this.student, this.existingFee});

  @override
  State<FeeUpdateScreen> createState() => _FeeUpdateScreenState();
}

class _FeeUpdateScreenState extends State<FeeUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _totalFeeController;
  late TextEditingController _paidAmountController;
  bool _isLoading = false;

  double get _totalFee => double.tryParse(_totalFeeController.text.trim()) ?? 0;
  double get _paidAmount =>
      double.tryParse(_paidAmountController.text.trim()) ?? 0;
  double get _remaining => (_totalFee - _paidAmount).clamp(0, double.infinity);

  String get _status {
    if (_totalFee <= 0) return 'Unpaid';
    if (_paidAmount >= _totalFee) return 'Paid';
    if (_paidAmount > 0) return 'Partial';
    return 'Unpaid';
  }

  Color get _statusColor {
    switch (_status) {
      case 'Paid':
        return AppColors.paid;
      case 'Partial':
        return AppColors.partial;
      default:
        return AppColors.unpaid;
    }
  }

  @override
  void initState() {
    super.initState();
    _totalFeeController = TextEditingController(
      text: widget.existingFee?.totalFee.toStringAsFixed(0) ?? '',
    );
    _paidAmountController = TextEditingController(
      text: widget.existingFee?.paidAmount.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _totalFeeController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final feeSvc = context.read<FeeService>();
    await feeSvc.saveFee(
      studentId: widget.student.id,
      totalFee: _totalFee,
      paidAmount: _paidAmount,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fee updated for ${widget.student.name}'),
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
        title: const Text('Update Fee'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Student info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        widget.student.name.isNotEmpty
                            ? widget.student.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            style: AppTextStyles.subheading,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Roll No: ${widget.student.rollNo} • ${widget.student.className}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Total fee field
              _buildLabel('Total Fee (₹)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _totalFeeController,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    Validators.validateFeeAmount(v, allowZero: false),
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(
                  hint: 'Enter total fee amount',
                  icon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(height: 24),

              // Paid amount field
              _buildLabel('Paid Amount (₹)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _paidAmountController,
                keyboardType: TextInputType.number,
                validator: (v) => Validators.validatePaidAmount(v, _totalFee),
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(
                  hint: 'Enter paid amount',
                  icon: Icons.payment,
                ),
              ),
              const SizedBox(height: 32),

              // Live preview card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Fee Summary',
                      style: AppTextStyles.subheading.copyWith(
                        color: _statusColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(
                      label: 'Total Fee',
                      value: Helpers.formatCurrency(_totalFee),
                    ),
                    const Divider(height: 16),
                    _SummaryRow(
                      label: 'Paid Amount',
                      value: Helpers.formatCurrency(_paidAmount),
                      valueColor: AppColors.paid,
                    ),
                    const Divider(height: 16),
                    _SummaryRow(
                      label: 'Remaining',
                      value: Helpers.formatCurrency(_remaining),
                      valueColor: AppColors.unpaid,
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: AppTextStyles.body),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _status,
                            style: TextStyle(
                              color: _statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save Fee',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      hintStyle: const TextStyle(color: AppColors.textLight),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.unpaid),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
