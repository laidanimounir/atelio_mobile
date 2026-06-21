import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/loading_shimmer.dart';

class RawMaterialReportScreen extends ConsumerStatefulWidget {
  const RawMaterialReportScreen({super.key});
  @override ConsumerState<RawMaterialReportScreen> createState() => _RawMaterialReportScreenState();
}

class _RawMaterialReportScreenState extends ConsumerState<RawMaterialReportScreen> {
  List<RawMaterial> _items = [];
  bool _loading = true;
  bool _negativeOnly = false;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    try {
      final data = await svc.fetchTable('rawmaterials', companyId: cid, limit: 500);
      setState(() { _items = data.map((j) => RawMaterial.fromJson(j)).toList(); _loading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    final filtered = _negativeOnly ? _items.where((m) => (m.stockActuel ?? 0) <= (m.stockMin ?? 0)).toList() : _items;
    final totalStock = _items.fold<double>(0, (s, m) => s + (m.pmapa ?? 0) * (m.stockActuel ?? 0));
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6, children: [
        KpiCard(title: 'Matieres', value: _items.length.toString(), accentColor: AppTheme.primary),
        KpiCard(title: 'Stock Negatif', value: _items.where((m) => (m.stockActuel ?? 0) < 0).length.toString(), accentColor: AppTheme.error),
        KpiCard(title: 'Valeur Stock', value: formatCurrency(totalStock), accentColor: AppTheme.success),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        const Text('Filtre:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(width: 12),
        InkWell(onTap: () => setState(() => _negativeOnly = false), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: _negativeOnly ? AppTheme.surface : AppTheme.primary, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary)), child: Text('Tous', style: TextStyle(color: _negativeOnly ? AppTheme.primary : Colors.white, fontSize: 11)))),
        const SizedBox(width: 8),
        InkWell(onTap: () => setState(() => _negativeOnly = true), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: _negativeOnly ? AppTheme.primary : AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary)), child: Text('Stock negatif', style: TextStyle(color: _negativeOnly ? Colors.white : AppTheme.primary, fontSize: 11)))),
      ])),
      const SizedBox(height: 8),
      Expanded(child: RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        headingRowColor: WidgetStatePropertyAll(AppTheme.primary.withAlpha(30)),
        dataRowMinHeight: 36, dataRowMaxHeight: 40, headingRowHeight: 40, columnSpacing: 10,
        columns: const [
          DataColumn(label: Text('Code', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Matiere', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('PMAPA', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Stock', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Min', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Valeur', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
        ],
        rows: filtered.map((m) {
          final sa = m.stockActuel ?? 0;
          final low = sa <= (m.stockMin ?? 0);
          final neg = sa < 0;
          return DataRow(
            color: WidgetStatePropertyAll(neg ? AppTheme.error.withAlpha(25) : (low ? AppTheme.primary.withAlpha(15) : null)),
            cells: [
              DataCell(Text(m.codeMatiere ?? '—', style: const TextStyle(fontSize: 11))),
              DataCell(Text(m.designation, style: const TextStyle(fontSize: 11))),
              DataCell(Text(formatCurrency(m.pmapa), style: const TextStyle(fontSize: 11))),
              DataCell(Text(formatStockValue(sa), style: TextStyle(fontSize: 11, color: neg ? AppTheme.error : (low ? AppTheme.primary : AppTheme.textPrimary), fontWeight: FontWeight.w600))),
              DataCell(Text(formatStockValue(m.stockMin ?? 0), style: const TextStyle(fontSize: 11))),
              DataCell(Text(formatCurrency((m.pmapa ?? 0) * sa), style: const TextStyle(fontSize: 11))),
            ]);
        }).toList(),
      )))),
    ]);
  }

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, size: 48, color: AppTheme.error), const SizedBox(height: 12),
    const Text('Failed to load', style: TextStyle(color: AppTheme.error, fontSize: 16)),
    const SizedBox(height: 16), ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
  ])));
}
