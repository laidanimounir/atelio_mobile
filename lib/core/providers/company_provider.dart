import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((_) => SupabaseService());

final companiesProvider = FutureProvider<List<Company>>((ref) async {
  final svc = ref.read(supabaseServiceProvider);
  final data = await svc.fetchCompanies();
  return data.map((j) => Company.fromJson(j)).toList();
});

final selectedCompanyProvider = StateProvider<Company?>((_) => null);

final selectedCompanyIdProvider = Provider<int?>((ref) {
  return ref.watch(selectedCompanyProvider)?.companyId;
});

enum ConnectivityState { online, offline, syncing, paused }

final connectivityStateProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier(ref);
});

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final Ref _ref;
  bool _running = false;

  ConnectivityNotifier(this._ref) : super(ConnectivityState.offline) {
    _startPolling();
  }

  void _startPolling() {
    if (_running) return;
    _running = true;
    _check();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      return _running;
    }).then((_) {});
  }

  Future<void> _check() async {
    try {
      final svc = _ref.read(supabaseServiceProvider);
      await svc.client.from('sync_logs').select().limit(1);
      state = ConnectivityState.online;
    } catch (_) {
      state = ConnectivityState.offline;
    }
  }

  void setSyncing() => state = ConnectivityState.syncing;
  void setPaused() => state = ConnectivityState.paused;

  @override
  void dispose() {
    _running = false;
    super.dispose();
  }
}
