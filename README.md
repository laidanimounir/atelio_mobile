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
| Login | `features/auth/login_screen.dart` | Supabase Auth email/password, dark theme, company selector |
| Dashboard | `features/dashboard/dashboard_screen.dart` | 4 KPI cards, low-stock alerts, recent activity |
| Customer List | `features/directory/customer_list_screen.dart` | Search, KPI cards, dense list with Code + Name + CA |
| Customer Detail | `features/directory/customer_detail_screen.dart` | Full profile (stub — tap from list) |
| Supplier List | `features/directory/supplier_list_screen.dart` | Search, KPI cards, dense list with debt |
| Supplier Detail | `features/directory/supplier_detail_screen.dart` | Full profile (stub) |
| Sales Invoices | `features/sales/sales_invoice_list_screen.dart` | Two tabs Production/Commercial, status badges |
| Sales Invoice Detail | `features/sales/sales_invoice_detail_screen.dart` | Full invoice (stub) |
| Purchase Invoices | `features/purchases/purchase_invoice_list_screen.dart` | Two tabs, status badges |
| Purchase Invoice Detail | `features/purchases/purchase_invoice_detail_screen.dart` | Full invoice (stub) |
| Products | `features/products/product_list_screen.dart` | Two tabs, search, stock level colors |
| Product Detail | `features/products/product_detail_screen.dart` | Full product info (stub) |
| Raw Materials | `features/materials/raw_materials_screen.dart` | KPIs, scrollable data table with PMAPA, stock, value |
| Sync Status | `features/sync_status/sync_status_screen.dart` | Device cards, pause/resume button, recent sync logs |
| More | `features/more/more_screen.dart` | Navigation links, about dialog, logout |

## What Is Not Yet Built

- **Customer/Supplier/Product Detail screens**: Stub screens exist but need full implementation with ID parameter passing via go_router
- **QuickSaleScreen**: POS quick sale form not yet implemented
- **Invoice Detail screens with line items**: Need to join with invoice lines tables
- **Offline mode**: No local SQLite caching — all data is live from Supabase
- **Barcode scanning**: Optional feature for quick product lookup
- **Add Customer/Supplier forms**: Read-only currently
- **Tests**: No unit or widget tests yet

## Dependencies

- `supabase_flutter` — Supabase client
- `go_router` — Declarative routing
- `flutter_riverpod` — State management
- `intl` — Number and date formatting
- `shimmer` — Loading placeholders
- `flutter_secure_storage` — Secure session storage
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
   - The Supabase URL and anon key are already configured in `lib/config/app_config.dart`
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
| Dashboard KPIs | After login, check the 4 cards | Numbers should match Supabase data for selected company |
| Customer List | Tap Directory tab → swipe to Customers | List shows all customers with Code, Name, CA amounts |
| Customer Search | Type in search bar | List filters in real-time |
| Supplier List | Swipe to Suppliers tab | List shows all suppliers with debt amounts colored red/green |
| Product List | Swipe to Products tab | Two tabs show manufacturing and commercial products with stock levels |
| Low Stock | Products with stock below minimum | Red circle indicator next to name |
| Sales Invoices | Tap Sales tab | Two tabs Production/Commercial, invoices with paid/unpaid badges |
| Raw Materials | More → Matieres Premieres | Table shows code, name, PMAPA, stock, value |
| Sync Status | More → Sync Status | Device cards with online dot, pause/resume buttons, recent logs |
| Pause Sync | Tap Pause button on a device | Button changes to Resume, Supabase devices.sync_paused updates |
| Logout | More → Logout | Returns to login screen, session cleared |
