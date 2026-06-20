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

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  List<Customer> _all = [];
  List<Customer> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    try {
    final data = await svc.fetchTable('customers', companyId: cid, limit: 500);
    final list = data.map((j) => Customer.fromJson(j)).toList();
    setState(() { _all = list; _filtered = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty ? _all : _all.where((c) => c.nomComplet.toLowerCase().contains(q.toLowerCase()) || (c.codeClient ?? '').toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    final active = _all.where((c) => !c.estRadie).length;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(children: [
        Container(color: AppTheme.primary.withAlpha(25), padding: const EdgeInsets.all(16),
          child: Text('Gestion des Clients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary))),
        Padding(padding: const EdgeInsets.all(16), child: GridView.count(crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
            children: [
              KpiCard(title: 'Total Clients', value: _all.length.toString(), icon: Icons.people, accentColor: AppTheme.primary),
              KpiCard(title: 'Clients Actifs', value: active.toString(), accentColor: AppTheme.success),
              KpiCard(title: 'Clients Radies', value: (_all.length - active).toString(), accentColor: AppTheme.error),
              KpiCard(title: 'CA Total TTC', value: formatCurrency(_all.fold<double>(0, (s, c) => s + (c.caTtc ?? 0))), accentColor: AppTheme.success),
            ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: CustomSearchBar(hint: 'Search client...', onChanged: _search)),
        const SizedBox(height: 8),
        if (_filtered.isEmpty) const EmptyState(title: 'No clients found')
        else ..._filtered.map((c) => ListTile(
              dense: true, leading: Text(c.codeClient ?? '—', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
              title: Text(c.nomComplet, style: const TextStyle(fontSize: 14)),
              subtitle: Text(c.activite ?? '', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              trailing: Text(formatCurrency(c.caTtc), style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
              onTap: () => context.push(AppRoutes.customerDetail, extra: c),
            )),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load customers', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
