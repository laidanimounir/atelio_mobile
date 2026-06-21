import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../core/models/all_models.dart';
import '../../core/providers/company_provider.dart';
import '../../core/services/supabase_service.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomComplet, _activite, _adresse, _nrc, _mf, _nid;
  String _typeId = 'Article';
  bool _saving = false;
  String? _code;
  bool get _isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _code = c?.codeClient;
    _nomComplet = TextEditingController(text: c?.nomComplet ?? '');
    _activite = TextEditingController(text: c?.activite ?? '');
    _adresse = TextEditingController(text: c?.adresse ?? '');
    _nrc = TextEditingController(text: '');
    _mf = TextEditingController(text: '');
    _nid = TextEditingController(text: '');
    _typeId = 'Article';
    if (!_isEdit) _generateCode();
  }

  Future<void> _generateCode() async {
    final cid = ref.read(selectedCompanyIdProvider);
    if (cid == null) return;
    final svc = ref.read(supabaseServiceProvider);
    try {
      final r = await svc.client.from('customers').select('codeclient').eq('companyid', cid.toString()).order('id', ascending: false).limit(1);
      String last = r.isNotEmpty ? (r[0]['codeclient'] ?? 'C000') : 'C000';
      final num = int.tryParse(last.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      _code = 'C${(num + 1).toString().padLeft(3, '0')}';
      setState(() {});
    } catch (_) { _code = 'C001'; setState(() {}); }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cid = ref.read(selectedCompanyIdProvider);
    if (cid == null) return;
    setState(() => _saving = true);
    try {
      final svc = ref.read(supabaseServiceProvider);
      final data = {
        'companyid': cid.toString(),
        'codeclient': _code,
        'nomcomplet': _nomComplet.text.trim(),
        'activite': _activite.text.trim(),
        'adresse': _adresse.text.trim(),
        'numerorc': _nrc.text.trim(),
        'matriculefiscal': _mf.text.trim(),
        'typeidentification': _typeId,
        'numeroidentification': _nid.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        'device_id': 'mobile',
      };
      if (_isEdit) {
        await svc.client.from('customers').update(data).eq('id', widget.customer!.id);
      } else {
        await svc.client.from('customers').insert(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'Client modifie' : 'Client cree'), backgroundColor: AppTheme.success));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e'), backgroundColor: AppTheme.error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nomComplet.dispose(); _activite.dispose(); _adresse.dispose();
    _nrc.dispose(); _mf.dispose(); _nid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Modifier Client' : 'Nouveau Client')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_code != null) ListTile(
            title: Text(_code!, style: TextStyle(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: const Text('Code client', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nomComplet,
            decoration: const InputDecoration(labelText: 'Nom / Raison sociale *'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _activite, decoration: const InputDecoration(labelText: 'Activite')),
          const SizedBox(height: 12),
          TextFormField(controller: _adresse, decoration: const InputDecoration(labelText: 'Adresse'), maxLines: 2),
          const SizedBox(height: 12),
          TextFormField(controller: _nrc, decoration: const InputDecoration(labelText: 'N RC')),
          const SizedBox(height: 12),
          TextFormField(controller: _mf, decoration: const InputDecoration(labelText: 'Matricule fiscal')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _typeId,
            decoration: const InputDecoration(labelText: 'Type identification'),
            items: const [
              DropdownMenuItem(value: 'Article', child: Text('Article')),
              DropdownMenuItem(value: 'BP', child: Text('BP')),
            ],
            onChanged: (v) => setState(() => _typeId = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _nid, decoration: const InputDecoration(labelText: 'N Identification')),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'ENREGISTRER' : 'CREER'),
            ),
          ),
        ]),
      ),
    );
  }
}
