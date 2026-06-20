import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/models/company.dart';

class CompanySelectorSheet extends StatelessWidget {
  final List<Company> companies;
  final void Function(Company) onSelect;

  const CompanySelectorSheet({
    super.key,
    required this.companies,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.textSecondary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Text('Select Company', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          ...companies.map((c) => ListTile(
                title: Text(c.name, style: const TextStyle(color: AppTheme.textPrimary)),
                subtitle: c.businessType != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppTheme.primary.withAlpha(40), borderRadius: BorderRadius.circular(4)),
                        child: Text(c.businessType!, style: const TextStyle(color: AppTheme.primary, fontSize: 11)),
                      )
                    : null,
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.pop(context);
                  onSelect(c);
                },
              )),
        ],
      ),
    );
  }
}
