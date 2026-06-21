import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/loading_shimmer.dart';

class CommercialJournalScreen extends ConsumerStatefulWidget {
  const CommercialJournalScreen({super.key});
  @override ConsumerState<CommercialJournalScreen> createState() => _CommercialJournalScreenState();
}

class _CommercialJournalScreenState extends ConsumerState<CommercialJournalScreen> {
  List<Map<String, dynamic>> _customers = [];
  bool _loading = true;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    final svc = ref.read(supabaseServiceProvider);
    if (cid == null) return;
    try {
      final data = await svc.client.from('commercialsalesinvoices').select('id,customerid,customername,invoicenumber,invoicedate,montantttc').eq('companyid', cid.toString()).order('invoicedate', ascending: false).limit(300);
      final grouped = <String, Map<String, dynamic>>{};
      for (final j in data) {
        final name = (j['customername'] ?? 'Inconnu').toString();
        final key = name.isEmpty ? 'Inconnu' : name;
        if (!grouped.containsKey(key)) {
          grouped[key] = {'name': key, 'count': 0, 'ca': 0.0, 'invoices': <Map<String, dynamic>>[]};
        }
        final inv = grouped[key]!;
        inv['count'] = (inv['count'] as int) + 1;
        inv['ca'] = (inv['ca'] as double) + (double.tryParse(j['montantttc']?.toString() ?? '0') ?? 0);
        (inv['invoices'] as List).add({'number': j['invoicenumber'] ?? '', 'date': j['invoicedate'] ?? '', 'ttc': double.tryParse(j['montantttc']?.toString() ?? '0') ?? 0});
      }
      setState(() { _customers = grouped.values.toList()..sort((a, b) => (b['ca'] as double).compareTo(a['ca'] as double)); _loading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    final totalCA = _customers.fold<double>(0, (s, c) => s + (c['ca'] as double));
    return RefreshIndicator(onRefresh: _load, child: ListView(children: [
      Padding(padding: const EdgeInsets.all(16), child: GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6, children: [
        KpiCard(title: 'CA Total', value: formatCurrency(totalCA), accentColor: AppTheme.success),
        KpiCard(title: 'Clients', value: _customers.length.toString(), accentColor: AppTheme.primary),
      ])),
      ..._customers.map((c) => ExpansionTile(
        leading: Icon(Icons.person, color: AppTheme.primary),
        title: Text(c['name'], style: const TextStyle(fontSize: 14)),
        subtitle: Text('${c['count']} factures', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        trailing: Text(formatCurrency(c['ca']), style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 14)),
        children: (c['invoices'] as List).map<Widget>((inv) => ListTile(
          dense: true,
          title: Text(inv['number'] ?? '', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
          subtitle: Text(formatDate(inv['date']), style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          trailing: Text(formatCurrency(inv['ttc']), style: TextStyle(color: AppTheme.success, fontSize: 12)),
        )).toList(),
      )),
      Container(color: AppTheme.primary.withAlpha(30), padding: const EdgeInsets.all(12),
        child: Text('Total CA: ${formatCurrency(totalCA)}', style: TextStyle(color: AppTheme.success, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
    ]));
  }

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline, size: 48, color: AppTheme.error), const SizedBox(height: 12),
    const Text('Failed to load', style: TextStyle(color: AppTheme.error, fontSize: 16)),
    const SizedBox(height: 16), ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
  ])));
}
