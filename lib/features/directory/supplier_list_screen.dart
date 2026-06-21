import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/custom_search_bar.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';
import 'supplier_form_screen.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});
  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  bool _loading = true;
  bool _loadingMore = false;
  int _offset = 0;
  int _totalCount = 0;
  static const _pageSize = 50;
  List<Supplier> _all = [], _filtered = [];
  String? _error;

  bool _initialized = false;

  @override
  void didChangeDependencies() { super.didChangeDependencies(); if (!_initialized) { _initialized = true; _load(); } }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider); if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    try {
    _offset = 0;
    final count = await svc.count('suppliers', cid);
    final data = await svc.fetchPaged('suppliers', companyId: cid, limit: _pageSize, offset: _offset);
    final list = data.map((j) => Supplier.fromJson(j)).toList();
    _offset += data.length;
    setState(() { _all = list; _filtered = list; _totalCount = count; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _all.length >= _totalCount) return;
    final cid = ref.read(selectedCompanyIdProvider); if (cid == null) return;
    setState(() => _loadingMore = true);
    try {
      final svc = ref.read(supabaseServiceProvider);
      final data = await svc.fetchPaged('suppliers', companyId: cid, limit: _pageSize, offset: _offset);
      final newItems = data.map((j) => Supplier.fromJson(j)).toList();
      _offset += data.length;
      setState(() { _all = [..._all, ...newItems]; _filtered = _all; _loadingMore = false; });
    } catch (_) { if (mounted) setState(() => _loadingMore = false); }
  }

  void _search(String q) {
    setState(() { _filtered = q.isEmpty ? _all : _all.where((s) => s.designation.toLowerCase().contains(q.toLowerCase())).toList(); });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    final actif = _all.where((s) => s.estActif).length;
    final dette = _all.fold<double>(0, (sum, s) => sum + (s.dette ?? 0));
    return Stack(children: [
      RefreshIndicator(onRefresh: _load, child: ListView(children: [
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
      const SizedBox(height: 4),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Showing ${_all.length} of $_totalCount', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center)),
      const SizedBox(height: 8),
      if (_filtered.isEmpty) const EmptyState(title: 'No suppliers')
      else ..._filtered.map((s) => ListTile(
            dense: true, leading: Text(s.codeFournisseur ?? '—', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            title: Text(s.designation, style: const TextStyle(fontSize: 14)),
            trailing: Text(formatCurrency(s.dette), style: TextStyle(color: (s.dette ?? 0) > 0 ? AppTheme.error : AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
            onTap: () => context.push(AppRoutes.supplierDetail, extra: s),
          )),
        const SizedBox(height: 8),
        if (_all.length < _totalCount)
          Padding(padding: const EdgeInsets.all(16), child: Center(child: _loadingMore
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : ElevatedButton(onPressed: _loadMore, child: const Text('Load More')))),
    ])),
      Positioned(bottom: 16, right: 16, child: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierFormScreen())); _load(); },
        child: const Icon(Icons.add, color: Colors.white),
      )),
    ]);
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load suppliers', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
