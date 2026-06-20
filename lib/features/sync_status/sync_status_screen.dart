import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/loading_shimmer.dart';

class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});
  @override ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  List<Device> _devices = [];
  List<SyncLog> _logs = [];
  bool _loading = true;
  String? _error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final cid = ref.read(selectedCompanyIdProvider);
    final svc = ref.read(supabaseServiceProvider);
    try {
    final dData = await svc.client.from('devices').select().eq('companyid', cid);
    final lData = await svc.client.from('sync_logs').select().eq('companyid', cid).order('created_at', ascending: false).limit(20);
    setState(() {
      _devices = dData.map((j) => Device.fromJson(j)).toList();
      _logs = lData.map((j) => SyncLog.fromJson(j)).toList();
      _loading = false;
    });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _togglePause(Device d) async {
    final svc = ref.read(supabaseServiceProvider);
    await svc.client.from('devices').update({'sync_paused': !d.syncPaused}).eq('id', d.id);
    _load();
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const LoadingShimmer();
    if (_error != null) return _buildError();
    return RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      const SizedBox(height: 8),
      ..._devices.map((d) => Card(
            child: ListTile(
              leading: Container(width: 10, height: 10, decoration: BoxDecoration(color: d.syncPaused ? AppTheme.primary : AppTheme.success, shape: BoxShape.circle)),
              title: Text(d.name, style: const TextStyle(fontSize: 14)),
              subtitle: Text('Last seen: ${formatDateTime(d.lastSeen)}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: d.syncPaused ? AppTheme.success : AppTheme.error, padding: const EdgeInsets.symmetric(horizontal: 12)),
                onPressed: () => _togglePause(d),
                child: Text(d.syncPaused ? 'Resume' : 'Pause', style: const TextStyle(fontSize: 12)),
              ),
            ),
          )),
      const SizedBox(height: 20),
      Text('Recent Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ..._logs.map((l) => ListTile(
            dense: true,
            leading: Icon(l.success ? Icons.check_circle : Icons.error, color: l.success ? AppTheme.success : AppTheme.error, size: 18),
            title: Text(l.type, style: const TextStyle(fontSize: 13)),
            subtitle: Text(formatDateTime(l.createdAt), style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          )),
    ]));
  }

  Widget _buildError() {
    return Center(
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        const Text('Failed to load sync status', style: TextStyle(color: AppTheme.error, fontSize: 16)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry')),
      ])),
    );
  }
}
