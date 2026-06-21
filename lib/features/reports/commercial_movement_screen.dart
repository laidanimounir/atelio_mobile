import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/loading_shimmer.dart';

class CommercialMovementScreen extends ConsumerStatefulWidget {
  const CommercialMovementScreen({super.key});
  @override ConsumerState<CommercialMovementScreen> createState() => _CommercialMovementScreenState();
}

class _CommercialMovementScreenState extends ConsumerState<CommercialMovementScreen> {
  List<Map<String, dynamic>> _rows = [];
  double _totalCA = 0, _totalCost = 0, _totalMargin = 0;
  bool _loading = true;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    final svc = ref.read(supabaseServiceProvider);
    if (cid == null) return;
    try {
      final data = await svc.client.from('commercialsalesinvoicelines').select('*, invoice:commercialsalesinvoices(invoicenumber,invoicedate,customerid,customername)').eq('companyid', cid.toString()).limit(200);
      double ca = 0, cost = 0;
      final rows = <Map<String, dynamic>>[];
      for (final j in data) {
        final inv = j['invoice'];
        final invMap = inv is List ? (inv.isNotEmpty ? inv[0] : null) : inv;
        final qty = double.tryParse(j['quantity']?.toString() ?? '0') ?? 0;
        final price = double.tryParse(j['unitprice']?.toString() ?? '0') ?? 0;
        final costPrice = double.tryParse(j['costprice']?.toString() ?? '0') ?? 0;
        final lineTotal = qty * price;
        final lineCost = qty * costPrice;
        ca += lineTotal;
        cost += lineCost;
        rows.add({
          'number': invMap?['invoicenumber'] ?? '',
          'date': invMap?['invoicedate'] ?? '',
          'customer': invMap?['customername'] ?? '',
          'product': j['commercialproductid'] ?? '',
          'qty': qty,
          'price': price,
          'total': lineTotal,
          'costUnit': costPrice,
          'costTotal': lineCost,
          'margin': lineTotal - lineCost,
        });
      }
      setState(() { _rows = rows; _totalCA = ca; _totalCost = cost; _totalMargin = ca - cost; _loading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    return RefreshIndicator(onRefresh: _load, child: ListView(children: [
      Padding(padding: const EdgeInsets.all(16), child: GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6, children: [
        KpiCard(title: 'CA Total', value: formatCurrency(_totalCA), accentColor: AppTheme.success),
        KpiCard(title: 'Cout Achat', value: formatCurrency(_totalCost), accentColor: AppTheme.error),
        KpiCard(title: 'Marge Brute', value: formatCurrency(_totalMargin), accentColor: AppTheme.primary),
        KpiCard(title: 'Lignes', value: _rows.length.toString(), accentColor: AppTheme.primary),
      ])),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        headingRowColor: WidgetStatePropertyAll(AppTheme.primary.withAlpha(30)),
        dataRowMinHeight: 36, dataRowMaxHeight: 40, headingRowHeight: 40, columnSpacing: 10,
        columns: const [
          DataColumn(label: Text('Facture', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Date', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Client', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Qte', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('P.Vente', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Montant', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
          DataColumn(label: Text('Marge', style: TextStyle(color: AppTheme.primary, fontSize: 11))),
        ],
        rows: _rows.map((r) => DataRow(cells: [
          DataCell(Text(r['number'] ?? '', style: const TextStyle(fontSize: 11))),
          DataCell(Text(formatDate(r['date']), style: const TextStyle(fontSize: 11))),
          DataCell(Text(r['customer'] ?? '', style: const TextStyle(fontSize: 11))),
          DataCell(Text(formatStockValue(r['qty']), style: const TextStyle(fontSize: 11))),
          DataCell(Text(formatCurrency(r['price']), style: const TextStyle(fontSize: 11))),
          DataCell(Text(formatCurrency(r['total']), style: TextStyle(color: AppTheme.success, fontSize: 11))),
          DataCell(Text(formatCurrency(r['margin']), style: TextStyle(color: (r['margin'] as double) >= 0 ? AppTheme.success : AppTheme.error, fontSize: 11))),
        ])).toList(),
      )),
      Container(color: AppTheme.primary.withAlpha(30), padding: const EdgeInsets.all(12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text('CA: ${formatCurrency(_totalCA)}', style: TextStyle(color: AppTheme.success, fontSize: 14, fontWeight: FontWeight.bold)),
          Text('Cout: ${formatCurrency(_totalCost)}', style: TextStyle(color: AppTheme.error, fontSize: 14, fontWeight: FontWeight.bold)),
          Text('Marge: ${formatCurrency(_totalMargin)}', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
        ])),
    ]));
  }

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, size: 48, color: AppTheme.error), const SizedBox(height: 12),
    const Text('Failed to load', style: TextStyle(color: AppTheme.error, fontSize: 16)),
    const SizedBox(height: 16), ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
  ])));
}
