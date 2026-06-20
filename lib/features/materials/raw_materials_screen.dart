import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/loading_shimmer.dart';

class RawMaterialsScreen extends ConsumerStatefulWidget {
  const RawMaterialsScreen({super.key});
  @override ConsumerState<RawMaterialsScreen> createState() => _RawMaterialsScreenState();
}

class _RawMaterialsScreenState extends ConsumerState<RawMaterialsScreen> {
  List<RawMaterial> _items = []; bool _loading = true; String? _error;

  @override void didChangeDependencies() { super.didChangeDependencies(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider); if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    try {
    final data = await svc.fetchTable('rawmaterials', companyId: cid, limit: 500);
    setState(() { _items = data.map((j) => RawMaterial.fromJson(j)).toList(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    final totalStock = _items.fold<double>(0, (s, m) => s + (m.pmapa ?? 0) * (m.stockActuel ?? 0));
    return RefreshIndicator(onRefresh: _load, child: ListView(children: [
      Padding(padding: const EdgeInsets.all(16), child: GridView.count(crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
          children: [
            KpiCard(title: 'Matières', value: _items.length.toString(), accentColor: AppTheme.primary),
            KpiCard(title: 'Valeur Stock', value: formatCurrency(totalStock), accentColor: AppTheme.success),
          ])),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        headingRowColor: WidgetStatePropertyAll(AppTheme.primary.withAlpha(30)),
        dataRowMinHeight: 36, dataRowMaxHeight: 40, headingRowHeight: 40,
        columnSpacing: 12, columns: const [
          DataColumn(label: Text('Code', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
          DataColumn(label: Text('Matiere', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
          DataColumn(label: Text('PMAPA', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
          DataColumn(label: Text('Stock', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
          DataColumn(label: Text('Valeur', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
        ],
        rows: _items.map((m) => DataRow(cells: [
          DataCell(Text(m.codeMatiere ?? '—', style: const TextStyle(fontSize: 12))),
          DataCell(Text(m.designation, style: const TextStyle(fontSize: 12))),
          DataCell(Text(formatCurrency(m.pmapa), style: const TextStyle(fontSize: 12))),
          DataCell(Text(formatStockValue(m.stockActuel), style: TextStyle(fontSize: 12, color: (m.stockActuel ?? 0) <= (m.stockMin ?? 0) ? AppTheme.error : AppTheme.textPrimary))),
          DataCell(Text(formatCurrency((m.pmapa ?? 0) * (m.stockActuel ?? 0)), style: const TextStyle(fontSize: 12))),
        ])).toList(),
      )),
    ]));
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load raw materials', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
