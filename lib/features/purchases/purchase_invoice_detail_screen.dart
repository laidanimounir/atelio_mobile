import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/loading_shimmer.dart';

class PurchaseInvoiceDetailScreen extends ConsumerStatefulWidget {
  final PurchaseInvoice invoice;
  const PurchaseInvoiceDetailScreen({super.key, required this.invoice});

  @override
  ConsumerState<PurchaseInvoiceDetailScreen> createState() => _PurchaseInvoiceDetailScreenState();
}

class _PurchaseInvoiceDetailScreenState extends ConsumerState<PurchaseInvoiceDetailScreen> {
  List<PurchaseInvoiceLine> _lines = [];
  double _ht = 0, _tva = 0, _ttc = 0;
  String? _supplierName;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    final svc = ref.read(supabaseServiceProvider);
    final inv = widget.invoice;
    try {
      if (inv.supplierId != null) {
        final supp = await svc.client.from('suppliers').select('designation').eq('id', inv.supplierId).maybeSingle();
        _supplierName = supp?['designation'];
      }
      final lData = await svc.client.from('purchaseinvoicelines').select('*, rawmaterial:rawmaterials(designation)').eq('purchaseinvoiceid', inv.id);
      final lines = lData.map((j) {
        final rm = j['rawmaterial'];
        final rmName = rm is List ? (rm.isNotEmpty ? rm[0]['designation']?.toString() : null) : rm?['designation']?.toString();
        return PurchaseInvoiceLine(id: j['id']??0, purchaseInvoiceId: j['purchaseinvoiceid']??0, rawMaterialId: j['rawmaterialid']??0, quantite: double.tryParse(j['quantite']?.toString()??''), prixUnitaire: double.tryParse(j['prixunitaire']?.toString()??''), montantLigne: double.tryParse(j['montantligne']?.toString()??''), rawMaterialName: rmName);
      }).toList();
      double ht = 0;
      for (final l in lines) { ht += (l.quantite ?? 0) * (l.prixUnitaire ?? 0); }
      final invData = await svc.client.from('purchaseinvoices').select('montantht,montanttva,montantttc').eq('id', inv.id).maybeSingle();
      _ht = ht;
      _tva = double.tryParse(invData?['montanttva']?.toString() ?? '0') ?? 0;
      _ttc = double.tryParse(invData?['montantttc']?.toString() ?? '0') ?? 0;
      setState(() { _lines = lines; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    if (_loading) return Scaffold(appBar: AppBar(title: Text(inv.numeroFacture ?? 'Purchase')), body: const LoadingShimmer());
    if (_error != null) return Scaffold(appBar: AppBar(title: Text(inv.numeroFacture ?? 'Purchase')), body: _buildError());

    return Scaffold(
      appBar: AppBar(title: Text(inv.numeroFacture ?? 'Purchase')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(inv.numeroFacture ?? 'N/A', style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          Text(_supplierName ?? 'Supplier #${inv.supplierId}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
          const SizedBox(height: 4),
          Text(formatDate(inv.dateFacture), style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ]))),
        const SizedBox(height: 16),
        Container(
          color: AppTheme.primary.withAlpha(20),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: const [
            Expanded(flex: 4, child: Text('Matiere', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text('Qte', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 3, child: Text('P.U.', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            Expanded(flex: 3, child: Text('Total', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          ]),
        ),
        if (_lines.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No line items', style: TextStyle(color: AppTheme.textSecondary)))
        else ..._lines.map((l) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border.withAlpha(50)))),
              child: Row(children: [
                Expanded(flex: 4, child: Text(l.rawMaterialName ?? 'Matiere #${l.rawMaterialId}', style: const TextStyle(fontSize: 13))),
                Expanded(flex: 2, child: Text(formatStockValue(l.quantite), style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
                Expanded(flex: 3, child: Text(formatCurrency(l.prixUnitaire), style: const TextStyle(fontSize: 13), textAlign: TextAlign.right)),
                Expanded(flex: 3, child: Text(formatCurrency(l.montantLigne), style: TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
              ]),
            )),
        const SizedBox(height: 16),
        Card(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total HT', style: TextStyle(color: AppTheme.textSecondary)), Text(formatCurrency(_ht), style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('TVA', style: TextStyle(color: AppTheme.textSecondary)), Text(formatCurrency(_tva), style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600))]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total TTC', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)), Text(formatCurrency(_ttc), style: TextStyle(color: AppTheme.success, fontSize: 20, fontWeight: FontWeight.bold))]),
          ])),
        ),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load purchase', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
