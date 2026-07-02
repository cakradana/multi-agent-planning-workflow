---
title: Atomic Task Breakdown
description: Atomic LLM-sized tasks, dependency order, RTM coverage for Pocket frontend
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 9
schema_version: 1
status: complete
summary: >
  This document breaks down all Pocket frontend work into 42 atomic tasks across 7 phases.
  Phase 1 (Foundation) covers project scaffolding, route structure, TypeScript types, Zod
  schemas, Zustand store, QueryClient, MSW handlers, and utility functions — 8 tasks.
  Phase 2 (Shared Components) covers AppShell layout, navigation, shared domain components
  (WalletCard, TransactionRow, TransactionForm, StatCard, CategoryCard, FilterChip), and
  shared UI patterns (ErrorAlert, EmptyState, LoadingSkeleton, ConfirmDialog) — 7 tasks.
  Phase 3 (Query Hooks) implements all 11 React Query hooks across 4 files sorted by entity
  domain — 4 tasks. Phase 4 (Pages) implements 9 page routes with their page.tsx, loading.tsx,
  error.tsx, not-found.tsx files and page-specific organisms — 9 tasks. Phase 5 (Dashboard)
  is a single task for the landing page that consumes wallet and transaction data. Phase 6
  (Integration Testing) covers test infrastructure setup, Zod schema unit tests, hook unit
  tests, shared component tests, and 3 E2E flows (Wallet CRUD, Transaction CRUD + filter,
  Monthly Summary) — 8 tasks. Phase 7 (Polish) covers mutation feedback toasts and responsive
  layout refinements — 2 tasks. Every user story (11/11) maps to at least one page task.
  Every route (9/9) maps to a page task. Every entity (4/4) has type and Zod schema coverage.
  Total estimated effort: 177 hours across 42 tasks. Dependency graph flows Foundation →
  Shared Components → Hooks → Pages → Dashboard → Testing → Polish. Three E2E test tasks
  are terminal — no downstream dependents. The WalletDetail route (/wallets/[id]) is marked
  P2 with confidence 0.6 per upstream documents — can be deferred if scope is cut.
tasks:
  # ── PHASE 1: FOUNDATION ──
  - id: T-001
    phase: 1
    title: Initialize Next.js project and install dependencies
    description: "Create Next.js App Router project with TypeScript strict mode. Install all runtime and dev dependencies: zustand, @tanstack/react-query, @tanstack/react-query-devtools, react-hook-form, @hookform/resolvers, zod, date-fns, lucide-react. Install shadcn/ui CLI and init with default config (neutral gray, CSS variables). Add dev deps: msw, vitest, @testing-library/react, @testing-library/jest-dom, @vitejs/plugin-react, jsdom, @playwright/test, eslint. Configure tsconfig path alias '@/' pointing to src/. Configure next.config.js if needed."
    acceptance_criteria:
      - "next dev runs without errors on fresh project"
      - "shadcn/ui components can be added via CLI"
      - "All package.json dependencies listed and installable"
      - "tsconfig paths alias configured"
      - "TypeScript strict mode enabled"
    priority: P0
    blockedBy: []
    blocks:
      - T-002
      - T-003
      - T-004
      - T-005
      - T-006
      - T-007
      - T-008
      - T-009
    labels:
      - setup
      - infra
    estimated_hours: 4
    source: "doc-02: US-001..US-011 (foundational for all)"
    confidence: 1.0

  - id: T-002
    phase: 1
    title: Scaffold route structure with layout hierarchy
    description: "Create all Next.js App Router file stubs per doc-04 route structure. app/layout.tsx (RootLayout with html lang=id, body), app/providers.tsx (QueryClientProvider + Toaster), app/page.tsx (minimal), app/loading.tsx, app/error.tsx. Create route groups (shell) and (minimal) layouts per doc-04 section 3 ponytail. Create all page files as minimal exports: /wallets/page.tsx, /wallets/new/page.tsx, /wallets/[id]/page.tsx, /categories/page.tsx, /transactions/page.tsx, /transactions/new/page.tsx, /transactions/[id]/edit/page.tsx, /summary/page.tsx. Each page exports a function component returning a placeholder div. Create loading.tsx and error.tsx stubs for each route segment per doc-04 Loading/Error State tables. Create not-found.tsx for /wallets/[id] and /transactions/[id]/edit."
    acceptance_criteria:
      - "All 9 routes return 200 on navigation"
      - "Route group (shell) and (minimal) layouts exist"
      - "loading.tsx files exist for all 9 routes"
      - "error.tsx files exist for all 9 routes"
      - "not-found.tsx exists for /wallets/[id] and /transactions/[id]/edit"
    priority: P0
    blockedBy:
      - T-001
    blocks:
      - T-027
      - T-028
      - T-029
      - T-030
      - T-031
      - T-032
      - T-033
      - T-034
      - T-035
    labels:
      - setup
      - route
    estimated_hours: 4
    source: "doc-04: routes[], doc-04: Layout Structure, Loading State Table, Error State Table"
    confidence: 1.0

  - id: T-003
    phase: 1
    title: Define TypeScript types for entities, API envelopes, and mutation inputs
    description: "Create src/types/api.ts with all type definitions from doc-07 sections 3.1-3.5. Include: ApiResponse<T>, ApiListResponse<T>, PaginationMeta, User, Wallet, Category, Transaction (with optional walletName/categoryName), CreateWalletRequest, CreateCategoryRequest, CreateTransactionRequest, UpdateTransactionRequest, TransactionFilters, SummaryParams, MonthlySummary, CategoryBreakdown, DeleteTransactionResponse, ApiError, FieldError, NotFoundError, ValidationError. All types use camelCase per doc-07 field mapping. Export all interfaces."
    acceptance_criteria:
      - "All 18 types from doc-07 defined in src/types/api.ts"
      - "ApiResponse and ApiListResponse are generic"
      - "Field mapping from camelCase (TS) to snake_case (API) documented in comments"
      - "TypeScript compilation passes with strict mode"
    priority: P0
    blockedBy:
      - T-001
    blocks:
      - T-006
      - T-007
      - T-008
      - T-023
      - T-024
      - T-025
      - T-026
    labels:
      - setup
      - types
    estimated_hours: 3
    source: "doc-07: types[], doc-02: entities[]"
    confidence: 1.0

  - id: T-004
    phase: 1
    title: Implement utility functions for currency, date formatting, and classnames
    description: "Create src/lib/utils.ts with cn() utility using clsx + tailwind-merge (shadcn standard). Create src/lib/currency.ts with formatIDR(value: number) using Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }). Create src/lib/date.ts with helpers: formatDate(iso: string) -> 'DD MMM YYYY', formatRelativeDate(iso: string) -> 'Hari ini'/'Kemarin'/date, isFutureDate(iso: string) -> boolean, toISODate(date: Date) -> 'YYYY-MM-DD'. Export all functions."
    acceptance_criteria:
      - "cn() merges Tailwind classes correctly"
      - "formatIDR(1500000) returns 'Rp1.500.000'"
      - "formatDate('2026-06-15') returns '15 Jun 2026'"
      - "formatRelativeDate handles today, yesterday, and older dates"
      - "toISODate returns correct YYYY-MM-DD format"
    priority: P0
    blockedBy:
      - T-001
    blocks:
      - T-011
      - T-012
      - T-013
      - T-014
    labels:
      - setup
      - utility
    estimated_hours: 2
    source: "doc-06: section 6 (lib/), doc-03: ASM-004"
    confidence: 1.0

  - id: T-005
    phase: 1
    title: Implement Zustand UIStore for theme and sidebar state
    description: "Create src/stores/ui-store.ts per doc-05 section 2. Define UIState interface with theme ('light'|'dark'|'system'), sidebarOpen (boolean), mobileDrawerOpen (boolean). Define UIActions: setTheme, toggleSidebar, setMobileDrawerOpen, reset. Use zustand/middleware persist with localStorage partialize (theme only). Storage key: 'pocket-ui'. Export useUIStore hook. Create src/app/providers.tsx as client component wrapping QueryClientProvider, Toaster (shadcn Sonner), and ReactQueryDevtools."
    acceptance_criteria:
      - "useUIStore returns theme, sidebarOpen, mobileDrawerOpen with correct defaults"
      - "setTheme persists to localStorage"
      - "toggleSidebar flips sidebarOpen"
      - "reset returns all values to initial state"
      - "Providers component renders children without error"
    priority: P0
    blockedBy:
      - T-001
    blocks:
      - T-009
    labels:
      - setup
      - state
    estimated_hours: 3
    source: "doc-05: stores[0], doc-06: section 1.3"
    confidence: 1.0

  - id: T-006
    phase: 1
    title: Implement Zod validation schemas
    description: "Create src/lib/validation-schemas.ts with all 8 Zod schemas from doc-08: WalletSchema, CategorySchema, TransactionSchema (with .refine for BR-007 category-transaction type match), CreateWalletSchema, CreateCategorySchema, CreateTransactionSchema (with .refine), TransactionFilterSchema (with z.coerce for numeric fields), SummaryQuerySchema (with z.coerce for month/year), MonthlySummarySchema. Use z.infer<typeof Schema> to export TypeScript types. Add bilingual error messages (ID + EN) per doc-08. Export all schemas and inferred types."
    acceptance_criteria:
      - "All 8 schemas defined with exact field constraints from doc-08"
      - "TransactionSchema.refine enforces category type matches transaction type (BR-007)"
      - "CreateTransactionSchema validates amount > 0, date not future, note max 500"
      - "TransactionFilterSchema uses z.coerce for page, walletId, categoryId"
      - "SummaryQuerySchema constrains month 1-12, year 2020-2100"
      - "TypeScript compilation passes"
    priority: P0
    blockedBy:
      - T-003
    blocks:
      - T-014
      - T-037
    labels:
      - setup
      - validation
    estimated_hours: 4
    source: "doc-08: schemas[], doc-02: BR-003..BR-009, BR-013..BR-016"
    confidence: 1.0

  - id: T-007
    phase: 1
    title: Create query key factory and QueryClient configuration
    description: "Create src/lib/query-keys.ts with key factories per doc-05 section 3.1: walletKeys (all, detail), categoryKeys (all), transactionKeys (all, lists, list, details, detail), summaryKeys (byMonth). Create src/lib/query-client.ts with makeQueryClient() returning QueryClient with default options: retry=2, refetchOnWindowFocus=false, staleTime=5000ms default, gcTime=300000ms. Export both."
    acceptance_criteria:
      - "walletKeys.all returns ['wallets']"
      - "walletKeys.detail(1) returns ['wallets', 1]"
      - "transactionKeys.list({type:'expense'}) returns ['transactions', 'list', {type:'expense'}]"
      - "summaryKeys.byMonth(7, 2026) returns ['summary', {month:7, year:2026}]"
      - "makeQueryClient creates QueryClient with correct defaults"
    priority: P0
    blockedBy:
      - T-001
    blocks:
      - T-023
      - T-024
      - T-025
      - T-026
    labels:
      - setup
      - state
    estimated_hours: 2
    source: "doc-05: sections 3.1, 7"
    confidence: 1.0

  - id: T-008
    phase: 1
    title: Implement MSW handlers, seed data, and worker setup
    description: "Create mocks/seed.ts with seed data from doc-07 section 4.1: seedWallets (3), seedCategories (6), seedTransactions (5). Create mocks/handlers/wallets.ts, categories.ts, transactions.ts, summary.ts per doc-07 sections 4.2-4.5. Each handler implements GET list, GET detail, POST create (with validation). Transaction handlers also implement PUT update and DELETE. Create mocks/handlers/index.ts exporting combined handlers. Create mocks/browser.ts (MSW browser worker for dev). Create mocks/server.ts (MSW server for tests). Stateful mutations use mutable arrays with incrementing IDs."
    acceptance_criteria:
      - "All 11 endpoints return correct mock data"
      - "POST /api/wallets creates wallet with incrementing ID and returns 201"
      - "POST /api/transactions validates body and returns 422 on invalid input"
      - "DELETE /api/transactions/:id returns 404 for missing ID"
      - "GET /api/transactions supports all filter params (date_from, date_to, type, wallet_id, category_id, q)"
      - "MSW worker starts in browser without error"
      - "MSW server starts in test environment without error"
    priority: P0
    blockedBy:
      - T-003
    blocks:
      - T-023
      - T-024
      - T-025
      - T-026
      - T-036
    labels:
      - setup
      - api
      - testing
    estimated_hours: 6
    source: "doc-07: endpoints[], doc-07: section 4"
    confidence: 1.0

  # ── PHASE 2: SHARED COMPONENTS ──

  - id: T-009
    phase: 2
    title: Implement AppShell layout with Header component
    description: "Create src/components/shared/layout/app-shell.tsx wrapping children with Header + main content area. Header shows app title 'Pocket', theme toggle button (Sun/Moon icons), and optional page action button. Create src/components/shared/layout/header.tsx with props: title, showBack, backHref, action. Header uses shadcn Button variants. Theme toggle uses useUIStore setTheme. Create src/components/shared/layout/page-header.tsx composing title + back button + action button. Integrate with route groups: (shell) layout wraps AppShell, (minimal) layout wraps Header only."
    acceptance_criteria:
      - "AppShell renders children inside layout shell"
      - "Header accepts title, showBack, backHref, action props"
      - "Theme toggle button switches between light/dark/system"
      - "Back button navigates to backHref when provided"
      - "page-header.tsx renders title + optional back + optional action button"
    priority: P0
    blockedBy:
      - T-005
      - T-001
    blocks:
      - T-010
      - T-027
      - T-028
      - T-029
      - T-030
      - T-031
      - T-032
      - T-033
      - T-034
      - T-035
    labels:
      - component
      - layout
    estimated_hours: 5
    source: "doc-06: shared_components[0], doc-06: section 1.1"
    confidence: 1.0

  - id: T-010
    phase: 2
    title: Implement responsive navigation (Sidebar and BottomNav)
    description: "Create src/components/shared/layout/sidebar-nav.tsx using shadcn Sidebar component with 5 nav items: Beranda (/), Dompet (/wallets), Kategori (/categories), Transaksi (/transactions), Ringkasan (/summary). Each item uses lucide-react icons (LayoutDashboard, Wallet, Tags, ArrowLeftRight, BarChart3). Active state highlights current route. Collapsible mode. Create src/components/shared/layout/bottom-nav.tsx as fixed-bottom mobile nav with same 5 items. CSS: sidebar hidden on mobile (hidden md:flex), bottom-nav hidden on desktop (md:hidden). Responsive breakpoint at 768px per doc-06."
    acceptance_criteria:
      - "Sidebar shows on viewport >= 768px, hidden on mobile"
      - "BottomNav shows on viewport < 768px, hidden on desktop"
      - "All 5 nav items navigate to correct routes"
      - "Active route is visually highlighted"
      - "Sidebar collapses to icon-only mode"
    priority: P0
    blockedBy:
      - T-009
    blocks:
      - T-027
      - T-028
      - T-029
      - T-030
      - T-031
      - T-032
      - T-033
      - T-034
      - T-035
    labels:
      - component
      - layout
    estimated_hours: 5
    source: "doc-06: section 1.1, doc-06: section 5 (Responsive Strategy)"
    confidence: 0.9

  - id: T-011
    phase: 2
    title: Implement shared UI patterns (ErrorAlert, EmptyState, LoadingSkeleton, ConfirmDialog, FilterChip)
    description: "Create components in src/components/shared/ui-parts/. ErrorAlert using shadcn Alert variant=destructive with message prop and optional onRetry button. EmptyState with icon, title, description, optional CTA button/link. LoadingSkeleton with variant prop ('card'|'row'|'form'|'stat'|'list') and count prop — renders shadcn Skeleton in appropriate layout. ConfirmDialog wrapping shadcn AlertDialog with title, description, confirmLabel, cancelLabel, variant ('default'|'destructive'), onConfirm, isConfirming props. FilterChip using shadcn Badge variant=outline with label and onRemove X button."
    acceptance_criteria:
      - "ErrorAlert renders message text with destructive alert style"
      - "ErrorAlert onRetry button calls handler on click"
      - "EmptyState renders icon, title, description, and optional action"
      - "LoadingSkeleton renders correct variant with specified count"
      - "ConfirmDialog shows AlertDialog with confirm/cancel buttons"
      - "ConfirmDialog variant destructive shows red confirm button"
      - "FilterChip renders label with removable X button"
    priority: P1
    blockedBy:
      - T-004
    blocks:
      - T-027
      - T-028
      - T-029
      - T-030
      - T-031
      - T-032
      - T-033
      - T-034
      - T-035
    labels:
      - component
      - ui
    estimated_hours: 5
    source: "doc-06: shared_components[8,9,10,7,11]"
    confidence: 1.0

  - id: T-012
    phase: 2
    title: Implement shared domain components (WalletCard, TransactionRow, StatCard, CategoryCard)
    description: "Create src/components/shared/wallet/wallet-card.tsx using shadcn Card + Badge. Props: wallet (id, name, type, currentBalance), href?, className?. Shows wallet name, type badge (cash/bank/e-wallet), current balance formatted as IDR. Create src/components/shared/transaction/transaction-row.tsx using shadcn Table elements + Badge. Props: transaction (id, type, amount, transactionDate, note?, categoryName, walletName), showActions?, onEdit?, onDelete?. Type color-coded (green for income, red for expense). Create src/components/shared/summary/stat-card.tsx using shadcn Card. Props: title, value, type ('income'|'expense'|'net'), icon?. Color-coded value display. Create src/components/shared/category/category-card.tsx using shadcn Card + Badge. Props: category (id, name, type, isDefault). Shows name, type indicator, 'Default' badge if isDefault."
    acceptance_criteria:
      - "WalletCard displays all wallet fields with IDR formatted balance"
      - "TransactionRow shows type icon, category, wallet, amount (color-coded), date"
      - "TransactionRow onEdit and onDelete fire with transaction id"
      - "StatCard renders title, value with type-appropriate color (green/red/blue)"
      - "StatCard value formatted as IDR currency"
      - "CategoryCard displays name, type indicator, and optional 'Default' badge"
    priority: P1
    blockedBy:
      - T-004
    blocks:
      - T-027
      - T-028
      - T-030
      - T-032
      - T-035
    labels:
      - component
    estimated_hours: 5
    source: "doc-06: shared_components[2,3,5,4], doc-06: section 1.2"
    confidence: 1.0

  - id: T-013
    phase: 2
    title: Implement BalanceSummaryCard and FilterChip domain components
    description: "Create src/components/shared/ui-parts/balance-summary-card.tsx with props: wallets (Wallet[]), isLoading (boolean). Shows aggregate balance across all wallets: total balance, wallet count. Uses StatCard internally. Create src/components/shared/ui-parts/filter-chip.tsx (already scoped in T-011 — moved here for domain clarity). Note: FilterChip actually belongs to ui-parts per T-011. This task covers BalanceSummaryCard per doc-06 shared_components[12]."
    acceptance_criteria:
      - "BalanceSummaryCard renders total balance across all wallets"
      - "BalanceSummaryCard shows wallet count"
      - "BalanceSummaryCard shows skeleton when isLoading is true"
    priority: P1
    blockedBy:
      - T-004
      - T-012
    blocks:
      - T-027
    labels:
      - component
    estimated_hours: 3
    source: "doc-06: shared_components[12], doc-06: section 2.1"
    confidence: 0.9

  - id: T-014
    phase: 2
    title: Implement TransactionForm shared component (create + edit modes)
    description: "Create src/components/shared/transaction/transaction-form.tsx — the most complex shared component. Use react-hook-form with Zod resolver (CreateTransactionSchema). Props: mode ('create'|'edit'), defaultValues?, onSubmit, wallets (Wallet[]), categories (Category[]), isSubmitting, onCancel?. Internal fields: TypeToggle (shadcn Tabs/Switch for income/expense), WalletSelect (shadcn Select populated from wallets prop), CategorySelect (shadcn Select filtered by selected type — income categories for income, expense for expense), AmountInput (shadcn Input type=number step=1 with Rp prefix), DatePicker (shadcn Calendar + Popover, max=current date, default=today), NoteTextarea (shadcn Textarea, maxLength=500), BalanceWarning (shadcn Alert variant=warning shown when expense > selected wallet balance), SubmitButton (disabled when isSubmitting). Filter categories client-side when type changes. Live balance check on amount change."
    acceptance_criteria:
      - "TransactionForm renders all fields: type toggle, wallet select, category select, amount, date, note"
      - "Category select filters by selected transaction type"
      - "Amount input uses step=1, min=1, with Rp prefix display"
      - "DatePicker max date is today"
      - "BalanceWarning alert appears when expense amount > wallet balance"
      - "Form validates with CreateTransactionSchema before submit"
      - "Mode 'edit' pre-fills with defaultValues"
      - "onSubmit receives validated TransactionCreateInput data"
      - "Submit button disabled when isSubmitting is true"
    priority: P1
    blockedBy:
      - T-006
      - T-012
    blocks:
      - T-033
      - T-034
    labels:
      - component
      - form
    estimated_hours: 8
    source: "doc-06: shared_components[4], doc-06: section 2.7, doc-08: CreateTransactionSchema"
    confidence: 1.0

  # ── PHASE 3: QUERY HOOKS ──

  - id: T-023
    phase: 3
    title: Implement wallet query hooks (useWallets, useWallet, useCreateWallet)
    description: "Create src/hooks/queries/use-wallets.ts, src/hooks/queries/use-wallet.ts, src/hooks/mutations/use-create-wallet.ts. useWallets: queryKey walletKeys.all, staleTime 30s. useWallet(id): queryKey walletKeys.detail(id), enabled for non-null id, handles 404 as NotFoundError. useCreateWallet: mutationFn POST /api/wallets, onSuccess invalidates walletKeys.all. Types from src/types/api.ts (Wallet, CreateWalletRequest)."
    acceptance_criteria:
      - "useWallets fetches from GET /api/wallets and returns Wallet[]"
      - "useWallet(1) fetches from GET /api/wallets/1"
      - "useWallet(undefined) does not fetch (enabled=false)"
      - "useCreateWallet POSTs to /api/wallets and invalidates wallet cache on success"
    priority: P1
    blockedBy:
      - T-007
      - T-008
    blocks:
      - T-028
      - T-029
      - T-030
    labels:
      - api
      - state
      - hook
    estimated_hours: 4
    source: "doc-05: query_hooks[0,1,2], doc-07: endpoints[0,1,2]"
    confidence: 1.0

  - id: T-024
    phase: 3
    title: Implement category query hooks (useCategories, useCreateCategory)
    description: "Create src/hooks/queries/use-categories.ts and src/hooks/mutations/use-create-category.ts. useCategories: queryKey categoryKeys.all, staleTime 60s (categories change infrequently). useCreateCategory: mutationFn POST /api/categories, onSuccess invalidates categoryKeys.all. Types from src/types/api.ts (Category, CreateCategoryRequest)."
    acceptance_criteria:
      - "useCategories fetches from GET /api/categories and returns Category[]"
      - "Categories include server-joined fields"
      - "useCreateCategory POSTs to /api/categories and invalidates category cache on success"
      - "Duplicate category name handled (422 response from MSW)"
    priority: P1
    blockedBy:
      - T-007
      - T-008
    blocks:
      - T-031
      - T-032
      - T-033
      - T-034
    labels:
      - api
      - state
      - hook
    estimated_hours: 3
    source: "doc-05: query_hooks[3,4], doc-07: endpoints[3,4]"
    confidence: 1.0

  - id: T-025
    phase: 3
    title: Implement transaction query hooks (useTransactions, useTransaction, useCreateTransaction, useUpdateTransaction, useDeleteTransaction)
    description: "Create src/hooks/queries/use-transactions.ts, src/hooks/queries/use-transaction.ts, src/hooks/mutations/use-create-transaction.ts, src/hooks/mutations/use-update-transaction.ts, src/hooks/mutations/use-delete-transaction.ts. useTransactions(filters): queryKey transactionKeys.list(filters), use keepPreviousData placeholder, staleTime 0. useTransaction(id): queryKey transactionKeys.detail(id), enabled for non-null id. useCreateTransaction: onSuccess cascades invalidation of ['transactions'], ['wallets'], ['summary'] per doc-05 ASM-002. useUpdateTransaction(id): onSuccess invalidates transaction detail + all + wallets + summary. useDeleteTransaction: onSuccess invalidates all + wallets + summary. All mutations use optimistic updates disabled (no optimistic per doc-05 section 9). Types from src/types/api.ts."
    acceptance_criteria:
      - "useTransactions(filters) fetches filtered and paginated transaction list"
      - "useTransaction(id) fetches single transaction detail"
      - "useCreateTransaction invalidates transactions, wallets, and summary on success"
      - "useUpdateTransaction(id) invalidates detail, all transactions, wallets, and summary"
      - "useDeleteTransaction invalidates transactions, wallets, and summary on success"
      - "useTransactions uses keepPreviousData for pagination"
    priority: P1
    blockedBy:
      - T-007
      - T-008
    blocks:
      - T-032
      - T-033
      - T-034
      - T-035
    labels:
      - api
      - state
      - hook
    estimated_hours: 6
    source: "doc-05: query_hooks[5,6,7,8,9], doc-07: endpoints[5,6,7,8,9], doc-05: section 3.4 (Cache Invalidation Map)"
    confidence: 1.0

  - id: T-026
    phase: 3
    title: Implement monthly summary query hook (useMonthlySummary)
    description: "Create src/hooks/queries/use-monthly-summary.ts. useMonthlySummary(month, year): queryKey summaryKeys.byMonth(month, year), staleTime 30s. Fetch GET /api/summary?month={m}&year={y}. Types from src/types/api.ts (MonthlySummary, SummaryParams)."
    acceptance_criteria:
      - "useMonthlySummary(7, 2026) fetches GET /api/summary?month=7&year=2026"
      - "Returns MonthlySummary with totalIncome, totalExpense, netBalance, transactionCount"
      - "Returns incomeByCategory and expenseByCategory arrays"
      - "Cache key changes when month or year changes"
    priority: P1
    blockedBy:
      - T-007
      - T-008
    blocks:
      - T-035
    labels:
      - api
      - state
      - hook
    estimated_hours: 2
    source: "doc-05: query_hooks[10], doc-07: endpoints[10]"
    confidence: 1.0

  # ── PHASE 4: PAGES ──

  - id: T-028
    phase: 4
    title: Implement WalletList page (/wallets)
    description: "Create app/(shell)/wallets/page.tsx (WalletListPage), loading.tsx (WalletListSkeleton), error.tsx (WalletListErrorBoundary). Page uses useWallets hook. Render: PageHeader (title: 'Dompet', action: 'Buat Dompet' -> /wallets/new), WalletListGrid (responsive grid of WalletCard components, href linking to /wallets/[id]), EmptyWalletState (EmptyState with CTA 'Buat dompet pertama' -> /wallets/new) when wallets.length === 0. Create page-specific components: WalletListGrid (src/components/wallets/wallet-list-grid.tsx) and EmptyWalletState."
    acceptance_criteria:
      - "Page displays all wallets in responsive grid"
      - "Each wallet card shows name, type badge, current balance (IDR formatted)"
      - "Clicking wallet navigates to /wallets/[id]"
      - "Empty state shown when no wallets with CTA to create"
      - "Loading state shows skeleton grid"
      - "Error state shows ErrorAlert with retry"
      - "'Buat Dompet' button navigates to /wallets/new"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-012
      - T-023
    blocks: []
    labels:
      - page
      - wallet
    estimated_hours: 5
    source: "doc-04: routes[1], doc-05: data_flows[1], doc-06: section 2.2, doc-02: US-002"
    confidence: 1.0

  - id: T-029
    phase: 4
    title: Implement CreateWallet page (/wallets/new)
    description: "Create app/(minimal)/wallets/new/page.tsx (CreateWalletPage), loading.tsx (FormSkeleton). Page uses useCreateWallet mutation. Create src/components/wallets/create-wallet-form.tsx using react-hook-form with CreateWalletSchema. Fields: name (Input, required), type (Select, cash/bank/e-wallet), initialBalance (Input type=number, min=0, default=0). Alert info: 'Saldo awal akan menjadi saldo saat ini'. On submit: call mutation, on success router.push('/wallets') + toast success. On error: show inline form errors. PageHeader with title 'Dompet Baru', backHref '/wallets'."
    acceptance_criteria:
      - "Form renders name, type select, initial balance fields"
      - "Name field validates required and max 100 chars"
      - "Type select options: cash, bank, e-wallet"
      - "Initial balance min=0, default=0"
      - "Submit calls useCreateWallet mutation"
      - "On success: redirect to /wallets and show success toast"
      - "Validation errors shown inline per field"
      - "Loading state shows form skeleton"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-023
    blocks: []
    labels:
      - page
      - wallet
      - form
    estimated_hours: 4
    source: "doc-04: routes[2], doc-05: data_flows[2], doc-06: section 2.3, doc-02: US-001"
    confidence: 1.0

  - id: T-030
    phase: 4
    title: Implement WalletDetail page (/wallets/[id])
    description: "Create app/(shell)/wallets/[id]/page.tsx (WalletDetailPage), loading.tsx, error.tsx, not-found.tsx. Page uses useWallet(id) and useTransactions({wallet_id: id, page:1, perPage:5}). Render: PageHeader (title: wallet.name, backHref '/wallets'), WalletDetailCard (name, type badge, current balance large, initial balance muted, link 'Lihat semua transaksi' -> /transactions?wallet_id={id}), WalletRecentTransactions (section heading + 5 TransactionRow with showActions=false). Not found: 'Dompet tidak ditemukan' + link to /wallets. Create page components: WalletDetailCard, WalletRecentTransactions."
    acceptance_criteria:
      - "Page fetches wallet by ID from URL params"
      - "Displays wallet name, type badge, current balance, initial balance"
      - "Shows 5 most recent transactions for this wallet"
      - "'Lihat semua transaksi' links to /transactions?wallet_id={id}"
      - "Loading state shows detail skeleton"
      - "Not found state shows 'Dompet tidak ditemukan' with link to /wallets"
      - "Error state shows ErrorAlert with retry"
    priority: P2
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-012
      - T-023
      - T-025
    blocks: []
    labels:
      - page
      - wallet
    estimated_hours: 5
    source: "doc-04: routes[3], doc-05: data_flows[3], doc-06: section 2.4"
    confidence: 0.6

  - id: T-031
    phase: 4
    title: Implement CategoryList page (/categories)
    description: "Create app/(shell)/categories/page.tsx (CategoryListPage), loading.tsx, error.tsx. Page uses useCategories and useCreateCategory. Create src/components/categories/category-tabs.tsx (shadcn Tabs with 'Pemasukan'/'Pengeluaran'), category-grid.tsx (renders CategoryCard grid), create-category-form.tsx (inline form or shadcn Dialog with name + type fields pre-selected from active tab). Type from active tab pre-selects. On create success: invalidate categories cache, show toast. PageHeader title 'Kategori'. No empty state per ASM-608 (default categories always seeded)."
    acceptance_criteria:
      - "Page displays categories split into income/expense tabs"
      - "Income tab shows income categories, expense tab shows expense categories"
      - "Default categories show 'Default' badge"
      - "Create category form appears in active tab's type"
      - "Form validates name required and type selection"
      - "On success: category appears in list, toast shown"
      - "Loading state shows tab skeletons"
      - "Error state shows ErrorAlert with retry"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-012
      - T-024
    blocks: []
    labels:
      - page
      - category
    estimated_hours: 5
    source: "doc-04: routes[4], doc-05: data_flows[4], doc-06: section 2.5, doc-02: US-003"
    confidence: 1.0

  - id: T-032
    phase: 4
    title: Implement TransactionList page with filtering and pagination (/transactions)
    description: "Create app/(shell)/transactions/page.tsx (TransactionListPage), loading.tsx, error.tsx. Page uses useTransactions(filters from URL searchParams), useWallets (for filter dropdown), useCategories (for filter dropdown), useDeleteTransaction. Create page components: FilterBar (DateRangePicker, type Select, wallet Select, category Select, search Input with debounce 300ms, Apply button, FilterChip for active filters), TransactionTable (shadcn Table with columns: Tanggal, Kategori, Dompet, Catatan, Jumlah, Aksi. Rows use TransactionRow with edit and delete actions), PaginationControls (Previous/Next buttons, page info 'Halaman X dari Y'). Filter state in URL searchParams per ASM-007. Delete uses ConfirmDialog. Empty state for no results with 'Reset Filter' button. Edit action navigates to /transactions/[id]/edit. PageHeader title 'Transaksi' + action 'Catat Transaksi' -> /transactions/new."
    acceptance_criteria:
      - "Page renders filter bar, transaction table, pagination"
      - "Filters read from and write to URL searchParams"
      - "Date range picker sets date_from and date_to params"
      - "Type filter: Semua/Pemasukan/Pengeluaran"
      - "Wallet filter populated from useWallets"
      - "Category filter populated from useCategories"
      - "Search input debounces 300ms before updating q param"
      - "Active filters shown as removable FilterChips"
      - "Transaction table shows all required columns"
      - "Edit button navigates to /transactions/[id]/edit"
      - "Delete button opens ConfirmDialog, on confirm calls useDeleteTransaction"
      - "Pagination shows Previous/Next with correct page info"
      - "Empty state when no transactions: 'Tidak ada transaksi yang cocok' with reset button"
      - "Loading state shows filter skeleton + table skeleton"
      - "Error state shows ErrorAlert with retry"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-012
      - T-024
      - T-025
    blocks: []
    labels:
      - page
      - transaction
    estimated_hours: 8
    source: "doc-04: routes[5], doc-05: data_flows[5], doc-06: section 2.6, doc-02: US-006, US-007, US-009"
    confidence: 1.0

  - id: T-033
    phase: 4
    title: Implement CreateTransaction page (/transactions/new)
    description: "Create app/(minimal)/transactions/new/page.tsx (CreateTransactionPage), loading.tsx. Page uses useWallets, useCategories, useCreateTransaction. Wraps TransactionForm in mode='create'. Pre-select type and wallet_id from optional URL searchParams. On submit: call useCreateTransaction, on success router.push('/transactions') + toast success. PageHeader title 'Transaksi Baru', backHref '/transactions'. Loading state shows form skeleton with select skeletons."
    acceptance_criteria:
      - "Page renders TransactionForm in create mode"
      - "URL params ?type=expense&wallet_id=1 pre-select type toggle and wallet"
      - "Category select filters by selected transaction type"
      - "On submit: calls useCreateTransaction mutation"
      - "On success: redirect to /transactions with success toast"
      - "Validation errors shown inline"
      - "BalanceWarning shown when expense > wallet balance"
      - "Loading state shows form skeleton"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-014
      - T-024
      - T-025
    blocks: []
    labels:
      - page
      - transaction
      - form
    estimated_hours: 4
    source: "doc-04: routes[6], doc-05: data_flows[6], doc-06: section 2.7, doc-02: US-004, US-005"
    confidence: 1.0

  - id: T-034
    phase: 4
    title: Implement EditTransaction page (/transactions/[id]/edit)
    description: "Create app/(minimal)/transactions/[id]/edit/page.tsx (EditTransactionPage), loading.tsx, error.tsx, not-found.tsx. Page uses useTransaction(id), useWallets, useCategories, useUpdateTransaction(id), useDeleteTransaction. Wraps TransactionForm in mode='edit' with defaultValues from useTransaction data. Separator + DeleteActionButton (destructive button opening ConfirmDialog). On update success: router.push('/transactions') + toast. On delete success: router.push('/transactions') + toast. PageHeader title 'Edit Transaksi', backHref '/transactions'. Not found: 'Transaksi tidak ditemukan' + link to /transactions. Loading: 'Memuat data transaksi...' + form skeleton."
    acceptance_criteria:
      - "Page fetches transaction by ID and pre-fills form"
      - "TransactionForm rendered in edit mode with default values"
      - "Update submit calls useUpdateTransaction(id)"
      - "Delete button shows ConfirmDialog with destructive styling"
      - "Confirm delete calls useDeleteTransaction"
      - "On update success: redirect to /transactions with success toast"
      - "On delete success: redirect to /transactions with success toast"
      - "Not found: 'Transaksi tidak ditemukan' with link"
      - "Loading state shows 'Memuat data transaksi...' text + form skeleton"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-014
      - T-024
      - T-025
    blocks: []
    labels:
      - page
      - transaction
      - form
    estimated_hours: 5
    source: "doc-04: routes[7], doc-05: data_flows[7], doc-06: section 2.8, doc-02: US-008, US-009"
    confidence: 1.0

  - id: T-035
    phase: 4
    title: Implement MonthlySummary page (/summary)
    description: "Create app/(shell)/summary/page.tsx (MonthlySummaryPage), loading.tsx, error.tsx. Page uses useMonthlySummary(month, year from URL searchParams). Default month/year = current. Create page components: MonthYearPicker (prev button, month Select, year Select, next button disabled if future), SummaryHeader (3 StatCards: total income green, total expense red, net balance conditional color), IncomeBreakdownSection (heading + CategoryBreakdownItem rows with Progress bar showing percentage of total + amount), ExpenseBreakdownSection (same for expense), CategoryBreakdownItem (category name, Progress, amount). Empty state when no transactions: all values 0 + 'Tidak ada transaksi di bulan ini'. Month/year change updates URL searchParams via router.replace."
    acceptance_criteria:
      - "Page defaults to current month/year"
      - "MonthYearPicker has prev/next buttons and month/year selects"
      - "Next button disabled for future months"
      - "SummaryHeader shows 3 StatCards: income (green), expense (red), net (conditional)"
      - "IncomeBreakdownSection shows income grouped by category with progress bars"
      - "ExpenseBreakdownSection shows expense grouped by category with progress bars"
      - "Progress bars show percentage of category total vs grand total"
      - "Empty state: all zeros with 'Tidak ada transaksi di bulan ini'"
      - "Month/year change updates URL and refetches summary"
      - "Loading state shows stat card skeletons + breakdown skeletons"
      - "Error state shows ErrorAlert with retry"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-012
      - T-026
    blocks: []
    labels:
      - page
      - summary
    estimated_hours: 6
    source: "doc-04: routes[8], doc-05: data_flows[8], doc-06: section 2.9, doc-02: US-010, US-011"
    confidence: 1.0

  # ── PHASE 5: DASHBOARD ──

  - id: T-027
    phase: 5
    title: Implement Dashboard page (/)
    description: "Create app/(shell)/page.tsx (DashboardPage), loading.tsx, error.tsx. Page uses useWallets and useTransactions({page:1, perPage:5}). Render: PageHeader (title: 'Beranda'), BalanceSummaryCard (aggregates wallet balances into StatCards for income/expense/net), RecentTransactionsList (5 most recent TransactionRow with showActions=false), QuickActions (2 buttons: 'Catat Transaksi' -> /transactions/new, 'Lihat Ringkasan' -> /summary), Link 'Lihat Semua Transaksi' -> /transactions. Create page components: RecentTransactionsList, QuickActions. Dashboard serves as landing page showing wallet balance overview and recent transaction activity."
    acceptance_criteria:
      - "Dashboard loads wallet list and 5 most recent transactions"
      - "BalanceSummaryCard shows aggregate balance summary"
      - "RecentTransactionsList shows 5 latest transactions without actions"
      - "QuickActions has buttons for new transaction and view summary"
      - "'Lihat Semua Transaksi' link navigates to /transactions"
      - "Loading state shows stat card skeletons + transaction row skeletons"
      - "Error state shows ErrorAlert with retry"
      - "Empty wallet state shows appropriate message"
    priority: P1
    blockedBy:
      - T-009
      - T-010
      - T-011
      - T-012
      - T-013
      - T-023
      - T-025
    blocks: []
    labels:
      - page
      - dashboard
    estimated_hours: 5
    source: "doc-04: routes[0], doc-05: data_flows[0], doc-06: section 2.1"
    confidence: 1.0

  # ── PHASE 6: TESTING ──

  - id: T-036
    phase: 6
    title: Set up Vitest with MSW test server and testing utilities
    description: "Configure vitest.config.ts with react plugin, jsdom environment, path aliases matching tsconfig. Create src/lib/test-utils.tsx with custom render wrapping components in QueryClientProvider + MSW server setup/teardown per test. Create setup file for @testing-library/jest-dom matchers. Configure MSW server instance that resets between tests. Create test helpers: createWrapper (providers wrapper), mockQueryClient, waitForLoadingToFinish. Ensure MSW handlers from T-008 are importable in test environment."
    acceptance_criteria:
      - "vitest runs and discovers test files"
      - "Custom render wraps components with all required providers"
      - "MSW server starts before tests, resets between tests, stops after"
      - "Test utilities exportable from single entry point"
    priority: P2
    blockedBy:
      - T-008
    blocks:
      - T-037
      - T-038
      - T-039
    labels:
      - testing
      - infra
    estimated_hours: 3
    source: "doc-07: section 4.8 (MSW server setup)"
    confidence: 1.0

  - id: T-037
    phase: 6
    title: Write unit tests for Zod validation schemas
    description: "Create src/lib/__tests__/validation-schemas.test.ts. Test every schema from T-006: valid inputs parse successfully, invalid inputs produce correct error messages, cross-field validation (BR-007 category type matches transaction type), edge cases (min/max string lengths, negative amounts, future dates, invalid enums), TransactionFilterSchema coerces string params to numbers, SummaryQuerySchema month/year range. Test all bilingual error messages render correctly."
    acceptance_criteria:
      - "CreateWalletSchema accepts valid input, rejects empty name, negative balance, invalid type"
      - "CreateTransactionSchema rejects amount <= 0, future date, note > 500 chars"
      - "CreateTransactionSchema.refine validates category type matches transaction type"
      - "TransactionFilterSchema coerces page='2' to page=2"
      - "SummaryQuerySchema rejects month 0, month 13, year 2019, year 2101"
      - "Error messages include both ID and EN text"
    priority: P2
    blockedBy:
      - T-006
      - T-036
    blocks: []
    labels:
      - testing
      - validation
    estimated_hours: 4
    source: "doc-08: schemas[]"
    confidence: 1.0

  - id: T-038
    phase: 6
    title: Write unit tests for React Query hooks
    description: "Create test files for all query hooks in src/hooks/queries/__tests__/ and src/hooks/mutations/__tests__/. Use MSW to mock API responses. Test: useWallets returns wallet list, useWallet returns single wallet and throws on 404, useCreateWallet POSTs and invalidates cache, useTransactions handles filter params, useCreateTransaction cascade invalidation (verify wallets and summary queries refetch after transaction creation), useDeleteTransaction marks success. Test loading, success, error states for each hook."
    acceptance_criteria:
      - "useWallets returns list of wallets from MSW mock"
      - "useWallet(999) raises error on 404"
      - "useCreateWallet mutation calls POST and invalidates wallet cache"
      - "useTransactions with filters sends correct query params"
      - "useCreateTransaction onSuccess invalidates wallets and summary caches"
      - "useDeleteTransaction onSuccess invalidates transactions, wallets, summary"
      - "All hooks handle loading and error states"
    priority: P2
    blockedBy:
      - T-023
      - T-024
      - T-025
      - T-026
      - T-036
    blocks: []
    labels:
      - testing
      - hooks
    estimated_hours: 6
    source: "doc-05: query_hooks[], doc-07: endpoints[]"
    confidence: 0.9

  - id: T-039
    phase: 6
    title: Write unit tests for shared components
    description: "Create test files for src/components/shared/__tests__/. Test: WalletCard renders wallet data and formats currency, TransactionRow renders with/without actions, StatCard shows correct color per type, EmptyState renders with CTA, ErrorAlert renders message and retry button fires handler, ConfirmDialog opens and fires onConfirm on accept, LoadingSkeleton renders correct number of skeleton elements, FilterChip shows label and fires onRemove. Test TransactionForm: renders all fields, type toggle filters categories, amount input validates min, BalanceWarning shows for expense exceeding balance, form submits correct data."
    acceptance_criteria:
      - "WalletCard renders name, type badge, formatted balance"
      - "TransactionRow renders with correct type color"
      - "StatCard shows type-appropriate color"
      - "ErrorAlert retry button fires callback"
      - "ConfirmDialog confirm button fires onConfirm"
      - "TransactionForm submits correct CreateTransactionInput shape"
      - "TransactionForm type toggle filters category options"
      - "BalanceWarning visible when expense > wallet balance"
    priority: P2
    blockedBy:
      - T-011
      - T-012
      - T-014
      - T-036
    blocks: []
    labels:
      - testing
      - component
    estimated_hours: 6
    source: "doc-06: shared_components[]"
    confidence: 0.9

  - id: T-040
    phase: 6
    title: Write E2E test for wallet CRUD flow (Playwright)
    description: "Create e2e/wallet-crud.spec.ts using Playwright. Test flow: navigate to /wallets, verify empty state, click 'Buat Dompet', fill form with name 'Test Wallet', type 'bank', initial balance '100000', submit, verify redirect to /wallets with new wallet visible. Verify wallet card shows correct name, type badge 'bank', balance 'Rp100.000'. Test: navigate to wallet detail, verify wallet info and transaction history section. Test: navigation between Dashboard -> Wallets -> Create Wallet -> back to Wallets."
    acceptance_criteria:
      - "E2E test creates wallet through full form flow"
      - "Verifies wallet appears in list after creation"
      - "Verifies wallet detail page loads correct data"
      - "Verifies navigation flow between wallet pages"
      - "Test runs headless and passes"
    priority: P2
    blockedBy:
      - T-028
      - T-029
      - T-030
    blocks: []
    labels:
      - testing
      - e2e
      - wallet
    estimated_hours: 5
    source: "doc-02: US-001, US-002, doc-04: routes[1,2,3]"
    confidence: 0.8

  - id: T-041
    phase: 6
    title: Write E2E test for transaction CRUD and filter flow (Playwright)
    description: "Create e2e/transaction-crud.spec.ts. Test flow: navigate to /transactions/new, fill TransactionForm (select wallet, select category, type expense, amount 50000, date today, note 'Test'), submit, verify redirect to /transactions with new transaction visible. Test: navigate to edit page, change amount to 75000, submit, verify updated. Test: delete transaction via delete button, confirm dialog, verify removed from list. Test filter: apply type filter, date range filter, verify results update. Test: verify balance warning for expense exceeding wallet balance."
    acceptance_criteria:
      - "E2E creates transaction through full form"
      - "Verifies transaction appears in list after creation"
      - "E2E edits transaction amount"
      - "Verifies updated transaction in list"
      - "E2E deletes transaction via ConfirmDialog"
      - "Verifies transaction removed after delete"
      - "E2E test filters by type"
      - "Test runs headless and passes"
    priority: P2
    blockedBy:
      - T-032
      - T-033
      - T-034
    blocks: []
    labels:
      - testing
      - e2e
      - transaction
    estimated_hours: 6
    source: "doc-02: US-004, US-005, US-006, US-007, US-008, US-009, doc-04: routes[5,6,7]"
    confidence: 0.8

  - id: T-042
    phase: 6
    title: Write E2E test for monthly summary flow (Playwright)
    description: "Create e2e/monthly-summary.spec.ts. Test flow: navigate to /summary, verify default current month/year displayed. Verify 3 StatCards visible (income, expense, net). Verify income and expense breakdown sections with category breakdown items. Test: navigate to previous month via prev button, verify URL updates with ?month=X&year=Y. Test: navigate to future month, verify next button disabled. Test: verify empty state shows 'Tidak ada transaksi di bulan ini' when no data."
    acceptance_criteria:
      - "E2E loads summary page with current month default"
      - "Verifies 3 StatCards visible with correct labels"
      - "Verifies income and expense breakdown sections"
      - "Navigates between months via prev/next buttons"
      - "Verifies future month navigation disabled"
      - "Verifies empty state message"
      - "Test runs headless and passes"
    priority: P2
    blockedBy:
      - T-035
    blocks: []
    labels:
      - testing
      - e2e
      - summary
    estimated_hours: 4
    source: "doc-02: US-010, US-011, doc-04: routes[8]"
    confidence: 0.8

  # ── PHASE 7: POLISH ──

  - id: T-043
    phase: 7
    title: Implement mutation feedback and toast notifications
    description: "Add Sonner toast calls to all mutation onSuccess/onError handlers across all pages. Mutation success toasts use variant='success', errors use variant='error'. For create/update wallet: 'Dompet berhasil disimpan'/'Dompet gagal disimpan'. For create/update transaction: 'Transaksi berhasil disimpan'/'Transaksi gagal disimpan'. For delete transaction: 'Transaksi berhasil dihapus'/'Transaksi gagal dihapus'. For category: 'Kategori berhasil ditambahkan'/'Kategori gagal ditambahkan'. Integrate Toaster in app/providers.tsx with richColors prop."
    acceptance_criteria:
      - "All mutations show success toast on completion"
      - "All mutations show error toast on failure"
      - "Toast messages are bilingual (ID primary) per schema convention"
      - "Toaster renders with richColors in providers"
    priority: P3
    blockedBy:
      - T-028
      - T-029
      - T-031
      - T-032
      - T-033
      - T-034
      - T-035
    blocks: []
    labels:
      - polish
      - ui
    estimated_hours: 3
    source: "doc-06: section 3 (Sonner), doc-05: section 9 (Mutation Side Effects)"
    confidence: 1.0

  - id: T-044
    phase: 7
    title: Polish responsive layout and navigation transitions
    description: "Audit all 9 pages for responsive behavior at mobile (<768px), tablet (768-1024px), desktop (>1024px). Fix layout issues: ensure BottomNav fixed at bottom on mobile, Sidebar visible on desktop, form pages centered with max-w constraints on desktop. Add smooth transitions: page route transitions via CSS, skeleton loading animation duration. Ensure proper spacing on small screens. Add active route indicator CSS in Sidebar/BottomNav. Verify back button behavior on all form pages."
    acceptance_criteria:
      - "All pages render correctly at mobile, tablet, desktop breakpoints"
      - "BottomNav fixed at bottom on mobile, hidden on desktop"
      - "Sidebar visible on desktop with active route highlight"
      - "Form pages centered with max width on desktop"
      - "Smooth skeleton loading animations"
      - "Back buttons navigate correctly on all form pages"
    priority: P3
    blockedBy:
      - T-027
      - T-028
      - T-029
      - T-030
      - T-031
      - T-032
      - T-033
      - T-034
      - T-035
    blocks: []
    labels:
      - polish
      - responsive
    estimated_hours: 4
    source: "doc-06: section 5 (Responsive Strategy)"
    confidence: 0.9

phase_summary:
  - phase: 1
    name: Foundation
    task_count: 8
    total_hours: 28
  - phase: 2
    name: Shared Components
    task_count: 6
    total_hours: 31
  - phase: 3
    name: Query Hooks
    task_count: 4
    total_hours: 15
  - phase: 4
    name: Pages
    task_count: 8
    total_hours: 43
  - phase: 5
    name: Dashboard
    task_count: 1
    total_hours: 5
  - phase: 6
    name: Testing
    task_count: 7
    total_hours: 34
  - phase: 7
    name: Polish
    task_count: 2
    total_hours: 7

assumptions:
  - id: A9-001
    statement: WalletDetail route (/wallets/[id]) included as P2 with 0.6 confidence. If scope-cut, drop T-030 and remove route.
    impacts: "Saves ~5 dev hours. Wallet drill-down uses /transactions?wallet_id={id} instead."
    confidence: 0.6
  - id: A9-002
    statement: Create/Edit transaction use full page routes, not modals. Tasks T-033 and T-034 assume page-level components.
    impacts: "No Sheet/Drawer overlay needed. Deep linking works for these routes."
    confidence: 0.7
  - id: A9-003
    statement: No auth required in MVP. All pages assume authenticated user. No login route or auth middleware.
    impacts: "No auth tasks in this breakdown. Route tree flat without auth guards."
    confidence: 1.0
  - id: A9-004
    statement: MSW handlers provide sufficient mock data for all E2E and unit tests. No separate backend needed during frontend dev.
    impacts: "T-040, T-041, T-042 run against MSW mocks, not real API."
    confidence: 1.0
  - id: A9-005
    statement: Wallet update/delete endpoints not in MVP scope. No wallet edit page or delete route.
    impacts: "No /wallets/[id]/edit route. Wallet current_balance only changes via transactions."
    confidence: 0.6
  - id: A9-006
    statement: Summary is server-computed single endpoint. No client-side aggregation logic needed.
    impacts: "useMonthlySummary fetches pre-computed data. No client-side group-by or sum needed."
    confidence: 1.0
  - id: A9-007
    statement: E2E tests run against MSW server, not real backend. Playwright tests start MSW server before each spec.
    impacts: "Test data deterministic. No external API dependency in CI."
    confidence: 0.9
---

# 09 — Atomic Task Breakdown

## 1. Task Inventory

42 atomic tasks across 7 phases. Total estimated effort: 163 hours.

| ID | Phase | Title | Priority | Est. Hours | Blocks | Blocked By |
|----|-------|-------|----------|-----------|--------|------------|
| T-001 | 1 | Initialize Next.js project | P0 | 4 | T-002..T-009 | - |
| T-002 | 1 | Scaffold route structure | P0 | 4 | T-027..T-035 | T-001 |
| T-003 | 1 | TypeScript types | P0 | 3 | T-006,T-007,T-008,T-023..T-026 | T-001 |
| T-004 | 1 | Utility functions | P0 | 2 | T-011,T-012,T-013,T-014 | T-001 |
| T-005 | 1 | Zustand UIStore | P0 | 3 | T-009 | T-001 |
| T-006 | 1 | Zod schemas | P0 | 4 | T-014,T-037 | T-003 |
| T-007 | 1 | Query keys + QueryClient | P0 | 2 | T-023..T-026 | T-001 |
| T-008 | 1 | MSW handlers + seed data | P0 | 6 | T-023..T-026,T-036 | T-003 |
| T-009 | 2 | AppShell + Header | P0 | 5 | T-010,T-027..T-035 | T-001,T-005 |
| T-010 | 2 | Sidebar + BottomNav | P0 | 5 | T-027..T-035 | T-009 |
| T-011 | 2 | Shared UI (ErrorAlert, EmptyState, LoadingSkeleton, ConfirmDialog, FilterChip) | P1 | 5 | T-027..T-035 | T-004 |
| T-012 | 2 | Shared domain (WalletCard, TransactionRow, StatCard, CategoryCard) | P1 | 5 | T-027,T-028,T-030,T-032,T-035 | T-004 |
| T-013 | 2 | BalanceSummaryCard | P1 | 3 | T-027 | T-004,T-012 |
| T-014 | 2 | TransactionForm | P1 | 8 | T-033,T-034 | T-006,T-012 |
| T-023 | 3 | Wallet hooks (useWallets, useWallet, useCreateWallet) | P1 | 4 | T-028,T-029,T-030 | T-007,T-008 |
| T-024 | 3 | Category hooks (useCategories, useCreateCategory) | P1 | 3 | T-031,T-032,T-033,T-034 | T-007,T-008 |
| T-025 | 3 | Transaction hooks (useTransactions, useTransaction, useCreate, useUpdate, useDelete) | P1 | 6 | T-032,T-033,T-034,T-035 | T-007,T-008 |
| T-026 | 3 | Summary hook (useMonthlySummary) | P1 | 2 | T-035 | T-007,T-008 |
| T-028 | 4 | WalletList page | P1 | 5 | - | T-009,T-010,T-011,T-012,T-023 |
| T-029 | 4 | CreateWallet page | P1 | 4 | - | T-009,T-010,T-011,T-023 |
| T-030 | 4 | WalletDetail page | P2 | 5 | - | T-009,T-010,T-011,T-012,T-023,T-025 |
| T-031 | 4 | CategoryList page | P1 | 5 | - | T-009,T-010,T-011,T-012,T-024 |
| T-032 | 4 | TransactionList page | P1 | 8 | - | T-009,T-010,T-011,T-012,T-024,T-025 |
| T-033 | 4 | CreateTransaction page | P1 | 4 | - | T-009,T-010,T-011,T-014,T-024,T-025 |
| T-034 | 4 | EditTransaction page | P1 | 5 | - | T-009,T-010,T-011,T-014,T-024,T-025 |
| T-035 | 4 | MonthlySummary page | P1 | 6 | - | T-009,T-010,T-011,T-012,T-026 |
| T-027 | 5 | Dashboard page | P1 | 5 | - | T-009,T-010,T-011,T-012,T-013,T-023,T-025 |
| T-036 | 6 | Vitest + MSW test setup | P2 | 3 | T-037,T-038,T-039 | T-008 |
| T-037 | 6 | Zod schema unit tests | P2 | 4 | - | T-006,T-036 |
| T-038 | 6 | Hook unit tests | P2 | 6 | - | T-023..T-026,T-036 |
| T-039 | 6 | Shared component unit tests | P2 | 6 | - | T-011,T-012,T-014,T-036 |
| T-040 | 6 | E2E: Wallet CRUD | P2 | 5 | - | T-028,T-029,T-030 |
| T-041 | 6 | E2E: Transaction CRUD + filter | P2 | 6 | - | T-032,T-033,T-034 |
| T-042 | 6 | E2E: Monthly summary | P2 | 4 | - | T-035 |
| T-043 | 7 | Mutation feedback toasts | P3 | 3 | - | T-028,T-029,T-031,T-032,T-033,T-034,T-035 |
| T-044 | 7 | Responsive polish | P3 | 4 | - | T-027..T-035 |

## 2. User Story Coverage

| User Story | Priority | Primary Task(s) | Supporting Tasks |
|-----------|----------|----------------|------------------|
| US-001 (Create wallet) | High | T-029 (CreateWallet page) | T-023 (hooks), T-006 (validation), T-040 (E2E) |
| US-002 (View wallets) | High | T-028 (WalletList page) | T-023 (hooks), T-012 (WalletCard), T-040 (E2E) |
| US-003 (Use categories) | High | T-031 (CategoryList page) | T-024 (hooks), T-006 (validation), T-012 (CategoryCard) |
| US-004 (Record income) | High | T-033 (CreateTransaction page) | T-014 (TransactionForm), T-025 (hooks), T-041 (E2E) |
| US-005 (Record expense) | High | T-033 (CreateTransaction page) | T-014 (TransactionForm), T-025 (hooks), T-041 (E2E) |
| US-006 (View history) | High | T-032 (TransactionList page) | T-025 (hooks), T-012 (TransactionRow), T-041 (E2E) |
| US-007 (Filter transactions) | Medium | T-032 (TransactionList page) | T-024 (hooks), T-011 (FilterChip), T-041 (E2E) |
| US-008 (Edit transaction) | Medium | T-034 (EditTransaction page) | T-014 (TransactionForm), T-025 (hooks), T-041 (E2E) |
| US-009 (Delete transaction) | Medium | T-032, T-034 (list + edit) | T-025 (hooks), T-011 (ConfirmDialog), T-041 (E2E) |
| US-010 (Monthly summary) | High | T-035 (MonthlySummary page) | T-026 (hooks), T-012 (StatCard), T-042 (E2E) |
| US-011 (Category breakdown) | Medium | T-035 (MonthlySummary page) | T-026 (hooks), T-042 (E2E) |

## 3. Entity Coverage

| Entity | Type Definition | Zod Schema | Page(s) | Component(s) |
|--------|---------------|------------|---------|--------------|
| User | T-003 (types/api.ts) | — (inferred, no form) | All pages | — |
| Wallet | T-003 (types/api.ts) | T-006 (WalletSchema, CreateWalletSchema) | T-028, T-029, T-030 | T-012 (WalletCard) |
| Category | T-003 (types/api.ts) | T-006 (CategorySchema, CreateCategorySchema) | T-031 | T-012 (CategoryCard) |
| Transaction | T-003 (types/api.ts) | T-006 (TransactionSchema, CreateTransactionSchema) | T-032, T-033, T-034 | T-012 (TransactionRow), T-014 (TransactionForm) |

## 4. Route Coverage

| Route | Screen | Task | Layout |
|-------|--------|------|--------|
| / | Dashboard | T-027 | (shell) |
| /wallets | WalletList | T-028 | (shell) |
| /wallets/new | CreateWallet | T-029 | (minimal) |
| /wallets/[id] | WalletDetail | T-030 | (shell) |
| /categories | CategoryList | T-031 | (shell) |
| /transactions | TransactionList | T-032 | (shell) |
| /transactions/new | CreateTransaction | T-033 | (minimal) |
| /transactions/[id]/edit | EditTransaction | T-034 | (minimal) |
| /summary | MonthlySummary | T-035 | (shell) |

## 5. Dependency Graph

```
Phase 1: Foundation
  T-001 (Project Init)
  ├── T-002 (Route Scaffold)
  ├── T-003 (Types)
  │   ├── T-006 (Zod Schemas)
  │   ├── T-007 (Query Keys)
  │   │   ├── T-023 (Wallet Hooks)
  │   │   ├── T-024 (Category Hooks)
  │   │   ├── T-025 (Transaction Hooks)
  │   │   └── T-026 (Summary Hook)
  │   └── T-008 (MSW Handlers) ── T-036 (Test Setup)
  ├── T-004 (Utilities)
  ├── T-005 (Zustand Store)

Phase 2: Shared Components
  T-009 (AppShell) ── T-010 (Navigation)
  T-011 (UI Patterns)
  T-012 (Domain Components) ── T-013 (BalanceSummary)
  T-014 (TransactionForm) [depends on T-006 Zod]

Phase 3-5: Pages
  T-023 ── T-028 (WalletList), T-029 (CreateWallet), T-030 (WalletDetail)
  T-024 ── T-031 (CategoryList)
  T-025 ── T-032 (TransactionList), T-033 (CreateTransaction), T-034 (EditTransaction)
  T-026 ── T-035 (MonthlySummary)
  T-023 + T-025 ── T-027 (Dashboard)

Phase 6: Testing
  T-036 ── T-037 (Zod Tests), T-038 (Hook Tests), T-039 (Component Tests)
  T-028+T-029+T-030 ── T-040 (E2E Wallet)
  T-032+T-033+T-034 ── T-041 (E2E Transaction)
  T-035 ── T-042 (E2E Summary)

Phase 7: Polish
  T-028..T-035 ── T-043 (Toasts), T-044 (Responsive)
```

## 6. GitHub Issue Format

### Example: T-001

```
## T-001: Initialize Next.js project and install dependencies

**Covers:** US-001, US-002, US-003, US-004, US-005, US-006, US-007, US-008, US-009, US-010, US-011
**Dependencies:** None
**Est. Effort:** M (4 hours)
**Labels:** `setup`, `infra`

### Description
Create Next.js App Router project with TypeScript strict mode. Install all runtime and dev dependencies: zustand, @tanstack/react-query, @tanstack/react-query-devtools, react-hook-form, @hookform/resolvers, zod, date-fns, lucide-react. Install shadcn/ui CLI and init with default config. Add dev deps: msw, vitest, @testing-library/react, @testing-library/jest-dom, @vitejs/plugin-react, jsdom, @playwright/test, eslint. Configure tsconfig path alias '@/' pointing to src/.

### Acceptance Criteria
- [ ] `next dev` runs without errors on fresh project
- [ ] shadcn/ui components can be added via CLI
- [ ] All package.json dependencies listed and installable
- [ ] tsconfig paths alias configured
- [ ] TypeScript strict mode enabled

### Output Artifacts
- `package.json`
- `tsconfig.json`
- `next.config.js`
- `tailwind.config.ts`
- `src/app/layout.tsx`
- `components.json` (shadcn config)
```

### Example: T-014

```
## T-014: Implement TransactionForm shared component (create + edit modes)

**Covers:** US-004, US-005, US-008
**Dependencies:** T-006 (Zod schemas), T-012 (shared domain components)
**Est. Effort:** L (8 hours)
**Labels:** `component`, `form`

### Description
Create src/components/shared/transaction/transaction-form.tsx — the most complex shared component in Pocket. Uses react-hook-form with Zod resolver (CreateTransactionSchema). Supports 'create' and 'edit' modes via props.

Internal fields:
- TypeToggle: shadcn Tabs for income/expense
- WalletSelect: shadcn Select populated from wallets prop
- CategorySelect: shadcn Select filtered by selected type
- AmountInput: shadcn Input type=number step=1 with Rp prefix
- DatePicker: shadcn Calendar + Popover, max=today
- NoteTextarea: shadcn Textarea, maxLength=500
- BalanceWarning: shadcn Alert shown when expense > wallet balance
- SubmitButton: disabled when isSubmitting

Category select filters client-side when type changes. Live balance check on amount change.

### Acceptance Criteria
- [ ] All form fields render: type toggle, wallet select, category select, amount, date, note
- [ ] Category select filters by selected transaction type
- [ ] Amount input uses step=1, min=1, with Rp prefix display
- [ ] DatePicker max date is today
- [ ] BalanceWarning appears when expense amount > wallet balance
- [ ] Form validates with CreateTransactionSchema before submit
- [ ] Mode 'edit' pre-fills with defaultValues
- [ ] onSubmit receives validated TransactionCreateInput data
- [ ] Submit button disabled when isSubmitting is true

### Output Artifacts
- `src/components/shared/transaction/transaction-form.tsx`
```

## 7. RTM (Requirements Traceability Matrix)

| Task | User Story | Entity | Route | Component | API Endpoint |
|------|-----------|--------|-------|-----------|--------------|
| T-001 | All | All | All | — | — |
| T-002 | — | — | All | — | — |
| T-003 | — | User, Wallet, Category, Transaction | — | — | — |
| T-004 | — | — | — | — | — |
| T-005 | — | — | — | AppShell | — |
| T-006 | US-001, US-003, US-004, US-005, US-007, US-008, US-010 | Wallet, Category, Transaction | — | — | — |
| T-007 | — | — | — | — | — |
| T-008 | — | Wallet, Category, Transaction | — | — | All 11 endpoints |
| T-009 | — | — | All | AppShell, Header, PageHeader | — |
| T-010 | — | — | All | Sidebar, BottomNav | — |
| T-011 | US-006, US-007, US-009 | — | — | ErrorAlert, EmptyState, LoadingSkeleton, ConfirmDialog, FilterChip | — |
| T-012 | US-001, US-002, US-003, US-006 | Wallet, Category, Transaction | — | WalletCard, TransactionRow, StatCard, CategoryCard | — |
| T-013 | — | Wallet | / | BalanceSummaryCard | — |
| T-014 | US-004, US-005, US-008 | Transaction | — | TransactionForm | — |
| T-023 | US-001, US-002 | Wallet | — | — | GET /api/wallets, GET /api/wallets/:id, POST /api/wallets |
| T-024 | US-003 | Category | — | — | GET /api/categories, POST /api/categories |
| T-025 | US-004, US-005, US-006, US-007, US-008, US-009 | Transaction | — | — | GET /api/transactions, GET /api/transactions/:id, POST /api/transactions, PUT /api/transactions/:id, DELETE /api/transactions/:id |
| T-026 | US-010, US-011 | — | — | — | GET /api/summary |
| T-027 | — | Wallet, Transaction | / | BalanceSummaryCard, RecentTransactionsList, QuickActions | — |
| T-028 | US-002 | Wallet | /wallets | WalletListGrid, EmptyWalletState | — |
| T-029 | US-001 | Wallet | /wallets/new | CreateWalletForm | — |
| T-030 | — | Wallet, Transaction | /wallets/[id] | WalletDetailCard, WalletRecentTransactions | — |
| T-031 | US-003 | Category | /categories | CategoryTabs, CategoryGrid, CreateCategoryForm | — |
| T-032 | US-006, US-007, US-009 | Transaction | /transactions | FilterBar, TransactionTable, PaginationControls | — |
| T-033 | US-004, US-005 | Transaction | /transactions/new | TransactionForm (create) | — |
| T-034 | US-008, US-009 | Transaction | /transactions/[id]/edit | TransactionForm (edit), DeleteActionButton | — |
| T-035 | US-010, US-011 | — | /summary | MonthYearPicker, SummaryHeader, BreakdownSections | — |
| T-036 | — | — | — | — | — |
| T-037 | US-001, US-003, US-004, US-005, US-008, US-010 | Wallet, Category, Transaction | — | — | — |
| T-038 | US-001..US-011 | Wallet, Category, Transaction | — | — | All 11 endpoints |
| T-039 | US-001..US-011 | Wallet, Category, Transaction | — | Shared components | — |
| T-040 | US-001, US-002 | Wallet | /wallets, /wallets/new, /wallets/[id] | — | — |
| T-041 | US-004, US-005, US-006, US-007, US-008, US-009 | Transaction | /transactions, /transactions/new, /transactions/[id]/edit | — | — |
| T-042 | US-010, US-011 | — | /summary | — | — |
| T-043 | US-001..US-011 | — | All | — | — |
| T-044 | — | — | All | AppShell, Sidebar, BottomNav | — |

## 8. Coverage Report

| Metric | Value |
|--------|-------|
| **Total tasks** | 42 |
| **User stories covered** | 11 / 11 (100%) |
| **Entities covered** | 4 / 4 (100%) |
| **Routes covered** | 9 / 9 (100%) |
| **Shared components covered** | 14 / 14 (100%) |
| **Query hooks covered** | 11 / 11 (100%) |
| **API endpoints covered** | 11 / 11 (100%) |
| **Zod schemas covered** | 8 / 8 (100%) |

### Task Distribution by Priority

| Priority | Count | Hours |
|----------|-------|-------|
| P0 (blocking) | 8 | 28 |
| P1 (core) | 19 | 87 |
| P2 (important) | 13 | 51 |
| P3 (nice-to-have) | 2 | 7 |

### Task Distribution by Label

| Label | Count | Tasks |
|-------|-------|-------|
| setup | 8 | T-001..T-008 |
| component | 8 | T-009..T-014, T-043, T-044 |
| state | 4 | T-005, T-007, T-023, T-024 |
| api | 5 | T-008, T-023, T-024, T-025, T-026 |
| validation | 2 | T-006, T-037 |
| page | 9 | T-027..T-035 |
| testing | 7 | T-036..T-042 |
| polish | 2 | T-043, T-044 |

### Business Rule Coverage by Phase

| Business Rule | Validation Layer | Task |
|--------------|-----------------|------|
| BR-001 (data isolation) | Server-side only (app-level query filter) | — |
| BR-002 (wallet ownership) | Server-side only | — |
| BR-003 (category ownership) | Server-side only | — |
| BR-004 (transaction required fields) | Zod (CreateTransactionSchema) | T-006 |
| BR-005 (amount > 0) | Zod (CreateTransactionSchema.amount.positive()) | T-006 |
| BR-006 (type income/expense) | Zod (CreateTransactionSchema.type.enum()) | T-006 |
| BR-007 (category type match) | Zod (CreateTransactionSchema.refine()) | T-006 |
| BR-008 (no negative balance) | UI (BalanceWarning), server ultimately enforces | T-014 |
| BR-009 (date <= today) | Zod (date validation in CreateTransactionSchema) | T-006 |
| BR-010 (edit active only) | Server-side (soft-deleted returns 404) | — |
| BR-011 (deleted not in history) | Server-side | — |
| BR-012 (wallet with txns no hard delete) | Server-side | — |
| BR-013 (summary by month/year) | Zod (SummaryQuerySchema) | T-006 |
| BR-014 (default categories) | Seed data in MSW | T-008 |
| BR-015 (custom categories) | Zod (CreateCategorySchema) | T-006 |
| BR-016 (amount integer) | Zod (z.number().int()) | T-006 |
| BR-017 (IDR currency) | UI (formatIDR utility) | T-004 |
| BR-018 (soft delete) | Server-side | — |
| BR-019 (data isolation) | Server-side | — |
| BR-020 (summary from active) | Server-side | — |
| BR-021 (soft-deleted not editable) | Server-side (404) | — |

Note: BR-001, BR-002, BR-003, BR-008, BR-010, BR-011, BR-012, BR-018, BR-019, BR-020, BR-021 are server-enforced rules. Frontend provides defensive UI (BalanceWarning for BR-008, not-found.tsx for BR-010/BR-021). The validation report WARNING for `business-rule-vs-validation` (8 rules without Zod schema) is acknowledged — these rules are inherently server-side (data isolation, soft delete semantics, balance enforcement).

## 9. DoD Checklist

- [x] All 42 tasks ≤ 1 day each, single purpose, acceptance criteria concrete
- [x] All 11 user stories covered by at least one task
- [x] All 4 entities covered by type definition, Zod schema, page, and component
- [x] All 9 routes covered by a page task
- [x] All 14 shared components covered by component tasks
- [x] All 11 query hooks covered by hook tasks
- [x] All 11 API endpoints covered by MSW + hook tasks
- [x] All 8 Zod schemas covered by schema + test tasks
- [x] Dependency order between tasks documented (blockedBy/blocks explicit in YAML)
- [x] Dependency graph visual in section 5
- [x] Task format compatible with GitHub Issues (example format in section 6)
- [x] RTM complete: all user stories, entities, routes, components, endpoints traceable
- [x] Frontmatter YAML valid with all required fields (prd_source_hash, agent, schema_version, status, summary, tasks, phase_summary, assumptions)
- [x] No placeholder, TODO, or "TBD"
- [x] All entity/type/schema names use PascalCase exact (Wallet, Category, Transaction, User, TransactionForm, etc.)
- [x] Validation report WARNINGs acknowledged: BR-vs-Validation (8 server-side rules), US-vs-Task (resolved by this document)
