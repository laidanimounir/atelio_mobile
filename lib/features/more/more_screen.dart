import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/providers/company_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(children: [
      const SizedBox(height: 8),
      _item(Icons.inventory, 'Matieres Premieres', () => context.go(AppRoutes.rawMaterials)),
      _item(Icons.people, 'Fournisseurs', () => context.go(AppRoutes.suppliers)),
      _item(Icons.inventory_2, 'Produits', () => context.go(AppRoutes.products)),
      _item(Icons.sync, 'Sync Status', () => context.go(AppRoutes.syncStatus)),
      const Divider(),
      _item(Icons.info_outline, 'About', () => _showAbout(context)),
      _item(Icons.logout, 'Logout', () async {
        await Supabase.instance.client.auth.signOut();
        ref.read(selectedCompanyProvider.notifier).state = null;
        if (context.mounted) context.go(AppRoutes.login);
      }),
    ]);
  }

  Widget _item(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: AppTheme.textSecondary), title: Text(title), trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary), onTap: onTap);
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(context: context, applicationName: 'ATELIO Mobile', applicationVersion: '1.0.0', applicationIcon: Icon(Icons.factory, color: AppTheme.primary, size: 48), children: [
      const Text('Mobile companion app for ProManSystem - ATELIO.\nBuilt with Flutter and Supabase.'),
    ]);
  }
}
