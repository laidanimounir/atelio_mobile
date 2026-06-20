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

class SupplierDetailScreen extends ConsumerStatefulWidget {
  final Supplier supplier;
  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  ConsumerState<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends ConsumerState<SupplierDetailScreen> {
  List<PurchaseInvoice> _invoices = [];
  double _ht = 0, _ttc = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    final svc = ref.read(supabaseServiceProvider);
    try {
      final data = await svc.client.from('purchaseinvoices').select().eq('companyid', cid).eq('supplierid', widget.supplier.id).order('datefacture', ascending: false);
      final invoices = data.map((j) => PurchaseInvoice.fromJson(j)).toList();
      double ht = 0, ttc = 0;
      for (int i = 0; i < invoices.length; i++) {
        ht += double.tryParse(data[i]['montantht']?.toString() ?? '0') ?? 0;
        ttc += double.tryParse(data[i]['montantttc']?.toString() ?? '0') ?? 0;
      }
      setState(() { _invoices = invoices; _ht = ht; _ttc = ttc; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.supplier;
    return Scaffold(
      appBar: AppBar(title: Text(s.designation)),
      body: _loading ? const LoadingShimmer() : _error != null ? _buildError() : ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(s.codeFournisseur ?? 'N/A', style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 8),
            Text(s.designation, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            if (s.activite != null) ...[const SizedBox(height: 4), Text(s.activite!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))],
          ])),
        ),
        const SizedBox(height: 12),
        GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.4,
          children: [
            KpiCard(title: 'Total HT', value: formatCurrency(_ht), accentColor: AppTheme.primary),
            KpiCard(title: 'Total TTC', value: formatCurrency(_ttc), accentColor: AppTheme.success),
            KpiCard(title: 'Factures', value: _invoices.length.toString(), accentColor: AppTheme.primary),
          ],
        ),
        const SizedBox(height: 16),
        Text('Historique des achats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        if (_invoices.isEmpty) const EmptyState(icon: Icons.receipt_long, title: 'No purchase invoices')
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
        const Text('Failed to load supplier', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
