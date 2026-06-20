import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.paid() => const StatusBadge(label: 'Payee', color: AppTheme.success);
  factory StatusBadge.unpaid() => const StatusBadge(label: 'Impayee', color: AppTheme.error);
  factory StatusBadge.confirmed() => const StatusBadge(label: 'Confirmee', color: AppTheme.primary);
  factory StatusBadge.pending() => const StatusBadge(label: 'En attente', color: AppTheme.primary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
