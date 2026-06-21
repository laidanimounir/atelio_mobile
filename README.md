# ATELIO Mobile

Mobile companion app for ProManSystem — a WPF C# desktop application for manufacturing and commercial management. Connects to the same Supabase project and displays real-time business data.

## Project Overview

ATELIO Mobile reads data from the Supabase database (project: `qlcwuxovpcaknxbdzuby`) that is synced by the ProManSystem WPF desktop application. It provides quick access to customers, suppliers, products, invoices, raw materials, and sync health from any mobile device.

## Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌──────────────────┐
│  WPF Desktop App │────▶│   Supabase   │◀────│  Flutter Mobile  │
│  (ProManSystem)  │     │ (PostgreSQL) │     │   (ATELIO)       │
│  Push every 30s  │     │              │     │   Read + CRUD    │
│  Pull on startup │     │ 17 tables    │     │                  │
└─────────────────┘     └──────────────┘     └──────────────────┘
```

## All Screens Built

| Screen | File | Features |
|--------|------|----------|
| Login | `features/auth/login_screen.dart` | Supabase Auth, block navigation when no company |
| Company Selector | `features/auth/company_selector_sheet.dart` | Search bar, type filter All/Production/Commercial |
| Dashboard | `features/dashboard/dashboard_screen.dart` | 4 KPI cards, low-stock alerts, recent activity |
| Customer List | `features/directory/customer_list_screen.dart` | Search, KPI cards, pagination, FAB to add + onTap → detail |
| Customer Add/Edit | `features/directory/customer_form_screen.dart` | Auto code generation, 8 fields, validation, Supabase insert/update |
| Customer Detail | `features/directory/customer_detail_screen.dart` | Full profile: code, name, activity, NRC, MF, statut badge; CA HT/TTC KPI; invoice history; edit + delete |
| Supplier List | `features/directory/supplier_list_screen.dart` | Search, KPI cards, pagination, FAB to add + onTap → detail |
| Supplier Add/Edit | `features/directory/supplier_form_screen.dart` | Auto code generation, 8 fields, validation |
| Supplier Detail | `features/directory/supplier_detail_screen.dart` | Full profile + purchase history; edit + delete with cascade check |
| Sales Invoices | `features/sales/sales_invoice_list_screen.dart` | Tabs hidden by company type, customer names resolved, onTap → detail |
| Sales Invoice Detail | `features/sales/sales_invoice_detail_screen.dart` | Line items with product names, HT/TVA/TTC footer, share button |
| Purchase Invoices | `features/purchases/purchase_invoice_list_screen.dart` | Tabs hidden by company type, supplier names resolved |
| Purchase Invoice Detail | `features/purchases/purchase_invoice_detail_screen.dart` | Line items with raw material names, HT/TVA/TTC footer |
| Products | `features/products/product_list_screen.dart` | Two tabs, search, stock colors, pagination |
| Product Detail | `features/products/product_detail_screen.dart` | Stock card, recipe/BOM or stock batches |
| Raw Materials | `features/materials/raw_materials_screen.dart` | KPIs, scrollable data table with PMAPA, stock, value |
| Raw Material Report | `features/reports/raw_material_report_screen.dart` | Negative stock filter, red highlights, full stock analysis |
| Proforma Invoices | `features/sales/proforma_list_screen.dart` | Lists proforma invoices only, tap → detail |
| Commercial Movement | `features/reports/commercial_movement_screen.dart` | Sales by invoice: CA, cost, margin per row, totals KPI |
| Commercial Journal | `features/reports/commercial_journal_screen.dart` | Sales grouped by customer, expandable invoice lists, CA totals |
| Sync Status | `features/sync_status/sync_status_screen.dart` | Device cards, pause/resume, company-filtered logs |
| More | `features/more/more_screen.dart` | Switch Company (async handler), nav links, logout |

## Phase 3 Completed (this session)

1. Dashboard: null-safe queries, individual try/catch, cid.toString() for TEXT columns
2. Invoice lines: removed broken FK joins, two-step fetch with client-side name resolution
3. Switch Company: async state handling with `.when()`, loading/error/data states
4. Offline banner: orange banner when offline, data stays in memory
5. Customer Add/Edit/Delete: full CRUD with auto code, validation, cascade check
6. Supplier Add/Edit/Delete: full CRUD with auto code, validation, cascade check
7. Complete financial info: NRC, MF, TypeID, NID, statut badge on detail screens
8. Commercial Movement report: sales lines with CA/cost/margin
9. Commercial Journal report: grouped by customer, expandable invoices
10. Raw Material Report: negative stock filter, red highlights
11. Proforma Invoices list: filtered proforma only
12. Sidebar navigation updated with all new screens
13. Code cleanup: all `flutter analyze` errors resolved

## Deferred to Phase 4

- QuickSaleScreen (POS): route constant exists, not implemented
- Company creation wizard: 5-step form with logo upload
- PDF/Excel export functionality
- Offline SQLite cache for true offline mode
- Push notifications for low stock alerts
- AI Chat with Groq integration
- Barcode scanning for product lookup
- Annual commercial reports (EtatsAnnuels)
- Customer/Supplier picker dialogs

## Known Limitations

- **No offline mode**: Data is live from Supabase; offline shows banner only
- **Pagination limit 50-300 per page**: Load More button for larger datasets
- **Company add requires desktop**: No mobile company creation wizard yet
- **No PDF/Excel export**: Share via text only
- **No push notifications**: Low stock alerts are inline only

## Dependencies

- `supabase_flutter` — Supabase client
- `go_router` — Declarative routing
- `flutter_riverpod` — State management
- `intl` — Number and date formatting
- `shimmer` — Loading placeholders
- `share_plus` — Share functionality

## Setup Guide

1. Ensure Flutter SDK installed: `flutter --version`
2. Install dependencies: `flutter pub get`
3. Configure Supabase in `lib/config/app_config.dart`
4. Create a user in Supabase Authentication → Users
5. Run: `flutter run`

## Testing Map

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Login | Enter email + password | Company selector or dashboard loads |
| No Company | Login with 0 companies | Error message blocks navigation |
| Add Customer | Tap FAB (+) on customer list | Form with auto-generated code, validation, saves to Supabase |
| Edit Customer | Tap pencil on customer detail | Pre-filled form, updates Supabase |
| Delete Customer | Tap delete on customer detail | Confirmation dialog, cascade check for invoices |
| Add Supplier | Tap FAB (+) on supplier list | Form with auto-generated code |
| Edit/Delete Supplier | Same as customer | Cascade check for purchase invoices |
| Customer Detail | Tap any customer | Code, name, NRC, MF, statut badge, CA KPI, invoice history |
| Invoice Detail | Tap any invoice | Line items, HT/TVA/TTC footer, share button |
| Proforma List | Sidebar → Proforma | Only isproforma=true invoices |
| Commercial Movement | Sidebar → Movement | KPIs, dense table with CA/cost/margin |
| Commercial Journal | Sidebar → Journal | Grouped by customer, expandable invoices |
| Raw Material Report | Sidebar → Raw Mat. Report | Negative stock filter, red highlights |
| Switch Company | Sidebar → Switch Company | Loading state while fetching, company selector sheet |
| Offline | Disconnect internet | Orange banner appears, existing data remains visible |
| Logout | Sidebar → Logout | Returns to login, session cleared |
