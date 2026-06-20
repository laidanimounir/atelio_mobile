import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/models/company.dart';

class CompanySelectorSheet extends StatefulWidget {
  final List<Company> companies;
  final void Function(Company) onSelect;

  const CompanySelectorSheet({
    super.key,
    required this.companies,
    required this.onSelect,
  });

  @override
  State<CompanySelectorSheet> createState() => _CompanySelectorSheetState();
}

class _CompanySelectorSheetState extends State<CompanySelectorSheet> {
  String _search = '';
  String? _typeFilter;

  List<Company> get _filtered {
    var list = widget.companies;
    if (_typeFilter != null) {
      list = list.where((c) => (c.businessType ?? '').toLowerCase() == _typeFilter!.toLowerCase()).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((c) => c.name.toLowerCase().contains(q) || (c.code ?? '').toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.textSecondary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Text('Select Company', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search companies...',
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', null),
                _filterChip('Production', 'production'),
                _filterChip('Commercial', 'commercial'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No companies match your search', style: TextStyle(color: AppTheme.textSecondary)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      return ListTile(
                        title: Row(
                          children: [
                            Text(c.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
                            if (c.code != null && c.code!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(c.code!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ],
                        ),
                        subtitle: c.businessType != null && c.businessType!.isNotEmpty
                            ? Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: c.businessType!.toLowerCase() == 'production' ? AppTheme.primary : AppTheme.success,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(c.businessType!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSelect(c);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _typeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _typeFilter = value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
          ),
          child: Text(label, style: TextStyle(color: selected ? Colors.white : AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
