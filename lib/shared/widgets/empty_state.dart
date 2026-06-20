import 'package:flutter/material.dart';
import '../../config/theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({super.key, this.icon = Icons.inbox_outlined, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, color: AppTheme.textSecondary), textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary.withAlpha(150)), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
