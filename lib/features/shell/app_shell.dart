import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/models/company.dart';
import '../../core/providers/company_provider.dart';
import '../../shared/widgets/sync_indicator.dart';
import '../auth/company_selector_sheet.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  String _currentRoute = AppRoutes.dashboard;

  void _navigateTo(String route) {
    setState(() => _currentRoute = route);
    context.go(route);
  }

  bool _isSelected(String route) => _currentRoute == route;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(selectedCompanyProvider);
    final connState = ref.watch(connectivityStateProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    void onSelect(String route) {
      Navigator.pop(context);
      _navigateTo(route);
    }

    Widget sidebar = _buildSidebar(company, onSelect, context, ref);

    return Scaffold(
      appBar: isWide
          ? null
          : AppBar(
              leading: Builder(builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              )),
              title: Text(_pageTitle(_currentRoute), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              actions: [Padding(padding: const EdgeInsets.only(right: 12), child: SyncIndicator(state: connState))],
            ),
      drawer: isWide ? null : Drawer(child: sidebar),
      body: Column(children: [
        if (connState == ConnectivityState.offline)
          Container(
            width: double.infinity,
            color: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 14),
              const SizedBox(width: 8),
              const Expanded(child: Text('Vous etes hors ligne — Les donnees affichees peuvent ne pas etre a jour', style: TextStyle(color: Colors.white, fontSize: 11))),
            ]),
          ),
        Expanded(child: isWide
            ? Row(children: [
                Container(width: 240, color: AppTheme.surface, child: sidebar),
                const VerticalDivider(width: 1, color: AppTheme.border),
                Expanded(child: widget.child),
              ])
            : widget.child),
      ]),
    );
  }

  String _pageTitle(String route) {
    switch (route) {
      case AppRoutes.dashboard: return 'Dashboard';
      case AppRoutes.salesInvoices: return 'Sales Invoices';
      case AppRoutes.purchaseInvoices: return 'Purchase Invoices';
      case AppRoutes.customers: return 'Customers';
      case AppRoutes.suppliers: return 'Suppliers';
      case AppRoutes.products: return 'Products';
      case AppRoutes.rawMaterials: return 'Raw Materials';
      case AppRoutes.syncStatus: return 'Sync Status';
      case AppRoutes.more: return 'More';
      default: return 'ATELIO';
    }
  }

  Widget _buildSidebar(Company? company, void Function(String) onSelect, BuildContext context, WidgetRef ref) {
    final bt = company?.businessType?.toLowerCase();
    final isProd = bt == 'production' || bt == null;
    final isComm = bt == 'commercial' || bt == null;

    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        color: AppTheme.surface,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ATELIO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 3)),
          const SizedBox(height: 4),
          Text(company?.name ?? 'Mobile', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ]),
      ),
      const Divider(height: 1, color: AppTheme.border),
      Expanded(
        child: ListView(padding: EdgeInsets.zero, children: [
          _sidebarItem(Icons.dashboard_outlined, 'Dashboard', AppRoutes.dashboard, onSelect),
          const Divider(height: 1, color: AppTheme.border),
          if (isProd) ..._section('PRODUCTION', [
            _sidebarItem(Icons.receipt_long_outlined, 'Sales Invoices', AppRoutes.salesInvoices, onSelect),
            _sidebarItem(Icons.shopping_cart_outlined, 'Purchase Invoices', AppRoutes.purchaseInvoices, onSelect),
            _sidebarItem(Icons.inventory_2_outlined, 'Products', AppRoutes.products, onSelect),
            _sidebarItem(Icons.inventory, 'Raw Materials', AppRoutes.rawMaterials, onSelect),
          ]),
          if (isComm) ..._section('COMMERCIAL', [
            _sidebarItem(Icons.receipt_long_outlined, 'Sales Invoices', AppRoutes.salesInvoices, onSelect),
            _sidebarItem(Icons.shopping_cart_outlined, 'Purchase Invoices', AppRoutes.purchaseInvoices, onSelect),
            _sidebarItem(Icons.inventory_2_outlined, 'Products', AppRoutes.products, onSelect),
          ]),
          ..._section('DIRECTORY', [
            _sidebarItem(Icons.people_outline, 'Customers', AppRoutes.customers, onSelect),
            _sidebarItem(Icons.business_outlined, 'Suppliers', AppRoutes.suppliers, onSelect),
          ]),
          const Divider(height: 1, color: AppTheme.border),
          _sidebarItem(Icons.sync, 'Sync Status', AppRoutes.syncStatus, onSelect),
          _sidebarItem(Icons.swap_horiz, 'Switch Company', '', (route) {
            _showCompanySheet(context, ref);
            Navigator.pop(context);
          }),
          _sidebarItem(Icons.logout, 'Logout', '', (route) async {
            await Supabase.instance.client.auth.signOut();
            ref.read(selectedCompanyProvider.notifier).state = null;
            if (context.mounted) context.go(AppRoutes.login);
          }),
        ]),
      ),
    ]);
  }

  List<Widget> _section(String title, List<Widget> items) {
    return [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        color: AppTheme.border,
        child: Text(title, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
      ),
      ...items,
    ];
  }

  Widget _sidebarItem(IconData icon, String label, String route, void Function(String) onSelect) {
    final selected = _isSelected(route);
    return Container(
      decoration: BoxDecoration(
        border: selected ? const Border(left: BorderSide(color: AppTheme.primary, width: 3)) : null,
        color: selected ? AppTheme.primary.withAlpha(20) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary, size: 20),
        title: Text(label, style: TextStyle(color: selected ? AppTheme.primary : AppTheme.textSecondary, fontSize: 13)),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: () => onSelect(route),
      ),
    );
  }

  void _showCompanySheet(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.read(companiesProvider);
    companiesAsync.whenData((companies) {
      if (companies.isEmpty) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => CompanySelectorSheet(
          companies: companies,
          onSelect: (c) {
            ref.read(selectedCompanyProvider.notifier).state = c;
            _navigateTo(AppRoutes.dashboard);
          },
        ),
      );
    });
  }
}
