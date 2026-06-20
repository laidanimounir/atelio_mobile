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

class SalesInvoiceListScreen extends ConsumerStatefulWidget {
  const SalesInvoiceListScreen({super.key});
  @override ConsumerState<SalesInvoiceListScreen> createState() => _SalesInvoiceListScreenState();
}

class _SalesInvoiceListScreenState extends ConsumerState<SalesInvoiceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<SalesInvoice> _prod = [], _comm = [];
  Map<int, String> _customerNames = {};
  bool _loading = true;
  String? _error;
  bool _hasTwoTabs = true;
  String? _companyType;

  @override void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  bool _initialized = false;
  @override void didChangeDependencies() { super.didChangeDependencies(); if (!_initialized) { _initialized = true; _load(); } }

  String? _effectiveType() {
    final c = ref.read(selectedCompanyProvider);
    return c?.businessType?.toLowerCase();
  }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider); if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    _companyType = _effectiveType();
    _hasTwoTabs = _companyType != 'production' && _companyType != 'commercial';
    try {
    if (_companyType != 'commercial') {
      final pData = await svc.fetchTable('salesinvoices', companyId: cid, orderBy: 'datefacture', limit: 300);
      _prod = pData.map((j) => SalesInvoice.fromJson(j)).toList();
    }
    if (_companyType != 'production') {
      final cData = await svc.fetchTable('commercialsalesinvoices', companyId: cid, orderBy: 'invoicedate', limit: 300);
      _comm = cData.map((j) {
        final m = Map<String, dynamic>.from(j);
        m['numerofacture'] = m['invoicenumber']; m['datefacture'] = m['invoicedate']; m['montantttc'] = m['montantttc'];
        return SalesInvoice.fromJson(m);
      }).toList();
    }
    setState(() { _loading = false; });
    _loadCustomerNames();
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _loadCustomerNames() async {
    final allIds = <int>{};
    for (final inv in [..._prod, ..._comm]) {
      if (inv.customerId != null) allIds.add(inv.customerId!);
    }
    if (allIds.isEmpty) return;
    final svc = ref.read(supabaseServiceProvider);
    final cid = ref.read(selectedCompanyIdProvider);
    try {
      final r = await svc.client.from('customers').select('id,nomcomplet').eq('companyid', cid ?? 0);
      for (final item in r) {
        final id = item['id'];
        if (id != null && allIds.contains(id)) {
          _customerNames[id] = item['nomcomplet'] ?? '';
        }
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Widget _buildList(List<SalesInvoice> list) {
    if (list.isEmpty) return const EmptyState(title: 'No invoices');
    return RefreshIndicator(onRefresh: _load, child: ListView.builder(
        itemCount: list.length, itemBuilder: (_, i) {
      final inv = list[i];
      return ListTile(
        dense: true,
        leading: Text(inv.numeroFacture ?? '—', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
        title: Text(_customerNames[inv.customerId] ?? 'Client #${inv.customerId}', style: const TextStyle(fontSize: 14)),
        subtitle: Text(formatDate(inv.dateFacture), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: Text(formatCurrency(inv.montantTtc), style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
        onTap: () => context.push(AppRoutes.salesInvoiceDetail, extra: inv),
      );
    }));
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    if (_hasTwoTabs) {
      return Column(children: [
        Container(color: AppTheme.primary.withAlpha(25), padding: const EdgeInsets.all(12),
          child: TabBar(controller: _tab, tabs: const [Tab(text: 'Production'), Tab(text: 'Commercial')])),
        Expanded(child: TabBarView(controller: _tab, children: [_buildList(_prod), _buildList(_comm)])),
      ]);
    }
    return _buildList(_prod.isNotEmpty ? _prod : _comm);
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load invoices', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
