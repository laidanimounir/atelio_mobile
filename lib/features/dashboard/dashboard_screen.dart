import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/models/all_models.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _custCount = 0, _suppCount = 0, _prodCount = 0;
  double _caTotal = 0;
  List<Product> _lowStock = [];
  List<SyncLog> _recentActivity = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    setState(() => _loading = true);

    final cust = await svc.count('customers', cid);
    final supp = await svc.count('suppliers', cid);
    final prod = await svc.count('products', cid);
    final prodData = await svc.fetchTable('products', companyId: cid, limit: 200);
    final prods = prodData.map((j) => Product.fromJson(j)).toList();
    final lowS = prods.where((p) {
      final sa = double.tryParse(p.stockActuel ?? '0') ?? 0;
      final sm = double.tryParse(p.stockMin ?? '0') ?? 0;
      return sa <= sm;
    }).toList();
    final invData = await svc.client.from('salesinvoices').select('montantttc').eq('companyid', cid);
    double ca = 0;
    for (final r in invData) {
      ca += double.tryParse(r['montantttc']?.toString() ?? '0') ?? 0;
    }
    final logsData = await svc.client.from('sync_logs').select().order('created_at', ascending: false).limit(10);
    final logs = logsData.map((j) => SyncLog.fromJson(j)).toList();

    setState(() {
      _custCount = cust; _suppCount = supp; _prodCount = prod;
      _lowStock = lowS; _caTotal = ca; _recentActivity = logs; _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6,
          children: [
            KpiCard(title: 'Total Clients', value: _custCount.toString(), icon: Icons.people, accentColor: AppTheme.primary),
            KpiCard(title: 'Total Fournisseurs', value: _suppCount.toString(), icon: Icons.business, accentColor: AppTheme.primary),
            KpiCard(title: 'CA Total TTC', value: formatCurrency(_caTotal), accentColor: AppTheme.success),
            KpiCard(title: 'Produits en stock', value: _prodCount.toString(), icon: Icons.inventory, accentColor: AppTheme.primary),
          ],
        ),
        const SizedBox(height: 20),
        Text('Alertes Stock', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        if (_lowStock.isEmpty)
          const EmptyState(icon: Icons.check_circle_outline, title: 'No low stock items', subtitle: 'All products are above minimum')
        else ..._lowStock.map((p) => ListTile(
              dense: true, leading: Icon(Icons.warning_amber, color: AppTheme.error, size: 20),
              title: Text(p.nom, style: const TextStyle(fontSize: 13)),
              subtitle: Text('Stock: ${p.stockActuel ?? "0"} / Min: ${p.stockMin ?? "0"}', style: TextStyle(color: AppTheme.error, fontSize: 11)),
            )),
        const SizedBox(height: 20),
        Text('Activite Recente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        if (_recentActivity.isEmpty)
          const EmptyState(icon: Icons.history, title: 'No activity yet')
        else ..._recentActivity.map((l) => ListTile(
              dense: true, leading: Icon(l.success ? Icons.check_circle : Icons.error, color: l.success ? AppTheme.success : AppTheme.error, size: 18),
              title: Text(l.type, style: const TextStyle(fontSize: 13)),
              subtitle: Text(formatDateTime(l.createdAt), style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            )),
      ]),
    );
  }
}
