---
title: Screen Route Mapping
description: Map PRD screens to Next.js App Router routes for Pocket personal finance app
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 4
schema_version: 1
status: complete
summary: >
  This document maps all 9 screens from Pocket PRD to Next.js App Router routes.
  Routes use lowercase kebab-case per Next.js convention. Dynamic params for
  wallet detail (/wallets/[id]) and transaction edit (/transactions/[id]/edit).
  Search params for filter state on transaction list (date_from, date_to, type,
  wallet_id, category_id, q, page) and monthly summary (month, year). Layout
  hierarchy: RootLayout wraps AppLayout (shared shell with navigation), which
  wraps all page routes. No auth layout needed — user assumed authenticated per
  ASM-001. Seven page-level routes identified: Dashboard (/), WalletList
  (/wallets), CreateWallet (/wallets/new), CategoryList (/categories),
  TransactionList (/transactions), CreateTransaction (/transactions/new),
  MonthlySummary (/summary). Two dynamic-param routes: WalletDetail
  (/wallets/[id]) and EditTransaction (/transactions/[id]/edit). Loading and
  error boundaries defined per route segment with loading.tsx and error.tsx
  convention. Not-found handling for dynamic routes via not-found.tsx or
  dedicated NotFoundAlert component. Navigation flow designed as hub-and-spoke
  from Dashboard. Create/Edit transaction routes chosen as page routes over
  modal approach for deep-linkability and simpler state management — modal can
  be added as enhancement later (ponytail: modal on transaction list). Category
  management at standalone /categories route (not nested under /settings) to
  minimize click depth. WalletDetail included as inferred screen for drill-down
  from wallet list — shows wallet info and optionally filtered transactions.
  Summary route uses month/year search params with current month as default.
  Total 9 routes mapped with confidence scores ranging 0.6-1.0. Two low-
  confidence items flagged for review gate: WalletDetail (0.6, not explicit in
  PRD) and CreateTransaction as page vs modal (0.7, UX pattern not confirmed).
routes:
  - path: /
    params: null
    searchParams: null
    screen_name: Dashboard
    metadata:
      title: Beranda - Pocket
      description: Dashboard keuangan pribadi — ringkasan saldo wallet dan transaksi terbaru
    related_routes:
      - /wallets
      - /transactions
      - /summary
    source: "doc-03: section 4.2 Navigation Structure (inferred landing page)"
    confidence: 0.8
  - path: /wallets
    params: null
    searchParams: null
    screen_name: WalletList
    metadata:
      title: Dompet - Pocket
      description: Daftar dompet — kelola saldo cash, bank, dan e-wallet
    related_routes:
      - /
      - /wallets/new
      - /wallets/[id]
    source: "doc-03: FR-001 routing (melihat wallet)"
    confidence: 1.0
  - path: /wallets/new
    params: null
    searchParams: null
    screen_name: CreateWallet
    metadata:
      title: Dompet Baru - Pocket
      description: Buat dompet baru — nama, tipe, dan saldo awal
    related_routes:
      - /wallets
    source: "doc-03: FR-001 routing (membuat wallet)"
    confidence: 1.0
  - path: /wallets/[id]
    params:
      - name: id
        type: integer
        source: path segment
    searchParams: null
    screen_name: WalletDetail
    metadata:
      title: Detail Dompet - Pocket
      description: Detail dompet dan transaksi terkait
    related_routes:
      - /wallets
      - /transactions?wallet_id={id}
    source: inference — not explicit in PRD, implied by drill-down UX pattern from wallet list
    confidence: 0.6
  - path: /categories
    params: null
    searchParams: null
    screen_name: CategoryList
    metadata:
      title: Kategori - Pocket
      description: Daftar kategori pemasukan dan pengeluaran
    related_routes:
      - /
      - /transactions/new
    source: "doc-03: FR-002 routing"
    confidence: 1.0
  - path: /transactions
    params: null
    searchParams:
      - name: date_from
        type: string (ISO date)
        required: false
        description: Filter tanggal awal (inklusif)
      - name: date_to
        type: string (ISO date)
        required: false
        description: Filter tanggal akhir (inklusif)
      - name: type
        type: enum (income, expense)
        required: false
        description: Filter tipe transaksi
      - name: wallet_id
        type: integer
        required: false
        description: Filter berdasarkan wallet
      - name: category_id
        type: integer
        required: false
        description: Filter berdasarkan kategori
      - name: q
        type: string
        required: false
        description: Pencarian berdasarkan note
      - name: page
        type: integer
        required: false
        default: 1
        description: Halaman untuk pagination
    screen_name: TransactionList
    metadata:
      title: Transaksi - Pocket
      description: Riwayat transaksi pemasukan dan pengeluaran — filter dan cari
    related_routes:
      - /
      - /transactions/new
      - /transactions/[id]/edit
      - /wallets/[id]
    source: "doc-03: FR-004 routing"
    confidence: 1.0
  - path: /transactions/new
    params: null
    searchParams:
      - name: type
        type: enum (income, expense)
        required: false
        description: Pre-select transaction type on form load
      - name: wallet_id
        type: integer
        required: false
        description: Pre-select wallet on form load
    screen_name: CreateTransaction
    metadata:
      title: Transaksi Baru - Pocket
      description: Catat pemasukan atau pengeluaran baru
    related_routes:
      - /transactions
      - /wallets
      - /categories
    source: "doc-03: FR-003 routing (page over modal chosen)"
    confidence: 0.7
  - path: /transactions/[id]/edit
    params:
      - name: id
        type: integer
        source: path segment
    searchParams: null
    screen_name: EditTransaction
    metadata:
      title: Edit Transaksi - Pocket
      description: Ubah transaksi pemasukan atau pengeluaran
    related_routes:
      - /transactions
      - /transactions/new
    source: "doc-03: FR-005 routing (page over modal chosen)"
    confidence: 0.7
  - path: /summary
    params: null
    searchParams:
      - name: month
        type: integer (1-12)
        required: false
        default: current month
        description: Bulan untuk summary
      - name: year
        type: integer (4 digit)
        required: false
        default: current year
        description: Tahun untuk summary
    screen_name: MonthlySummary
    metadata:
      title: Ringkasan Bulanan - Pocket
      description: Ringkasan pemasukan, pengeluaran, dan net balance per bulan
    related_routes:
      - /
      - /transactions
    source: "doc-03: FR-007 routing"
    confidence: 1.0
assumptions:
  - id: ASM-001
    statement: Dashboard (/) berfungsi sebagai landing page dengan ringkasan wallet dan transaksi terbaru.
    impacts:
      - Dashboard membutuhkan data dari wallets dan transactions queries
      - Entry point aplikasi setelah user login
    confidence: 0.8
    source: "doc-03: section 4.2 Navigation Structure"
  - id: ASM-002
    statement: WalletDetail (/wallets/[id]) adalah inferred screen — tidak eksplisit di PRD tetapi berguna untuk drill-down dari wallet list.
    impacts:
      - Perlu API endpoint GET /api/wallets/:id
      - Mungkin perlu fetched transactions untuk wallet tersebut
    confidence: 0.6
    source: inference
  - id: ASM-003
    statement: Create transaction menggunakan page route (/transactions/new) bukan modal.
    impacts:
      - Navigasi penuh halaman, bukan overlay
      - Bisa di-deep link dan di-cache oleh router
      - UX sedikit kurang mulus dibanding modal (ponytail: can be modal later)
    confidence: 0.7
    source: "Agent 4 decision (ref task: delegated from Agent 3)"
  - id: ASM-004
    statement: Edit transaction menggunakan page route (/transactions/[id]/edit) bukan modal.
    impacts:
      - Navigasi penuh halaman
      - Mudah di-refresh dan di-cache
      - Transaction data di-fetch via useQuery sebelum form diisi
    confidence: 0.7
    source: "Agent 4 decision (ref task: delegated from Agent 3)"
  - id: ASM-005
    statement: Category management berada di route standalone /categories, bukan nested di /settings.
    impacts:
      - Akses langsung dari navigasi utama
      - Tidak perlu settings layout atau route group
      - Click depth minimal (1 level dari dashboard)
    confidence: 0.8
    source: "doc-03: FR-002 routing"
  - id: ASM-006
    statement: Delete transaction tidak memiliki route khusus — aksi dari tombol di TransactionList atau EditTransaction.
    impacts:
      - Tidak perlu halaman atau route terpisah
      - Konfirmasi via AlertDialog di tempat
      - Cache invalidation setelah delete
    confidence: 1.0
    source: "doc-03: FR-006 routing"
  - id: ASM-007
    statement: Filter state di TransactionList disimpan di URL search params sebagai source of truth.
    impacts:
      - Filter persist saat page refresh
      - User bisa bookmark filtered view
      - Back/forward navigation preserves filter state
    confidence: 1.0
    source: "doc-03: FR-004 frontend_concern.routing.detail"
  - id: ASM-008
    statement: Summary month/year default ke bulan dan tahun saat ini saat pertama kali navigasi.
    impacts:
      - URL /summary tanpa params berarti month=bulan_ini&year=tahun_ini
      - Tidak perlu redirect — cukup default di server component atau client
    confidence: 1.0
    source: "doc-03: FR-007 UI state requirements (Edge: current month default)"
  - id: ASM-009
    statement: Tidak ada route untuk login, register, settings, atau profile — semua out of MVP scope.
    impacts:
      - Route tree flat — tidak perlu auth group atau middleware guard
      - Semua route berada dalam satu layout tanpa kondisional
    confidence: 1.0
    source: "doc-02: ASM-001, doc-03: ASM-001"
  - id: ASM-010
    statement: Wallet update/delete tidak termasuk MVP — hanya create dan view.
    impacts:
      - Tidak ada route /wallets/[id]/edit
      - Wallet current_balance read-only, diupdate otomatis via transaksi
    confidence: 0.6
    source: "doc-03: ASM-002"
---

# 04 — Screen Route Mapping

## 1. Screen Inventory

### Screen 1: Dashboard

| Field | Value |
|-------|-------|
| Screen Name | `Dashboard` |
| User Stories | Inferred — serves as landing page showing wallet overview and recent transactions |
| Route Path | `/` |
| Layout | AppLayout (shared shell) |
| Dynamic Params | None |
| Search Params | None |
| Source | `doc-03: section 4.2 Navigation Structure` |
| Confidence | 0.8 |

### Screen 2: WalletList

| Field | Value |
|-------|-------|
| Screen Name | `WalletList` |
| User Stories | US-002 (melihat daftar wallet) |
| Route Path | `/wallets` |
| Layout | AppLayout (shared shell) |
| Dynamic Params | None |
| Search Params | None |
| Source | `doc-02: FR-001`, `doc-03: FR-001 routing` |
| Confidence | 1.0 |

### Screen 3: CreateWallet

| Field | Value |
|-------|-------|
| Screen Name | `CreateWallet` |
| User Stories | US-001 (membuat wallet) |
| Route Path | `/wallets/new` |
| Layout | AppLayout (shared shell) — or minimal layout |
| Dynamic Params | None |
| Search Params | None |
| Source | `doc-02: FR-001`, `doc-03: FR-001 routing` |
| Confidence | 1.0 |

### Screen 4: WalletDetail

| Field | Value |
|-------|-------|
| Screen Name | `WalletDetail` |
| User Stories | Inferred — drill-down from wallet list to see wallet details and related transactions |
| Route Path | `/wallets/[id]` |
| Layout | AppLayout (shared shell) |
| Dynamic Params | `id` (integer — wallet ID) |
| Search Params | None (filtered transactions use `/transactions?wallet_id={id}` instead) |
| Source | inference — not explicit in PRD |
| Confidence | 0.6 |

### Screen 5: CategoryList

| Field | Value |
|-------|-------|
| Screen Name | `CategoryList` |
| User Stories | US-003 (menggunakan kategori transaksi) |
| Route Path | `/categories` |
| Layout | AppLayout (shared shell) |
| Dynamic Params | None |
| Search Params | None |
| Source | `doc-02: FR-002`, `doc-03: FR-002 routing` |
| Confidence | 1.0 |

### Screen 6: TransactionList

| Field | Value |
|-------|-------|
| Screen Name | `TransactionList` |
| User Stories | US-006 (melihat riwayat transaksi), US-007 (memfilter transaksi) |
| Route Path | `/transactions` |
| Layout | AppLayout (shared shell) |
| Dynamic Params | None |
| Search Params | `date_from`, `date_to`, `type`, `wallet_id`, `category_id`, `q`, `page` |
| Source | `doc-02: FR-004`, `doc-03: FR-004 routing` |
| Confidence | 1.0 |

### Screen 7: CreateTransaction

| Field | Value |
|-------|-------|
| Screen Name | `CreateTransaction` |
| User Stories | US-004 (mencatat income), US-005 (mencatat expense) |
| Route Path | `/transactions/new` |
| Layout | AppLayout (shared shell) — or minimal layout |
| Dynamic Params | None |
| Search Params | `type` (pre-select income/expense), `wallet_id` (pre-select wallet) |
| Source | `doc-02: FR-003`, `doc-03: FR-003 routing` |
| Confidence | 0.7 (page vs modal decision) |

### Screen 8: EditTransaction

| Field | Value |
|-------|-------|
| Screen Name | `EditTransaction` |
| User Stories | US-008 (mengubah transaksi) |
| Route Path | `/transactions/[id]/edit` |
| Layout | AppLayout (shared shell) — or minimal layout |
| Dynamic Params | `id` (integer — transaction ID) |
| Search Params | None |
| Source | `doc-02: FR-005`, `doc-03: FR-005 routing` |
| Confidence | 0.7 (page vs modal decision) |

### Screen 9: MonthlySummary

| Field | Value |
|-------|-------|
| Screen Name | `MonthlySummary` |
| User Stories | US-010 (melihat summary bulanan), US-011 (melihat breakdown kategori) |
| Route Path | `/summary` |
| Layout | AppLayout (shared shell) |
| Dynamic Params | None |
| Search Params | `month` (1-12, default: current), `year` (4 digit, default: current) |
| Source | `doc-02: FR-007`, `doc-03: FR-007 routing` |
| Confidence | 1.0 |

---

## 2. Route Definitions

Next.js App Router file structure for all routes:

```
app/
  layout.tsx                    # RootLayout — html, body, providers
  page.tsx                      # Dashboard page
  loading.tsx                   # Dashboard loading state
  error.tsx                     # Dashboard error boundary
  wallets/
    layout.tsx                  # WalletLayout (optional — for group loading/error)
    page.tsx                    # WalletList page
    loading.tsx                 # WalletList loading state
    error.tsx                   # WalletList error boundary
    new/
      page.tsx                  # CreateWallet page
      loading.tsx               # CreateWallet loading state
    [id]/
      page.tsx                  # WalletDetail page
      loading.tsx               # WalletDetail loading state
      error.tsx                 # WalletDetail error boundary
      not-found.tsx             # Wallet not found state
  categories/
    page.tsx                    # CategoryList page
    loading.tsx                 # CategoryList loading state
    error.tsx                   # CategoryList error boundary
  transactions/
    page.tsx                    # TransactionList page
    loading.tsx                 # TransactionList loading state
    error.tsx                   # TransactionList error boundary
    new/
      page.tsx                  # CreateTransaction page
      loading.tsx               # CreateTransaction loading state
    [id]/
      edit/
        page.tsx                # EditTransaction page
        loading.tsx             # EditTransaction loading state
        error.tsx               # EditTransaction error boundary
        not-found.tsx           # Transaction not found state
  summary/
    page.tsx                    # MonthlySummary page
    loading.tsx                 # MonthlySummary loading state
    error.tsx                   # MonthlySummary error boundary
```

### Route Table

| Route Path | Screen | Layout | Dynamic Params | Search Params | Page Component | Source |
|-----------|--------|--------|---------------|--------------|----------------|--------|
| `/` | Dashboard | AppLayout | none | none | `DashboardPage` | doc-03: 4.2 |
| `/wallets` | WalletList | AppLayout | none | none | `WalletListPage` | doc-03: FR-001 |
| `/wallets/new` | CreateWallet | AppLayout | none | none | `CreateWalletPage` | doc-03: FR-001 |
| `/wallets/[id]` | WalletDetail | AppLayout | `id` | none | `WalletDetailPage` | inference |
| `/categories` | CategoryList | AppLayout | none | none | `CategoryListPage` | doc-03: FR-002 |
| `/transactions` | TransactionList | AppLayout | none | `date_from`, `date_to`, `type`, `wallet_id`, `category_id`, `q`, `page` | `TransactionListPage` | doc-03: FR-004 |
| `/transactions/new` | CreateTransaction | AppLayout | none | `type`, `wallet_id` (pre-select) | `CreateTransactionPage` | doc-03: FR-003 |
| `/transactions/[id]/edit` | EditTransaction | AppLayout | `id` | none | `EditTransactionPage` | doc-03: FR-005 |
| `/summary` | MonthlySummary | AppLayout | none | `month`, `year` | `MonthlySummaryPage` | doc-03: FR-007 |

---

## 3. Layout Structure

### Layout Hierarchy

```
<RootLayout>                          # app/layout.tsx
  └─ <Providers>                      # TanStack Query provider, Zustand hydration, Toaster
      └─ <AppLayout>                  # Shared shell — Header, Nav (sidebar/bottom), Content
          └─ <Outlet />               # Page content per route
```

### RootLayout (`app/layout.tsx`)

```
- <html lang="id">
- <body>
  - <QueryClientProvider>      — TanStack Query provider
    - <Toaster />              — shadcn Sonner toast
    - {children}               — AppLayout + page content
```

### AppLayout — Shared Shell

AppLayout wraps all page-level routes. Contains:

- **Header**: App title "Pocket" + optional action buttons per page context
- **Navigation**: Bottom navigation (mobile) or sidebar (desktop) with links:
  - Dashboard (`/`)
  - Wallets (`/wallets`)
  - Categories (`/categories`)
  - Transactions (`/transactions`)
  - Summary (`/summary`)
- **Content area**: `{children}` from page components

`ponytail: use responsive layout component (shadcn Sidebar on desktop, BottomNav on mobile). Add later if needed.`

### Nested Layouts

No nested layouts beyond AppLayout — all pages share same shell. Rationale: flat route hierarchy, no settings/auth/profile sections that would need different layouts.

CreateWallet, CreateTransaction, EditTransaction could optionally use minimal layout (no sidebar, just header + back button) for form focus. Decision delegated to Agent 6 (component design). If needed, use route group `(shell)` and `(minimal)` to separate layouts.

```
app/
  (shell)/
    layout.tsx                 # AppLayout with nav
    page.tsx                   # Dashboard
    wallets/
    categories/
    transactions/
    summary/
  (minimal)/
    layout.tsx                 # MinimalLayout — header + back button only
    wallets/new/
    transactions/new/
    transactions/[id]/edit/
```

### Loading States per Route Segment

| Route Segment | loading.tsx | Content |
|---------------|------------|---------|
| `/` | LoadingSkeleton | 3 stat card skeletons + 2 row skeletons for recent transactions |
| `/wallets` | LoadingSkeleton | 4 card skeletons (grid) |
| `/wallets/new` | FormSkeleton | Single card skeleton for form |
| `/wallets/[id]` | LoadingSkeleton | 1 card skeleton (wallet detail) + 3 row skeletons (recent transactions) |
| `/categories` | LoadingSkeleton | 2 tab skeletons (income + expense) with list skeletons |
| `/transactions` | LoadingSkeleton | Filter bar skeleton + 5 row table skeletons + pagination skeleton |
| `/transactions/new` | FormSkeleton | Select wallet skeleton + select category skeleton + inputs skeleton |
| `/transactions/[id]/edit` | FormSkeleton | Fetching transaction skeleton + form skeleton |
| `/summary` | LoadingSkeleton | 3 stat card skeletons + 2 breakdown section skeletons |

### Error States per Route Segment

| Route Segment | error.tsx / not-found.tsx | Behavior |
|---------------|--------------------------|----------|
| `/` | ErrorAlert | Retry button, "Gagal memuat dashboard" |
| `/wallets` | ErrorAlert | Retry button, "Gagal memuat daftar dompet" |
| `/wallets/new` | ErrorAlert | "Gagal memuat halaman" — unexpected only |
| `/wallets/[id]` | ErrorAlert + not-found.tsx | Not found: "Dompet tidak ditemukan" + link ke /wallets. Error: retry |
| `/categories` | ErrorAlert | Retry button, "Gagal memuat kategori" |
| `/transactions` | ErrorAlert | Retry button, "Gagal memuat transaksi" |
| `/transactions/new` | ErrorAlert | "Gagal memuat halaman" — unexpected only |
| `/transactions/[id]/edit` | ErrorAlert + not-found.tsx | Not found: "Transaksi tidak ditemukan" + link ke /transactions. Error: retry |
| `/summary` | ErrorAlert | Retry button, "Gagal memuat ringkasan" |

---

## 4. Navigation Flow

### Hub-and-Spoke from Dashboard

```
                      ┌─────────────────┐
                      │   Dashboard (/)  │
                      └────────┬────────┘
              ┌────────┬───────┼───────┬────────┐
              │        │       │       │        │
              ▼        ▼       ▼       ▼        ▼
        ┌─────────┐ ┌──────┐ ┌──────┐ ┌────────┐ ┌──────────┐
        │ Wallets │ │ Cat. │ │ Txns │ │Summary │ │ (links)  │
        └────┬────┘ └──────┘ └──┬───┘ └────────┘ └──────────┘
             │                  │
             ▼                  ▼
      ┌──────────┐      ┌──────────────┐
      │ Create   │      │ Create       │
      │ Wallet   │      │ Transaction  │
      └──────────┘      └──────┬───────┘
             │                  │
             ▼                  ▼
      ┌──────────┐      ┌──────────────┐
      │ Wallet   │      │ Edit         │
      │ Detail   │      │ Transaction  │
      └──────────┘      └──────────────┘
```

### Link Paths

| From | To | Action | Link Component |
|------|----|--------|----------------|
| Nav bar | Dashboard | Click nav icon | `Link href="/"` (shared) |
| Nav bar | Wallets | Click nav icon | `Link href="/wallets"` (shared) |
| Nav bar | Categories | Click nav icon | `Link href="/categories"` (shared) |
| Nav bar | Transactions | Click nav icon | `Link href="/transactions"` (shared) |
| Nav bar | Summary | Click nav icon | `Link href="/summary"` (shared) |
| Dashboard WalletCard | Wallet Detail | Click card | `Link href="/wallets/[id]"` |
| Dashboard RecentTransaction | TransactionList | Click "Lihat semua" | `Link href="/transactions"` |
| Dashboard SummaryStat | Summary | Click "Lihat ringkasan" | `Link href="/summary"` |
| WalletList | CreateWallet | Click "Buat dompet" button | `Link href="/wallets/new"` |
| WalletList | WalletDetail | Click wallet card | `Link href="/wallets/[id]"` |
| CreateWallet | WalletList | After create success | `router.push("/wallets")` |
| TransactionList | CreateTransaction | Click "Catat transaksi" button | `Link href="/transactions/new"` |
| TransactionList | EditTransaction | Click edit icon on row | `Link href="/transactions/[id]/edit"` |
| TransactionList | WalletDetail | Click wallet name on row | `Link href="/wallets/[wallet_id]"` |
| CreateTransaction | TransactionList | After create success | `router.push("/transactions")` |
| EditTransaction | TransactionList | After edit success | `router.push("/transactions")` |
| Delete action | TransactionList | After delete success | `router.push("/transactions")` (if on edit page) |

### Back Navigation Behavior

| Screen | Back to | Behavior |
|--------|---------|----------|
| CreateWallet | WalletList | Native back or cancel button → `router.back()` |
| WalletDetail | WalletList | Native back or back button → `router.back()` |
| CreateTransaction | TransactionList | Native back or cancel button → `router.back()` |
| EditTransaction | TransactionList | Native back or cancel button → `router.back()` |
| All others | Previous page | Native browser back |

### Redirect After Create/Edit/Delete

| Action | Origin Screen | Redirect Target | Condition |
|--------|--------------|----------------|-----------|
| Create wallet | CreateWallet | `/wallets` | Always |
| Create transaction | CreateTransaction | `/transactions` | Always |
| Edit transaction | EditTransaction | `/transactions` | Always |
| Delete transaction | TransactionList | Stay on page (remove from list) | List view |
| Delete transaction | EditTransaction | `/transactions` | Edit view |
| Delete transaction | WalletDetail | `/wallets` or `/transactions` | Depending on entry point |

### Deep Linking

All routes support direct URL access:
- `/wallets/42` — langsung ke wallet detail ID 42
- `/transactions?type=expense&wallet_id=1&page=2` — langsung ke filtered transaction list
- `/summary?month=12&year=2025` — langsung ke summary bulan Desember 2025
- `/transactions/99/edit` — langsung ke edit transaksi ID 99

If resource not found (invalid ID), show not-found error state per route.

---

## 5. Route Metadata

| Route Path | title | description |
|-----------|-------|-------------|
| `/` | Beranda - Pocket | Dashboard keuangan pribadi — ringkasan saldo wallet dan transaksi terbaru |
| `/wallets` | Dompet - Pocket | Daftar dompet — kelola saldo cash, bank, dan e-wallet |
| `/wallets/new` | Dompet Baru - Pocket | Buat dompet baru — nama, tipe, dan saldo awal |
| `/wallets/[id]` | Detail Dompet - Pocket | Detail dompet dan transaksi terkait |
| `/categories` | Kategori - Pocket | Daftar kategori pemasukan dan pengeluaran |
| `/transactions` | Transaksi - Pocket | Riwayat transaksi pemasukan dan pengeluaran — filter dan cari |
| `/transactions/new` | Transaksi Baru - Pocket | Catat pemasukan atau pengeluaran baru |
| `/transactions/[id]/edit` | Edit Transaksi - Pocket | Ubah transaksi pemasukan atau pengeluaran |
| `/summary` | Ringkasan Bulanan - Pocket | Ringkasan pemasukan, pengeluaran, dan net balance per bulan |

Metadata implemented via Next.js `generateMetadata` in each page component. All titles use format `{Page Title} - Pocket` for consistent tab/browser display.

---

## 6. Loading & Error States per Route

### Loading State Table

| Route | loading.tsx | Visual | Notes |
|-------|-------------|--------|-------|
| `/` | DashboardSkeleton | 3 StatCard placeholders + 2 transaction row placeholders | Dashboard has multiple data sources |
| `/wallets` | WalletListSkeleton | 4 Card placeholders in responsive grid | Matches expected wallet count for personal use |
| `/wallets/new` | FormSkeleton | Single Card placeholder with 3 field placeholders | Form is lightweight |
| `/wallets/[id]` | WalletDetailSkeleton | 1 detail card + 3 transaction row placeholders | Includes recent transactions for this wallet |
| `/categories` | CategoryListSkeleton | 2 tab skeletons + list item placeholders | Income + expense tabs |
| `/transactions` | TransactionListSkeleton | Filter bar skeleton + 5 table row placeholders | Most complex loading state |
| `/transactions/new` | FormSkeleton | Select skeletons + input placeholders | Depends on wallet + category queries |
| `/transactions/[id]/edit` | EditTransactionSkeleton | Form skeleton + "Memuat data..." text | Needs fetch existing transaction |
| `/summary` | SummarySkeleton | 3 StatCard placeholders + 2 list section placeholders | Two breakdown sections |

### Error State Table

| Route | error.tsx | not-found.tsx | Specific Errors |
|-------|-----------|---------------|-----------------|
| `/` | ErrorAlert + retry | — | Network failure |
| `/wallets` | ErrorAlert + retry | — | Network failure |
| `/wallets/new` | ErrorAlert + retry | — | Unexpected render error |
| `/wallets/[id]` | ErrorAlert + retry | "Dompet tidak ditemukan" + link ke /wallets | EC-014 (EC-008 via ASM-007) |
| `/categories` | ErrorAlert + retry | — | Network failure |
| `/transactions` | ErrorAlert + retry | — | Network failure, filter parse error |
| `/transactions/new` | ErrorAlert + retry | — | Wallet/category query failure (dependencies) |
| `/transactions/[id]/edit` | ErrorAlert + retry | "Transaksi tidak ditemukan" + link ke /transactions | EC-016 (EC-008 via ASM-007) |
| `/summary` | ErrorAlert + retry | — | Network failure, invalid month/year |

Implementation: `error.tsx` catches unexpected errors (error boundaries). `not-found.tsx` handles `notFound()` calls for resource-not-found scenarios. Dedicated client-side NotFoundAlert component for cases where error boundary isn't appropriate.

Reference: `doc-02: EC-014` (wallet not found), `doc-02: EC-015` (category not found), `doc-02: EC-016` (transaction not found), `doc-02: EC-017` (insufficient balance — form error, not page error).

---

## 7. Assumptions

| ID | Statement | Impacts | Confidence | Source |
|----|-----------|---------|-----------|--------|
| ASM-001 | Dashboard (/) sebagai landing page dengan ringkasan wallet dan transaksi terbaru | Dashboard butuh data wallets + transactions queries | 0.8 | doc-03: 4.2 NAV |
| ASM-002 | WalletDetail (/wallets/[id]) inferred — tidak eksplisit di PRD | Perlu API GET /api/wallets/:id, fetched transactions | 0.6 | inference |
| ASM-003 | Create transaction page route bukan modal | Navigasi penuh, deep-linkable, router-cacheable | 0.7 | Agent 4 decision |
| ASM-004 | Edit transaction page route bukan modal | Navigasi penuh, data di-fetch via useQuery | 0.7 | Agent 4 decision |
| ASM-005 | Category management di standalone /categories | Akses langsung dari nav, click depth 1 | 0.8 | doc-03: FR-002 |
| ASM-006 | Delete transaction tanpa route khusus | Tombol di list/edit page, konfirmasi dialog | 1.0 | doc-03: FR-006 |
| ASM-007 | Filter state di URL search params (source of truth) | Filter persist di refresh, bookmarkable | 1.0 | doc-03: FR-004 |
| ASM-008 | Summary month/year default ke current month/year | URL tanpa params = current month | 1.0 | doc-03: FR-007 UI |
| ASM-009 | Tidak ada login/register/settings/profile routes | Route tree flat, tanpa auth guard | 1.0 | doc-02: ASM-001 |
| ASM-010 | Wallet update/delete tidak termasuk MVP | Tidak ada /wallets/:id/edit | 0.6 | doc-03: ASM-002 |

### Low-Confidence Items (Review Gate Attention)

**ASM-002 (confidence 0.6):** WalletDetail screen. PRD FR-001 only mentions "membuat dan melihat wallet" — seeing is satisfied by list view. WalletDetail adds drill-down scope. If removed, `/wallets/[id]` route is eliminated and wallet-related transaction filtering happens via `/transactions?wallet_id={id}`.

**ASM-003 & ASM-004 (confidence 0.7):** Page route vs modal for create/edit. Modal approach keeps user on `/transactions` page, uses Sheet/Drawer component. Page approach is simpler and deep-linkable. Decision delegated from Agent 3. If Agent 6 or review gate prefers modal, routes still exist but become shallow (ModalTransaction and ModalEditTransaction as component-level, not page-level).

**ASM-010 (confidence 0.6):** Wallet update/delete exclusion from MVP. PRD Open Question No 1 (line 605) asks about scope. If wallet edit is included later, `/wallets/[id]/edit` route needed.

---

## 8. DoD Checklist

- [x] All 9 screens from PRD mapped to Next.js App Router routes
- [x] Dynamic route params documented (wallet id, transaction id)
- [x] Layout structure defined (RootLayout -> AppLayout -> pages)
- [x] Loading and error states identified per route (loading.tsx + error.tsx tables)
- [x] Navigation flow between screens documented (hub-and-spoke diagram + link paths table + redirect behaviors)
- [x] References doc-02 (entity references, edge cases) and doc-03 (FR routing, search params)
- [x] Screen names PascalCase (Dashboard, WalletList, WalletDetail, CreateWallet, CategoryList, TransactionList, CreateTransaction, EditTransaction, MonthlySummary)
- [x] Route paths lowercase kebab-case per Next.js convention
- [x] Metadata (title, description) per route for SEO
- [x] Frontmatter YAML valid and complete with prd_source_hash matching chain state
- [x] No placeholder, TODO, or "TBD"
- [x] Confidence scores 0.0-1.0 on all routes and assumptions
- [x] Low-confidence items flagged with provenance for review gate
