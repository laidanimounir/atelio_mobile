import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SyncIndicator extends StatelessWidget {
  final bool? isOnline;
  final bool? isPaused;

  const SyncIndicator({super.key, this.isOnline, this.isPaused});

  @override
  Widget build(BuildContext context) {
    final color = isPaused == true ? AppTheme.primary : (isOnline == true ? AppTheme.success : AppTheme.textSecondary);
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
