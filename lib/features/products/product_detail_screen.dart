import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/loading_shimmer.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  List<ProductRecipe> _recipes = [];
  List<StockBatch> _batches = [];
  bool _loading = true;
  String? _error;
  bool _isCommercial = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    final svc = ref.read(supabaseServiceProvider);
    _isCommercial = widget.product.codeProduit == null;
    try {
      if (!_isCommercial) {
        final rData = await svc.client.from('productrecipes').select('*, rawmaterial:rawmaterials(designation)').eq('companyid', cid ?? 0).eq('productid', widget.product.id);
        final recipes = rData.map((j) {
          final rm = j['rawmaterial'];
          final rmName = rm is List ? (rm.isNotEmpty ? rm[0]['designation']?.toString() : null) : rm?['designation']?.toString();
          return ProductRecipe(id: j['id']??0, productId: j['productid']??0, rawMaterialId: j['rawmaterialid']??0, quantiteNecessaire: double.tryParse(j['quantitenecessaire']?.toString()??''), rawMaterialName: rmName);
        }).toList();
        setState(() { _recipes = recipes; _loading = false; });
      } else {
        final bData = await svc.client.from('stockbatches').select().eq('companyid', cid ?? 0).eq('commercialproductid', widget.product.id);
        setState(() { _batches = bData.map((j) => StockBatch.fromJson(j)).toList(); _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    if (_loading) return Scaffold(appBar: AppBar(title: Text(p.nom)), body: const LoadingShimmer());
    if (_error != null) return Scaffold(appBar: AppBar(title: Text(p.nom)), body: _buildError());

    final sa = double.tryParse(p.stockActuel ?? '0') ?? 0;
    final sm = double.tryParse(p.stockMin ?? '0') ?? 0;
    final low = sa <= sm;
    final price = double.tryParse(p.prixVente ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(p.nom)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(p.codeProduit ?? 'N/A', style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          Text(p.nom, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Prix: ${formatCurrency(price)}', style: TextStyle(color: AppTheme.success, fontSize: 16)),
        ]))),
        const SizedBox(height: 12),
        Card(
          color: low ? AppTheme.error.withAlpha(20) : AppTheme.surface,
          child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            Text(low ? 'Stock Faible' : 'Stock OK', style: TextStyle(color: low ? AppTheme.error : AppTheme.success, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Column(children: [Text('Actuel', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)), const SizedBox(height: 4), Text(formatStockValue(p.stockActuel ?? '0'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold))]),
              Column(children: [Text('Min', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)), const SizedBox(height: 4), Text(formatStockValue(p.stockMin ?? '0'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold))]),
            ]),
          ])),
        ),
        if (!_isCommercial) ...[
          const SizedBox(height: 16),
          Text('Recette (BOM)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          if (_recipes.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No recipe defined', style: TextStyle(color: AppTheme.textSecondary))))
          else ..._recipes.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(r.rawMaterialName ?? 'Raw Material #${r.rawMaterialId}', style: const TextStyle(fontSize: 14)),
                  trailing: Text(formatStockValue(r.quantiteNecessaire), style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              )),
        ] else ...[
          const SizedBox(height: 16),
          Text('Lots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          if (_batches.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No stock batches', style: TextStyle(color: AppTheme.textSecondary))))
          else ..._batches.map((b) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(b.batchNumber ?? 'N/A', style: const TextStyle(fontSize: 14)),
                  subtitle: Text(b.purchaseDate != null ? formatDate(b.purchaseDate) : '', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  trailing: Text(formatStockValue(b.quantityRemaining), style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              )),
        ],
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load product', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
