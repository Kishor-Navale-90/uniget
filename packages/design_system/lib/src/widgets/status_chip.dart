import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// Renders the "In Use / Maintenance / Transfer Pending" and
/// "Pending Approval / Approved" pills that show up on nearly every
/// list screen across all three feature modules.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.success(String label) => StatusChip(label: label, color: AppColors.success);
  factory StatusChip.warning(String label) => StatusChip(label: label, color: AppColors.warning);
  factory StatusChip.danger(String label) => StatusChip(label: label, color: AppColors.danger);
  factory StatusChip.neutral(String label) => StatusChip(label: label, color: AppColors.accent);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
