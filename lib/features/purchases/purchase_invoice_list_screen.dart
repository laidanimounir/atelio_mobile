import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';

class PurchaseInvoiceListScreen extends ConsumerStatefulWidget {
  const PurchaseInvoiceListScreen({super.key});
  @override ConsumerState<PurchaseInvoiceListScreen> createState() => _PurchaseInvoiceListScreenState();
}

class _PurchaseInvoiceListScreenState extends ConsumerState<PurchaseInvoiceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab; List<PurchaseInvoice> _prod = [], _comm = []; bool _loading = true;
  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void didChangeDependencies() { super.didChangeDependencies(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider); if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    final pData = await svc.fetchTable('purchaseinvoices', companyId: cid, orderBy: 'datefacture', limit: 300);
    final cData = await svc.fetchTable('commercialpurchaseinvoices', companyId: cid, orderBy: 'invoicedate', limit: 300);
    setState(() {
      _prod = pData.map((j) => PurchaseInvoice.fromJson(j)).toList();
      _comm = cData.map((j) {
        final m = Map<String, dynamic>.from(j); m['numerofacture'] = m['invoicenumber']; m['datefacture'] = m['invoicedate']; m['montantttc'] = m['montantttc']; m['estpayee'] = '0';
        return PurchaseInvoice.fromJson(m);
      }).toList(); _loading = false;
    });
  }

  Widget _buildList(List<PurchaseInvoice> list) {
    if (list.isEmpty) return const EmptyState(title: 'No purchase invoices');
    return RefreshIndicator(onRefresh: _load, child: ListView.builder(itemCount: list.length, itemBuilder: (_, i) {
      final inv = list[i];
      return ListTile(dense: true, leading: Text(inv.numeroFacture ?? '—', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
        title: Text('Supplier #${inv.supplierId}', style: const TextStyle(fontSize: 14)),
        subtitle: Text(formatDate(inv.dateFacture), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(formatCurrency(inv.montantTtc), style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 8), inv.estPayee ? StatusBadge.paid() : StatusBadge.unpaid(),
        ]));
    }));
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    return Column(children: [
      Container(color: AppTheme.primary.withAlpha(25), padding: const EdgeInsets.all(12),
        child: TabBar(controller: _tab, tabs: const [Tab(text: 'Production'), Tab(text: 'Commercial')])),
      Expanded(child: TabBarView(controller: _tab, children: [_buildList(_prod), _buildList(_comm)])),
    ]);
  }
}
