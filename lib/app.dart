import 'package:go_router/go_router.dart';
import 'config/routes.dart';
import 'core/models/all_models.dart';
import 'features/auth/login_screen.dart';
import 'features/shell/app_shell.dart';
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
import 'features/reports/commercial_movement_screen.dart';
import 'features/reports/commercial_journal_screen.dart';
import 'features/reports/raw_material_report_screen.dart';
import 'features/sales/proforma_list_screen.dart';

final router = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),
        GoRoute(path: AppRoutes.salesInvoices, builder: (_, __) => const SalesInvoiceListScreen()),
        GoRoute(path: AppRoutes.salesInvoiceDetail, builder: (_, state) => SalesInvoiceDetailScreen(invoice: state.extra as SalesInvoice)),
        GoRoute(path: AppRoutes.purchaseInvoiceDetail, builder: (_, state) => PurchaseInvoiceDetailScreen(invoice: state.extra as PurchaseInvoice)),
        GoRoute(path: AppRoutes.customers, builder: (_, __) => const CustomerListScreen()),
        GoRoute(path: AppRoutes.customerDetail, builder: (_, state) => CustomerDetailScreen(customer: state.extra as Customer)),
        GoRoute(path: AppRoutes.suppliers, builder: (_, __) => const SupplierListScreen()),
        GoRoute(path: AppRoutes.supplierDetail, builder: (_, state) => SupplierDetailScreen(supplier: state.extra as Supplier)),
        GoRoute(path: AppRoutes.products, builder: (_, __) => const ProductListScreen()),
        GoRoute(path: AppRoutes.productDetail, builder: (_, state) => ProductDetailScreen(product: state.extra as Product)),
        GoRoute(path: AppRoutes.rawMaterials, builder: (_, __) => const RawMaterialsScreen()),
        GoRoute(path: AppRoutes.syncStatus, builder: (_, __) => const SyncStatusScreen()),
        GoRoute(path: AppRoutes.more, builder: (_, __) => const MoreScreen()),
        GoRoute(path: AppRoutes.commercialMovement, builder: (_, __) => const CommercialMovementScreen()),
        GoRoute(path: AppRoutes.commercialJournal, builder: (_, __) => const CommercialJournalScreen()),
        GoRoute(path: AppRoutes.rawMaterialReport, builder: (_, __) => const RawMaterialReportScreen()),
        GoRoute(path: AppRoutes.proformaInvoices, builder: (_, __) => const ProformaListScreen()),
      ],
    ),
  ],
);
