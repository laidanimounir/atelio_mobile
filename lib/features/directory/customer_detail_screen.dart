import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  List<SalesInvoice> _invoices = [];
  double _caHt = 0, _caTtc = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    final svc = ref.read(supabaseServiceProvider);
    try {
      final data = await svc.client.from('salesinvoices').select().eq('companyid', cid).eq('customerid', widget.customer.id).order('datefacture', ascending: false);
      final invoices = data.map((j) => SalesInvoice.fromJson(j)).toList();
      double ht = 0, ttc = 0;
      for (final inv in invoices) {
        ht += double.tryParse(data.firstWhere((d) => d['id'] == inv.id)['montantht']?.toString() ?? '0') ?? 0;
        ttc += inv.montantTtc ?? 0;
      }
      setState(() { _invoices = invoices; _caHt = ht; _caTtc = ttc; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;
    return Scaffold(
      appBar: AppBar(title: Text(c.nomComplet)),
      body: _loading ? const LoadingShimmer() : _error != null ? _buildError() : ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(c.codeClient ?? 'N/A', style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 8),
              Text(c.nomComplet, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              if (c.activite != null) ...[const SizedBox(height: 4), Text(c.activite!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))],
              if (c.adresse != null) ...[const SizedBox(height: 4), Row(children: [const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary), const SizedBox(width: 4), Expanded(child: Text(c.adresse!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)))])],
            ]),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.4,
          children: [
            KpiCard(title: 'CA HT', value: formatCurrency(_caHt), accentColor: AppTheme.primary),
            KpiCard(title: 'CA TTC', value: formatCurrency(_caTtc), accentColor: AppTheme.success),
            KpiCard(title: 'Factures', value: _invoices.length.toString(), accentColor: AppTheme.primary),
          ],
        ),
        const SizedBox(height: 16),
        Text('Historique des ventes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        if (_invoices.isEmpty)
          const EmptyState(icon: Icons.receipt_long, title: 'No invoices')
        else ..._invoices.map((inv) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(inv.numeroFacture ?? 'N/A', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                subtitle: Text(formatDate(inv.dateFacture), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                trailing: Text(formatCurrency(inv.montantTtc), style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            )),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load customer', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
