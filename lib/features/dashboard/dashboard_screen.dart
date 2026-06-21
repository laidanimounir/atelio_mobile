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
  String? _error;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) { _initialized = true; _load(); }
  }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    if (cid == null) {
      setState(() { _error = 'No company selected'; _loading = false; });
      return;
    }
    final cidStr = cid.toString();
    final svc = ref.read(supabaseServiceProvider);
    setState(() { _loading = true; _error = null; });

    int cust = 0, supp = 0, prod = 0;
    double ca = 0;
    List<Product> prods = [];
    List<SyncLog> logs = [];
    final errors = <String>[];

    try {
      cust = await svc.count('customers', cid);
    } catch (e) { errors.add('customers: $e'); }
    try {
      supp = await svc.count('suppliers', cid);
    } catch (e) { errors.add('suppliers: $e'); }
    try {
      prod = await svc.count('products', cid);
    } catch (e) { errors.add('products count: $e'); }
    try {
      final prodData = await svc.fetchTable('products', companyId: cid, limit: 200);
      prods = prodData.map((j) => Product.fromJson(j)).toList();
    } catch (e) { errors.add('products fetch: $e'); }
    try {
      final invData = await svc.client.from('salesinvoices').select('montantttc').eq('companyid', cidStr);
      for (final r in invData) {
        ca += double.tryParse(r['montantttc']?.toString() ?? '0') ?? 0;
      }
    } catch (e) { errors.add('salesinvoices: $e'); }
    try {
      final logsData = await svc.client.from('sync_logs').select().eq('companyid', cidStr).order('created_at', ascending: false).limit(10);
      logs = logsData.map((j) => SyncLog.fromJson(j)).toList();
    } catch (e) { errors.add('sync_logs: $e'); }

    if (!mounted) return;
    if (errors.isNotEmpty) {
      setState(() { _error = errors.join('\n'); _loading = false; });
      return;
    }

    final lowS = prods.where((p) {
      final sa = double.tryParse(p.stockActuel ?? '0') ?? 0;
      final sm = double.tryParse(p.stockMin ?? '0') ?? 0;
      return sa <= sm;
    }).toList();

    setState(() {
      _custCount = cust; _suppCount = supp; _prodCount = prod;
      _lowStock = lowS; _caTotal = ca; _recentActivity = logs; _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 12),
            const Text('Failed to load dashboard', style: TextStyle(color: AppTheme.error, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
