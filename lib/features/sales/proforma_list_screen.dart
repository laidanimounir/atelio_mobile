import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/loading_shimmer.dart';
import '../../shared/widgets/empty_state.dart';

class ProformaListScreen extends ConsumerStatefulWidget {
  const ProformaListScreen({super.key});
  @override ConsumerState<ProformaListScreen> createState() => _ProformaListScreenState();
}

class _ProformaListScreenState extends ConsumerState<ProformaListScreen> {
  List<SalesInvoice> _items = [];
  bool _loading = true;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    try {
      final data = await svc.client.from('salesinvoices').select().eq('companyid', cid.toString()).eq('isproforma', 'true').order('datefacture', ascending: false).limit(200);
      setState(() { _items = data.map((j) => SalesInvoice.fromJson(j)).toList(); _loading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    return RefreshIndicator(onRefresh: _load, child: _items.isEmpty ? const EmptyState(title: 'No proforma invoices') : ListView.builder(itemCount: _items.length, itemBuilder: (_, i) {
      final inv = _items[i];
      return ListTile(
        dense: true,
        leading: Text(inv.numeroFacture ?? '—', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
        title: Text('Client #${inv.customerId}', style: const TextStyle(fontSize: 14)),
        subtitle: Text(formatDate(inv.dateFacture), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: Text(formatCurrency(inv.montantTtc), style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
        onTap: () => context.push(AppRoutes.salesInvoiceDetail, extra: inv),
      );
    }));
  }

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, size: 48, color: AppTheme.error), const SizedBox(height: 12),
    const Text('Failed to load', style: TextStyle(color: AppTheme.error, fontSize: 16)),
    const SizedBox(height: 16), ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
  ])));
}
