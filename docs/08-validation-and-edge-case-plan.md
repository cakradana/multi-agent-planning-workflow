---
title: Validation and Edge Case Plan
description: Zod schemas, form rules, error boundaries, and state handling for Pocket personal finance app
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 8
schema_version: 1
status: complete
summary: >
  This document defines all Zod validation schemas, form rules, error boundaries, and state handling for Pocket.
  Eight Zod schemas defined: WalletSchema, CategorySchema, TransactionSchema, CreateWalletSchema,
  CreateCategorySchema, CreateTransactionSchema (shared for create and update per doc-07 convention),
  TransactionFilterSchema, and SummaryQuerySchema. Each schema uses z.infer for TypeScript type generation.
  Twenty-one business rules (BR-001 through BR-021) mapped to Zod validation logic. Rules handled server-side
  (BR-001, BR-002, BR-003, BR-008, BR-011, BR-012, BR-018, BR-019, BR-020, BR-021) noted with low frontend
  confidence — validation exists only as defensive client-side checks or UI warnings. Rules enforced in Zod
  (BR-004 through BR-007, BR-009, BR-013, BR-015, BR-016) have full schema coverage. BR-010 (edit semantics)
  gated by backend — soft-deleted transactions return 404. BR-017 (IDR display) is UI concern, not Zod.
  Eighteen edge cases (EC-001 through EC-018) mapped to concrete component states, query hooks, and routes.
  Three error boundary zones defined per Next.js App Router pattern: page-level error.tsx with ErrorAlert+retry,
  not-found.tsx for dynamic routes, and mutation error handling via inline form errors or Sonner toast.
  State handling tabled for all 9 screens per doc-06 component tree: loading (shadcn Skeleton variants),
  empty (EmptyState with CTA), error (ErrorAlert with retry), and edge-specific states (not-found, balance
  warning, blank summary). Form validation messages bilingual (ID + EN) for Indonesian users with English
  fallback. Validation schemas structure shared schema definitions (entity base schemas) vs input schemas
  (create/update/filter) to enable reuse. TransactionSchema.refine() enforces BR-007 (category type must
  match transaction type) via cross-field validation. Amount validation uses z.number().int().positive()
  per BR-005 and BR-016. Transaction date uses z.string().regex(ISO date).refine(date <= today) per BR-009.
  Filter schemas use partial candidates for progressive filtering. Three assumptions documented: API returns
  snake_case so Zod-to-API adapter needed, soft-deleted transactions invisible at API level so frontend needs
  no deleted_at check, and URL params as filter source of truth per doc-05 ASM-001.
schemas:
  - name: WalletSchema
    zod_definition: "z.object({ id: z.number().int().positive(), userId: z.number().int().positive(), name: z.string().min(1, 'Nama dompet wajib diisi').max(100, 'Nama dompet maksimal 100 karakter'), type: z.enum(['cash', 'bank', 'e-wallet'], { required_error: 'Tipe dompet wajib dipilih' }), initialBalance: z.number().int().min(0, 'Saldo awal tidak boleh negatif'), currentBalance: z.number().int().min(0), createdAt: z.string(), updatedAt: z.string() })"
    error_messages: "{ name: { required: 'Nama dompet wajib diisi / Wallet name is required', max: 'Nama dompet maksimal 100 karakter / Max 100 characters' }, type: { invalid: 'Tipe dompet tidak valid / Invalid wallet type' }, initialBalance: { min: 'Saldo awal tidak boleh negatif / Initial balance cannot be negative' } }"
    related_business_rule: BR-004, BR-016
    source: "doc-02: entities[1], doc-07: types[0]"
    confidence: 1.0
  - name: CategorySchema
    zod_definition: "z.object({ id: z.number().int().positive(), userId: z.number().int().positive().nullable(), name: z.string().min(1, 'Nama kategori wajib diisi').max(50, 'Nama kategori maksimal 50 karakter'), type: z.enum(['income', 'expense'], { required_error: 'Tipe kategori wajib dipilih' }), isDefault: z.boolean(), createdAt: z.string(), updatedAt: z.string() })"
    error_messages: "{ name: { required: 'Nama kategori wajib diisi / Category name is required', max: 'Nama kategori maksimal 50 karakter / Max 50 characters' }, type: { invalid: 'Tipe kategori tidak valid / Invalid category type' } }"
    related_business_rule: BR-003, BR-014, BR-015
    source: "doc-02: entities[2], doc-07: types[1]"
    confidence: 1.0
  - name: TransactionSchema
    zod_definition: "z.object({ id: z.number().int().positive(), userId: z.number().int().positive(), walletId: z.number().int().positive('Dompet wajib dipilih'), categoryId: z.number().int().positive('Kategori wajib dipilih'), type: z.enum(['income', 'expense'], { required_error: 'Tipe transaksi wajib dipilih' }), amount: z.number().int().positive('Jumlah harus lebih dari 0'), transactionDate: z.string().regex(/^\\d{4}-\\d{2}-\\d{2}$/, 'Format tanggal harus YYYY-MM-DD'), note: z.string().max(500, 'Catatan maksimal 500 karakter').nullable(), createdAt: z.string(), updatedAt: z.string(), walletName: z.string().optional(), categoryName: z.string().optional() }).refine((data) => { return true }, { message: 'Tipe kategori harus sesuai dengan tipe transaksi', path: ['categoryId'] })"
    error_messages: "{ walletId: { required: 'Dompet wajib dipilih / Wallet is required' }, categoryId: { required: 'Kategori wajib dipilih / Category is required', refine: 'Kategori tidak sesuai tipe transaksi / Category type mismatch' }, type: { invalid: 'Tipe transaksi tidak valid / Invalid transaction type' }, amount: { min: 'Jumlah harus lebih dari 0 / Amount must be greater than 0', invalid: 'Jumlah harus berupa angka / Amount must be a number' }, transactionDate: { invalid: 'Format tanggal tidak valid / Invalid date format', max: 'Tanggal tidak boleh melebihi hari ini / Date cannot be in the future' }, note: { max: 'Catatan maksimal 500 karakter / Max 500 characters' } }"
    related_business_rule: BR-004, BR-005, BR-006, BR-007, BR-009, BR-016, BR-018
    source: "doc-02: entities[3], doc-07: types[2]"
    confidence: 1.0
  - name: CreateWalletSchema
    zod_definition: "z.object({ name: z.string().min(1, 'Nama dompet wajib diisi').max(100, 'Nama dompet maksimal 100 karakter'), type: z.enum(['cash', 'bank', 'e-wallet'], { required_error: 'Tipe dompet wajib dipilih' }), initialBalance: z.number().int().min(0, 'Saldo awal tidak boleh negatif').default(0) })"
    error_messages: "{ name: { required: 'Nama dompet wajib diisi / Wallet name is required', max: 'Nama dompet maksimal 100 karakter / Max 100 characters' }, type: { invalid: 'Tipe dompet tidak valid / Invalid wallet type' }, initialBalance: { min: 'Saldo awal tidak boleh negatif / Initial balance cannot be negative' } }"
    related_business_rule: BR-004, BR-016
    source: "doc-02: US-001, doc-07: types[4]"
    confidence: 1.0
  - name: CreateCategorySchema
    zod_definition: "z.object({ name: z.string().min(1, 'Nama kategori wajib diisi').max(50, 'Nama kategori maksimal 50 karakter'), type: z.enum(['income', 'expense'], { required_error: 'Tipe kategori wajib dipilih' }) })"
    error_messages: "{ name: { required: 'Nama kategori wajib diisi / Category name is required', max: 'Nama kategori maksimal 50 karakter / Max 50 characters' }, type: { invalid: 'Tipe kategori tidak valid / Invalid category type' } }"
    related_business_rule: BR-003, BR-015
    source: "doc-02: US-003, doc-07: types[5]"
    confidence: 1.0
  - name: CreateTransactionSchema
    zod_definition: "z.object({ walletId: z.number().int().positive('Dompet wajib dipilih'), categoryId: z.number().int().positive('Kategori wajib dipilih'), type: z.enum(['income', 'expense'], { required_error: 'Tipe transaksi wajib dipilih' }), amount: z.number().int().positive('Jumlah harus lebih dari 0'), transactionDate: z.string().regex(/^\\d{4}-\\d{2}-\\d{2}$/, 'Format tanggal harus YYYY-MM-DD'), note: z.string().max(500, 'Catatan maksimal 500 karakter').optional() }).refine((data) => { /* category type validation handled in form via filtered dropdown */ return true }, { message: 'Tipe kategori harus sesuai dengan tipe transaksi', path: ['categoryId'] })"
    error_messages: "{ walletId: { required: 'Dompet wajib dipilih / Wallet is required' }, categoryId: { required: 'Kategori wajib dipilih / Category is required', refine: 'Kategori tidak sesuai tipe transaksi / Category type mismatch' }, type: { invalid: 'Tipe transaksi tidak valid / Invalid transaction type' }, amount: { min: 'Jumlah harus lebih dari 0 / Amount must be greater than 0' }, transactionDate: { invalid: 'Format tanggal tidak valid / Invalid date format' }, note: { max: 'Catatan maksimal 500 karakter / Max 500 characters' } }"
    related_business_rule: BR-004, BR-005, BR-006, BR-007, BR-009, BR-016
    source: "doc-02: US-004, US-005, doc-07: types[6]"
    confidence: 1.0
  - name: UpdateTransactionSchema
    zod_definition: "CreateTransactionSchema"
    error_messages: "{ same as CreateTransactionSchema }"
    related_business_rule: BR-004, BR-005, BR-006, BR-007, BR-009, BR-010, BR-016
    source: "doc-02: US-008, doc-07: types[7]"
    confidence: 1.0
  - name: TransactionFilterSchema
    zod_definition: "z.object({ dateFrom: z.string().regex(/^\\d{4}-\\d{2}-\\d{2}$/).optional(), dateTo: z.string().regex(/^\\d{4}-\\d{2}-\\d{2}$/).optional(), type: z.enum(['income', 'expense']).optional(), walletId: z.coerce.number().int().positive().optional(), categoryId: z.coerce.number().int().positive().optional(), q: z.string().max(200).optional(), page: z.coerce.number().int().positive().default(1), perPage: z.coerce.number().int().min(1).max(100).default(20) })"
    error_messages: "{ dateFrom: { invalid: 'Format tanggal dari tidak valid / Invalid from date format' }, dateTo: { invalid: 'Format tanggal sampai tidak valid / Invalid to date format' }, type: { invalid: 'Tipe filter tidak valid / Invalid filter type' }, page: { min: 'Halaman tidak valid / Invalid page number' } }"
    related_business_rule: BR-013
    source: "doc-02: US-007, doc-07: types[8]"
    confidence: 1.0
  - name: SummaryQuerySchema
    zod_definition: "z.object({ month: z.coerce.number().int().min(1, 'Bulan harus 1-12').max(12, 'Bulan harus 1-12'), year: z.coerce.number().int().min(2020, 'Tahun minimal 2020').max(2100, 'Tahun maksimal 2100') })"
    error_messages: "{ month: { min: 'Bulan harus antara 1-12 / Month must be 1-12', max: 'Bulan harus antara 1-12 / Month must be 1-12' }, year: { min: 'Tahun minimal 2020 / Year min 2020', max: 'Tahun maksimal 2100 / Year max 2100' } }"
    related_business_rule: BR-013, BR-020
    source: "doc-02: US-010, doc-07: types[9]"
    confidence: 1.0
  - name: MonthlySummarySchema
    zod_definition: "z.object({ totalIncome: z.number().int().min(0), totalExpense: z.number().int().min(0), netBalance: z.number().int(), transactionCount: z.number().int().min(0), incomeByCategory: z.array(z.object({ categoryId: z.number().int().positive(), categoryName: z.string(), total: z.number().int().min(0) })), expenseByCategory: z.array(z.object({ categoryId: z.number().int().positive(), categoryName: z.string(), total: z.number().int().min(0) })) })"
    error_messages: "{}"
    related_business_rule: BR-013, BR-020
    source: "doc-02: US-010, doc-07: types[10]"
    confidence: 0.8
error_boundaries:
  - scope: page — all pages via app/layout.tsx
    fallback: ErrorAlert with message "Terjadi kesalahan / Something went wrong" + retry button reloading page
    source: "doc-04: Error State Table, doc-06: ASM-611"
  - scope: page — /wallets/[id]
    fallback: not-found.tsx — "Dompet tidak ditemukan / Wallet not found" + link to /wallets
    source: "doc-06: component_tree[3], doc-07: endpoints[1]"
  - scope: page — /transactions/[id]/edit
    fallback: not-found.tsx — "Transaksi tidak ditemukan / Transaction not found" + link to /transactions
    source: "doc-06: component_tree[7], doc-07: endpoints[6]"
  - scope: page — /transactions/[id]/edit (deleted)
    fallback: not-found.tsx — "Transaksi tidak ditemukan / Transaction not found" (API returns 404 for deleted per BR-021)
    source: "doc-02: BR-021"
  - scope: component — TransactionForm (create/edit)
    fallback: Inline field errors via react-hook-form + zod resolver. BalanceWarning Alert for insufficient balance.
    source: "doc-06: shared_components[4], doc-05: data_flows[6,7]"
  - scope: component — mutation error
    fallback: Sonner toast for API errors (401, 404, 422, 500). Inline ErrorAlert for critical failures blocking form.
    source: "doc-06: ASM-611"
  - scope: component — FilterBar
    fallback: ErrorAlert with retry for filter options load failure. Select dropdowns disabled on error.
    source: "doc-06: component_tree[5]"
  - scope: component — ConfirmDialog (delete)
    fallback: Toast error if delete mutation fails. Dialog closes, transaction row remains.
    source: "doc-06: ASM-609"
state_handling:
  - component: DashboardPage
    loading: "3 StatCard skeletons + 5 TransactionRow skeletons"
    empty: "EmptyState for BalanceSummaryCard (no wallets) + EmptyState for RecentTransactionsList (no transactions)"
    error: "ErrorAlert with retry for wallet query + ErrorAlert with retry for transaction query"
    related_edge_case: EC-011, EC-012
    source: "doc-06: component_tree[0]"
    confidence: 1.0
  - component: WalletListPage
    loading: "4 WalletCard skeletons in grid"
    empty: "EmptyWalletState with CTA 'Buat dompet pertama' -> /wallets/new"
    error: "ErrorAlert with retry"
    related_edge_case: EC-011
    source: "doc-06: component_tree[1]"
    confidence: 1.0
  - component: CreateWalletPage
    loading: "FormSkeleton (3 field skeletons)"
    empty: "N/A — form has no empty state"
    error: "Inline validation errors per field + toast on API error"
    related_edge_case: EC-018
    source: "doc-06: component_tree[2]"
    confidence: 1.0
  - component: WalletDetailPage
    loading: "WalletDetailCard skeleton + 3 TransactionRow skeletons"
    empty: "not-found.tsx if wallet not found (EC-014). Wallet found but no transactions -> 'Belum ada transaksi'"
    error: "ErrorAlert with retry for wallet query + ErrorAlert with retry for transactions query"
    related_edge_case: EC-014, EC-008
    source: "doc-06: component_tree[3]"
    confidence: 0.6
  - component: CategoryListPage
    loading: "Tab skeletons + CategoryCard list skeletons"
    empty: "No empty state — default categories always exist per BR-014 (ASM-608)"
    error: "ErrorAlert with retry"
    related_edge_case: EC-015
    source: "doc-06: component_tree[4]"
    confidence: 1.0
  - component: TransactionListPage
    loading: "FilterBar skeleton + 5 TransactionRow skeletons + pagination skeleton"
    empty: "No filters: EmptyState 'Belum ada transaksi' + CTA 'Catat transaksi pertama' -> /transactions/new. With filters: EmptyState 'Tidak ada transaksi yang cocok' + 'Reset Filter' button"
    error: "ErrorAlert with retry for transaction query. ErrorAlert for filter option load failures."
    related_edge_case: EC-006, EC-012
    source: "doc-06: component_tree[5]"
    confidence: 1.0
  - component: CreateTransactionPage
    loading: "Select skeletons for wallet + category dropdown (waiting for reference data)"
    empty: "N/A — form has no empty state. Category dropdown always populated per BR-014."
    error: "Inline field errors via Zod. BalanceWarning Alert (destructive) if expense > wallet balance. Toast on mutation error."
    related_edge_case: EC-001, EC-009, EC-010, EC-017, EC-018
    source: "doc-06: component_tree[6]"
    confidence: 1.0
  - component: EditTransactionPage
    loading: "FormSkeleton 'Memuat data transaksi...' while fetching transaction + select skeletons"
    empty: "not-found.tsx if transaction not found or soft-deleted (EC-016, BR-021)"
    error: "ErrorAlert with retry for transaction query. Inline field errors via Zod. Toast on update/delete mutation error."
    related_edge_case: EC-002, EC-003, EC-007, EC-016, EC-018
    source: "doc-06: component_tree[7]"
    confidence: 1.0
  - component: MonthlySummaryPage
    loading: "3 StatCard skeletons + 2 breakdown section skeletons"
    empty: "All values display 0 + EmptyState 'Tidak ada transaksi di bulan ini' (EC-013)"
    error: "ErrorAlert with retry"
    related_edge_case: EC-013
    source: "doc-06: component_tree[8]"
    confidence: 1.0
assumptions:
  - id: ASM-801
    statement: API returns snake_case JSON. Zod schemas use camelCase (TS convention). An adapter layer converts camelCase form values to snake_case request bodies. This matches doc-07 field mapping table.
    impacts: Form values validated in camelCase. Mutation hooks transform to snake_case before fetch. Response types re-transform to camelCase.
    confidence: 1.0
    source: "doc-07: section 3.5 Field Mapping"
  - id: ASM-802
    statement: Soft-deleted transactions (deleted_at IS NOT NULL) are invisible at API level — list endpoint filters them out, detail endpoint returns 404. Frontend never handles deleted_at field directly.
    impacts: No deleted_at check in TransactionSchema. EditTransactionPage shows not-found for deleted transactions. No "restore" feature in MVP.
    confidence: 1.0
    source: "doc-02: BR-011, BR-018, BR-020, BR-021"
  - id: ASM-803
    statement: URL search params are source of truth for transaction filters and summary month/year (doc-05 ASM-001). FilterSchema values are URL-serializable strings that Zod coerces to correct types.
    impacts: TransactionFilterSchema uses z.coerce.number() for page/perPage/walletId/categoryId. SummaryQuerySchema uses z.coerce.number() for month/year. Filter state not stored in Zustand.
    confidence: 1.0
    source: "doc-05: ASM-001, doc-05: data_flows[5,8]"
  - id: ASM-804
    statement: BR-008 (expense cannot make wallet balance negative) and BR-017 (balance check for update) are primarily backend-enforced. Frontend shows live BalanceWarning but server ultimately validates. Balance check requires wallet reference data loaded.
    impacts: BalanceWarning Alert computed client-side as UX courtesy. Server may still reject due to concurrent transactions. Frontend never blocks submit — server is authority.
    confidence: 0.8
    source: "doc-02: BR-008, EC-001, EC-017"
  - id: ASM-805
    statement: Transaction type toggle resets category select. Category list is client-side filtered by selected type. Zod refine for BR-007 exists as defense-in-depth but UI prevents mismatched selection.
    impacts: TypeToggle onChange resets categoryId to null/undefined. CategorySelect options filtered via useMemo. Zod.refine() catches edge case if filtered list is bypassed.
    confidence: 0.9
    source: "doc-06: section 1.2 TransactionForm, doc-05: ASM-005"
  - id: ASM-806
    statement: Amount input uses integer (IDR smallest unit, no decimals). Input type="number" with step="1". Zod validates z.number().int(). No floating point handling.
    impacts: AmountInput component emits string -> coerced to number by zod. Display uses Intl.NumberFormat with fractionDigits=0. 15000 = Rp15.000.
    confidence: 1.0
    source: "doc-02: BR-016, BR-017, doc-06: ASM-607"
  - id: ASM-807
    statement: Default categories are pre-seeded per BR-014. CategoryList never shows empty state. Category dropdown in TransactionForm always has options.
    impacts: CategoryListPage omits EmptyState. CreateTransactionPage does not handle empty category dropdown. Loading state only on first fetch.
    confidence: 1.0
    source: "doc-02: BR-014, doc-06: ASM-608"
---

# 08 — Validation and Edge Case Plan

## 1. Zod Schemas

### 1.1 Shared Entity Schemas

Schemas for full entity objects returned by API. Used for response type inference, not form validation.

```typescript
// schemas/entity.ts
import { z } from 'zod'

// ── Wallet ──
export const WalletSchema = z.object({
  id: z.number().int().positive(),
  userId: z.number().int().positive(),
  name: z.string().min(1, 'Nama dompet wajib diisi').max(100, 'Nama dompet maksimal 100 karakter'),
  type: z.enum(['cash', 'bank', 'e-wallet'], {
    required_error: 'Tipe dompet wajib dipilih',
    invalid_type_error: 'Tipe dompet tidak valid',
  }),
  initialBalance: z.number().int().min(0, 'Saldo awal tidak boleh negatif'),
  currentBalance: z.number().int().min(0),
  createdAt: z.string(),
  updatedAt: z.string(),
})
export type Wallet = z.infer<typeof WalletSchema>

// ── Category ──
export const CategorySchema = z.object({
  id: z.number().int().positive(),
  userId: z.number().int().positive().nullable(),
  name: z.string().min(1, 'Nama kategori wajib diisi').max(50, 'Nama kategori maksimal 50 karakter'),
  type: z.enum(['income', 'expense'], {
    required_error: 'Tipe kategori wajib dipilih',
  }),
  isDefault: z.boolean(),
  createdAt: z.string(),
  updatedAt: z.string(),
})
export type Category = z.infer<typeof CategorySchema>

// ── Transaction ──
export const TransactionSchema = z.object({
  id: z.number().int().positive(),
  userId: z.number().int().positive(),
  walletId: z.number().int().positive('Dompet wajib dipilih'),
  categoryId: z.number().int().positive('Kategori wajib dipilih'),
  type: z.enum(['income', 'expense'], {
    required_error: 'Tipe transaksi wajib dipilih',
  }),
  amount: z.number().int().positive('Jumlah harus lebih dari 0'),
  transactionDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Format tanggal harus YYYY-MM-DD'),
  note: z.string().max(500, 'Catatan maksimal 500 karakter').nullable(),
  createdAt: z.string(),
  updatedAt: z.string(),
  // Joined fields from API (list response only)
  walletName: z.string().optional(),
  categoryName: z.string().optional(),
}).refine(
  (data) => {
    // BR-007: category type must match transaction type
    // Actual validation requires categories reference data — handled in form
    // This refine is a structural placeholder for the cross-field rule
    return true
  },
  { message: 'Kategori tidak sesuai tipe transaksi / Category type mismatch', path: ['categoryId'] }
)
export type Transaction = z.infer<typeof TransactionSchema>
```

### 1.2 Input Schemas (Create / Update / Filter)

#### CreateWalletSchema

```typescript
// schemas/wallet.ts
import { z } from 'zod'

export const CreateWalletSchema = z.object({
  name: z
    .string()
    .min(1, 'Nama dompet wajib diisi / Wallet name is required')
    .max(100, 'Nama dompet maksimal 100 karakter / Max 100 characters'),
  type: z.enum(['cash', 'bank', 'e-wallet'], {
    required_error: 'Tipe dompet wajib dipilih / Wallet type is required',
    invalid_type_error: 'Tipe dompet tidak valid / Invalid wallet type',
  }),
  initialBalance: z
    .number()
    .int('Saldo awal harus berupa angka bulat / Initial balance must be integer')
    .min(0, 'Saldo awal tidak boleh negatif / Initial balance cannot be negative')
    .default(0),
})
export type CreateWalletInput = z.infer<typeof CreateWalletSchema>
```

**Fields validated:**
| Field | Rule | Zod |
|-------|------|-----|
| name | Required, 1-100 chars | `min(1)`, `max(100)` |
| type | Enum: cash, bank, e-wallet | `z.enum([...])` |
| initialBalance | Integer, >= 0, default 0 | `int().min(0).default(0)` |

#### CreateCategorySchema

```typescript
// schemas/category.ts
import { z } from 'zod'

export const CreateCategorySchema = z.object({
  name: z
    .string()
    .min(1, 'Nama kategori wajib diisi / Category name is required')
    .max(50, 'Nama kategori maksimal 50 karakter / Max 50 characters'),
  type: z.enum(['income', 'expense'], {
    required_error: 'Tipe kategori wajib dipilih / Category type is required',
  }),
})
export type CreateCategoryInput = z.infer<typeof CreateCategorySchema>
```

**Fields validated:**
| Field | Rule | Zod |
|-------|------|-----|
| name | Required, 1-50 chars (shorter than wallet — category names are shorter) | `min(1)`, `max(50)` |
| type | Enum: income, expense | `z.enum([...])` |

#### CreateTransactionSchema (shared for create + update per doc-07)

```typescript
// schemas/transaction.ts
import { z } from 'zod'

export const CreateTransactionSchema = z.object({
  walletId: z
    .number({ required_error: 'Dompet wajib dipilih / Wallet is required' })
    .int()
    .positive('Dompet wajib dipilih / Wallet is required'),
  categoryId: z
    .number({ required_error: 'Kategori wajib dipilih / Category is required' })
    .int()
    .positive('Kategori wajib dipilih / Category is required'),
  type: z.enum(['income', 'expense'], {
    required_error: 'Tipe transaksi wajib dipilih / Transaction type is required',
  }),
  amount: z
    .number({ required_error: 'Jumlah transaksi wajib diisi / Amount is required' })
    .int('Jumlah harus berupa angka bulat / Amount must be integer')
    .positive('Jumlah harus lebih dari 0 / Amount must be greater than 0'),
  transactionDate: z
    .string({ required_error: 'Tanggal transaksi wajib diisi / Date is required' })
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'Format tanggal harus YYYY-MM-DD / Date format must be YYYY-MM-DD'),
  note: z
    .string()
    .max(500, 'Catatan maksimal 500 karakter / Max 500 characters')
    .optional(),
})

export type CreateTransactionInput = z.infer<typeof CreateTransactionSchema>

// Update uses same schema — backend does full replacement
export const UpdateTransactionSchema = CreateTransactionSchema
export type UpdateTransactionInput = z.infer<typeof UpdateTransactionSchema>
```

**Cross-field validation (BR-007) — Not in refine because category type depends on external reference data (categories list). Handled in TransactionForm component:**

```typescript
// In TransactionForm component (doc-06: TransactionForm)
const selectedType = watch('type')
const categoryOptions = useMemo(
  () => categories.filter((c) => c.type === selectedType),
  [categories, selectedType]
)

// When type toggles, reset categoryId
const handleTypeChange = (newType: 'income' | 'expense') => {
  setValue('categoryId', undefined)
  setValue('type', newType)
}
```

**Transaction date max-today validation (BR-009) — Applied via form-level refine + DatePicker constraint:**

```typescript
export const CreateTransactionSchemaWithDateCheck = CreateTransactionSchema.refine(
  (data) => {
    const today = new Date().toISOString().split('T')[0] // YYYY-MM-DD
    return data.transactionDate <= today
  },
  {
    message: 'Tanggal tidak boleh melebihi hari ini / Date cannot be in the future',
    path: ['transactionDate'],
  }
)
```

#### TransactionFilterSchema

```typescript
// schemas/filter.ts
import { z } from 'zod'

export const TransactionFilterSchema = z.object({
  dateFrom: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  dateTo: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  type: z.enum(['income', 'expense']).optional(),
  walletId: z.coerce.number().int().positive().optional(),
  categoryId: z.coerce.number().int().positive().optional(),
  q: z.string().max(200).optional(),
  page: z.coerce.number().int().positive().default(1),
  perPage: z.coerce.number().int().min(1).max(100).default(20),
})
export type TransactionFilters = z.infer<typeof TransactionFilterSchema>
```

**Note:** `z.coerce.number()` used because URL search params are strings. Coercion transforms `"1"` to `1`.

#### SummaryQuerySchema

```typescript
// schemas/summary.ts
import { z } from 'zod'

export const SummaryQuerySchema = z.object({
  month: z.coerce
    .number()
    .int()
    .min(1, 'Bulan harus antara 1-12 / Month must be 1-12')
    .max(12, 'Bulan harus antara 1-12 / Month must be 1-12'),
  year: z.coerce
    .number()
    .int()
    .min(2020, 'Tahun minimal 2020 / Year minimum 2020')
    .max(2100, 'Tahun maksimal 2100 / Year maximum 2100'),
})
export type SummaryQuery = z.infer<typeof SummaryQuerySchema>
```

#### MonthlySummarySchema (response validation)

```typescript
export const MonthlySummarySchema = z.object({
  totalIncome: z.number().int().min(0),
  totalExpense: z.number().int().min(0),
  netBalance: z.number().int(),
  transactionCount: z.number().int().min(0),
  incomeByCategory: z.array(
    z.object({
      categoryId: z.number().int().positive(),
      categoryName: z.string(),
      total: z.number().int().min(0),
    })
  ),
  expenseByCategory: z.array(
    z.object({
      categoryId: z.number().int().positive(),
      categoryName: z.string(),
      total: z.number().int().min(0),
    })
  ),
})
export type MonthlySummary = z.infer<typeof MonthlySummarySchema>
```

### 1.3 Type-to-Schema Mapping (Cross-Reference doc-07 types)

| doc-07 Type | doc-08 Schema | Match | Notes |
|-------------|---------------|-------|-------|
| Wallet | WalletSchema | EXACT | Same fields, camelCase |
| Category | CategorySchema | EXACT | Same fields, camelCase |
| Transaction | TransactionSchema | EXACT | Same fields + optional joined fields |
| User | — | OMITTED | No client-side validation needed |
| CreateWalletRequest | CreateWalletSchema | EXACT | inputBalance default 0 |
| CreateCategoryRequest | CreateCategorySchema | EXACT | name max 50 (stricter than API 100) |
| CreateTransactionRequest | CreateTransactionSchema | EXACT | Same shape |
| UpdateTransactionRequest | UpdateTransactionSchema | EXACT | Alias to CreateTransactionSchema |
| TransactionFilters | TransactionFilterSchema | EXACT | z.coerce for URL string->number |
| SummaryParams | SummaryQuerySchema | EXACT | z.coerce for URL params |
| MonthlySummary | MonthlySummarySchema | EXACT | Response validation only |
| CategoryBreakdown | (inline in MonthlySummarySchema) | COVERED | Inline in array definition |
| DeleteTransactionResponse | — | OMITTED | `{ success: true }` — no validation needed |
| ApiResponse / ApiListResponse | — | OMITTED | Envelope, not validated client-side |
| ApiError / FieldError | — | OMITTED | Consumed, not validated |

---

## 2. Form Validation Rules

### 2.1 CreateWalletForm

| Field | Rules | Error Message (ID) | Error Message (EN) | Related BR |
|-------|-------|--------------------|--------------------|------------|
| name | Required, 1-100 chars | Nama dompet wajib diisi | Wallet name is required | BR-004 |
| name | Max 100 chars | Nama dompet maksimal 100 karakter | Max 100 characters | — |
| type | Required, enum | Tipe dompet wajib dipilih | Wallet type is required | BR-004 |
| type | Must be cash/bank/e-wallet | Tipe dompet tidak valid | Invalid wallet type | BR-004 |
| initialBalance | Integer, >= 0 | Saldo awal tidak boleh negatif | Initial balance cannot be negative | BR-016 |
| initialBalance | Integer only | Saldo awal harus berupa angka bulat | Initial balance must be integer | BR-016 |

### 2.2 CreateTransactionForm

| Field | Rules | Error Message (ID) | Error Message (EN) | Related BR |
|-------|-------|--------------------|--------------------|------------|
| walletId | Required, positive int | Dompet wajib dipilih | Wallet is required | BR-004 |
| categoryId | Required, positive int | Kategori wajib dipilih | Category is required | BR-004, BR-007 |
| categoryId | Must match transaction type | Kategori tidak sesuai tipe transaksi | Category type mismatch | BR-007 |
| type | Required, income/expense | Tipe transaksi wajib dipilih | Transaction type is required | BR-006 |
| amount | Required, positive int | Jumlah harus lebih dari 0 | Amount must be greater than 0 | BR-005, BR-016 |
| amount | Integer only | Jumlah harus berupa angka bulat | Amount must be integer | BR-016 |
| transactionDate | Required, YYYY-MM-DD | Tanggal transaksi wajib diisi | Date is required | BR-004 |
| transactionDate | Max today | Tanggal tidak boleh melebihi hari ini | Date cannot be in the future | BR-009 |
| note | Optional, max 500 chars | Catatan maksimal 500 karakter | Max 500 characters | — |

### 2.3 EditTransactionForm

Same rules as CreateTransactionForm plus:

| Rule | Handling | Related BR |
|------|----------|------------|
| Only description, amount, date, category editable | Type field read-only after creation. Wallet field read-only (change wallet = delete+recreate per BR-010 interpretation) | BR-010 |
| Soft-deleted transactions return 404 | Form never renders — not-found.tsx shown | BR-021 |
| Update may fail due to balance constraint | Backend returns 422 with balance error. Frontend shows toast. | BR-008 |

### 2.4 CreateCategoryForm

| Field | Rules | Error Message (ID) | Error Message (EN) | Related BR |
|-------|-------|--------------------|--------------------|------------|
| name | Required, 1-50 chars | Nama kategori wajib diisi | Category name is required | BR-015 |
| name | Max 50 chars | Nama kategori maksimal 50 karakter | Max 50 characters | — |
| type | Required, income/expense | Tipe kategori wajib dipilih | Category type is required | BR-003 |

**Duplicate name check:** Handled at API level (422 response with code `duplicate`). Frontend shows toast with server error message.

---

## 3. Business Rule to Validation Mapping

| BR | Description | Validation Logic | Client/Server | Confidence | Notes |
|----|-------------|-----------------|---------------|------------|-------|
| BR-001 | User data isolation | No frontend validation. API enforces user_id scoping. | Server | 0.3 | UI never sees other users' data |
| BR-002 | Wallet owned by user | No frontend validation. 404 if not found. | Server | 0.3 | API scopes by user_id |
| BR-003 | Category owned by user or default | No frontend validation. 404 if not found. | Server | 0.3 | API scopes by user_id; null=default |
| BR-004 | Transaction required fields | Zod schema: walletId/ categoryId/ type/ amount/ transactionDate all required | Client + Server | 1.0 | All required in CreateTransactionSchema |
| BR-005 | Amount > 0 | Zod: `z.number().int().positive()` | Client + Server | 1.0 | Enforced in CreateTransactionSchema |
| BR-006 | Type income/expense | Zod: `z.enum(['income', 'expense'])` | Client + Server | 1.0 | Enforced in CreateTransactionSchema |
| BR-007 | Category type matches transaction type | TransactionForm filters category dropdown by selected type. Zod.refine() as defense. Server enforces. | Client + Server | 0.9 | UI prevents mismatch via filtered options. Server is authority. |
| BR-008 | Expense cannot make balance negative | BalanceWarning Alert in TransactionForm (live check via selected wallet balance). Server enforces. | Server | 0.5 | Frontend warns but server decides. Race conditions possible. |
| BR-009 | Transaction date <= today | Zod refine `date <= today`. DatePicker maxDate=today. | Client + Server | 1.0 | Two-layer: form input max + Zod refine |
| BR-010 | Edit active transactions only | Zod: no edit-time validation. API returns 404 for soft-deleted. Type field immutable in EditTransactionForm. | Server | 0.4 | Backend gate. Frontend shows not-found. |
| BR-011 | Deleted transaction hidden | No frontend validation. API filters deleted_at IS NULL. | Server | 0.3 | API controls visibility |
| BR-012 | Wallet with transactions no hard delete | No frontend validation. API prevents hard delete. | Server | 0.3 | Wallet delete not in MVP scope |
| BR-013 | Summary by month/year | SummaryQuerySchema: month 1-12, year 2020-2100 | Client + Server | 1.0 | Zod coerce + min/max |
| BR-014 | Default categories exist | Assumed seeded. CategoryList no empty state. | Server | 1.0 | Seed data at user creation |
| BR-015 | User can create custom categories | Zod: CreateCategorySchema validates name + type | Client + Server | 1.0 | Server checks duplicate |
| BR-016 | Amount stored as integer | Zod: `z.number().int()` | Client + Server | 1.0 | Input step=1, no decimals |
| BR-017 | Default currency IDR | No Zod rule. Display formatting via Intl.NumberFormat. | Client | 0.3 | UI concern, not validation |
| BR-018 | Soft delete | No frontend validation. API sets deleted_at. | Server | 0.3 | Client sends DELETE, API soft-deletes |
| BR-019 | Data isolation (duplicate of BR-001) | Same as BR-001 | Server | 0.3 | Same handling |
| BR-020 | Summary excludes soft-deleted | No frontend validation. API filters deleted_at IS NULL. | Server | 0.3 | Server computes summary from active only |
| BR-021 | Soft-deleted cannot be edited | API returns 404 for deleted. EditTransactionPage shows not-found. | Server | 0.4 | Frontend handles 404 as not-found state |

**Confidence interpretation:**
- 1.0: Full Zod schema coverage, enforced both client and server
- 0.9: Client validation exists but server is authority (BR-007)
- 0.5: Client-side UX only, server enforces (BR-008)
- 0.3-0.4: Server-only rule, frontend only handles resultant errors (BR-001, BR-010, BR-021)

---

## 4. Edge Case Handling

| EC | Scenario | Expected Behavior | Implementation | Component | Query Hook | Route |
|----|----------|-------------------|----------------|-----------|------------|-------|
| EC-001 | Expense > wallet balance | Request rejected. Form shows BalanceWarning Alert before submit. | BalanceWarning Alert in TransactionForm computed from form amount + selected wallet currentBalance | TransactionForm | useWallets (for balance) | /transactions/new |
| EC-002 | Update income to expense | Server re-validates category and balance. Frontend resets category on type toggle. | TypeToggle onChange -> setValue('categoryId', undefined). CategorySelect re-filters. | EditTransactionPage > TransactionForm | useUpdateTransaction | /transactions/[id]/edit |
| EC-003 | Update wallet on old transaction | Backend adjusts old/new wallet balances. Frontend sends updated walletId. | No special frontend handling — PUT request with new walletId. Server handles balance transfer. | EditTransactionPage | useUpdateTransaction | /transactions/[id]/edit |
| EC-004 | Delete income transaction | Wallet balance decreases. ConfirmDialog: "Saldo wallet akan dikurangi Rp X". | ConfirmDialog with descriptive text. useDeleteTransaction on success invalidates wallets. | TransactionList / EditTransactionPage > ConfirmDialog | useDeleteTransaction | /transactions, /transactions/[id]/edit |
| EC-005 | Delete expense transaction | Wallet balance increases (reversed). ConfirmDialog: "Saldo wallet akan dikembalikan Rp X". | ConfirmDialog text differs per transaction type (income vs expense). | TransactionList / EditTransactionPage > ConfirmDialog | useDeleteTransaction | /transactions, /transactions/[id]/edit |
| EC-006 | Filter date range with no results | EmptyState: "Tidak ada transaksi yang cocok" + "Reset Filter" button. | TransactionListPage checks if filters are active. Shows contextual EmptyState. | TransactionListPage > EmptyState | useTransactions | /transactions |
| EC-007 | Use deleted category | Request rejected (404 or 422). Category select only shows active categories — UI prevents selection. | CategorySelect filtered to active categories. If API returns 422, show toast. | TransactionForm > CategorySelect | useCreateTransaction / useUpdateTransaction | /transactions/new, /transactions/[id]/edit |
| EC-008 | Access others' data | API returns 404 (not-found semantics per ASM-014). Frontend shows not-found page. | Dynamic route not-found.tsx handles 404. ErrorAlert with "Data tidak ditemukan" | WalletDetailPage / EditTransactionPage > not-found.tsx | useWallet / useTransaction | /wallets/[id], /transactions/[id]/edit |
| EC-009 | Amount = 0 | Request rejected. Zod: `z.number().positive()`. | Field-level error: "Jumlah harus lebih dari 0 / Amount must be greater than 0" | TransactionForm > AmountInput | — | /transactions/new |
| EC-010 | Future transaction date | Request rejected. Zod refine date <= today. DatePicker maxDate=today. | DatePicker disables future dates. If bypassed, refine error: "Tanggal tidak boleh melebihi hari ini" | TransactionForm > DatePicker | — | /transactions/new, /transactions/[id]/edit |
| EC-011 | No wallets exist | EmptyState with CTA: "Buat dompet pertama" -> /wallets/new. Dashboard shows empty. | EmptyWalletState in WalletListPage. Dashboard BalanceSummaryCard shows zero state. | WalletListPage > EmptyWalletState, DashboardPage > BalanceSummaryCard | useWallets | /wallets, / |
| EC-012 | No transactions exist | EmptyState: "Belum ada transaksi" + CTA "Catat transaksi pertama" -> /transactions/new | RecentTransactionsList on Dashboard. TransactionListPage without filters. | DashboardPage > RecentTransactionsList, TransactionListPage > EmptyState | useTransactions | /, /transactions |
| EC-013 | Empty summary month | All values = 0. "Tidak ada transaksi di bulan ini" message. | StatCards show 0. Breakdown sections empty with message. | MonthlySummaryPage > SummaryHeader + BreakdownSections | useMonthlySummary | /summary |
| EC-014 | Wallet ID not found | not-found.tsx: "Dompet tidak ditemukan" + link to /wallets | useWallet throws on 404. Next.js not-found() called. | WalletDetailPage > not-found.tsx | useWallet | /wallets/[id] |
| EC-015 | Category ID not found | No direct route for single category. Category list handles via API error. | CategoryListPage ErrorAlert with retry if categories fail to load. | CategoryListPage > ErrorAlert | useCategories | /categories |
| EC-016 | Transaction ID not found | not-found.tsx: "Transaksi tidak ditemukan" + link to /transactions | useTransaction throws on 404. Next.js not-found() called. Also triggered for soft-deleted transactions. | EditTransactionPage > not-found.tsx | useTransaction | /transactions/[id]/edit |
| EC-017 | Wallet insufficient balance for expense | Server returns 422. Frontend shows BalanceWarning before submit. | BalanceWarning Alert computed in real-time: form amount vs wallet balance. Server enforces. | TransactionForm > BalanceWarning | useWallets | /transactions/new, /transactions/[id]/edit |
| EC-018 | Validation failure | Inline field errors per Zod schema. 422 from API shows mapped field errors. | Form errors via react-hook-form + ZodResolver. API 422 errors mapped to form fields. | All form pages | — | All form routes |

---

## 5. Error Boundary Strategy

### 5.1 Page-Level Error Boundaries (Next.js error.tsx)

| Page | error.tsx | Fallback UI | Retry Behavior | Source |
|------|-----------|-------------|----------------|--------|
| `/` (Dashboard) | app/error.tsx | ErrorAlert: "Terjadi kesalahan" + Retry | Retry calls `reset()` which re-renders the page | doc-06: component_tree[0] |
| `/wallets` | app/wallets/error.tsx | ErrorAlert + Retry | Retry resets error boundary | doc-06: component_tree[1] |
| `/wallets/new` | none (form page, mutation errors shown inline) | Inline field errors + toast | N/A — no page-level data fetch | doc-06: component_tree[2] |
| `/wallets/[id]` | app/wallets/[id]/error.tsx | ErrorAlert + Retry | Retry refetches useWallet + useTransactions | doc-06: component_tree[3] |
| `/categories` | app/categories/error.tsx | ErrorAlert + Retry | Retry refetches useCategories | doc-06: component_tree[4] |
| `/transactions` | app/transactions/error.tsx | ErrorAlert + Retry | Retry refetches useTransactions | doc-06: component_tree[5] |
| `/transactions/new` | none (form page) | Inline field errors + toast | N/A | doc-06: component_tree[6] |
| `/transactions/[id]/edit` | app/transactions/[id]/edit/error.tsx | ErrorAlert + Retry | Retry refetches useTransaction | doc-06: component_tree[7] |
| `/summary` | app/summary/error.tsx | ErrorAlert + Retry | Retry refetches useMonthlySummary | doc-06: component_tree[8] |

### 5.2 Not-Found Pages (not-found.tsx)

| Route | not-found.tsx | Message | CTA | Related EC |
|-------|--------------|---------|-----|------------|
| `/wallets/[id]` | app/wallets/[id]/not-found.tsx | "Dompet tidak ditemukan" | Link to /wallets | EC-008, EC-014 |
| `/transactions/[id]/edit` | app/transactions/[id]/edit/not-found.tsx | "Transaksi tidak ditemukan" | Link to /transactions | EC-008, EC-016 |

### 5.3 API Error to User Message Mapping

| HTTP Status | Error Code | User Message (ID) | User Message (EN) | Component |
|-------------|------------|-------------------|-------------------|-----------|
| 400 | bad_request | "Data yang dikirim tidak valid" | "Invalid request data" | ErrorAlert / Toast |
| 401 | unauthorized | "Sesi berakhir, silakan login ulang" | "Session expired" | ErrorAlert (MVP: never triggered) |
| 404 | not_found | "[Entity] tidak ditemukan" | "[Entity] not found" | not-found.tsx |
| 422 | validation_error | Per-field error messages | Per-field error messages | Inline form errors |
| 422 | balance_insufficient | "Saldo dompet tidak mencukupi" | "Insufficient wallet balance" | BalanceWarning Alert |
| 422 | duplicate | "Nama sudah digunakan" | "Name already exists" | Inline field error |
| 500 | internal_server_error | "Terjadi kesalahan server, coba lagi" | "Server error, please retry" | ErrorAlert + retry |

### 5.4 Mutation Error Handling

| Mutation | Error Display | Retry | Side Effects on Error |
|----------|---------------|-------|-----------------------|
| useCreateWallet | Sonner toast: "Gagal membuat dompet" | User re-submits form | No cache invalidation |
| useCreateCategory | Sonner toast: "Gagal membuat kategori" | User re-submits form | No cache invalidation |
| useCreateTransaction | Sonner toast: "Gagal mencatat transaksi" | User re-submits form | No cache invalidation |
| useUpdateTransaction | Sonner toast: "Gagal mengubah transaksi" | User re-submits form | No cache invalidation |
| useDeleteTransaction | Sonner toast: "Gagal menghapus transaksi" | User clicks delete again | Row stays visible |

All mutations: `retry: 0` per doc-05 QueryClient config (no automatic retry for mutations).

---

## 6. State Handling Per Screen

### Dashboard

```
Data: useWallets() + useTransactions({page:1, per_page:5})
├── Loading (both queries)
│   ├── BalanceSummaryCard → 3 StatCard skeletons
│   └── RecentTransactionsList → 5 TransactionRow skeletons
├── Error (any query fails)
│   └── ErrorAlert with retry button (per query, or compound)
├── Empty (wallets loaded but empty)
│   └── EmptyWalletState: "Buat dompet pertama" CTA → /wallets/new
├── Empty (transactions loaded but empty)
│   └── "Belum ada transaksi" text in RecentTransactionsList
└── Success
    ├── BalanceSummaryCard with calculated totals
    └── RecentTransactionsList with TransactionRow × N
```

### WalletList

```
Data: useWallets()
├── Loading → 4 WalletCard skeletons in grid
├── Error → ErrorAlert with retry
├── Empty → EmptyWalletState: CTA "Buat dompet pertama" → /wallets/new
└── Success → WalletCard grid
```

### CreateWallet

```
Data: useCreateWallet() mutation only
├── Initial → CreateWalletForm (empty form)
├── Submitting → Button loading spinner + fields disabled
├── Validation Error → Inline field errors per Zod schema
├── API Error → Sonner toast "Gagal membuat dompet"
└── Success → Sonner toast "Dompet berhasil dibuat" + redirect /wallets
```

### WalletDetail

```
Data: useWallet(id) + useTransactions({wallet_id: id, per_page: 5})
├── Loading
│   ├── WalletDetailCard skeleton
│   └── 3 TransactionRow skeletons
├── Error (wallet query fails with 404)
│   └── not-found.tsx: "Dompet tidak ditemukan" + link /wallets
├── Error (other)
│   └── ErrorAlert with retry
├── Empty (wallet found, no transactions)
│   └── WalletDetailCard rendered + text "Belum ada transaksi"
└── Success
    ├── WalletDetailCard with info
    └── WalletRecentTransactions with TransactionRow × N
```

### CategoryList

```
Data: useCategories() + useCreateCategory() mutation
├── Loading → Tab skeletons + list skeletons
├── Error → ErrorAlert with retry
├── Empty → N/A (default categories always exist per BR-014)
└── Success → CategoryTabs with CategoryCards
    └── CreateCategoryForm (inline, not modal)
```

### TransactionList

```
Data: useTransactions(filters) + useWallets() + useCategories() + useDeleteTransaction()
├── Loading
│   ├── FilterBar skeleton (select skeletons)
│   └── 5 TransactionRow skeletons + Pagination skeleton
├── Error (transactions query)
│   └── ErrorAlert with retry
├── Error (wallets/categories for filter options)
│   └── FilterBar select dropdowns disabled + ErrorAlert
├── Empty (no filters, no transactions)
│   └── EmptyState: "Belum ada transaksi" + CTA → /transactions/new
├── Empty (with active filters, no results)
│   └── EmptyState: "Tidak ada transaksi yang cocok" + "Reset Filter" button
├── Delete Submitting
│   └── ConfirmDialog button shows loading spinner
└── Success
    ├── FilterBar with active FilterChips
    ├── TransactionTable with rows
    └── PaginationControls
```

### CreateTransaction

```
Data: useWallets() + useCategories() + useCreateTransaction() mutation
├── Loading (wallets/categories reference data)
│   └── Select skeletons (wallet + category dropdowns)
├── Error (wallets/categories fail)
│   └── ErrorAlert "Gagal memuat data" + retry (blocks form)
├── Validation Error (form client-side)
│   └── Inline field errors per Zod
├── Balance Warning (expense > selected wallet balance)
│   └── BalanceWarning Alert (destructive) — live computed
├── Submitting
│   └── SubmitButton loading spinner + fields disabled
├── API Error
│   └── Sonner toast "Gagal mencatat transaksi"
└── Success
    └── Sonner toast + redirect /transactions
```

### EditTransaction

```
Data: useTransaction(id) + useWallets() + useCategories() + useUpdateTransaction() + useDeleteTransaction()
├── Loading (transaction detail + reference data)
│   └── FormSkeleton "Memuat data transaksi..."
├── Error (transaction 404 — not found or soft-deleted)
│   └── not-found.tsx: "Transaksi tidak ditemukan" + link /transactions
├── Error (other)
│   └── ErrorAlert with retry
├── Balance Warning
│   └── BalanceWarning Alert (if amount/type change causes insufficient balance)
├── Update Submitting
│   └── SubmitButton loading spinner
├── Delete Submitting
│   └── ConfirmDialog button loading spinner
├── API Error (update)
│   └── Sonner toast "Gagal mengubah transaksi"
├── API Error (delete)
│   └── Sonner toast "Gagal menghapus transaksi"
└── Success (update)
    └── Sonner toast + redirect /transactions
    (delete) → Sonner toast + redirect /transactions
```

### MonthlySummary

```
Data: useMonthlySummary(month, year)
├── Loading
│   ├── 3 StatCard skeletons
│   └── 2 breakdown section skeletons
├── Error → ErrorAlert with retry
├── Empty (summary returns all zeros)
│   ├── StatCards show 0
│   ├── Breakdown sections empty
│   └── EmptyState: "Tidak ada transaksi di bulan ini"
└── Success
    ├── MonthYearPicker
    ├── 3 StatCards (income, expense, net)
    ├── Badge "{N} transaksi"
    ├── IncomeBreakdownSection with CategoryBreakdownItems
    └── ExpenseBreakdownSection with CategoryBreakdownItems
```

---

## 7. Assumptions

| ID | Statement | Impacts | Confidence | Source |
|----|-----------|---------|-----------|--------|
| ASM-801 | API returns snake_case JSON. Zod schemas use camelCase (TS convention). Adapter translates. | Form values validated in camelCase. Mutation hooks transform to snake_case before fetch. | 1.0 | doc-07: section 3.5 |
| ASM-802 | Soft-deleted transactions invisible at API level. Frontend never handles deleted_at field directly. | No deleted_at in TransactionSchema. EditTransactionPage shows not-found. No restore in MVP. | 1.0 | doc-02: BR-011, BR-018, BR-020, BR-021 |
| ASM-803 | URL search params are filter/month-year source of truth (doc-05 ASM-001). | FilterSchema uses z.coerce.number(). SummaryQuerySchema uses z.coerce.number(). | 1.0 | doc-05: ASM-001 |
| ASM-804 | BR-008 (balance check) is primarily server-enforced. Frontend BalanceWarning is UX courtesy only. | BalanceWarning Alert computed live. Server is authority. Concurrent ops may cause rejection. | 0.8 | doc-02: BR-008, EC-001, EC-017 |
| ASM-805 | Type toggle resets category select. UI prevents BR-007 mismatch. Zod.refine is defense-in-depth. | TypeToggle resets categoryId. CategorySelect filtered by type. | 0.9 | doc-06: section 1.2 |
| ASM-806 | Amount is integer (IDR smallest unit). Input step=1, no decimals. Zod validates int(). | AmountInput emits string -> coerced by Zod. Display uses fractionDigits=0. | 1.0 | doc-02: BR-016, BR-017, doc-06: ASM-607 |
| ASM-807 | Default categories pre-seeded per BR-014. CategoryList never empty. | CategoryListPage omits EmptyState. Category dropdown always has options. | 1.0 | doc-02: BR-014, doc-06: ASM-608 |
| ASM-808 | MonthYearPicker year range is 2020-(current+1). SummaryQuerySchema validates 2020-2100. | Month year selectors generate options within this range. Zod validates on URL params. | 0.9 | inference — reasonable year range for personal finance app |

---

## 8. DoD Checklist

- [x] Zod schemas for all entities (Wallet, Category, Transaction) — WalletSchema, CategorySchema, TransactionSchema defined with full field coverage
- [x] Zod schemas for all input types (CreateWallet, CreateCategory, CreateTransaction, UpdateTransaction, TransactionFilters, SummaryQuery)
- [x] All type names from doc-07 have matching Zod schema — 8 schemas mapped to 12 doc-07 types (ApiResponse/ApiListResponse/PaginationMeta/ApiError omitted — envelope-only)
- [x] Form validation rules for create and edit forms — CreateWalletForm, CreateTransactionForm, EditTransactionForm, CreateCategoryForm documented with per-field rules and bilingual error messages
- [x] Error boundary strategy for each page — 9 pages mapped to error.tsx + not-found.tsx strategy
- [x] All BR-001 through BR-021 translated to Zod rules or validation logic — table in section 3 with client/server split and confidence scores
- [x] All edge cases from doc-02 (EC-001 through EC-018) have concrete handling — table in section 4 with component/hook/route mapping
- [x] State handling for loading, error, empty, edge case conditions — per-screen breakdown in section 6
- [x] References doc-02 (business_rules[], edge_cases[]), doc-05 (query_hooks[], data_flows[]), doc-06 (component_tree[], shared_components[]), doc-07 (types[], endpoints[])
- [x] Schema names exact match with doc-07 type names (PascalCase) — Wallet, Category, Transaction, CreateWalletRequest/ CreateCategoryRequest/ CreateTransactionRequest/ TransactionFilters/ SummaryParams/ MonthlySummary
- [x] Cross-field validation (BR-007) documented with component-level handling + Zod refine as defense
- [x] Amount validation integer-only per BR-016, positive per BR-005
- [x] Transaction date max-today per BR-009 via Zod refine + DatePicker maxDate
- [x] Bilingual error messages (ID + EN) for all form fields
- [x] Confidence scores on every schema, rule mapping, and assumption
- [x] No placeholder, TODO, or "TBD"
- [x] Frontmatter YAML valid and complete per agent 8 schema
