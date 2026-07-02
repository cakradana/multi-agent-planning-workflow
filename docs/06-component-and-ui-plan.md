---
title: Component and UI Plan
description: Component tree, shared vs page-specific components, shadcn/ui selections for Pocket personal finance app
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 6
schema_version: 1
status: complete
summary: >
  This document defines the complete component architecture for Pocket — a personal
  finance app with 9 screen routes. The architecture follows atomic design principles
  organized into atoms (shadcn/ui primitives), molecules (simple compositions), and
  organisms (complex sections) across shared and page-specific boundaries. Seven
  shared layout components form the app shell: AppShell wraps all pages with a
  responsive navigation system (BottomNav on mobile, Sidebar on desktop) and a
  context-aware Header. Eight shared domain components are reused across multiple
  screens: WalletCard (Dashboard + WalletList), TransactionRow (Dashboard + WalletDetail
  + TransactionList), TransactionForm (CreateTransaction + EditTransaction), FilterBar
  (TransactionList only — could become shared if WalletDetail needs filtered view),
  StatCard (Dashboard + MonthlySummary), CategoryCard (CategoryList only — could
  become shared if used in transaction form), ConfirmDialog (DeleteTransaction action),
  and EmptyState (WalletList + TransactionList + MonthlySummary). The TransactionForm
  is the most complex shared component — it encapsulates type toggle, wallet/category
  selection, amount input with IDR formatting, date picker, notes textarea, and
  real-time balance validation. Page-specific organisms include BalanceSummaryCard
  (Dashboard — aggregates wallet balances), QuickActions (Dashboard — navigation
  shortcuts), WalletListGrid (WalletList), CreateWalletForm (CreateWallet),
  WalletDetailCard (WalletDetail — info card + recent transactions), CategoryTabs
  (CategoryList — income/expense tab split), TransactionTable (TransactionList —
  data table with actions), DeleteActionButton (EditTransaction), SummaryHeader
  (MonthlySummary — three stat cards), and breakdown sections (IncomeBreakdownSection,
  ExpenseBreakdownSection). Twenty shadcn/ui components are selected with rationale:
  Button, Card, Input, Select, Badge, Skeleton, Alert, AlertDialog, Table, Tabs,
  Calendar, Popover, Separator, Switch, Textarea, Progress, Label, Sheet, Sonner,
  Sidebar. Form handling uses react-hook-form with Zod resolver. The responsive
  strategy is mobile-first (breakpoint at 768px) with BottomNav < 768px and Sidebar
  >= 768px. WalletDetail screen (confidence 0.6) is included per doc-04 but flagged
  for potential removal. Create and Edit transaction screens use full page routes per
  doc-04 decision, with a ponytail to switch to Sheet/Drawer overlay pattern.
  Eleven assumptions document design decisions, including the decision to keep
  TransactionForm as shared between create and edit, and WalletDetail scope uncertainty.

assumptions:
  - id: ASM-601
    statement: All 9 screens from doc-04 are implemented. WalletDetail (confidence 0.6) included for completeness. If dropped, remove /wallets/[id] route and WalletDetailPage component tree.
    impacts:
      - WalletDetailPage component tree removed
      - WalletCard drill-down navigates to /transactions?wallet_id={id} instead
      - One less page-specific organism and one less page entry in routing
    confidence: 0.6
    source: "doc-04: routes[3] (inferred screen, confidence 0.6)"
  - id: ASM-602
    statement: Create and Edit transaction use full page routes, not modals (Sheet/Drawer). Confirmed by doc-04 ASM-003 and ASM-004.
    impacts:
      - TransactionForm is a page component, not an overlay
      - Deep linking works for /transactions/new and /transactions/[id]/edit
      - ponytail: can switch to Sheet overlay on TransactionListPage later
    confidence: 0.7
    source: "doc-04: ASM-003, ASM-004"
  - id: ASM-603
    statement: TransactionForm component is shared between CreateTransactionPage and EditTransactionPage. EditTransaction pre-fills form with useQuery(['transactions', id]) data.
    impacts:
      - One TransactionForm component in shared/
      - Edit variant adds loading state for prefetch and DeleteActionButton
      - Prop interface must support both create and edit modes
    confidence: 1.0
    source: inference — identical form structure per doc-03: FR-003 and FR-005
  - id: ASM-604
    statement: AppShell uses responsive navigation — BottomNav for mobile (< 768px), Sidebar for desktop (>= 768px). shadcn Sidebar component wraps desktop nav.
    impacts:
      - Two navigation components maintained in parallel (BottomNav, Sidebar)
      - CSS: hidden bottom-nav on desktop, hidden sidebar on mobile via Tailwind responsive classes
      - Theme toggle visible in Header on desktop, possibly in BottomNav on mobile
    confidence: 0.9
    source: "doc-04: section 3 ponytail comment"
  - id: ASM-605
    statement: Zustand UIStore (theme + sidebar) is the only client state. No additional Zustand stores needed per doc-05.
    impacts:
      - ThemeProvider reads from UIStore for dark/light mode
      - Sidebar collapsed state in UIStore
      - No Zustand for form, filter, or domain state
    confidence: 1.0
    source: "doc-05: stores[]"
  - id: ASM-606
    statement: FilterBar is page-specific to TransactionListPage (not shared). WalletDetail uses hardcoded wallet_id filter on the API query, not a reusable FilterBar.
    impacts:
      - FilterBar lives in transactions/ directory, not shared/
      - If WalletDetail needs full filter UI later, promote FilterBar to shared/
      - FilterChip component is extracted as shared since it's simple
    confidence: 0.9
    source: "doc-03: FR-004 UI components"
  - id: ASM-607
    statement: Amount input uses integer for IDR (smallest unit). Display uses Intl.NumberFormat('id-ID') with IDR formatting. No decimal input, no currency selector.
    impacts:
      - AmountInput component uses type="number" with step="1" and min="1"
      - Display components format via useCurrencyFormat hook or util function
      - No floating-point handling needed in inputs
    confidence: 1.0
    source: "doc-03: ASM-004"
  - id: ASM-608
    statement: Category list always has default categories seeded. No empty state for /categories. Only error and loading states.
    impacts:
      - CategoryListPage has no EmptyState component
      - CategorySkeleton shows list placeholders on first load
      - CreateCategoryForm only shown after default categories load
    confidence: 1.0
    source: "doc-03: ASM-009, doc-02: BR-014"
  - id: ASM-609
    statement: Delete action uses AlertDialog (shadcn/ui). Confirmation required. Optimistic UI update not implemented — wait for API response before removing row.
    impacts:
      - ConfirmDialog wraps shadcn AlertDialog
      - No optimistic removal — row stays until API success
      - Toast shows success/error after response
      - ponytail: add optimistic update with undo toast later
    confidence: 0.8
    source: "doc-03: FR-006 UI (konfirmasi dialog)"
  - id: ASM-610
    statement: Loading states use shadcn Skeleton component. Each page has a dedicated loading.tsx per doc-04 route segment specifications.
    impacts:
      - Skeleton patterns defined per page (card skeletons, row skeletons, form skeletons)
      - Reusable LoadingSkeleton molecule pattern for common shapes
      - loading.tsx files use Next.js streaming SSR
    confidence: 1.0
    source: "doc-04: Loading State Table"
  - id: ASM-611
    statement: Error states use shadcn Alert component with retry action. not-found pages use dedicated not-found.tsx with link back. No toast for page-level errors.
    impacts:
      - ErrorAlert molecule wraps shadcn Alert with icon + message + retry Button
      - not-found.tsx per dynamic route (wallets/[id], transactions/[id]/edit)
      - Toast (Sonner) reserved for mutation success/error feedback
    confidence: 1.0
    source: "doc-04: Error State Table"

component_tree:
  - page: Dashboard
    organisms:
      - AppShell
      - BalanceSummaryCard
      - RecentTransactionsList
      - QuickActions
    source: "doc-04: routes[0]"
  - page: WalletList
    organisms:
      - AppShell
      - WalletListGrid
      - EmptyWalletState
    source: "doc-04: routes[1]"
  - page: CreateWallet
    organisms:
      - AppShell
      - CreateWalletForm
    source: "doc-04: routes[2]"
  - page: WalletDetail
    organisms:
      - AppShell
      - WalletDetailCard
      - WalletRecentTransactions
    source: "doc-04: routes[3]"
  - page: CategoryList
    organisms:
      - AppShell
      - CategoryTabs
      - CreateCategoryForm
    source: "doc-04: routes[4]"
  - page: TransactionList
    organisms:
      - AppShell
      - FilterBar
      - TransactionTable
      - PaginationControls
    source: "doc-04: routes[5]"
  - page: CreateTransaction
    organisms:
      - AppShell
      - TransactionForm
    source: "doc-04: routes[6]"
  - page: EditTransaction
    organisms:
      - AppShell
      - TransactionForm
      - DeleteActionButton
    source: "doc-04: routes[7]"
  - page: MonthlySummary
    organisms:
      - AppShell
      - SummaryHeader
      - MonthYearPicker
      - IncomeBreakdownSection
      - ExpenseBreakdownSection
    source: "doc-04: routes[8]"

shared_components:
  - name: AppShell
    shadcn_source: custom
    props:
      - name: children
        type: ReactNode
    used_by:
      - Dashboard
      - WalletList
      - CreateWallet
      - WalletDetail
      - CategoryList
      - TransactionList
      - CreateTransaction
      - EditTransaction
      - MonthlySummary
    source: "doc-04: section 3 Layout Structure"
    confidence: 1.0
  - name: PageHeader
    shadcn_source: custom (uses shadcn Button)
    props:
      - name: title
        type: string
      - name: backHref
        type: string | undefined
      - name: action
        type: "{ label: string; href?: string; onClick?: () => void; variant?: 'default' | 'outline' } | undefined"
    used_by:
      - Dashboard
      - WalletList
      - CreateWallet
      - WalletDetail
      - CategoryList
      - TransactionList
      - CreateTransaction
      - EditTransaction
      - MonthlySummary
    source: "doc-04: section 3 Header"
    confidence: 1.0
  - name: WalletCard
    shadcn_source: custom (uses shadcn Card, Badge)
    props:
      - name: wallet
        type: Wallet
      - name: href
        type: string | undefined
      - name: className
        type: string | undefined
    used_by:
      - Dashboard
      - WalletList
      - WalletDetail
    source: "doc-03: FR-001 UI components"
    confidence: 1.0
  - name: TransactionRow
    shadcn_source: custom (uses shadcn Table, Badge, Button)
    props:
      - name: transaction
        type: Transaction
      - name: onEdit
        type: "((id: number) => void) | undefined"
      - name: onDelete
        type: "((id: number) => void) | undefined"
      - name: showActions
        type: boolean
    used_by:
      - Dashboard
      - TransactionList
      - WalletDetail
    source: "doc-03: FR-004 UI components"
    confidence: 1.0
  - name: TransactionForm
    shadcn_source: custom (uses shadcn Form via react-hook-form, Input, Select, Switch, Textarea, Calendar, Popover, Alert, Button, Label)
    props:
      - name: mode
        type: "'create' | 'edit'"
      - name: defaultValues
        type: "TransactionCreateInput | undefined"
      - name: onSubmit
        type: "(data: TransactionCreateInput) => Promise<void>"
      - name: wallets
        type: Wallet[]
      - name: categories
        type: Category[]
      - name: isSubmitting
        type: boolean
      - name: onCancel
        type: "(() => void) | undefined"
    used_by:
      - CreateTransaction
      - EditTransaction
    source: "doc-03: FR-003, FR-005 UI components"
    confidence: 1.0
  - name: StatCard
    shadcn_source: custom (uses shadcn Card)
    props:
      - name: title
        type: string
      - name: value
        type: number
      - name: type
        type: "'income' | 'expense' | 'net'"
      - name: icon
        type: "ReactNode | undefined"
    used_by:
      - Dashboard
      - MonthlySummary
    source: "doc-03: FR-007 UI components"
    confidence: 1.0
  - name: ConfirmDialog
    shadcn_source: shadcn AlertDialog
    props:
      - name: open
        type: boolean
      - name: onOpenChange
        type: "(open: boolean) => void"
      - name: title
        type: string
      - name: description
        type: string
      - name: confirmLabel
        type: string
      - name: cancelLabel
        type: string
      - name: variant
        type: "'default' | 'destructive'"
      - name: onConfirm
        type: "() => void"
      - name: isConfirming
        type: boolean | undefined
    used_by:
      - TransactionList
      - EditTransaction
    source: "doc-03: FR-006 — konfirmasi dialog"
    confidence: 1.0
  - name: EmptyState
    shadcn_source: custom (uses shadcn Card, Button)
    props:
      - name: title
        type: string
      - name: description
        type: string | undefined
      - name: action
        type: "{ label: string; href?: string; onClick?: () => void } | undefined"
      - name: icon
        type: "ReactNode | undefined"
    used_by:
      - WalletList
      - TransactionList
      - MonthlySummary
    source: "doc-03: section 4.3 Shared Components"
    confidence: 1.0
  - name: ErrorAlert
    shadcn_source: shadcn Alert
    props:
      - name: message
        type: string
      - name: onRetry
        type: "(() => void) | undefined"
      - name: className
        type: string | undefined
    used_by:
      - Dashboard
      - WalletList
      - CreateWallet
      - WalletDetail
      - CategoryList
      - TransactionList
      - CreateTransaction
      - EditTransaction
      - MonthlySummary
    source: "doc-03: section 4.3 Shared Components"
    confidence: 1.0
  - name: LoadingSkeleton
    shadcn_source: shadcn Skeleton
    props:
      - name: variant
        type: "'card' | 'row' | 'form' | 'stat' | 'list'"
      - name: count
        type: number
    used_by:
      - Dashboard
      - WalletList
      - CreateWallet
      - WalletDetail
      - CategoryList
      - TransactionList
      - CreateTransaction
      - EditTransaction
      - MonthlySummary
    source: "doc-04: Loading State Table"
    confidence: 1.0
  - name: BalanceSummaryCard
    shadcn_source: custom (uses shadcn Card)
    props:
      - name: wallets
        type: Wallet[]
      - name: isLoading
        type: boolean
    used_by:
      - Dashboard
    source: "doc-03: FR-001 — balance display"
    confidence: 0.9
  - name: FilterChip
    shadcn_source: custom (uses shadcn Badge, X icon)
    props:
      - name: label
        type: string
      - name: onRemove
        type: "() => void"
    used_by:
      - TransactionList
    source: "doc-03: FR-004 UI — active filter badges"
    confidence: 1.0
---

# 06 — Component and UI Plan

## 1. Shared Components

### 1.1 Layout Components

All pages share the same shell via `AppShell`. Navigation adapts to viewport.

**AppShell** — The root layout wrapper containing:
- `Header` (app title + theme toggle + optional page action button)
- `Sidebar` (desktop navigation — shadcn Sidebar component)
- `BottomNav` (mobile navigation — custom)
- `{children}` (page content)

```
<AppShell>
  <Header title="Pocket">
    {<ThemeToggle />}
  </Header>
  <div className="flex">
    <Sidebar>        {/* hidden on mobile, shown on desktop */}
      <NavItem href="/" icon={LayoutDashboard} label="Beranda" />
      <NavItem href="/wallets" icon={Wallet} label="Dompet" />
      <NavItem href="/categories" icon={Tags} label="Kategori" />
      <NavItem href="/transactions" icon={ArrowLeftRight} label="Transaksi" />
      <NavItem href="/summary" icon={BarChart3} label="Ringkasan" />
    </Sidebar>
    <main>
      {children}
    </main>
  </div>
  <BottomNav>        {/* hidden on desktop, shown on mobile */}
    <BottomNavItem href="/" icon={LayoutDashboard} label="Beranda" />
    <BottomNavItem href="/wallets" icon={Wallet} label="Dompet" />
    <BottomNavItem href="/categories" icon={Tags} label="Kategori" />
    <BottomNavItem href="/transactions" icon={ArrowLeftRight} label="Transaksi" />
    <BottomNavItem href="/summary" icon={BarChart3} label="Ringkasan" />
  </BottomNav>
</AppShell>
```

**Header** — Props: `title: string`, `showBack?: boolean`, `backHref?: string`, `action?: { label: string; href?: string; onClick?: () => void }`.

**Sidebar** — Uses shadcn `Sidebar`, `SidebarContent`, `SidebarGroup`, `SidebarMenu`, `SidebarMenuItem`, `SidebarMenuButton`. Wraps with `SidebarProvider` in AppShell. Source: `shadcn Sidebar component docs`.

**BottomNav** — Custom component. Fixed bottom bar with 5 nav links. Uses shadcn `Sheet` for optional overflow menu. Props: `items: NavItem[]`.

**PageHeader** — Molecule composing title + optional back Button (shadcn Button variant="ghost" with arrow-left icon) + optional action Button.

### 1.2 Domain Shared Components

**WalletCard** — Displays single wallet summary: name, type (with Badge: cash/bank/e-wallet), current_balance (formatted IDR). Clickable card linking to `/wallets/[id]`. Props interface:

```typescript
interface WalletCardProps {
  wallet: {
    id: number
    name: string
    type: 'cash' | 'bank' | 'e-wallet'
    currentBalance: number
    initialBalance: number
  }
  href?: string
  className?: string
}
```

Uses shadcn `Card`, `CardHeader`, `CardContent`, `Badge`.

**TransactionRow** — Single transaction row/line item. Shows: type icon (income green up / expense red down), category name, wallet name, amount (formatted IDR, color-coded), date, optional note preview. Action buttons: edit (pencil icon), delete (trash icon). Props:

```typescript
interface TransactionRowProps {
  transaction: {
    id: number
    type: 'income' | 'expense'
    amount: number
    transactionDate: string
    note?: string
    categoryName: string
    walletName: string
  }
  showActions?: boolean
  onEdit?: (id: number) => void
  onDelete?: (id: number) => void
}
```

On `Dashboard`: compact variant with `showActions=false`. On `TransactionList`: full variant with actions. On `WalletDetail`: compact with wallet info implicit.

**CategoryCard** — Displays single category: name, type icon (income/expense), `isDefault` badge. Props:

```typescript
interface CategoryCardProps {
  category: {
    id: number
    name: string
    type: 'income' | 'expense'
    isDefault: boolean
  }
}
```

Uses shadcn `Card`, `Badge`.

**StatCard** — Single stat display for summary values. Color-coded by type: income (green), expense (red), net (blue or red if negative). Props:

```typescript
interface StatCardProps {
  title: string
  value: number
  type: 'income' | 'expense' | 'net'
  icon?: ReactNode
}
```

Uses shadcn `Card`, `CardHeader`, `CardContent`. Formats value with `Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 })`.

**TransactionForm** — The most complex shared component. Used in both CreateTransaction and EditTransaction modes. Internal structure:

```
TransactionForm
├── TypeToggle          (shadcn Tabs or Switch — income/expense)
├── WalletSelect        (shadcn Select — populated from useQuery(['wallets']))
├── CategorySelect      (shadcn Select — filtered by selected type)
├── AmountInput         (shadcn Input type="number" + IDR prefix)
├── DatePicker          (shadcn Calendar + Popover — max=current date)
├── NoteTextarea        (shadcn Textarea — optional, max 500 chars)
├── BalanceWarning      (shadcn Alert variant="warning" — conditional)
└── SubmitButton        (shadcn Button type="submit")
```

Props:

```typescript
interface TransactionFormProps {
  mode: 'create' | 'edit'
  defaultValues?: Partial<TransactionCreateInput>
  onSubmit: (data: TransactionCreateInput) => Promise<void>
  wallets: Wallet[]
  categories: Category[]
  isSubmitting: boolean
  onCancel?: () => void
}
```

`ponytail: split into BaseTransactionForm + CreateTransactionForm + EditTransactionForm if mode branching adds complexity. Merge back if forms diverge.`

**FilterBar** — Transaction list filters. Props:

```typescript
interface FilterBarProps {
  filters: {
    dateFrom?: string
    dateTo?: string
    type?: 'income' | 'expense'
    walletId?: number
    categoryId?: number
    q?: string
  }
  onChange: (filters: Partial<FilterBarProps['filters']>) => void
  wallets: Wallet[]
  categories: Category[]
  onReset: () => void
}
```

Internal structure:

```
FilterBar
├── DateRangePicker     (shadcn Calendar + Popover — date_from/date_to)
├── TypeSelect          (shadcn Select — income/expense/all)
├── WalletSelect        (shadcn Select — from wallet list)
├── CategorySelect      (shadcn Select — from category list)
├── SearchInput         (shadcn Input with search icon — debounced 300ms)
├── ApplyButton         (shadcn Button — apply filters)
└── FilterChips         (shadcn Badge with remove X — active filters)
```

**ConfirmDialog** — Wraps shadcn `AlertDialog`. Reused for delete confirmation. Props defined in shared_components above.

**EmptyState** — Generic empty state with icon, title, description, and optional CTA button/link. Props defined above.

**ErrorAlert** — Wraps shadcn `Alert` with `variant="destructive"`. Shows error message + optional retry button. Props defined above.

**LoadingSkeleton** — Abstracted skeleton pattern. Props: `variant: 'card' | 'row' | 'form' | 'stat' | 'list'`, `count: number`. Uses shadcn `Skeleton`.

**FilterChip** — Active filter badge with remove button. Mapped to shadcn `Badge` with `variant="outline"` + close icon Button.

### 1.3 UI Store Integration (Zustand)

Referenced from doc-05. Only one store:

```typescript
// stores/ui-store.ts
interface UIStore {
  theme: 'light' | 'dark'
  sidebarCollapsed: boolean
  setTheme: (theme: 'light' | 'dark') => void
  toggleSidebar: () => void
}
```

`useUIStore` imported in:
- `ThemeToggle` component (Header)
- `Sidebar` component (responsive collapse)
- `AppShell` layout

---

## 2. Page-Specific Component Trees

### 2.1 Dashboard (`/`)

```
app/
  page.tsx                           # DashboardPage
  loading.tsx                        # DashboardSkeleton (3 StatCard skeletons + 5 TransactionRow skeletons)
  error.tsx                          # DashboardErrorBoundary
  components/
    balance-summary-card.tsx         # Organism — total balance across all wallets
    recent-transactions-list.tsx     # Organism — last 5 transactions
    quick-actions.tsx                # Organism — shortcut links (Catat Transaksi, Lihat Ringkasan)
```

**DashboardPage internal hierarchy:**

```
DashboardPage
├── AppShell
│   ├── Header (title: "Beranda")
│   └── Sidebar/BottomNav
├── BalanceSummaryCard
│   ├── StatCard (type="income" — total income this month)
│   ├── StatCard (type="expense" — total expense this month)
│   └── StatCard (type="net" — net balance)
├── RecentTransactionsList
│   └── TransactionRow (×5, showActions=false)
├── QuickActions
│   ├── Button "Catat Transaksi" → /transactions/new
│   └── Button "Lihat Ringkasan" → /summary
└── Link "Lihat Semua Transaksi" → /transactions
```

Data sources per doc-05:
- `useQuery(['wallets'])` — wallet list for balance summary
- `useQuery(['transactions', { page: 1, perPage: 5 }])` — recent 5 transactions

### 2.2 WalletList (`/wallets`)

```
app/wallets/
  page.tsx                           # WalletListPage
  loading.tsx                        # WalletListSkeleton (4 Card skeletons in grid)
  error.tsx                          # WalletListErrorBoundary
  components/
    wallet-list-grid.tsx             # Organism — responsive Card grid
    empty-wallet-state.tsx           # Organism — CTA to create first wallet
```

**WalletListPage internal hierarchy:**

```
WalletListPage
├── AppShell
│   └── Header (title: "Dompet" + action: "Buat Dompet" → /wallets/new)
├── WalletListGrid
│   └── WalletCard (×N, href="/wallets/[id]")
│       ├── Card (shadcn)
│       ├── Badge (type: cash/bank/e-wallet)
│       └── Balance (formatted IDR)
└── EmptyWalletState (shown when wallets.length === 0)
    └── EmptyState (icon: Wallet, title: "Belum ada dompet", action: "Buat dompet pertama" → /wallets/new)
```

Data sources per doc-05: `useQuery(['wallets'])`.

### 2.3 CreateWallet (`/wallets/new`)

```
app/wallets/new/
  page.tsx                           # CreateWalletPage
  loading.tsx                        # FormSkeleton (3 field skeletons)
```

**CreateWalletPage internal hierarchy:**

```
CreateWalletPage
├── AppShell
│   └── Header (title: "Dompet Baru", showBack=true, backHref="/wallets")
└── CreateWalletForm
    ├── Input (name — shadcn Input, required)
    ├── Select (type — cash/bank/e-wallet, optional icon per option)
    ├── Input (initialBalance — type="number", min=0, default=0)
    ├── Alert (info: "Saldo awal akan menjadi saldo saat ini")
    └── Button (submit — "Simpan")
```

Data sources per doc-05: `useCreateWallet` mutation.

### 2.4 WalletDetail (`/wallets/[id]`)

```
app/wallets/[id]/
  page.tsx                           # WalletDetailPage
  loading.tsx                        # WalletDetailSkeleton (1 Card + 3 rows)
  error.tsx                          # WalletDetailErrorBoundary
  not-found.tsx                      # WalletNotFound (link back to /wallets)
  components/
    wallet-detail-card.tsx           # Organism — wallet info + balance
    wallet-recent-transactions.tsx   # Organism — transactions for this wallet
```

**WalletDetailPage internal hierarchy:**

```
WalletDetailPage
├── AppShell
│   └── Header (title: wallet.name, showBack=true, backHref="/wallets")
├── WalletDetailCard
│   ├── Card
│   │   ├── Wallet name + type Badge
│   │   ├── Current balance (formatted IDR, large text)
│   │   └── Initial balance (small, muted)
│   └── Link "Lihat semua transaksi dompet ini" → /transactions?wallet_id={id}
├── WalletRecentTransactions
│   ├── Section heading "Transaksi Terbaru"
│   └── TransactionRow (×5, showActions=false)
└── (if wallet not found → not-found.tsx: "Dompet tidak ditemukan" + link to /wallets)
```

Data sources per doc-05:
- `useQuery(['wallets', id])` — single wallet
- `useQuery(['transactions', { walletId: id, page: 1, perPage: 5 }])` — wallet transactions

`ponytail: if wallet detail screen is removed per ASM-601, remove this entire tree. Transaction drill-down goes directly to /transactions?wallet_id={id}.`

### 2.5 CategoryList (`/categories`)

```
app/categories/
  page.tsx                           # CategoryListPage
  loading.tsx                        # CategoryListSkeleton (2 tab skeletons + list items)
  error.tsx                          # CategoryListErrorBoundary
  components/
    category-tabs.tsx                # Organism — income/expense tabs
    category-grid.tsx                # Molecule — category cards per tab
    create-category-form.tsx         # Organism — form to create custom category
```

**CategoryListPage internal hierarchy:**

```
CategoryListPage
├── AppShell
│   └── Header (title: "Kategori" + action: "Tambah Kategori" → opens create form inline or Dialog)
├── CategoryTabs (shadcn Tabs — "Pemasukan" | "Pengeluaran")
│   ├── TabsList
│   │   ├── TabsTrigger "Pemasukan" (value="income")
│   │   └── TabsTrigger "Pengeluaran" (value="expense")
│   └── TabsContent (value="income")
│       └── CategoryGrid
│           └── CategoryCard (×N — income categories)
│               ├── Category name
│               └── Badge "Default" (only if isDefault=true)
│   └── TabsContent (value="expense")
│       └── CategoryGrid
│           └── CategoryCard (×N — expense categories)
├── CreateCategoryForm (inline form or shadcn Dialog)
│   ├── Input (name — required, unique per type)
│   ├── Select (type — income/expense, pre-selected based on active tab)
│   └── Button (submit — "Simpan")
```

Data sources per doc-05:
- `useQuery(['categories'])` — all categories (default + custom)
- `useCreateCategory` mutation — create custom category

### 2.6 TransactionList (`/transactions`)

```
app/transactions/
  page.tsx                           # TransactionListPage
  loading.tsx                        # TransactionListSkeleton (FilterBar skeleton + 5 row skeletons + pagination skeleton)
  error.tsx                          # TransactionListErrorBoundary
  components/
    transaction-table.tsx            # Organism — data table with rows + actions
    pagination-controls.tsx          # Molecule — page navigation
```

**TransactionListPage internal hierarchy:**

```
TransactionListPage
├── AppShell
│   └── Header (title: "Transaksi" + action: "Catat Transaksi" → /transactions/new)
├── FilterBar
│   ├── DateRangePicker (shadcn Calendar + Popover — date_from → date_to)
│   ├── Select (type — Semua/Pemasukan/Pengeluaran)
│   ├── Select (wallet — from useQuery(['wallets']))
│   ├── Select (category — from useQuery(['categories']))
│   ├── Input (search — search icon, placeholder: "Cari catatan...")
│   ├── Button "Terapkan Filter" (apply)
│   └── FilterChip (×N active filters — Badge with X to remove individual)
├── TransactionTable
│   ├── Table (shadcn Table)
│   │   ├── TableHeader
│   │   │   └── TableRow
│   │   │       ├── TableHead "Tanggal"
│   │   │       ├── TableHead "Kategori"
│   │   │       ├── TableHead "Dompet"
│   │   │       ├── TableHead "Catatan"
│   │   │       ├── TableHead "Jumlah"
│   │   │       └── TableHead "Aksi"
│   │   └── TableBody
│   │       └── TransactionRow (×N, showActions=true)
│   │           ├── TransactionRow cells
│   │           ├── Button (edit → /transactions/[id]/edit)
│   │           └── Button (delete → ConfirmDialog)
│   └── EmptyState (if no results — "Tidak ada transaksi yang cocok" + "Reset Filter" button)
├── PaginationControls
│   ├── Button "Sebelumnya" (disabled on page 1)
│   ├── Page info: "Halaman X dari Y"
│   └── Button "Berikutnya" (disabled on last page)
└── ConfirmDialog (delete confirmation, mounted conditionally)
```

Data sources per doc-05:
- `useQuery(['transactions', filters])` — filtered, paginated transaction list
- `useQuery(['wallets'])` — wallet list for filter dropdown
- `useQuery(['categories'])` — category list for filter dropdown
- `useDeleteTransaction` mutation

### 2.7 CreateTransaction (`/transactions/new`)

```
app/transactions/new/
  page.tsx                           # CreateTransactionPage
  loading.tsx                        # FormSkeleton (Select skeletons + Input skeletons)
```

**CreateTransactionPage internal hierarchy:**

```
CreateTransactionPage
├── AppShell
│   └── Header (title: "Transaksi Baru", showBack=true)
└── CreateTransactionForm
    └── TransactionForm (mode="create")
        ├── TypeToggle (shadcn Tabs — "Pemasukan" | "Pengeluaran")
        ├── Select (wallet — from useQuery(['wallets']))
        ├── Select (category — filtered by selected type, from useQuery(['categories']))
        ├── Input (amount — type="number", min=1, prefix: "Rp")
        ├── DatePicker (shadcn Calendar + Popover — max=current date, default=today)
        ├── Textarea (note — optional, max 500 chars)
        ├── Alert (balance warning — shown when expense > wallet balance)
        └── Button "Simpan" (submit, disabled when submitting)
    └── UseMutation: useCreateTransaction
```

Data sources per doc-05:
- `useQuery(['wallets'])` — wallet options
- `useQuery(['categories'])` — category options (filtered client-side by type)
- `useCreateTransaction` mutation

### 2.8 EditTransaction (`/transactions/[id]/edit`)

```
app/transactions/[id]/edit/
  page.tsx                           # EditTransactionPage
  loading.tsx                        # EditTransactionSkeleton ("Memuat data transaksi..." + form skeleton)
  error.tsx                          # EditTransactionErrorBoundary
  not-found.tsx                      # TransactionNotFound (link back to /transactions)
  components/
    delete-action-button.tsx         # Molecule — delete button + ConfirmDialog
```

**EditTransactionPage internal hierarchy:**

```
EditTransactionPage
├── AppShell
│   └── Header (title: "Edit Transaksi", showBack=true)
├── (if loading transaction data)
│   └── FormSkeleton
├── (if not found)
│   └── not-found.tsx: "Transaksi tidak ditemukan" + link to /transactions
├── (if loaded)
│   └── EditTransactionForm
│       └── TransactionForm (mode="edit", defaultValues from useQuery(['transactions', id]))
│           ├── TypeToggle
│           ├── Select (wallet)
│           ├── Select (category)
│           ├── Input (amount)
│           ├── DatePicker
│           ├── Textarea (note)
│           ├── Alert (balance warning)
│           └── Button "Simpan Perubahan" (submit)
├── DeleteActionButton
│   ├── Separator
│   ├── Button variant="destructive" "Hapus Transaksi"
│   └── ConfirmDialog ("Apakah kamu yakin ingin menghapus transaksi ini? Saldo akan disesuaikan.")
```

Data sources per doc-05:
- `useQuery(['transactions', id])` — existing transaction data
- `useQuery(['wallets'])` — wallet options
- `useQuery(['categories'])` — category options
- `useUpdateTransaction` mutation
- `useDeleteTransaction` mutation

### 2.9 MonthlySummary (`/summary`)

```
app/summary/
  page.tsx                           # MonthlySummaryPage
  loading.tsx                        # SummarySkeleton (3 StatCard skeletons + 2 breakdown section skeletons)
  error.tsx                          # SummaryErrorBoundary
  components/
    summary-header.tsx               # Organism — 3 StatCards (income, expense, net)
    month-year-picker.tsx            # Molecule — prev/current/next month navigation
    income-breakdown-section.tsx     # Organism — income by category with progress bars
    expense-breakdown-section.tsx    # Organism — expense by category with progress bars
    category-breakdown-item.tsx      # Molecule — single category row in breakdown
```

**MonthlySummaryPage internal hierarchy:**

```
MonthlySummaryPage
├── AppShell
│   └── Header (title: "Ringkasan Bulanan")
├── MonthYearPicker
│   ├── Button ("<" previous month)
│   ├── Select (month — 1..12, numeric or name)
│   ├── Select (year — 2020..current+1)
│   └── Button (">" next month, disabled if current/future month)
├── SummaryHeader
│   ├── StatCard (type="income", title="Total Pemasukan", value=totalIncome)
│   ├── StatCard (type="expense", title="Total Pengeluaran", value=totalExpense)
│   └── StatCard (type="net", title="Saldo Bersih", value=netBalance)
├── Badge "X transaksi" (transactionCount)
├── IncomeBreakdownSection
│   ├── Section heading "Pemasukan per Kategori"
│   └── CategoryBreakdownItem (×N)
│       ├── Category name
│       ├── Progress (shadcn Progress — percentage of total income)
│       └── Amount (formatted IDR)
├── ExpenseBreakdownSection
│   ├── Section heading "Pengeluaran per Kategori"
│   └── CategoryBreakdownItem (×N)
│       ├── Category name
│       ├── Progress (shadcn Progress — percentage of total expense)
│       └── Amount (formatted IDR)
└── EmptyState (if no transactions — "Tidak ada transaksi di bulan ini", all values = 0)
```

Data sources per doc-05:
- `useQuery(['summary', { month, year }])` — aggregated summary data
- Search params: `?month=&year=` from URL (default to current month/year)

---

## 3. shadcn/ui Selections

| Component | shadcn/ui Name | Used In | Rationale |
|-----------|---------------|---------|-----------|
| Button | Button | All pages — actions, submit, navigation, toggles | Core primitive for all clickable actions |
| Card | Card | WalletCard, CategoryCard, StatCard, BalanceSummaryCard, SummaryHeader | Consistent container pattern for data display |
| Input | Input | Form fields (name, amount, search, initial_balance) | Native input with Tailwind styling |
| Select | Select | Wallet selection, category selection, type filter, month/year picker | Radix-powered accessible select |
| Badge | Badge | Wallet type indicator, isDefault badge, FilterChip, transaction count | Compact status/label display |
| Skeleton | Skeleton | All loading.tsx pages — card, row, form, stat, list variants | Placeholder loading pattern |
| Alert | Alert | BalanceWarning, ErrorAlert, info messages | Contextual feedback messages |
| AlertDialog | AlertDialog | ConfirmDialog — delete confirmation | Modal confirmation with focus trap |
| Table | Table | TransactionTable — transaction list data display | Structured tabular data for transactions |
| Tabs | Tabs | CategoryTabs (income/expense), TypeToggle in TransactionForm | Tab-based content switching |
| Calendar | Calendar | DatePicker (TransactionForm), DateRangePicker (FilterBar) | Date selection UI |
| Popover | Popover | DatePicker wrapper (Calendar + Popover), DateRangePicker | Floating panel for date selection |
| Separator | Separator | Between sections (EditTransaction — form vs delete section), SummaryHeader | Visual section dividers |
| Switch | Switch | TypeToggle alternative (income/expense toggle in TransactionForm) | Binary toggle for transaction type |
| Textarea | Textarea | Note field in TransactionForm | Multi-line text input |
| Progress | Progress | CategoryBreakdownItem — percentage bar | Visual progress for category breakdown |
| Label | Label | Form field labels in TransactionForm, CreateWalletForm | Accessible form label |
| Sheet | Sheet | Mobile navigation drawer (optional), future modal enhancement | Slide-in panel for overflow content |
| Sonner | Sonner | Toast notifications — success/error feedback for all mutations | Lightweight toast library |
| Sidebar | Sidebar | Desktop navigation — AppShell sidebar | Responsive sidebar with collapsible groups |

**Additional non-shadcn dependencies:**
- `react-hook-form` + `@hookform/resolvers/zod` — form state and validation (used by TransactionForm, CreateWalletForm, CreateCategoryForm)
- `lucide-react` — icon library (imported by shadcn/ui, used for nav icons, action icons, type icons)
- `date-fns` — date formatting and manipulation (used by DatePicker, Calendar, summary)

---

## 4. Component Hierarchy per Screen (Visual Trees)

### Dashboard

```
DashboardPage
├── AppShell
│   ├── Header (title: "Beranda")
│   ├── Sidebar (desktop) / BottomNav (mobile)
│   └── main
│       ├── BalanceSummaryCard
│       │   ├── StatCard (type="income", title="Pemasukan Bulan Ini")
│       │   ├── StatCard (type="expense", title="Pengeluaran Bulan Ini")
│       │   └── StatCard (type="net", title="Saldo Bersih")
│       ├── RecentTransactionsList
│       │   └── TransactionRow (×5, showActions=false)
│       │       ├── Badge (type icon: ↑/↓)
│       │       ├── Category name
│       │       ├── Wallet name
│       │       ├── Amount (color-coded)
│       │       └── Date (relative: "Hari ini", "Kemarin", or date)
│       └── QuickActions
│           ├── Button "Catat Transaksi" → /transactions/new
│           └── Button "Lihat Ringkasan" → /summary
```

### WalletList

```
WalletListPage
├── AppShell
│   ├── Header (title: "Dompet", action: "Buat Dompet" → /wallets/new)
│   └── main
│       ├── WalletListGrid (grid-cols-1 sm:grid-cols-2 lg:grid-cols-3)
│       │   └── WalletCard (×N)
│       │       ├── Card
│       │       │   ├── CardHeader
│       │       │   │   ├── Wallet name
│       │       │   │   └── Badge (type: cash/bank/e-wallet)
│       │       │   └── CardContent
│       │       │       ├── "Saldo Saat Ini"
│       │       │       └── Amount (large, formatted IDR)
│       │       └── Link → /wallets/[id]
│       └── EmptyWalletState (when wallets.length === 0)
│           └── EmptyState (icon, title, description, CTA → /wallets/new)
```

### CreateWallet

```
CreateWalletPage
├── AppShell
│   ├── Header (title: "Dompet Baru", backHref="/wallets")
│   └── main
│       └── CreateWalletForm (max-w-md mx-auto)
│           ├── Input (name, label: "Nama Dompet", required, placeholder: "Dompet Harian")
│           ├── Select (type, label: "Tipe Dompet", required, options: cash/bank/e-wallet)
│           ├── Input (initialBalance, label: "Saldo Awal", type="number", min=0, default=0)
│           ├── Alert (info: "Saldo awal akan menjadi saldo saat ini")
│           └── Button (type="submit", "Simpan")
```

### WalletDetail

```
WalletDetailPage
├── AppShell
│   ├── Header (title: wallet.name, backHref="/wallets")
│   └── main
│       ├── WalletDetailCard
│       │   └── Card
│       │       ├── Badge (type: cash/bank/e-wallet)
│       │       ├── Current balance (text-2xl font-bold, formatted IDR)
│       │       ├── "Saldo Awal: Rp X" (text-sm text-muted-foreground)
│       │       └── Link → /transactions?wallet_id={id} ("Lihat Semua Transaksi")
│       ├── WalletRecentTransactions
│       │   ├── h3 "Transaksi Terbaru"
│       │   └── TransactionRow (×5, showActions=false)
│       └── (not-found.tsx when wallet not found → "Dompet tidak ditemukan" + Link to /wallets)
```

### CategoryList

```
CategoryListPage
├── AppShell
│   ├── Header (title: "Kategori")
│   └── main
│       ├── Tabs (default: active tab for income)
│       │   ├── TabsList
│       │   │   ├── TabsTrigger "Pemasukan" (value: "income")
│       │   │   └── TabsTrigger "Pengeluaran" (value: "expense")
│       │   ├── TabsContent (value: "income")
│       │   │   └── CategoryGrid
│       │   │       └── CategoryCard (×N, income categories)
│       │   │           └── Card
│       │   │               ├── Category name
│       │   │               └── Badge "Default" (conditional, if isDefault)
│       │   └── TabsContent (value: "expense")
│       │       └── CategoryGrid
│       │           └── CategoryCard (×N, expense categories)
│       ├── Separator
│       └── CreateCategoryForm (collapsible or Dialog)
│           ├── Input (name, label: "Nama Kategori")
│           ├── Select (type, label: "Tipe", pre-selected from active tab)
│           └── Button "Simpan"
```

### TransactionList

```
TransactionListPage
├── AppShell
│   ├── Header (title: "Transaksi", action: "Catat Transaksi" → /transactions/new)
│   └── main
│       ├── FilterBar (sticky top)
│       │   ├── DateRangePicker (Calendar + Popover)
│       │   ├── Select (type: Semua/Pemasukan/Pengeluaran)
│       │   ├── Select (wallet: all wallets)
│       │   ├── Select (category: all categories)
│       │   ├── Input (search, debounced)
│       │   ├── Button "Terapkan Filter"
│       │   └── FilterChip (×N, removable)
│       │       └── Badge (outline) + X Button
│       ├── TransactionTable
│       │   └── Table
│       │       ├── TableHeader
│       │       │   └── TableRow
│       │       │       ├── TableHead "Tanggal"
│       │       │       ├── TableHead "Kategori"
│       │       │       ├── TableHead "Dompet"
│       │       │       ├── TableHead "Catatan"
│       │       │       ├── TableHead "Jumlah"
│       │       │       └── TableHead "Aksi"
│       │       └── TableBody
│       │           └── TransactionRow (×N, showActions=true)
│       │               ├── Date
│       │               ├── Category name + Badge type
│       │               ├── Wallet name
│       │               ├── Note preview (truncated)
│       │               ├── Amount (formatted IDR, color-coded)
│       │               └── Button Group
│       │                   ├── Button (edit → /transactions/[id]/edit)
│       │                   └── Button (delete → open ConfirmDialog)
│       ├── PaginationControls
│       │   ├── Button "Sebelumnya" (disabled on page 1)
│       │   ├── "Halaman X dari Y"
│       │   └── Button "Berikutnya" (disabled on last page)
│       └── EmptyState (conditional — no results with filters active vs no transactions at all)
```

### CreateTransaction

```
CreateTransactionPage
├── AppShell
│   ├── Header (title: "Transaksi Baru", backHref="/transactions")
│   └── main
│       └── TransactionForm (mode="create")
│           ├── Tabs (TypeToggle — "Pemasukan" | "Pengeluaran", default: expense)
│           ├── Select (wallet, label: "Dompet", placeholder: "Pilih dompet")
│           ├── Select (category, label: "Kategori", placeholder: "Pilih kategori", filtered by type)
│           ├── Input (amount, label: "Jumlah", type="number", prefix: "Rp", min=1)
│           ├── div (DatePicker)
│           │   ├── Popover
│           │   │   ├── Button (trigger — selected date)
│           │   │   └── PopoverContent
│           │   │       └── Calendar (mode="single", maxDate=today)
│           │   └── Label "Tanggal"
│           ├── Textarea (note, label: "Catatan", optional, maxLength=500)
│           ├── Alert (variant="destructive", conditional: "Saldo tidak mencukupi" — live check)
│           └── Button (type="submit", "Catat Transaksi")
```

### EditTransaction

```
EditTransactionPage
├── AppShell
│   ├── Header (title: "Edit Transaksi", backHref="/transactions")
│   └── main
│       ├── (skeleton while loading transaction data)
│       ├── (not-found.tsx if transaction doesn't exist)
│       └── EditTransactionForm
│           └── TransactionForm (mode="edit", defaultValues from useQuery)
│               ├── Tabs (TypeToggle — pre-selected from existing type)
│               ├── Select (wallet — pre-selected)
│               ├── Select (category — pre-selected)
│               ├── Input (amount — pre-filled)
│               ├── DatePicker — pre-selected
│               ├── Textarea (note — pre-filled)
│               ├── Alert (balance warning — conditional)
│               └── Button "Simpan Perubahan" (submit)
│       ├── Separator
│       └── DeleteActionButton
│           ├── Button variant="destructive" "Hapus Transaksi"
│           └── ConfirmDialog
│               ├── AlertDialogContent
│               │   ├── AlertDialogTitle "Hapus Transaksi?"
│               │   ├── AlertDialogDescription "Saldo wallet akan disesuaikan."
│               │   ├── AlertDialogCancel "Batal"
│               │   └── AlertDialogAction variant="destructive" "Hapus"
```

### MonthlySummary

```
MonthlySummaryPage
├── AppShell
│   ├── Header (title: "Ringkasan Bulanan")
│   └── main
│       ├── MonthYearPicker
│       │   ├── Button variant="outline" "<" (previous month)
│       │   ├── Select (month — 1..12)
│       │   ├── Select (year — 2020..current+1)
│       │   └── Button variant="outline" ">" (next month, disabled if future)
│       ├── SummaryHeader (grid-cols-1 sm:grid-cols-3)
│       │   ├── StatCard (type="income", green)
│       │   │   └── Card
│       │   │       ├── CardHeader: icon + "Total Pemasukan"
│       │   │       └── CardContent: amount (text-green-600)
│       │   ├── StatCard (type="expense", red)
│       │   │   └── Card
│       │   │       ├── CardHeader: icon + "Total Pengeluaran"
│       │   │       └── CardContent: amount (text-red-600)
│       │   └── StatCard (type="net", blue or red if negative)
│       │       └── Card
│       │           ├── CardHeader: icon + "Saldo Bersih"
│       │           └── CardContent: amount (conditional color)
│       ├── Badge "{transactionCount} transaksi"
│       ├── IncomeBreakdownSection
│       │   ├── h3 "Pemasukan per Kategori"
│       │   └── CategoryBreakdownItem (×N, sorted desc)
│       │       └── div
│       │           ├── Category name
│       │           ├── Progress (percentage of total income)
│       │           └── Amount
│       ├── ExpenseBreakdownSection
│       │   ├── h3 "Pengeluaran per Kategori"
│       │   └── CategoryBreakdownItem (×N, sorted desc)
│       │       └── div
│       │           ├── Category name
│       │           ├── Progress (percentage of total expense)
│       │           └── Amount
│       └── EmptyState (when no transactions — "Tidak ada transaksi di bulan ini")
```

---

## 5. Responsive Strategy

### Breakpoints

| Breakpoint | Viewport | Navigation | Layout |
|-----------|----------|-----------|--------|
| Mobile | < 768px (md) | BottomNav (fixed bottom, 5 tabs) | Single column, full-width cards |
| Tablet | 768px - 1024px (md - lg) | Sidebar collapsed (icon-only) | 2-column grid for wallet/list cards |
| Desktop | >= 1024px (lg) | Sidebar expanded (icon + label) | 3-column grid for wallets, full table for transactions |

### Navigation Components

- **BottomNav** (mobile, < 768px): Fixed to bottom. 5 nav items with icons. Active state highlight. Tooltip for labels. Hidden on desktop via `md:hidden`.
- **Sidebar** (desktop, >= 768px): Fixed left sidebar. Uses shadcn `Sidebar` with collapsible mode (icon-only when collapsed). Collapse toggle button in sidebar footer or Header. Hidden on mobile via `hidden md:block`.
- **Header**: Visible on all breakpoints. Contains app title "Pocket", optional back button, theme toggle. On mobile, can contain a hamburger menu to open sidebar as Sheet (shadcn `Sheet` trigger).

### Content Layouts

| Screen | Mobile | Desktop |
|--------|--------|---------|
| Dashboard | Stacked cards, single column | 3-column summary + 2-column recent list |
| WalletList | Single column cards | 2-3 column card grid |
| CreateWallet | Full width form | Centered form (max-w-md) |
| WalletDetail | Stacked layout | Side-by-side detail + transactions |
| CategoryList | Stacked tabs | Side-by-side income/expense panels (optional) |
| TransactionList | Card list (horizontal items) | Full Table with columns |
| CreateTransaction | Full width form | Centered form (max-w-2xl) |
| EditTransaction | Full width form | Centered form (max-w-2xl) |
| MonthlySummary | Stacked stat cards + lists | 3-column stat cards, 2-column breakdowns |

### Implementation Pattern

```tsx
// Responsive navigation switching
<>
  {/* Mobile: BottomNav */}
  <BottomNav className="fixed bottom-0 left-0 right-0 md:hidden" />
  
  {/* Desktop: Sidebar */}
  <Sidebar className="hidden md:flex" />
</>
```

```tsx
// Responsive grid for wallet list
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  {wallets.map(w => <WalletCard key={w.id} wallet={w} />)}
</div>
```

```tsx
// Responsive table → card list for transactions
<div className="hidden md:block">
  <Table>...</Table>  {/* Desktop: table */}
</div>
<div className="md:hidden space-y-2">
  {transactions.map(t => <TransactionRowCard key={t.id} />)}  {/* Mobile: card list */}
</div>
```

`ponytail: if mobile card list for transactions adds maintenance burden, use responsive Table variant with collapsed columns instead.`

---

## 6. File Structure (components directory)

```
src/
  components/
    ui/                              # shadcn/ui auto-generated primitives
      button.tsx
      card.tsx
      input.tsx
      select.tsx
      badge.tsx
      skeleton.tsx
      alert.tsx
      alert-dialog.tsx
      table.tsx
      tabs.tsx
      calendar.tsx
      popover.tsx
      separator.tsx
      switch.tsx
      textarea.tsx
      progress.tsx
      label.tsx
      sheet.tsx
      sidebar.tsx
      sonner.tsx

    shared/
      layout/
        app-shell.tsx                # Layout wrapper
        header.tsx                   # Top navigation bar
        sidebar-nav.tsx              # Desktop sidebar navigation
        bottom-nav.tsx               # Mobile bottom navigation
        page-header.tsx              # Page title + back + action

      wallet/
        wallet-card.tsx              # Reusable wallet display card

      transaction/
        transaction-row.tsx          # Reusable transaction list item
        transaction-form.tsx         # Shared form: create + edit

      category/
        category-card.tsx            # Reusable category display card

      summary/
        stat-card.tsx                # Reusable stat display card

      ui-parts/
        confirm-dialog.tsx           # Delete confirmation wrapper
        empty-state.tsx              # Empty state with CTA
        error-alert.tsx              # Error state with retry
        loading-skeleton.tsx         # Abstracted skeleton pattern
        filter-chip.tsx              # Active filter badge
        balance-summary-card.tsx     # Dashboard balance summary

    dashboard/
      recent-transactions-list.tsx
      quick-actions.tsx

    wallets/
      wallet-list-grid.tsx
      empty-wallet-state.tsx
      create-wallet-form.tsx
      wallet-detail-card.tsx
      wallet-recent-transactions.tsx

    categories/
      category-tabs.tsx
      category-grid.tsx
      create-category-form.tsx

    transactions/
      transaction-table.tsx
      transaction-form-create.tsx    # Wraps shared TransactionForm for create context
      transaction-form-edit.tsx      # Wraps shared TransactionForm for edit context
      filter-bar.tsx
      pagination-controls.tsx
      delete-action-button.tsx

    summary/
      summary-header.tsx
      month-year-picker.tsx
      income-breakdown-section.tsx
      expense-breakdown-section.tsx
      category-breakdown-item.tsx

  hooks/                             # From doc-05 React Query hooks
    use-wallets.ts
    use-wallet.ts
    use-categories.ts
    use-transactions.ts
    use-transaction.ts
    use-monthly-summary.ts
    use-create-wallet.ts
    use-create-category.ts
    use-create-transaction.ts
    use-update-transaction.ts
    use-delete-transaction.ts

  stores/
    ui-store.ts                      # Zustand UIStore (theme + sidebar)

  lib/
    utils.ts                         # cn() utility from shadcn
    currency.ts                      # formatIDR() — Intl.NumberFormat wrapper
    date.ts                          # date formatting helpers
```

---

## 7. Cross-Document References

| Reference | Target | Usage |
|-----------|--------|-------|
| doc-03: FR-001 | WalletCard, CreateWalletForm | WalletCard defined from FR-001 UI mapping |
| doc-03: FR-002 | CategoryCard, CategoryTabs, CreateCategoryForm | Category UI components from FR-002 |
| doc-03: FR-003 | TransactionForm (create mode) | Form structure from FR-003 UI components |
| doc-03: FR-004 | FilterBar, TransactionTable, FilterChip, PaginationControls | Filter and list UI from FR-004 |
| doc-03: FR-005 | TransactionForm (edit mode) | Edit form inherits from FR-003, adds delete |
| doc-03: FR-006 | DeleteActionButton, ConfirmDialog | Delete UI from FR-006 |
| doc-03: FR-007 | StatCard, SummaryHeader, MonthYearPicker, BreakdownSections | Summary UI from FR-007 |
| doc-03: section 4.3 | AppShell, LoadingSkeleton, ErrorAlert, EmptyState, ConfirmDialog | Shared components derived from cross-cutting concerns |
| doc-04: routes[] | All 9 component_tree entries | screen_name exact mapping for route-vs-screen validation |
| doc-04: section 3 | AppShell layout hierarchy | Layout structure definition |
| doc-04: Loading State Table | LoadingSkeleton variants | Per-route skeleton patterns |
| doc-04: Error State Table | ErrorAlert, not-found.tsx | Per-route error handling |
| doc-04: Navigation Flow | Header back behavior, redirects | Navigation patterns in page-level components |
| doc-05: query_hooks[] | Data sources per screen | 11 React Query hooks linked to page data needs |
| doc-05: stores[] | UIStore (Zustand) | Theme and sidebar state integration |

---

## 8. Assumptions

| ID | Statement | Impacts | Confidence | Source |
|----|-----------|---------|-----------|--------|
| ASM-601 | WalletDetail included despite 0.6 confidence. If dropped, remove route and component tree. | Route + page components + API endpoint | 0.6 | doc-04: routes[3] |
| ASM-602 | Create/edit use full page routes, not modals | TransactionForm is page-level, no Sheet/Drawer | 0.7 | doc-04: ASM-003, ASM-004 |
| ASM-603 | TransactionForm shared between create and edit | Props interface supports both modes | 1.0 | inference |
| ASM-604 | AppShell uses responsive nav: BottomNav mobile, Sidebar desktop | Two nav components, conditional rendering | 0.9 | doc-04: section 3 |
| ASM-605 | Only one Zustand store (UIStore) — no additional client stores | Theme + sidebar only | 1.0 | doc-05: stores[] |
| ASM-606 | FilterBar is page-specific to TransactionList | Not promoted to shared/ unless reused | 0.9 | doc-03: FR-004 |
| ASM-607 | Amount is integer (IDR smallest unit), no decimals | Input step=1, no currency selector | 1.0 | doc-03: ASM-004 |
| ASM-608 | Default categories seeded — no empty state for CategoryList | No EmptyState needed on /categories | 1.0 | doc-03: ASM-009 |
| ASM-609 | Delete uses AlertDialog, no optimistic UI | Row stays until API success | 0.8 | doc-03: FR-006 |
| ASM-610 | Loading states use shadcn Skeleton in loading.tsx | Skeleton patterns per route | 1.0 | doc-04: Loading Table |
| ASM-611 | Error states use shadcn Alert with retry, not toast | Page errors in Alert, mutation feedback in Toast | 1.0 | doc-04: Error Table |

---

## 9. DoD Checklist

- [x] Component tree for each screen defined (9 pages in component_tree YAML + visual trees in section 4)
- [x] Shared components identified (14 components in shared_components YAML + full documentation in section 1)
- [x] Page-specific components identified (organisms per page in component_tree + components/ directory per page)
- [x] shadcn/ui component selections with rationale per component (20 components in section 3 table)
- [x] Props interface sketches for key components (TransactionForm, WalletCard, TransactionRow, StatCard, ConfirmDialog, FilterBar, EmptyState, ErrorAlert, LoadingSkeleton, PageHeader, BalanceSummaryCard, FilterChip in section 1)
- [x] References doc-03 (FR-001 through FR-007 UI mappings) and doc-04 (all 9 routes, layout structure, loading/error states)
- [x] Screen names exact match with doc-04 (Dashboard, WalletList, CreateWallet, WalletDetail, CategoryList, TransactionList, CreateTransaction, EditTransaction, MonthlySummary)
- [x] Frontmatter YAML valid and complete (prd_source_hash, agent: 6, schema_version: 1, status: complete, summary, component_tree, shared_components, assumptions)
- [x] No placeholder, TODO, or "TBD" — all ponytail markers labeled per convention
- [x] All entity/type/schema names PascalCase exact (WalletCard, CategoryCard, TransactionForm, StatCard, ConfirmDialog, EmptyState, ErrorAlert, etc.)
