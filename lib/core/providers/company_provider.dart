import 'package:flutter_riverpod/flutter_riverpod.dart';
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
