import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/custom_search_bar.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});
  @override ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Product> _manu = [], _comm = [];
  List<Product> _manuF = [], _commF = [];
  bool _loading = true;

  @override void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override void didChangeDependencies() { super.didChangeDependencies(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider); if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    final pData = await svc.fetchTable('products', companyId: cid, limit: 500);
    final cData = await svc.fetchTable('commercialproducts', companyId: cid, limit: 500);
    final manu = pData.map((j) => Product.fromJson(j)).toList();
    final comm = cData.map((j) => Product(id: j['id']??0, codeProduit: j['code'], nom: j['name']??'', prixVente: j['sellingpriceretail']?.toString(), stockActuel: j['stockquantity']?.toString(), stockMin: j['minstocklevel']?.toString(), companyId: j['companyid']??0)).toList();
    setState(() { _manu = manu; _comm = comm; _manuF = manu; _commF = comm; _loading = false; });
  }

  Widget _buildRow(Product p) {
    final sa = double.tryParse(p.stockActuel ?? '0') ?? 0;
    final sm = double.tryParse(p.stockMin ?? '0') ?? 0;
    final low = sa <= sm;
    return ListTile(
      dense: true, leading: low ? Icon(Icons.circle, color: AppTheme.error, size: 10) : null,
      title: Row(children: [
        Expanded(flex: 2, child: Text(p.codeProduit ?? '—', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13))),
        Expanded(flex: 4, child: Text(p.nom, style: const TextStyle(fontSize: 13))),
        Expanded(flex: 2, child: Text(formatStockValue(p.stockActuel), style: TextStyle(color: low ? AppTheme.error : AppTheme.success, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        Expanded(flex: 3, child: Text(formatCurrency(double.tryParse(p.prixVente ?? '0')), style: TextStyle(color: AppTheme.textPrimary, fontSize: 13), textAlign: TextAlign.right)),
      ]),
    );
  }

  void _search(String q, bool isManu) {
    setState(() {
      if (isManu) _manuF = q.isEmpty ? _manu : _manu.where((p) => p.nom.toLowerCase().contains(q.toLowerCase())).toList();
      else _commF = q.isEmpty ? _comm : _comm.where((p) => p.nom.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    return Column(children: [
      Container(color: AppTheme.primary.withAlpha(25), padding: const EdgeInsets.all(12),
        child: TabBar(controller: _tab, tabs: const [Tab(text: 'Production'), Tab(text: 'Commercial')])),
      Padding(padding: const EdgeInsets.all(12), child: CustomSearchBar(onChanged: (q) { _search(q, _tab.index == 0); _search(q, _tab.index == 1); })),
      Container(color: AppTheme.primary.withAlpha(20), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: const [
          Expanded(flex: 2, child: Text('Code', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 4, child: Text('Name', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Stock', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
          Expanded(flex: 3, child: Text('Price', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        ])),
      Expanded(child: TabBarView(controller: _tab, children: [
        RefreshIndicator(onRefresh: _load, child: _manuF.isEmpty ? const EmptyState(title: 'No products') : ListView.builder(itemCount: _manuF.length, itemBuilder: (_, i) => _buildRow(_manuF[i]))),
        RefreshIndicator(onRefresh: _load, child: _commF.isEmpty ? const EmptyState(title: 'No products') : ListView.builder(itemCount: _commF.length, itemBuilder: (_, i) => _buildRow(_commF[i]))),
      ])),
    ]);
  }
}
