import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/providers/company_provider.dart';

class SyncIndicator extends StatelessWidget {
  final ConnectivityState state;
  const SyncIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      ConnectivityState.online => AppTheme.success,
      ConnectivityState.syncing => AppTheme.primary,
      ConnectivityState.paused => AppTheme.primary,
      ConnectivityState.offline => AppTheme.error,
    };
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
