# ATELIO Mobile

Mobile companion app for ProManSystem — a WPF C# desktop application for manufacturing and commercial management. Connects to the same Supabase project and displays real-time business data.

## Project Overview

ATELIO Mobile reads data from the Supabase database (project: `qlcwuxovpcaknxbdzuby`) that is synced by the ProManSystem WPF desktop application. It provides quick access to customers, suppliers, products, invoices, raw materials, and sync health from any mobile device.

## Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌──────────────────┐
│  WPF Desktop App │────▶│   Supabase   │◀────│  Flutter Mobile  │
│  (ProManSystem)  │     │ (PostgreSQL) │     │   (ATELIO)       │
│  Push every 30s  │     │              │     │   Read + Quick   │
│  Pull on startup │     │ 17 tables    │     │   CRUD           │
└─────────────────┘     └──────────────┘     └──────────────────┘
```

## All Screens Built

| Screen | File | Features |
|--------|------|----------|
| Login | `features/auth/login_screen.dart` | Supabase Auth, blocks navigation when no company assigned, company selector |
| Company Selector | `features/auth/company_selector_sheet.dart` | Search bar, business type filter (All/Production/Commercial), close button, code+name+type |
| Dashboard | `features/dashboard/dashboard_screen.dart` | 4 KPI cards, low-stock alerts, recent activity, CA from Supabase aggregation |
| Customer List | `features/directory/customer_list_screen.dart` | Search, KPI cards, pagination, names resolved, onTap → detail |
| Customer Detail | `features/directory/customer_detail_screen.dart` | Full profile: code, name, activity, address; CA HT/TTC KPI; invoice history |
| Supplier List | `features/directory/supplier_list_screen.dart` | Search, KPI cards, pagination, onTap → detail |
| Supplier Detail | `features/directory/supplier_detail_screen.dart` | Full profile: code, name, activity; HT/TTC KPI; purchase invoice history |
| Sales Invoices | `features/sales/sales_invoice_list_screen.dart` | Two tabs Production/Commercial, customer names resolved, onTap → detail |
| Sales Invoice Detail | `features/sales/sales_invoice_detail_screen.dart` | Invoice lines with product names, HT/TVA/TTC footer, share via share_plus |
| Purchase Invoices | `features/purchases/purchase_invoice_list_screen.dart` | Two tabs, supplier names resolved, onTap → detail |
| Purchase Invoice Detail | `features/purchases/purchase_invoice_detail_screen.dart` | Invoice lines with raw material names, HT/TVA/TTC footer |
| Products | `features/products/product_list_screen.dart` | Two tabs, search, stock level colors, pagination, onTap → detail |
| Product Detail | `features/products/product_detail_screen.dart` | Product info, stock card, recipe/BOM or stock batches |
| Raw Materials | `features/materials/raw_materials_screen.dart` | KPIs, scrollable data table with PMAPA, stock, value, pagination |
| Sync Status | `features/sync_status/sync_status_screen.dart` | Device cards, pause/resume, recent logs (all company-filtered) |
| More | `features/more/more_screen.dart` | Switch Company, navigation links, about dialog, logout |

## Completed Fixes (v1.1)

1. Null company on login: shows error message, blocks navigation to dashboard
2. Company selector: search bar, type filter, close button, code+name display
3. Company filter on sync_logs and devices queries (dashboard + sync status)
4. Suppliers and Products added to More menu navigation
5. Sync indicator connected to real Supabase connectivity polling (30s)
6. Error handling with retry button on all 8 data screens
7. Customer detail: full implementation with invoice history
8. Supplier detail: full implementation with purchase history
9. Product detail: stock card, recipe/BOM, stock batches
10. Sales invoice detail: line items table, HT/TVA/TTC footer, share button
11. Purchase invoice detail: line items, supplier name resolved, HT/TVA/TTC footer
12. Payment status removed from all invoice screens
13. Customer and supplier names resolved in invoice lists
14. Business-type aware navigation tabs (Production/Commercial/Hybrid)
15. Company switch option in More menu (shows company selector)
16. Pagination with Load More on all list screens (50 items per page)
17. CA totals computed from Supabase aggregation (not client-side sum)
18. didChangeDependencies guarded with _initialized flag to prevent duplicate API calls
19. Removed dead code: DenseDataTable, unused anon key, QuickSale route
20. README updated to reflect current state

## Known Limitations

- **No offline mode**: All data is live from Supabase — no local SQLite caching
- **Pagination limit 50 per page**: Each screen loads 50 items initially with Load More button
- **No annual reports or journals**: CommercialMovementView, CommercialJournalView, EtatsAnnuels from WPF not yet in mobile
- **No Proforma invoices**: ProformaInvoicesView from WPF not yet in mobile
- **No production journal**: CustomerPurchasesView (production movement) not yet in mobile
- **No barcode scanning**: Optional feature for quick product lookup
- **No add/edit forms**: Customers and suppliers are read-only in mobile (Quick Add only)
- **No tests**: No unit or widget tests yet

## Future Improvements

- Implement QuickSaleScreen (POS) for fast point-of-sale transactions
- Add barcode scanning for product lookup
- Implement CSV/PDF export for invoices
- Add dark/light theme toggle
- Add biometric authentication (fingerprint/face)
- Implement offline SQLite cache with background sync
- Add annual commercial reports screen
- Implement Proforma invoice creation and listing
- Add push notifications for low stock alerts

## Dependencies

- `supabase_flutter` — Supabase client
- `go_router` — Declarative routing
- `flutter_riverpod` — State management
- `intl` — Number and date formatting
- `shimmer` — Loading placeholders
- `share_plus` — Share functionality

## Setup Guide

1. Ensure Flutter SDK is installed: `flutter --version`

2. Clone the project:
   ```bash
   cd C:\Users\Mounir\Desktop
   cd atelio_mobile
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Configure Supabase:
   - The Supabase URL and publishable key are already configured in `lib/config/app_config.dart`
   - Ensure the Supabase project `qlcwuxovpcaknxbdzuby` has Email Auth enabled
   - Create a user in Supabase Authentication → Users

5. Run the app:
   ```bash
   flutter run
   ```

## Testing Map

| Test | Steps | Expected Result |
|------|-------|-----------------|
| Login | Enter email + password, tap LOGIN | Company selector appears if multiple companies, or dashboard loads directly |
| No Company | Login with account that has 0 companies | Error message: "No company assigned..." blocks navigation |
| Company Selector | Search, tap type filter (All/Production/Commercial) | Filtered list, close button dismisses sheet |
| Dashboard KPIs | After login, check the 4 cards | Numbers match Supabase data for selected company |
| Sync Indicator | Green dot in app bar when online, red when offline | Connected to real connectivity polling |
| Customer List | Tap Directory tab | Paginated list with Load More, customer names shown |
| Customer Detail | Tap any customer | Code, name, activity, address, CA KPI, invoice history |
| Customer Search | Type in search bar | List filters in real-time |
| Supplier List | More → Fournisseurs | Supplier list with debt amounts, Load More |
| Supplier Detail | Tap any supplier | Code, name, activity, purchase history |
| Product List | More → Produits | Two tabs, search, stock colors, Load More |
| Product Detail | Tap any product | Stock card, recipe/BOM or batches, low stock indicator |
| Sales Invoices | Tap Sales tab | Customer names resolved (not IDs), tap → detail |
| Sales Invoice Detail | Tap any invoice | Line items, HT/TVA/TTC footer, share button |
| Purchase Invoices | Tap Purchases tab | Supplier names resolved, tap → detail |
| Purchase Invoice Detail | Tap any purchase | Line items, HT/TVA/TTC footer |
| Raw Materials | More → Matieres Premieres | Table, KPIs, Load More |
| Sync Status | More → Sync Status | Devices with pause/resume, logs (company-filtered) |
| Switch Company | More → Switch Company | Shows company selector, navigates to dashboard on select |
| Business Type Tabs | Select Commercial vs Production company | Navigation tabs change labels accordingly |
| Logout | More → Logout | Returns to login screen, session cleared |
