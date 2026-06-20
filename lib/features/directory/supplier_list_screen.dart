import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/custom_search_bar.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});
  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  bool _loading = true;
  List<Supplier> _all = [], _filtered = [];

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider); if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    final data = await svc.fetchTable('suppliers', companyId: cid, limit: 500);
    final list = data.map((j) => Supplier.fromJson(j)).toList();
    setState(() { _all = list; _filtered = list; _loading = false; });
  }

  void _search(String q) {
    setState(() { _filtered = q.isEmpty ? _all : _all.where((s) => s.designation.toLowerCase().contains(q.toLowerCase())).toList(); });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    final actif = _all.where((s) => s.estActif).length;
    final dette = _all.fold<double>(0, (sum, s) => sum + (s.dette ?? 0));
    return RefreshIndicator(onRefresh: _load, child: ListView(children: [
      Container(color: AppTheme.primary.withAlpha(25), padding: const EdgeInsets.all(16),
        child: Text('Gestion des Fournisseurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary))),
      Padding(padding: const EdgeInsets.all(16), child: GridView.count(crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
          children: [
            KpiCard(title: 'Total', value: _all.length.toString(), accentColor: AppTheme.primary),
            KpiCard(title: 'Actifs', value: actif.toString(), accentColor: AppTheme.success),
            KpiCard(title: 'Dette Totale', value: formatCurrency(dette), accentColor: AppTheme.error),
            KpiCard(title: 'Inactifs', value: (_all.length - actif).toString(), accentColor: AppTheme.textSecondary),
          ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: CustomSearchBar(onChanged: _search)),
      const SizedBox(height: 8),
      if (_filtered.isEmpty) const EmptyState(title: 'No suppliers')
      else ..._filtered.map((s) => ListTile(
            dense: true, leading: Text(s.codeFournisseur ?? '—', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            title: Text(s.designation, style: const TextStyle(fontSize: 14)),
            trailing: Text(formatCurrency(s.dette), style: TextStyle(color: (s.dette ?? 0) > 0 ? AppTheme.error : AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
          )),
    ]));
  }
}
