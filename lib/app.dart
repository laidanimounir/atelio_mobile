import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config/routes.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/sales/sales_invoice_list_screen.dart';
import 'features/sales/sales_invoice_detail_screen.dart';
import 'features/purchases/purchase_invoice_list_screen.dart';
import 'features/purchases/purchase_invoice_detail_screen.dart';
import 'features/directory/customer_list_screen.dart';
import 'features/directory/customer_detail_screen.dart';
import 'features/directory/supplier_list_screen.dart';
import 'features/directory/supplier_detail_screen.dart';
import 'features/products/product_list_screen.dart';
import 'features/products/product_detail_screen.dart';
import 'features/materials/raw_materials_screen.dart';
import 'features/sync_status/sync_status_screen.dart';
import 'features/more/more_screen.dart';

final router = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
        GoRoute(path: AppRoutes.salesInvoices, builder: (_, __) => const SalesInvoiceListScreen()),
        GoRoute(path: AppRoutes.salesInvoiceDetail, builder: (_, __) => const SalesInvoiceDetailScreen()),
        GoRoute(path: AppRoutes.purchaseInvoices, builder: (_, __) => const PurchaseInvoiceListScreen()),
        GoRoute(path: AppRoutes.purchaseInvoiceDetail, builder: (_, __) => const PurchaseInvoiceDetailScreen()),
        GoRoute(path: AppRoutes.customers, builder: (_, __) => const CustomerListScreen()),
        GoRoute(path: AppRoutes.customerDetail, builder: (_, __) => const CustomerDetailScreen()),
        GoRoute(path: AppRoutes.suppliers, builder: (_, __) => const SupplierListScreen()),
        GoRoute(path: AppRoutes.supplierDetail, builder: (_, __) => const SupplierDetailScreen()),
        GoRoute(path: AppRoutes.products, builder: (_, __) => const ProductListScreen()),
        GoRoute(path: AppRoutes.productDetail, builder: (_, __) => const ProductDetailScreen()),
        GoRoute(path: AppRoutes.rawMaterials, builder: (_, __) => const RawMaterialsScreen()),
        GoRoute(path: AppRoutes.syncStatus, builder: (_, __) => const SyncStatusScreen()),
        GoRoute(path: AppRoutes.more, builder: (_, __) => const MoreScreen()),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
