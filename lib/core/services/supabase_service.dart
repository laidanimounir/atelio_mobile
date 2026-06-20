import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;
  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchCompanies() async {
    final res = await client.from('companies').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchTable(
    String table, {
    required int companyId,
    String? orderBy,
    bool ascending = false,
    int limit = 100,
  }) async {
    var query = client
        .from(table)
        .select()
        .eq('companyid', companyId)
        .limit(limit);
    if (orderBy != null) query = query.order(orderBy, ascending: ascending);
    final res = await query;
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>?> fetchById(String table, int id) async {
    final res =
        await client.from(table).select().eq('id', id).maybeSingle();
    return res;
  }

  Future<int> count(String table, int companyId) async {
    final res = await client
        .from(table)
        .select('id')
        .eq('companyid', companyId);
    return res.length;
  }
}
