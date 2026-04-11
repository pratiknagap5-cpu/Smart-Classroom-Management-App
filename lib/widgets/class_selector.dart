import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Reusable class selector dropdown (Class 1–10)
class ClassSelector extends StatelessWidget {
  final String? selectedClass;
  final ValueChanged<String?> onChanged;
  final bool showAllOption;
  final String? label;

  const ClassSelector({
    super.key,
    required this.selectedClass,
    required this.onChanged,
    this.showAllOption = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<String>>[];

    if (showAllOption) {
      items.add(
        const DropdownMenuItem(value: 'All', child: Text('All Classes')),
      );
    }

    for (final cls in AppConstants.classList) {
      items.add(DropdownMenuItem(value: cls, child: Text(cls)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTextStyles.bodySmall),
          const SizedBox(height: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedClass,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              hint: const Text('Select Class'),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
              ),
              style: AppTextStyles.body,
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
