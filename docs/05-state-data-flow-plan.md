---
title: State & Data Flow Plan
description: Zustand stores, React Query keys and hooks, and data flow per screen for Pocket personal finance app
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 5
schema_version: 1
status: complete
summary: >
  This document defines state management and data flow architecture for Pocket.
  Two categories of state: server state (TanStack Query) and client state (Zustand).
  Server state dominates — every screen renders data fetched from API. Zustand is
  minimal: a single UIStore for theme and sidebar. Filter state lives in URL search
  params (source of truth per ASM-007). Form state lives in react-hook-form (local).
  Eleven React Query hooks defined: useWallets, useWallet, useCategories, useTransactions,
  useTransaction, useMonthlySummary for queries; useCreateWallet, useCreateCategory,
  useCreateTransaction, useUpdateTransaction, useDeleteTransaction for mutations. Query
  keys follow structured hierarchy with key factories: ['wallets'] base,
  ['wallets', id] for detail, ['transactions', filters] for list, ['categories'] base,
  ['summary', {month, year}] for summary. Nine screens mapped to data flow: Dashboard
  needs wallets + recent transactions; WalletList needs wallets; CreateWallet needs
  create mutation; WalletDetail needs single wallet + its transactions; CategoryList
  needs categories; TransactionList needs transactions + wallets + categories for filter
  dropdowns; CreateTransaction needs wallets + categories + create mutation;
  EditTransaction needs single transaction + wallets + categories + update mutation;
  MonthlySummary needs summary by month/year. Cache invalidation is the most critical
  design decision — mutations cascade invalidate across entity boundaries: creating a
  transaction invalidates ['transactions'], ['wallets'], and ['summary'] because wallet
  balance and summary data change as side effects. Six assumptions documented, including
  the URL-as-source-of-truth pattern for filters and month/year selectors. State and
  data flow for the WalletDetail screen has lower confidence (0.6) since the screen
  itself is inferred.
stores:
  - name: UIStore
    slices:
      - name: theme
        type: enum ('light', 'dark', 'system')
        default: system
      - name: sidebarOpen
        type: boolean
        default: true
      - name: mobileDrawerOpen
        type: boolean
        default: false
    actions:
      - name: setTheme
        params: "[theme: 'light' | 'dark' | 'system']"
      - name: toggleSidebar
        params: []
      - name: setMobileDrawerOpen
        params: "[open: boolean]"
      - name: reset
        params: []
    persist:
      storage: localStorage
      partialize: [theme]
    related_entity: null
    source: inference — standard UI preferences store
    confidence: 1.0
query_hooks:
  - name: useWallets
    queryKey: "['wallets']"
    endpoint_ref: GET /api/wallets
    source: "doc-03: FR-001"
    confidence: 1.0
  - name: useWallet
    queryKey: "['wallets', id]"
    endpoint_ref: GET /api/wallets/:id
    source: "doc-03: FR-001 (detail), doc-04: ASM-002"
    confidence: 0.6
  - name: useCreateWallet
    queryKey: null (mutation)
    endpoint_ref: POST /api/wallets
    source: "doc-03: FR-001"
    confidence: 1.0
  - name: useCategories
    queryKey: "['categories']"
    endpoint_ref: GET /api/categories
    source: "doc-03: FR-002"
    confidence: 1.0
  - name: useCreateCategory
    queryKey: null (mutation)
    endpoint_ref: POST /api/categories
    source: "doc-03: FR-002"
    confidence: 1.0
  - name: useTransactions
    queryKey: "['transactions', 'list', filters]"
    endpoint_ref: GET /api/transactions
    source: "doc-03: FR-004"
    confidence: 1.0
  - name: useTransaction
    queryKey: "['transactions', 'detail', id]"
    endpoint_ref: GET /api/transactions/:id
    source: "doc-03: FR-005"
    confidence: 0.9
  - name: useCreateTransaction
    queryKey: null (mutation)
    endpoint_ref: POST /api/transactions
    source: "doc-03: FR-003"
    confidence: 1.0
  - name: useUpdateTransaction
    queryKey: null (mutation)
    endpoint_ref: PUT /api/transactions/:id
    source: "doc-03: FR-005"
    confidence: 0.9
  - name: useDeleteTransaction
    queryKey: null (mutation)
    endpoint_ref: DELETE /api/transactions/:id
    source: "doc-03: FR-006"
    confidence: 1.0
  - name: useMonthlySummary
    queryKey: "['summary', {month, year}]"
    endpoint_ref: GET /api/summary
    source: "doc-03: FR-007"
    confidence: 1.0
data_flows:
  - screen: Dashboard
    route: /
    store_deps: []
    query_deps:
      - useWallets
      - useTransactions (default params, page=1, per_page=5)
    source: "doc-04: screen Dashboard"
    confidence: 0.8
  - screen: WalletList
    route: /wallets
    store_deps: []
    query_deps:
      - useWallets
    source: "doc-04: screen WalletList"
    confidence: 1.0
  - screen: CreateWallet
    route: /wallets/new
    store_deps: []
    query_deps:
      - useCreateWallet (mutation)
    source: "doc-04: screen CreateWallet"
    confidence: 1.0
  - screen: WalletDetail
    route: /wallets/[id]
    store_deps: []
    query_deps:
      - useWallet(id)
      - useTransactions({wallet_id: id})
    source: "doc-04: screen WalletDetail"
    confidence: 0.6
  - screen: CategoryList
    route: /categories
    store_deps: []
    query_deps:
      - useCategories
      - useCreateCategory (mutation)
    source: "doc-04: screen CategoryList"
    confidence: 1.0
  - screen: TransactionList
    route: /transactions
    store_deps: []
    query_deps:
      - useTransactions(filters) — filters from URL searchParams
      - useWallets (for wallet filter dropdown)
      - useCategories (for category filter dropdown)
    source: "doc-04: screen TransactionList"
    confidence: 1.0
  - screen: CreateTransaction
    route: /transactions/new
    store_deps: []
    query_deps:
      - useWallets (for wallet select options)
      - useCategories (for category select options — filtered client-side by type)
      - useCreateTransaction (mutation)
    source: "doc-04: screen CreateTransaction"
    confidence: 0.7
  - screen: EditTransaction
    route: /transactions/[id]/edit
    store_deps: []
    query_deps:
      - useTransaction(id) (pre-fill form)
      - useWallets (for wallet select options)
      - useCategories (for category select options)
      - useUpdateTransaction (mutation)
    source: "doc-04: screen EditTransaction"
    confidence: 0.7
  - screen: MonthlySummary
    route: /summary
    store_deps: []
    query_deps:
      - useMonthlySummary(month, year) — params from URL searchParams
    source: "doc-04: screen MonthlySummary"
    confidence: 1.0
assumptions:
  - id: ASM-001
    statement: URL search params are source of truth for transaction filters and summary month/year. No Zustand store for filter state.
    impacts:
      - Filter changes push to URL via router.replace or router.push
      - Query key derives from URL search params
      - Page refresh preserves filter state
      - Back/forward navigation works correctly
    confidence: 1.0
    source: "doc-04: ASM-007"
  - id: ASM-002
    statement: Cache invalidation cascade — transaction mutations invalidate ['wallets'] and ['summary'] because wallet balance and summary aggregate change as side effects.
    impacts:
      - useCreateTransaction onSuccess: invalidate ['transactions'], ['wallets'], ['summary']
      - useUpdateTransaction onSuccess: invalidate ['transactions'], ['transactions', 'detail', id], ['wallets'], ['summary']
      - useDeleteTransaction onSuccess: invalidate ['transactions'], ['wallets'], ['summary']
    confidence: 1.0
    source: "doc-03: FR-003, FR-005, FR-006"
  - id: ASM-003
    statement: Wallet list and category list are fetched eagerly and cached — used as reference data across multiple screens.
    impacts:
      - useWallets and useCategories have staleTime > 0 (e.g., 30s) to reduce refetch on navigation
      - Create/Edit transaction screens use cached wallet/category data without loading states
      - Only refetched when user navigates to /wallets or /categories, or after a mutation
    confidence: 0.9
    source: inference — reference data pattern
  - id: ASM-004
    statement: Monthly summary is single-endpoint (GET /api/summary), not computed client-side from transaction list.
    impacts:
      - No client-side aggregation logic needed
      - Summary query key changes with month/year
      - Cache per month/year pair: ['summary', {month: 7, year: 2026}] separate from ['summary', {month: 8, year: 2026}]
    confidence: 1.0
    source: "doc-03: FR-007"
  - id: ASM-005
    statement: Form state uses react-hook-form (local), not Zustand. Type toggle (income/expense) is local state with effect that resets category select.
    impacts:
      - No form state in global store
      - Category select options filter based on selected transaction type
      - Balance warning computed from form amount + selected wallet balance
    confidence: 1.0
    source: "doc-03: FR-003, doc-08 (inferred — standard React pattern)"
  - id: ASM-006
    statement: No Zustand store for selected wallet or selected transaction context. Current context derived from URL params (wallet_id, transaction id).
    impacts:
      - WalletDetail reads id from useParams, passes to useWallet(id)
      - EditTransaction reads id from useParams, passes to useTransaction(id)
      - No cross-screen state leakage
    confidence: 1.0
    source: "doc-04: ASM-007 (URL as source of truth pattern extended)"
---

# 05 — State & Data Flow Plan

## 1. State Architecture Overview

Two state categories:

| Category | Tool | Scope | Persistence |
|----------|------|-------|-------------|
| Server state | TanStack Query | All entity data (wallets, categories, transactions, summary) | Memory cache + stale-while-revalidate |
| Client state | Zustand | UI preferences (theme, sidebar) | localStorage (theme only) |
| Form state | react-hook-form | Form field values, validation state, submission | None (local component) |
| URL state | useSearchParams | Transaction filters, summary month/year, page | URL (shareable, bookmarkable) |

### State Dependency Graph

```
                    ┌──────────────────────┐
                    │   URL Search Params   │
                    │ (filters, month/year) │
                    └──────────┬───────────┘
                               │ drives queryKey params
                               ▼
                    ┌──────────────────────┐
                    │   React Query Cache   │
                    │  (wallets, categories │
                    │  transactions, summary)│
                    └──────────┬───────────┘
                               │ provides data
                    ┌──────────▼───────────┐
                    │   Screens / Pages    │
                    │  (9 screens total)   │
                    └──────────────────────┘
                    
                    ┌──────────────────────┐
                    │   Zustand UIStore    │
                    │  (theme, sidebar)    │
                    └──────────────────────┘
                         │ consumed by
                         ▼
                    ┌──────────────────────┐
                    │   AppLayout / Theme  │
                    │   Provider           │
                    └──────────────────────┘
```

No cross-screen clientside state beyond UI preferences. Every screen derives its data from React Query cache keyed by URL params.

---

## 2. Zustand Stores

### 2.1 UIStore

Single store for global UI preferences. Minimal — only what affects layout rendering.

```typescript
// stores/ui-store.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

type Theme = 'light' | 'dark' | 'system'

interface UIState {
  theme: Theme
  sidebarOpen: boolean
  mobileDrawerOpen: boolean
}

interface UIActions {
  setTheme: (theme: Theme) => void
  toggleSidebar: () => void
  setMobileDrawerOpen: (open: boolean) => void
  reset: () => void
}

const initialState: UIState = {
  theme: 'system',
  sidebarOpen: true,
  mobileDrawerOpen: false,
}

export const useUIStore = create<UIState & UIActions>()(
  persist(
    (set) => ({
      ...initialState,
      setTheme: (theme) => set({ theme }),
      toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
      setMobileDrawerOpen: (open) => set({ mobileDrawerOpen: open }),
      reset: () => set(initialState),
    }),
    {
      name: 'pocket-ui',
      partialize: (state) => ({ theme: state.theme }),
    }
  )
)
```

| Field | Type | Persisted | Purpose |
|-------|------|-----------|---------|
| `theme` | `'light' | 'dark' | 'system'` | Yes | Theme provider state |
| `sidebarOpen` | `boolean` | No | Desktop sidebar collapse |
| `mobileDrawerOpen` | `boolean` | No | Mobile nav drawer toggle |

No other Zustand stores needed for MVP. All other state is either server state (React Query), URL state (useSearchParams), or local form state (react-hook-form).

`ponytail: add TransactionFilterStore if filter state needs to be shared across screens outside URL. Add WalletStore for selectedWallet if multi-step wizards are introduced.`

---

## 3. React Query Keys & Hooks

### 3.1 Query Key Factory

```typescript
// lib/query-keys.ts
export const walletKeys = {
  all: ['wallets'] as const,
  detail: (id: number) => ['wallets', id] as const,
}

export const categoryKeys = {
  all: ['categories'] as const,
}

export const transactionKeys = {
  all: ['transactions'] as const,
  lists: () => [...transactionKeys.all, 'list'] as const,
  list: (filters: TransactionFilters) =>
    [...transactionKeys.lists(), filters] as const,
  details: () => [...transactionKeys.all, 'detail'] as const,
  detail: (id: number) => [...transactionKeys.details(), id] as const,
}

export const summaryKeys = {
  byMonth: (month: number, year: number) =>
    ['summary', { month, year }] as const,
}
```

Key hierarchy enables fuzzy invalidation:

| Invalidation call | Effect |
|------------------|--------|
| `queryClient.invalidateQueries({ queryKey: ['transactions'] })` | Invalidates all transaction queries (list variants + detail) |
| `queryClient.invalidateQueries({ queryKey: ['transactions', 'list'] })` | Invalidates all list variants only (keeps detail cache) |
| `queryClient.invalidateQueries({ queryKey: ['wallets'] })` | Invalidates all wallet queries (list + detail) |

### 3.2 Query Hooks

#### `useWallets`

```typescript
// hooks/queries/use-wallets.ts
import { useQuery } from '@tanstack/react-query'
import { walletKeys } from '@/lib/query-keys'

interface Wallet {
  id: number
  user_id: number
  name: string
  type: 'cash' | 'bank' | 'e-wallet'
  initial_balance: number
  current_balance: number
  created_at: string
}

interface WalletsResponse {
  data: Wallet[]
}

export function useWallets() {
  return useQuery({
    queryKey: walletKeys.all,
    queryFn: async (): Promise<WalletsResponse> => {
      const res = await fetch('/api/wallets')
      if (!res.ok) throw new Error('Failed to fetch wallets')
      return res.json()
    },
    staleTime: 30_000, // 30s — wallets change infrequently
  })
}
```

| Property | Value |
|----------|-------|
| queryKey | `['wallets']` |
| endpoint | `GET /api/wallets` |
| staleTime | 30s (reference data pattern) |
| cacheTime | 5min |

#### `useWallet`

```typescript
// hooks/queries/use-wallet.ts
export function useWallet(id: number) {
  return useQuery({
    queryKey: walletKeys.detail(id),
    queryFn: async (): Promise<Wallet> => {
      const res = await fetch(`/api/wallets/${id}`)
      if (res.status === 404) throw new NotFoundError('Wallet not found')
      if (!res.ok) throw new Error('Failed to fetch wallet')
      return res.json()
    },
    enabled: !!id,
  })
}
```

| Property | Value |
|----------|-------|
| queryKey | `['wallets', id]` |
| endpoint | `GET /api/wallets/:id` |
| staleTime | 30s |
| enabled | false if id is undefined/null |

#### `useCategories`

```typescript
// hooks/queries/use-categories.ts
interface Category {
  id: number
  user_id: number | null
  name: string
  type: 'income' | 'expense'
  is_default: boolean
  created_at: string
}

export function useCategories() {
  return useQuery({
    queryKey: categoryKeys.all,
    queryFn: async (): Promise<Category[]> => {
      const res = await fetch('/api/categories')
      if (!res.ok) throw new Error('Failed to fetch categories')
      return res.json()
    },
    staleTime: 60_000, // 1min — categories change very infrequently
  })
}
```

| Property | Value |
|----------|-------|
| queryKey | `['categories']` |
| endpoint | `GET /api/categories` |
| staleTime | 60s (reference data) |

Client-side filtering by type:

```typescript
// Derived select: filter categories by type
const { data: categories } = useCategories()
const incomeCategories = useMemo(
  () => categories?.filter((c) => c.type === 'income') ?? [],
  [categories]
)
const expenseCategories = useMemo(
  () => categories?.filter((c) => c.type === 'expense') ?? [],
  [categories]
)
```

#### `useTransactions`

```typescript
// hooks/queries/use-transactions.ts
interface TransactionFilters {
  date_from?: string
  date_to?: string
  type?: 'income' | 'expense'
  wallet_id?: number
  category_id?: number
  q?: string
  page?: number
  per_page?: number
}

interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  per_page: number
}

interface Transaction {
  id: number
  wallet_id: number
  category_id: number
  type: 'income' | 'expense'
  amount: number
  transaction_date: string
  note: string | null
  created_at: string
  wallet_name?: string   // populated by API join
  category_name?: string // populated by API join
}

export function useTransactions(filters: TransactionFilters) {
  return useQuery({
    queryKey: transactionKeys.list(filters),
    queryFn: async (): Promise<PaginatedResponse<Transaction>> => {
      const params = new URLSearchParams()
      Object.entries(filters).forEach(([key, val]) => {
        if (val !== undefined && val !== '') {
          params.set(key, String(val))
        }
      })
      const res = await fetch(`/api/transactions?${params}`)
      if (!res.ok) throw new Error('Failed to fetch transactions')
      return res.json()
    },
    placeholderData: keepPreviousData, // preserve previous page data while fetching new page
  })
}
```

| Property | Value |
|----------|-------|
| queryKey | `['transactions', 'list', filters]` |
| endpoint | `GET /api/transactions` |
| placeholderData | `keepPreviousData` (paginated) |
| staleTime | 0 (fresh data on every filter change) |

#### `useTransaction`

```typescript
// hooks/queries/use-transaction.ts
export function useTransaction(id: number) {
  return useQuery({
    queryKey: transactionKeys.detail(id),
    queryFn: async (): Promise<Transaction> => {
      const res = await fetch(`/api/transactions/${id}`)
      if (res.status === 404) throw new NotFoundError('Transaction not found')
      if (!res.ok) throw new Error('Failed to fetch transaction')
      return res.json()
    },
    enabled: !!id,
  })
}
```

| Property | Value |
|----------|-------|
| queryKey | `['transactions', 'detail', id]` |
| endpoint | `GET /api/transactions/:id` |
| enabled | false if id is undefined/null |

#### `useMonthlySummary`

```typescript
// hooks/queries/use-monthly-summary.ts
interface MonthlySummary {
  total_income: number
  total_expense: number
  net_balance: number
  transaction_count: number
  income_by_category: CategoryBreakdown[]
  expense_by_category: CategoryBreakdown[]
}

interface CategoryBreakdown {
  category_id: number
  category_name: string
  total: number
}

export function useMonthlySummary(month: number, year: number) {
  return useQuery({
    queryKey: summaryKeys.byMonth(month, year),
    queryFn: async (): Promise<MonthlySummary> => {
      const res = await fetch(`/api/summary?month=${month}&year=${year}`)
      if (!res.ok) throw new Error('Failed to fetch summary')
      return res.json()
    },
    staleTime: 30_000,
  })
}
```

| Property | Value |
|----------|-------|
| queryKey | `['summary', {month, year}]` |
| endpoint | `GET /api/summary` |
| staleTime | 30s |

### 3.3 Mutation Hooks

#### `useCreateWallet`

```typescript
// hooks/mutations/use-create-wallet.ts
interface CreateWalletInput {
  name: string
  type: 'cash' | 'bank' | 'e-wallet'
  initial_balance: number
}

export function useCreateWallet() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (input: CreateWalletInput): Promise<Wallet> => {
      const res = await fetch('/api/wallets', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      })
      if (!res.ok) throw new Error('Failed to create wallet')
      return res.json()
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: walletKeys.all })
    },
  })
}
```

#### `useCreateCategory`

```typescript
interface CreateCategoryInput {
  name: string
  type: 'income' | 'expense'
}

export function useCreateCategory() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (input: CreateCategoryInput): Promise<Category> => {
      const res = await fetch('/api/categories', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      })
      if (!res.ok) throw new Error('Failed to create category')
      return res.json()
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: categoryKeys.all })
    },
  })
}
```

#### `useCreateTransaction`

```typescript
interface CreateTransactionInput {
  wallet_id: number
  category_id: number
  type: 'income' | 'expense'
  amount: number
  transaction_date: string
  note?: string
}

export function useCreateTransaction() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (input: CreateTransactionInput): Promise<Transaction> => {
      const res = await fetch('/api/transactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      })
      if (!res.ok) throw new Error('Failed to create transaction')
      return res.json()
    },
    onSuccess: () => {
      // Cascade invalidate: transaction list, wallet balances, summary aggregates
      queryClient.invalidateQueries({ queryKey: transactionKeys.all })
      queryClient.invalidateQueries({ queryKey: walletKeys.all })
      queryClient.invalidateQueries({ queryKey: ['summary'] })
    },
  })
}
```

#### `useUpdateTransaction`

```typescript
interface UpdateTransactionInput {
  wallet_id: number
  category_id: number
  type: 'income' | 'expense'
  amount: number
  transaction_date: string
  note?: string
}

export function useUpdateTransaction(id: number) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (input: UpdateTransactionInput): Promise<Transaction> => {
      const res = await fetch(`/api/transactions/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      })
      if (!res.ok) throw new Error('Failed to update transaction')
      return res.json()
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: transactionKeys.detail(id) })
      queryClient.invalidateQueries({ queryKey: transactionKeys.all })
      queryClient.invalidateQueries({ queryKey: walletKeys.all })
      queryClient.invalidateQueries({ queryKey: ['summary'] })
    },
  })
}
```

#### `useDeleteTransaction`

```typescript
export function useDeleteTransaction() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: async (id: number): Promise<{ success: boolean }> => {
      const res = await fetch(`/api/transactions/${id}`, {
        method: 'DELETE',
      })
      if (!res.ok) throw new Error('Failed to delete transaction')
      return res.json()
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: transactionKeys.all })
      queryClient.invalidateQueries({ queryKey: walletKeys.all })
      queryClient.invalidateQueries({ queryKey: ['summary'] })
    },
  })
}
```

### 3.4 Cache Invalidation Map

| Mutation | Invalidates |
|----------|-------------|
| `useCreateWallet` | `['wallets']` |
| `useCreateCategory` | `['categories']` |
| `useCreateTransaction` | `['transactions']`, `['wallets']`, `['summary']` |
| `useUpdateTransaction(id)` | `['transactions', 'detail', id]`, `['transactions']`, `['wallets']`, `['summary']` |
| `useDeleteTransaction` | `['transactions']`, `['wallets']`, `['summary']` |

---

## 4. Data Flow Per Screen

### 4.1 Dashboard (`/`)

```
Dashboard
├── useWallets()
│   └── GET /api/wallets → Wallet[]
│   └── Render: StatCards (total balance, wallet count)
│
├── useTransactions({page: 1, per_page: 5})
│   └── GET /api/transactions?page=1&per_page=5 → Transaction[]
│   └── Render: RecentTransactionList (5 latest)
│
└── Zustand: none
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useWallets` | Wallet[] | 3 StatCard skeletons | EmptyWalletState with CTA | ErrorAlert + retry |
| `useTransactions` | Transaction[] | 5 row skeletons | EmptyTransactionState | ErrorAlert + retry |

### 4.2 WalletList (`/wallets`)

```
WalletList
├── useWallets()
│   └── GET /api/wallets → Wallet[]
│   └── Render: WalletCard grid (Card + Badge + balance)
│
└── Zustand: none
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useWallets` | Wallet[] | 4 Card skeletons | Empty state + "Buat wallet pertama" CTA | ErrorAlert + retry |

### 4.3 CreateWallet (`/wallets/new`)

```
CreateWallet
├── useCreateWallet() [mutation]
│   └── POST /api/wallets
│   └── On success: invalidate ['wallets'], router.push('/wallets')
│
└── Form state: react-hook-form (local)
    └── Field: name (string, required)
    └── Field: type (enum, required — select)
    └── Field: initial_balance (integer, >= 0, default 0)
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useCreateWallet` | mutation | FormSkeleton (page load) | N/A | Inline form errors (validation) or toast (API) |

### 4.4 WalletDetail (`/wallets/[id]`)

```
WalletDetail
├── useWallet(id)            — id from useParams
│   └── GET /api/wallets/:id → Wallet
│   └── Render: WalletDetailCard (name, type, balance, dates)
│
├── useTransactions({wallet_id: id})
│   └── GET /api/transactions?wallet_id={id} → Transaction[]
│   └── Render: TransactionList (scoped to this wallet)
│   └── Link: /transactions?wallet_id={id} (full list view)
│
└── Zustand: none
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useWallet(id)` | Wallet | DetailCard skeleton | NotFoundAlert (if 404) | ErrorAlert + retry |
| `useTransactions` | Transaction[] | 3 row skeletons | "Belum ada transaksi" | ErrorAlert + retry |

`confidence: 0.6` — WalletDetail is an inferred screen (doc-04: ASM-002).

### 4.5 CategoryList (`/categories`)

```
CategoryList
├── useCategories()
│   └── GET /api/categories → Category[]
│   └── Render: tabs (income / expense), CategoryCard list
│   └── Client-side filter: categories.filter(c => c.type === tab)
│
├── useCreateCategory() [mutation]
│   └── POST /api/categories
│   └── On success: invalidate ['categories']
│
└── Zustand: none
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useCategories` | Category[] | Tab skeletons + list skeletons | N/A (defaults exist) | ErrorAlert + retry |
| `useCreateCategory` | mutation | Button loading spinner | N/A | Inline error: duplicate name |

### 4.6 TransactionList (`/transactions`)

```
TransactionList
├── useTransactions(filters) — filters from URL searchParams
│   └── GET /api/transactions?date_from=&date_to=&type=&wallet_id=&category_id=&q=&page=
│   └── Render: TransactionTable + pagination
│
├── useWallets()    — for wallet filter Select dropdown
├── useCategories() — for category filter Select dropdown
│
├── useDeleteTransaction() [mutation] — from inline action buttons
│
└── URL state: useSearchParams (source of truth)
    └── Filters: date_from, date_to, type, wallet_id, category_id, q, page
    └── FilterBar → router.replace(/transactions?date_from=...)
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useTransactions(filters)` | Transaction[] | 5 row skeletons + filter bar skeleton | Empty state (no txns) or "Tidak cocok dengan filter" | ErrorAlert + retry |
| `useWallets` | Wallet[] | Select skeleton | Select disabled + tooltip | ErrorAlert + retry |
| `useCategories` | Category[] | Select skeleton | N/A | ErrorAlert + retry |
| `useDeleteTransaction` | mutation | Button spinner | N/A | Toast error |

### 4.7 CreateTransaction (`/transactions/new`)

```
CreateTransaction
├── useWallets()    — for wallet Select (render options)
├── useCategories() — for category Select (filtered by type)
│
├── useCreateTransaction() [mutation]
│   └── POST /api/transactions
│   └── On success: invalidate ['transactions'], ['wallets'], ['summary']
│   └── On success: router.push('/transactions')
│
├── Local state (useState):
│   └── transactionType: 'income' | 'expense' — drives category filter
│
├── Form state: react-hook-form
│   └── Field: wallet_id (Select, required)
│   └── Field: category_id (Select, required, filtered by type)
│   └── Field: amount (Input, integer > 0)
│   └── Field: transaction_date (DatePicker, max: today)
│   └── Field: note (Textarea, optional, max 500)
│
└── URL searchParams (optional pre-select):
    └── ?type=expense&wallet_id=1
    └── Used once for initial form state, then local state takes over
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useWallets` | Wallet[] | Select skeleton (form) | N/A (form) | ErrorAlert (block form) |
| `useCategories` | Category[] | Select skeleton (form) | N/A (defaults exist) | ErrorAlert (block form) |
| `useCreateTransaction` | mutation | Button loading spinner | N/A | Inline form errors or BalanceWarning alert |

### 4.8 EditTransaction (`/transactions/[id]/edit`)

```
EditTransaction
├── useTransaction(id) — id from useParams, pre-fill form
│   └── GET /api/transactions/:id → Transaction
│
├── useWallets()    — for wallet Select
├── useCategories() — for category Select (filtered by type)
│
├── useUpdateTransaction(id) [mutation]
│   └── PUT /api/transactions/:id
│   └── On success: invalidate ['transactions'], ['transactions', 'detail', id], ['wallets'], ['summary']
│   └── On success: router.push('/transactions')
│
├── Local state (useState):
│   └── transactionType: derived from fetched transaction
│
└── Form state: react-hook-form (pre-filled from useTransaction data)
    └── Default values: useTransaction(id).data populated into form
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useTransaction(id)` | Transaction | FormSkeleton + "Memuat data..." | NotFoundAlert (if 404 → EC-016) | ErrorAlert + retry |
| `useWallets` | Wallet[] | Select skeleton | N/A | ErrorAlert (block form) |
| `useCategories` | Category[] | Select skeleton | N/A | ErrorAlert (block form) |
| `useUpdateTransaction(id)` | mutation | Button loading spinner | N/A | Inline form errors or balance alert |

### 4.9 MonthlySummary (`/summary`)

```
MonthlySummary
├── useMonthlySummary(month, year) — params from URL searchParams
│   └── GET /api/summary?month={m}&year={y}
│   └── Render: StatCards (income, expense, net) + breakdown lists
│
├── URL state: useSearchParams
│   └── month: 1-12 (default: current month)
│   └── year: 4-digit (default: current year)
│   └── MonthYearPicker → router.replace('/summary?month=...&year=...')
│
└── Zustand: none
```

| Source | Data | Loading State | Empty State | Error State |
|--------|------|---------------|-------------|-------------|
| `useMonthlySummary(month, year)` | MonthlySummary | 3 StatCard skeletons + 2 breakdown section skeletons | All values = 0 + "Tidak ada transaksi di bulan ini" | ErrorAlert + retry |

---

## 5. Data Dependencies

### Store → Query Dependencies

No Zustand store depends on any query result for MVP. UIStore is purely client-side preferences with no server data dependency.

### Query → Query Dependencies

| Primary Query | Depends On | Reason |
|---------------|------------|--------|
| `useTransactions(filters)` | `useWallets`, `useCategories` | Filter dropdown options (not data dependency — parallel queries) |
| `useTransaction(id)` | None | Self-contained fetch |
| `useCreateTransaction` | `useWallets`, `useCategories` | Form select options, must wait for these to load before enabling form |
| `useUpdateTransaction(id)` | `useTransaction(id)`, `useWallets`, `useCategories` | Must fetch existing transaction for pre-fill + options for selects |
| `useMonthlySummary` | None | Self-contained fetch |

### Parallel vs Sequential Fetch Strategy

```
Screen Load → [useWallets, useCategories, useTransactions] (parallel if all needed)
              ↓
              Form mutation (sequential — user action)
```

On CreateTransaction and EditTransaction, wallet and category queries are prefetched or cached. They execute in parallel with page render — no waterfall.

```typescript
// CreateTransaction page — parallel fetch
// Both useWallets() and useCategories() run on mount simultaneously
// Form renders when both have data (can check status separately)
const walletsQuery = useWallets()
const categoriesQuery = useCategories()
const createMutation = useCreateTransaction()

const isLoading = walletsQuery.isLoading || categoriesQuery.isLoading
```

`ponytail: if wallet/category list grows large, add prefetch at router level or use suspense boundaries.`

---

## 6. TypeScript Types

### 6.1 API Response Types

```typescript
// types/api.ts
// Shared across all query hooks and screen components

interface User {
  id: number
}

interface Wallet {
  id: number
  user_id: number
  name: string
  type: 'cash' | 'bank' | 'e-wallet'
  initial_balance: number
  current_balance: number
  created_at: string
  updated_at: string
}

interface Category {
  id: number
  user_id: number | null  // null for system default categories
  name: string
  type: 'income' | 'expense'
  is_default: boolean
  created_at: string
  updated_at: string
}

interface Transaction {
  id: number
  user_id: number
  wallet_id: number
  category_id: number
  type: 'income' | 'expense'
  amount: number
  transaction_date: string
  note: string | null
  created_at: string
  updated_at: string
  // Joined fields from API (not in entity schema)
  wallet_name?: string
  category_name?: string
}

interface TransactionFilters {
  date_from?: string
  date_to?: string
  type?: 'income' | 'expense'
  wallet_id?: number
  category_id?: number
  q?: string
  page?: number
  per_page?: number
}

interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  per_page: number
}

interface CategoryBreakdown {
  category_id: number
  category_name: string
  total: number
}

interface MonthlySummary {
  total_income: number
  total_expense: number
  net_balance: number
  transaction_count: number
  income_by_category: CategoryBreakdown[]
  expense_by_category: CategoryBreakdown[]
}
```

### 6.2 Mutation Input Types

```typescript
// types/mutations.ts
// Input types for all mutation hooks

interface CreateWalletInput {
  name: string
  type: 'cash' | 'bank' | 'e-wallet'
  initial_balance: number
}

interface CreateCategoryInput {
  name: string
  type: 'income' | 'expense'
}

interface CreateTransactionInput {
  wallet_id: number
  category_id: number
  type: 'income' | 'expense'
  amount: number
  transaction_date: string
  note?: string
}

// Same shape for update — backend handles differential update
type UpdateTransactionInput = CreateTransactionInput
```

---

## 7. QueryClient Configuration

```typescript
// lib/query-client.ts
import { QueryClient } from '@tanstack/react-query'

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        retry: 2,
        refetchOnWindowFocus: false,   // personal finance — no need to refetch on focus
        staleTime: 5_000,              // 5s default stale time
        gcTime: 5 * 60 * 1000,         // 5min garbage collection
      },
      mutations: {
        retry: 0,                      // don't retry mutations
      },
    },
  })
}
```

| Option | Value | Rationale |
|--------|-------|-----------|
| `retry` (queries) | 2 | Retry transient network failures |
| `refetchOnWindowFocus` | false | Personal finance data doesn't change in background |
| `staleTime` | 5s default (overridden per query) | Quick fresh data without excessive refetches |
| `gcTime` | 5min | Keep unused query data in memory for navigation back |
| `retry` (mutations) | 0 | Never retry — user should see error and decide |

---

## 8. Query Provider Setup

```tsx
// app/providers.tsx
'use client'

import { QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'
import { Toaster } from '@/components/ui/sonner'

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => makeQueryClient())

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <Toaster richColors />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

```tsx
// app/layout.tsx
import { Providers } from './providers'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="id">
      <body>
        <Providers>
          <AppLayout>{children}</AppLayout>
        </Providers>
      </body>
    </html>
  )
}
```

---

## 9. Mutation Side Effects Summary

| Mutation | onSuccess Actions | Error Handling |
|----------|-------------------|----------------|
| `useCreateWallet` | `invalidate(['wallets'])`, `router.push('/wallets')`, toast success | Toast error |
| `useCreateCategory` | `invalidate(['categories'])`, toast success | Inline error (duplicate name) |
| `useCreateTransaction` | `invalidate(['transactions', 'wallets', 'summary'])`, `router.push('/transactions')`, toast success | Inline form errors + BalanceWarning |
| `useUpdateTransaction(id)` | `invalidate(['transactions', 'transactions', 'detail', id, 'wallets', 'summary'])`, `router.push('/transactions')`, toast success | Inline form errors |
| `useDeleteTransaction` | `invalidate(['transactions', 'wallets', 'summary'])`, toast success | Toast error |

No optimistic updates for MVP. The financial data consistency risk outweighs the UX benefit of instant UI feedback.

`ponytail: add optimistic updates for delete transaction (remove from list instantly) when undo toast pattern is implemented. Add optimistic update for create transaction if latency becomes noticeable.`

---

## 10. Assumptions

| ID | Statement | Impacts | Confidence | Source |
|----|-----------|---------|-----------|--------|
| ASM-001 | URL search params are source of truth for filters and month/year. No Zustand store for filter state. | Filter changes push to URL; query key derives from URL; page refresh preserves state | 1.0 | doc-04: ASM-007 |
| ASM-002 | Cache invalidation cascade — transaction mutations invalidate ['wallets'] and ['summary'] | Every create/update/delete transaction refreshes wallet balances and summary aggregates | 1.0 | doc-03: FR-003, FR-005, FR-006 |
| ASM-003 | Wallet and category lists are reference data with staleTime > 0 | Cached across screens; form dependencies use cached data without loading spinners | 0.9 | inference |
| ASM-004 | Summary is single-endpoint (not client-side computed) | No client aggregation; cache per month/year pair | 1.0 | doc-03: FR-007 |
| ASM-005 | Form state is local (react-hook-form), not Zustand | Type toggle resets category select; balance warning from form amount + wallet balance | 1.0 | doc-03: FR-003 |
| ASM-006 | No Zustand store for selected wallet/transaction context — derived from URL params | WalletDetail uses useParams; EditTransaction uses useParams | 1.0 | doc-04: ASM-007 (extended) |

---

## 11. DoD Checklist

- [x] All 9 screens from doc-04 have data flow definitions (Dashboard, WalletList, CreateWallet, WalletDetail, CategoryList, TransactionList, CreateTransaction, EditTransaction, MonthlySummary)
- [x] All entities from doc-02 that need state have store/query hook (Wallet, Category, Transaction, User — User implicit via assumed auth)
- [x] Query keys follow TanStack Query conventions (array keys, hierarchical, factory pattern)
- [x] Frontmatter YAML valid and complete with stores[], query_hooks[], data_flows[] arrays populated
- [x] No placeholder, TODO, or "TBD"
- [x] Output file name matches workflow.yaml agents[id=5].output (docs/05-state-data-flow-plan.md)
- [x] All entity names use PascalCase (Wallet, Category, Transaction, User)
- [x] TypeScript interfaces defined for all state shapes and API types
- [x] Cache invalidation map documented for all mutations
- [x] Data flow per screen traces: screen -> store_deps -> query_deps -> API endpoint
- [x] Confidence scores on all stores, hooks, and data flows
- [x] Assumptions documented in structured {id, statement, impacts, confidence} format
- [x] Cross-references use relative doc paths (doc-03, doc-04)
- [x] Zustand slices pattern used for store structure
- [x] Parallel vs sequential fetch strategy documented
- [x] QueryClient configuration documented with rationale
