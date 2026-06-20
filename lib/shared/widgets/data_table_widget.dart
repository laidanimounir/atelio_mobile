import 'package:flutter/material.dart';
import '../../config/theme.dart';

class DenseDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final Widget? footer;

  const DenseDataTable({
    super.key,
    required this.headers,
    required this.rows,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppTheme.primary.withAlpha(30),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: headers
                  .map((h) => Expanded(child: Text(h, style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600))))
                  .toList(),
            ),
          ),
          ...rows.asMap().entries.map((e) => Container(
                color: e.key.isEven ? AppTheme.bg : AppTheme.tableAlt,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: e.value),
              )),
          if (footer != null)
            Container(
              color: AppTheme.tableAlt,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: footer!,
            ),
        ],
      ),
    );
  }
}
