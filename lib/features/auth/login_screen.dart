import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/providers/company_provider.dart';
import '../../core/models/company.dart';
import 'company_selector_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _noCompanyError;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await _loadCompaniesAndGo();
    }
  }

  Future<void> _loadCompaniesAndGo() async {
    final companiesAsync = ref.read(companiesProvider);
    companiesAsync.whenData((companies) {
      if (!mounted) return;
      if (companies.isEmpty) {
        setState(() {
          _noCompanyError = 'No company assigned to this account. Contact your administrator.';
        });
        return;
      }
      setState(() => _noCompanyError = null);
      if (companies.length == 1) {
        ref.read(selectedCompanyProvider.notifier).state = companies.first;
        context.go(AppRoutes.dashboard);
      } else {
        _showCompanySheet(companies);
      }
    });
  }

  void _showCompanySheet(List<Company> companies) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CompanySelectorSheet(
        companies: companies,
        onSelect: (c) {
          ref.read(selectedCompanyProvider.notifier).state = c;
          context.go(AppRoutes.dashboard);
        },
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      await _loadCompaniesAndGo();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                Text('ATELIO', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 6)),
                const SizedBox(height: 8),
                Text('Mobile', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                const SizedBox(height: 48),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
                  obscureText: true,
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null) Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
                if (_noCompanyError != null) Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.error.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.warning_amber, color: AppTheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_noCompanyError!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('LOGIN'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
