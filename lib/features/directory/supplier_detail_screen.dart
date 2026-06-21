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
import 'supplier_form_screen.dart';

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
      final data = await svc.client.from('purchaseinvoices').select().eq('companyid', cid ?? 0).eq('supplierid', widget.supplier.id).order('datefacture', ascending: false);
      final invoices = data.map((j) => PurchaseInvoice.fromJson(j)).toList();
      double ttc = 0;
      for (final inv in invoices) { ttc += inv.montantTtc ?? 0; }
      setState(() { _invoices = invoices; _ttc = ttc; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.supplier;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.designation),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => SupplierFormScreen(supplier: s)));
            _load();
          }),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error), onPressed: _deleteSupplier),
        ],
      ),
      body: _loading ? const LoadingShimmer() : _error != null ? _buildError() : ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(s.codeFournisseur ?? 'N/A', style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: s.estActif ? AppTheme.success.withAlpha(30) : AppTheme.error.withAlpha(30), borderRadius: BorderRadius.circular(4)), child: Text(s.estActif ? 'Actif' : 'Inactif', style: TextStyle(color: s.estActif ? AppTheme.success : AppTheme.error, fontSize: 11, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 8),
            Text(s.designation, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            if (s.activite != null) ...[const SizedBox(height: 4), Text(s.activite!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))],
            if (s.numeroRC != null && s.numeroRC!.isNotEmpty) ...[const SizedBox(height: 4), Text('NRC: ${s.numeroRC}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))],
            if (s.matriculeFiscal != null && s.matriculeFiscal!.isNotEmpty) ...[const SizedBox(height: 2), Text('MF: ${s.matriculeFiscal}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))],
            if (s.typeIdentification != null) ...[const SizedBox(height: 2), Text('${s.typeIdentification}: ${s.numeroIdentification ?? ""}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))],
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
      ])),
    );
  }

  Future<void> _deleteSupplier() async {
    final s = widget.supplier;
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Supprimer ce fournisseur ?'),
      content: const Text('Cette action est irreversible.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: AppTheme.error))),
      ],
    ));
    if (confirm != true || !mounted) return;
    final svc = ref.read(supabaseServiceProvider);
    try {
      final invCheck = await svc.client.from('purchaseinvoices').select('id').eq('supplierid', s.id).limit(1);
      if (invCheck.isNotEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ce fournisseur a des factures. Suppression impossible.'), backgroundColor: AppTheme.error));
        return;
      }
      await svc.client.from('suppliers').delete().eq('id', s.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fournisseur supprime'), backgroundColor: AppTheme.success)); context.pop(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.error));
    }
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
