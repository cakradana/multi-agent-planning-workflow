---
title: Frontend Requirement Mapping
description: Map functional requirements to frontend concerns for Pocket personal finance app
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 3
schema_version: 1
status: complete
summary: >
  This document maps 7 functional requirements (FR-001 through FR-007) from the Pocket PRD
  to concrete frontend concerns. Each FR is analyzed across five dimensions: routing (Next.js
  App Router routes needed), state management (Zustand stores and TanStack Query hooks),
  API integration (endpoints and methods), validation (Zod schemas and business rules), and
  UI components (shadcn/ui selections and custom components). FR-001 (Wallet Management)
  maps to /wallets list and /wallets/new routes, needs wallet CRUD state, and uses Card,
  Form, and Select components. FR-002 (Category Management) maps to a categories section,
  needs category query state, and distinguishes default vs custom categories in UI. FR-003
  (Create Transaction) is the most complex FR — it depends on FR-001 and FR-002 for wallet
  and category data, requires a form with type toggle (income/expense), wallet balance
  validation, and date constraint. FR-004 (Transaction History) needs a filterable list with
  date range, type, wallet, category, and note search — maps to /transactions route with
  query params for filters. FR-005 (Update Transaction) and FR-006 (Delete Transaction)
  build on FR-004, requiring edit/delete actions on transaction list items with wallet
  balance recalculation. FR-007 (Monthly Summary) needs aggregated data display with
  income/expense totals, net balance, transaction count, and category breakdown — maps to
  /summary route. Data requirements and UI state requirements (loading, empty, error, edge
  cases) are identified per FR. Four cross-cutting concerns are documented: auth context
  (assumed authenticated per ASM-001), navigation structure, shared UI states, and error
  handling. Dependencies between FRs are mapped: FR-003 depends on FR-001 and FR-002,
  FR-005 and FR-006 depend on FR-004, and FR-007 depends on FR-003 data. Nine assumptions
  document mapping decisions, including wallet CRUD scope uncertainty (ASM-010) and
  category mutability (ASM-011).
requirements:
  - id: FR-001
    description: "Wallet Management — Sistem menyediakan kemampuan untuk membuat dan melihat wallet milik user. Wallet memiliki informasi dasar seperti nama, tipe (cash, bank, e-wallet), saldo awal, dan saldo saat ini."
    frontend_concern:
      routing:
        required: true
        detail: "Dua route: /wallets (daftar wallet milik user), /wallets/new (form create wallet)"
      state:
        required: true
        detail: "useQuery(['wallets']) untuk daftar wallet. useMutation untuk create wallet. Zustand useWalletStore opsional untuk selectedWallet jika perlu context di halaman lain."
      api:
        required: true
        detail: "GET /api/wallets (list), POST /api/wallets (create). Request body: {name, type, initial_balance}. Response includes current_balance."
      validation:
        required: true
        detail: "name: required, non-empty string. type: required, enum ['cash', 'bank', 'e-wallet']. initial_balance: required, integer >= 0. Schemas di Zod: WalletCreateSchema."
      ui:
        required: true
        detail: "WalletList (Card + Badge untuk tipe wallet + balance display). WalletCard (shadcn Card). CreateWalletForm (Form, Input, Select — shadcn/ui). EmptyWalletState (CTA untuk create wallet pertama). Loading skeleton untuk list."
    related_entities:
      - Wallet
      - User
    source: "doc-02: FR-001"
    confidence: 1.0
  - id: FR-002
    description: "Category Management — Sistem menyediakan kategori transaksi untuk income dan expense. Kategori dapat berupa default category atau custom category milik user. Kategori income hanya untuk transaksi income, kategori expense hanya untuk transaksi expense."
    frontend_concern:
      routing:
        required: true
        detail: "Satu route: /categories (daftar kategori + create custom category). Atau bisa jadi section di halaman settings (/settings/categories) — tergantung keputusan UX di Agent 4."
      state:
        required: true
        detail: "useQuery(['categories']) untuk daftar kategori. useMutation untuk create custom category. Filter client-side by type (income/expense) jika perlu."
      api:
        required: true
        detail: "GET /api/categories (list semua kategori milik user + default). POST /api/categories (create custom category). Request body: {name, type}. Response includes is_default flag."
      validation:
        required: true
        detail: "name: required, unique per user per type. type: required, enum ['income', 'expense']. Custom category validasi: name tidak boleh sama dengan default category milik user. Schemas: CategoryCreateSchema."
      ui:
        required: true
        detail: "CategoryList (tabs atau grouped: income vs expense). CategoryCard (shadcn Card — default categories marked as read-only/badge). CreateCategoryForm (Form, Input, Select — shadcn/ui). DefaultCategoryBadge (badge: 'Default'). EmptyState: tidak perlu karena default categories selalu ada."
    related_entities:
      - Category
    source: "doc-02: FR-002"
    confidence: 1.0
  - id: FR-003
    description: "Create Transaction — User dapat membuat transaksi income atau expense. Transaksi harus terhubung ke wallet dan kategori. Income menambah saldo wallet. Expense mengurangi saldo wallet dan ditolak jika saldo tidak cukup."
    frontend_concern:
      routing:
        required: true
        detail: "Satu route: /transactions/new (form create transaction). Atau modal/dialog yang muncul dari halaman /transactions."
      state:
        required: true
        detail: "useMutation untuk create transaction. Dependencies: useQuery(['wallets']) dan useQuery(['categories']) untuk form options. Transaction type toggle state (income/expense) di form local state. Perlu optimistic update untuk wallet balance jika diinginkan."
      api:
        required: true
        detail: "POST /api/transactions. Request body: {wallet_id, category_id, type, amount, transaction_date, note (opsional)}. Response: Transaction object with updated wallet balance."
      validation:
        required: true
        detail: "wallet_id: required, must exist and owned by user. category_id: required, must exist, type must match transaction type. type: required, enum ['income', 'expense']. amount: required, integer > 0. transaction_date: required, date format, <= today (BR-009). note: opsional, max 500 chars. Expense: amount must not exceed wallet current_balance (BR-008). Schemas: TransactionCreateSchema."
      ui:
        required: true
        detail: "TransactionForm (Form shadcn/ui). TypeToggle (Switch atau Tabs — income/expense). WalletSelect (Select — hanya wallet milik user). CategorySelect (Select — filter by type sesuai toggle). AmountInput (Input with IDR formatting). DatePicker (DatePicker/Calendar — max today). NoteTextarea (Textarea opsional). BalanceWarning (Alert — jika expense exceeds wallet balance)."
    related_entities:
      - Transaction
      - Wallet
      - Category
    source: "doc-02: FR-003"
    confidence: 1.0
  - id: FR-004
    description: "Transaction History — User dapat melihat daftar transaksi miliknya. Riwayat dapat difilter berdasarkan date range, transaction type, wallet, category, dan keyword pada note. Daftar ditampilkan descending berdasarkan transaction date terbaru."
    frontend_concern:
      routing:
        required: true
        detail: "Satu route: /transactions. Filter params sebagai URL search params (useSearchParams): ?date_from=&date_to=&type=&wallet_id=&category_id=&q="
      state:
        required: true
        detail: "useQuery(['transactions', filters]) dengan filter params dinamis. Filter state di URL search params (source of truth). Debounce untuk search query (note keyword)."
      api:
        required: true
        detail: "GET /api/transactions?date_from=&date_to=&type=&wallet_id=&category_id=&q=&page=&per_page= Query params: semua opsional. Response: {data: Transaction[], total, page, per_page}. Sorted by transaction_date DESC (source: doc-02: US-006)."
      validation:
        required: true
        detail: "date_from: optional date. date_to: optional date. type: optional, enum ['income', 'expense']. wallet_id: optional, integer. category_id: optional, integer. q: optional, string. Semua filter optional — daftar penuh jika tidak ada filter. Tidak perlu Zod schema khusus untuk query params, validasi dasar di API saja."
      ui:
        required: true
        detail: "TransactionList (Table shadcn/ui atau Card list). FilterBar (DateRangePicker + Select untuk type + Select untuk wallet + Select untuk category + SearchInput untuk note). FilterChip (badge untuk active filters — bisa di-remove individual). Pagination atau InfiniteScroll. EmptyTransactionState (CTA create transaction pertama). LoadingSkeleton untuk list."
    related_entities:
      - Transaction
      - Wallet
      - Category
    source: "doc-02: FR-004"
    confidence: 1.0
  - id: FR-005
    description: "Update Transaction — User dapat mengubah transaksi aktif. Perubahan harus memperbarui saldo wallet secara konsisten. Jika menyebabkan saldo wallet tidak valid, sistem menolak perubahan."
    frontend_concern:
      routing:
        required: true
        detail: "Satu route: /transactions/:id/edit (form edit). Atau modal edit dari halaman transaction list."
      state:
        required: true
        detail: "useQuery(['transactions', id]) untuk fetch data transaksi existing. useMutation untuk update. Need wallet list and category list as dependencies. Perlu handle konsistensi balance: jika amount/wallet/type berubah, balance harus di-recalculate."
      api:
        required: true
        detail: "GET /api/transactions/:id (fetch existing transaction). PUT /api/transactions/:id (update). Request body: {wallet_id, category_id, type, amount, transaction_date, note}. Backend handle balance recalculation."
      validation:
        required: true
        detail: "Sama seperti FR-003 (TransactionCreateSchema) plus: transaction must be active (not soft-deleted) — BR-021. Jika type berubah (income -> expense atau sebaliknya): re-validate category type match. Jika wallet_id berubah: adjust balance of old and new wallet — EC-003. Jika amount changed: recalculate balance delta. Schemas: TransactionUpdateSchema extends TransactionCreateSchema."
      ui:
        required: true
        detail: "EditTransactionForm (sama seperti TransactionForm tapi pre-filled). DeleteActionButton (terpisah — untuk FR-006). Form dibungkus dengan Sheet (shadcn Drawer/Sheet) atau halaman penuh. Loading state untuk fetch existing data. Error state jika transaction not found."
    related_entities:
      - Transaction
      - Wallet
    source: "doc-02: FR-005"
    confidence: 0.9
  - id: FR-006
    description: "Delete Transaction — User dapat menghapus transaksi aktif menggunakan soft delete. Transaksi dihapus tidak muncul di riwayat dan tidak dihitung di summary. Saldo wallet dikembalikan sesuai efek transaksi."
    frontend_concern:
      routing:
        required: true
        detail: "Tidak perlu route khusus. Aksi delete dari: tombol di baris transaction list, atau halaman edit /transactions/:id/edit. Konfirmasi via dialog."
      state:
        required: true
        detail: "useMutation untuk soft delete. Optimistic update: hapus dari list + adjust balance display. Cache invalidation: invalidate ['transactions'], ['wallets'], ['summary'] setelah delete."
      api:
        required: true
        detail: "DELETE /api/transactions/:id (soft delete — set deleted_at). Backend handle: reverse balance effect — if income subtract, if expense add back — EC-004, EC-005. Response: {success: true, message: 'Transaction deleted', updated_wallet_balance: number}."
      validation:
        required: true
        detail: "Transaction must be active (deleted_at IS NULL) — BR-021. Transaction must belong to current user. Konfirmasi user sebelum delete (dialog). Tidak perlu Zod schema — validasi di backend."
      ui:
        required: true
        detail: "DeleteButton (Button shadcn/ui dengan icon trash). AlertDialog (shadcn AlertDialog) untuk konfirmasi: 'Apakah kamu yakin ingin menghapus transaksi ini? Saldo wallet akan disesuaikan.' Toast notification setelah berhasil/gagal."
    related_entities:
      - Transaction
      - Wallet
    source: "doc-02: FR-006"
    confidence: 1.0
  - id: FR-007
    description: "Monthly Summary — User dapat melihat summary keuangan per bulan menampilkan total income, total expense, net balance, total transaction count, expense breakdown by category, dan income breakdown by category."
    frontend_concern:
      routing:
        required: true
        detail: "Satu route: /summary. Bulan/tahun sebagai search params: /summary?month=7&year=2026. Atau bisa jadi section di dashboard home (/) — tergantung keputusan UX di Agent 4."
      state:
        required: true
        detail: "useQuery(['summary', {month, year}]) untuk data summary. Month/year selector sebagai local state (disimpan di URL search params)."
      api:
        required: true
        detail: "GET /api/summary?month=&year= Query params: month (1-12), year (4 digit). Response: {total_income, total_expense, net_balance, transaction_count, income_by_category: [{category_id, category_name, total}], expense_by_category: [{category_id, category_name, total}]}. Atau: GET /api/transactions/summary dengan response yang sama."
      validation:
        required: true
        detail: "month: required, integer 1-12. year: required, integer reasonable range (e.g., 2020-current_year+1). Tidak perlu Zod schema khusus — query params sederhana."
      ui:
        required: true
        detail: "SummaryHeader (total income, expense, net balance — Card atau StatCard shadcn/ui). MonthYearPicker (Select month + Select year atau DatePicker). TransactionCountBadge. CategoryBreakdownList (list per kategori dengan progress bar). IncomeBreakdownSection (group by category). ExpenseBreakdownSection (group by category). EmptySummaryState: 'Tidak ada transaksi di bulan ini' dengan nilai 0. LoadingSkeleton untuk stat cards. InfoAlert jika data summary tidak tersedia."
    related_entities:
      - Transaction
      - Category
    source: "doc-02: FR-007"
    confidence: 1.0
assumptions:
  - id: ASM-001
    statement: User sudah authenticated — tidak ada login page di MVP.
    impacts:
      - Semua route tidak perlu auth guard component
      - API call menyertakan user_id dari context/session
      - Tidak perlu auth state management di frontend
    confidence: 1.0
    source: "doc-02: ASM-001"
  - id: ASM-002
    statement: Wallet CRUD terbatas ke create dan view untuk MVP — update/delete wallet tidak termasuk.
    impacts:
      - Tidak perlu route /wallets/:id/edit
      - Tidak perlu wallet edit form
      - Wallet current_balance bersifat read-only (diupdate otomatis oleh transaksi)
    confidence: 0.6
    source: "doc-02: ASM-010"
  - id: ASM-003
    statement: Category management untuk MVP mencakup view semua kategori (default + custom) dan create custom category. Update/delete custom category dan editability default category masih open question.
    impacts:
      - UI perlu menampilkan perbedaan visual antara default dan custom category
      - Default category harus read-only di UI
      - Custom category bisa memiliki tombol edit/delete tetapi tidak diimplementasi di fase ini
    confidence: 0.6
    source: "doc-02: ASM-011"
  - id: ASM-004
    statement: "Amount disimpan dalam integer (smallest unit: rupiah) dan ditampilkan dengan format IDR."
    impacts:
      - Input amount menerima angka integer
      - Display amount menggunakan IDR formatting (Intl.NumberFormat)
      - Tidak ada floating-point di amount field
      - Tidak ada currency selector
    confidence: 1.0
    source: "doc-02: ASM-004, ASM-005"
  - id: ASM-005
    statement: Transaction date validasi maksimal hari ini (tidak boleh future date). Backdate tanpa batas bawah.
    impacts:
      - DatePicker membatasi tanggal maksimum ke hari ini
      - Tidak ada minimal date validation
      - User bisa memasukkan transaksi dari tahun kapanpun
    confidence: 0.8
    source: "doc-02: BR-009, ASM-012"
  - id: ASM-006
    statement: Summary dihitung real-time dari transaksi aktif (bukan snapshot).
    impacts:
      - Tidak perlu summary cache di frontend
      - Setiap navigasi ke halaman summary = fetch ulang
      - Cache invalidation setelah create/update/delete transaction perlu invalidate summary query
    confidence: 0.7
    source: "doc-02: ASM-013"
  - id: ASM-007
    statement: API mengembalikan error 404 untuk resource not found milik user lain (security through obscurity).
    impacts:
      - Frontend tidak perlu membedakan 403 vs 404
      - Error handler cukup handle 404 sebagai 'Data tidak ditemukan'
      - Tidak perlu UI untuk permission denied
    confidence: 0.8
    source: "doc-02: ASM-014"
  - id: ASM-008
    statement: Semua form menggunakan client-side validation sebelum submit ke API.
    impacts:
      - Zod schemas di frontend untuk form validation
      - Validasi client-side untuk mengurangi API error
      - API tetap perlu server-side validation (double validation)
    confidence: 1.0
    source: inference
  - id: ASM-009
    statement: Default categories sudah ada saat user pertama kali membuka aplikasi (seeded).
    impacts:
      - Tidak perlu empty state untuk categories
      - Category list selalu punya data default
      - UI selalu bisa menampilkan kategori bahkan sebelum user membuat custom category
    confidence: 1.0
    source: "doc-02: ASM-009"
---

# 03 — Frontend Requirement Mapping

## 1. FR to Frontend Concern Mapping

### 1.1 FR-001: Wallet Management

**Deskripsi:** User dapat membuat dan melihat wallet. Wallet memiliki nama, tipe (cash, bank, e-wallet), saldo awal, dan saldo saat ini. (source: `doc-02: FR-001`)

| Concern | Mapping | Detail |
|---------|---------|--------|
| Routing | Dua route | `/wallets` — daftar wallet. `/wallets/new` — form create wallet. |
| State | Query + Mutation | `useQuery(['wallets'])` untuk daftar. `useMutation` untuk create. `useWalletStore` (Zustand) opsional untuk selected wallet context. |
| API | Dua endpoint | `GET /api/wallets` — list. `POST /api/wallets` — create body: `{name, type, initial_balance}`. |
| Validation | Zod schema | `WalletCreateSchema`: name (required, non-empty), type (enum cash/bank/e-wallet), initial_balance (integer >= 0). |
| UI | 4 komponen utama | `WalletList` (Card grid/stack), `WalletCard` (shadcn Card + Badge for type), `CreateWalletForm` (shadcn Form + Input + Select), `EmptyWalletState` (CTA). |

**Data requirements:** Wallet entity fields — id, name, type, initial_balance, current_balance, created_at. (source: `doc-02: entities[Wallet]`)

**UI state requirements:**

| State | Behavior |
|-------|----------|
| Loading | Skeleton cards (4 placeholder cards) saat fetch wallet list |
| Empty | Empty state with illustration + CTA button: "Buat wallet pertama" — EC-011 |
| Error | Error alert dengan tombol retry: "Gagal memuat data wallet" |
| Create success | Toast: "Wallet berhasil dibuat" + redirect ke /wallets |
| Create error | Form error message: toast atau inline error |
| Edge: wallet type select | Select options: cash, bank, e-wallet dengan icon masing-masing |
| Edge: initial_balance 0 | Valid: kolom opsional dengan default 0 |

---

### 1.2 FR-002: Category Management

**Deskripsi:** Sistem menyediakan kategori income dan expense. Kategori bisa default (system) atau custom (milik user). Income category hanya untuk income transaction. (source: `doc-02: FR-002`)

| Concern | Mapping | Detail |
|---------|---------|--------|
| Routing | Satu route | `/categories` — daftar + create. Bisa jadi nested di settings. |
| State | Query + Mutation | `useQuery(['categories'])` — semua kategori. `useMutation` — create custom. Filter client-side by type. |
| API | Dua endpoint | `GET /api/categories` — list (termasuk default). `POST /api/categories` — create custom: `{name, type}`. |
| Validation | Zod schema | `CategoryCreateSchema`: name (required, unique per type-user), type (enum income/expense). |
| UI | 4 komponen | `CategoryList` (tabs: income/expense), `CategoryCard` (Card + is_default badge), `CreateCategoryForm` (Form + Input + Select), `DefaultBadge`. |

**Data requirements:** Category entity fields — id, name, type (income/expense), is_default (boolean). (source: `doc-02: entities[Category]`)

**UI state requirements:**

| State | Behavior |
|-------|----------|
| Loading | Skeleton list untuk income dan expense tabs |
| Empty | Tidak ada — default categories selalu terisi (ASM-009) — source: `doc-02: BR-014` |
| Error | Error alert dengan retry |
| Create success | Toast + langsung muncul di list |
| Create error | Inline error: "Nama kategori sudah ada" atau "Gagal membuat kategori" |
| Edge: default vs custom | Default category: badge "Default" + disabled edit/delete. Custom category: bisa diedit/dihapus (jika fitur diimplementasi) — ASM-003 |
| Edge: duplicate name | Error validation: kategori dengan nama yang sama untuk tipe yang sama tidak boleh dibuat |
| Edge: category type constraint | Income category only appears when transaction type is income, vice versa — BR-007 |

---

### 1.3 FR-003: Create Transaction

**Deskripsi:** User membuat transaksi income atau expense. Terhubung ke wallet dan kategori. Income tambah balance. Expense kurangi balance. Expense ditolak jika balance tidak cukup. (source: `doc-02: FR-003`)

| Concern | Mapping | Detail |
|---------|---------|--------|
| Routing | Satu route/modal | `/transactions/new` — halaman penuh ATAU Sheet/Dialog dari halaman /transactions. |
| State | Mutation + Query dependencies | `useMutation` create. `useQuery(['wallets'])` dan `useQuery(['categories'])` sebagai dependencies. Local state untuk type toggle. |
| API | Satu endpoint | `POST /api/transactions` body: `{wallet_id, category_id, type, amount, transaction_date, note?}`. |
| Validation | Zod schema + business rules | `TransactionCreateSchema`: wallet_id (required), category_id (required), type (income/expense), amount (integer > 0), transaction_date (date, <= today). Business: category type matches transaction type (BR-007), expense <= wallet balance (BR-008). |
| UI | 7+ komponen | `TransactionForm` (shadcn Form), `TypeToggle` (Switch/Tabs), `WalletSelect` (Select), `CategorySelect` (Select, filter by type), `AmountInput` (Input + IDR format), `DatePicker` (Calendar, max: today), `NoteTextarea` (Textarea), `BalanceWarning` (Alert jika expense exceeds balance). |

**Data requirements:** Transaction entity fields untuk submit. Wallet current_balance untuk validasi. Category type untuk filtering. (source: `doc-02: entities[Transaction, Wallet, Category]`)

**UI state requirements:**

| State | Behavior |
|-------|----------|
| Loading | Skeleton form + loading select options (wallets + categories) |
| Error (form deps) | Error alert jika wallet atau category gagal di-fetch |
| Error (validation) | Inline form errors per field (Zod validation) |
| Error (balance) | Alert: "Saldo wallet tidak mencukupi" — tetap di halaman form |
| Error (API) | Toast: "Gagal membuat transaksi" + detail error dari API |
| Success | Toast: "Transaksi berhasil dicatat" + redirect ke /transactions |
| Edge: type toggle | Saat toggle income<->expense: category select reset + filter ulang berdasarkan type baru |
| Edge: wallet balance | Saat expense: tampilkan balance warning jika amount melebihi saldo — real-time saat user input |
| Edge: future date | DatePicker nonaktifkan tanggal > hari ini — BR-009 |
| Edge: amount 0 | Form prevent submit: amount > 0 — BR-005, EC-009 |
| Edge: default categories | Category list selalu terisi — default category tersedia untuk income dan expense — BR-014 |

---

### 1.4 FR-004: Transaction History

**Deskripsi:** User melihat daftar transaksi miliknya. Bisa filter berdasarkan date range, type, wallet, category, dan keyword note. Urut descending berdasarkan transaction date. (source: `doc-02: FR-004`)

| Concern | Mapping | Detail |
|---------|---------|--------|
| Routing | Satu route + search params | `/transactions`. Filter sebagai URL search params: `?date_from=&date_to=&type=&wallet_id=&category_id=&q=&page=`. |
| State | Query + URL state | `useQuery(['transactions', filters])`. Filter state di URL (useSearchParams) sebagai source of truth. Debounce untuk search query (300ms). |
| API | Satu endpoint | `GET /api/transactions` query params: date_from, date_to, type, wallet_id, category_id, q, page, per_page. Response: `{data: Transaction[], total, page, per_page}`. |
| Validation | Optional params | Semua filter optional. Tidak perlu Zod. Validasi tipe di API. |
| UI | 6 komponen | `TransactionTable` (Table shadcn/ui), `FilterBar` (DateRangePicker + Select x3 + SearchInput), `ActiveFilterChip` (Badge — removable), `PaginationControls`, `EmptyTransactionState` (CTA), `LoadingSkeleton`. |

**Data requirements:** Transaction fields + related Wallet name + Category name. (source: `doc-02: entities[Transaction, Wallet, Category]`)

**UI state requirements:**

| State | Behavior |
|-------|----------|
| Loading | Skeleton table (5 row placeholders) |
| Empty (no transactions) | Empty state: "Belum ada transaksi" + CTA "Catat transaksi pertama" — EC-012 |
| Empty (filter no results) | Empty state: "Tidak ada transaksi yang cocok dengan filter" + tombol "Reset filter" — EC-006 |
| Error | Error alert: "Gagal memuat transaksi" + retry button |
| Filter active | FilterChip component menampilkan active filters dengan tombol X untuk remove |
| Pagination | Page info: "Menampilkan 1-10 dari 50 transaksi" |
| Edge: URL state sync | Filter state persist di URL — user bisa bookmark/share filtered view |
| Edge: empty wallet | Jika wallet list kosong, filter wallet disabled dengan tooltip: "Buat wallet dulu" |

---

### 1.5 FR-005: Update Transaction

**Deskripsi:** User mengubah transaksi aktif. Perubahan update saldo wallet secara konsisten. Jika saldo tidak valid, ditolak. (source: `doc-02: FR-005`)

| Concern | Mapping | Detail |
|---------|---------|--------|
| Routing | Satu route | `/transactions/:id/edit` — halaman edit. Atau modal dari /transactions. |
| State | Query + Mutation | `useQuery(['transactions', id])` — fetch existing. `useMutation` — update. Dependencies: wallets, categories. |
| API | Dua endpoint | `GET /api/transactions/:id` — fetch existing. `PUT /api/transactions/:id` — update body: `{wallet_id, category_id, type, amount, transaction_date, note}`. |
| Validation | Zod schema + business rules | `TransactionUpdateSchema` (sama dengan create). Plus: transaction must be active (BR-021). Type change re-validates category. Wallet change adjusts both balances (EC-003). |
| UI | 3 komponen | `EditTransactionForm` (pre-filled TransactionForm), `LoadingOverride` (skeleton saat fetch existing), `NotFoundAlert` (jika transaction tidak ditemukan — EC-016). |

**Data requirements:** Transaction entity existing data (pre-fill). Wallet current_balance for validation. Category list for select. (source: `doc-02: entities[Transaction, Wallet, Category]`)

**UI state requirements:**

| State | Behavior |
|-------|----------|
| Loading (fetch) | Skeleton form + loading status "Memuat data transaksi..." |
| Not found | Alert: "Transaksi tidak ditemukan" + link back ke /transactions — EC-016 |
| Error (validation) | Inline form errors — sama seperti create |
| Error (balance) | Alert: "Saldo wallet tidak mencukupi setelah perubahan" — EC-002 |
| Success | Toast: "Transaksi berhasil diubah" + redirect ke /transactions |
| Edge: type change | Jika user toggel income<->expense: category select reset, category list filter by new type — EC-002 |
| Edge: wallet change | Saat wallet_id berubah: balance warning perlu cek balance wallet baru — EC-003 |
| Edge: amount change | Re-validate balance if type is expense: new amount vs wallet balance |
| Edge: soft-deleted transaction | Jika transaksi sudah dihapus: tampilkan error + disable edit — BR-021 |

---

### 1.6 FR-006: Delete Transaction

**Deskripsi:** User menghapus transaksi aktif dengan soft delete. Transaksi tidak muncul di history dan summary. Saldo wallet dikembalikan. (source: `doc-02: FR-006`)

| Concern | Mapping | Detail |
|---------|---------|--------|
| Routing | Tidak ada route khusus | Action dari tombol di list item atau halaman edit. |
| State | Mutation + cache invalidation | `useMutation` soft delete. Optimistic update. Invalidate: `['transactions']`, `['wallets']`, `['summary']`. |
| API | Satu endpoint | `DELETE /api/transactions/:id` — soft delete. Backend reverse balance. Response: success + updated wallet balance. |
| Validation | Konfirmasi user | Must be active transaction (BR-021). Konfirmasi dialog sebelum delete. |
| UI | 2 komponen | `DeleteButton` (Button icon: Trash2). `ConfirmDialog` (AlertDialog: "Apakah kamu yakin? Saldo akan disesuaikan."). |

**Data requirements:** Transaction id. Wallet current_balance (untuk feedback setelah delete). (source: `doc-02: entities[Transaction, Wallet]`)

**UI state requirements:**

| State | Behavior |
|-------|----------|
| Loading | Button loading spinner + disabled |
| Success | Toast: "Transaksi berhasil dihapus. Saldo wallet telah disesuaikan." |
| Error | Toast: "Gagal menghapus transaksi" |
| Edge: income delete | Wallet balance berkurang — EC-004 |
| Edge: expense delete | Wallet balance bertambah — EC-005 |
| Edge: already deleted | Toast error jika transaksi sudah soft-deleted — BR-021 |
| Edge: confirm dialog | Dialog dengan dua tombol: "Batal" (secondary) dan "Hapus" (destructive — red) |
| Edge: optimistic removal | List item langsung hilang dari UI + undo option dalam toast (opsional) |

---

### 1.7 FR-007: Monthly Summary

**Deskripsi:** User melihat summary keuangan per bulan: total income, expense, net balance, transaction count, expense breakdown by category, income breakdown by category. (source: `doc-02: FR-007`)

| Concern | Mapping | Detail |
|---------|---------|--------|
| Routing | Satu route | `/summary` — halaman summary. Month/year sebagai search params: `?month=7&year=2026`. Atau sebagai section di dashboard `/`. |
| State | Query + local state | `useQuery(['summary', {month, year}])`. Month/year selector: local state (useSearchParams). |
| API | Satu endpoint | `GET /api/summary?month=&year=` Response: `{total_income, total_expense, net_balance, transaction_count, income_by_category: [{category_id, name, total}], expense_by_category: [{category_id, name, total}]}`. |
| Validation | Minimal | month: 1-12, year: reasonable range. Tidak perlu Zod schema. |
| UI | 8 komponen | `SummaryHeader` (3 StatCards: income, expense, net), `MonthYearPicker` (Select + Select), `TransactionCountBadge`, `IncomeBreakdownSection` (list with progress bar), `ExpenseBreakdownSection` (list with progress bar), `CategoryBreakdownItem` (Card atau ListItem), Empty state, Loading skeleton. |

**Data requirements:** Aggregated transaction data per month. Category breakdown by type. (source: `doc-02: entities[Transaction, Category]`)

**UI state requirements:**

| State | Behavior |
|-------|----------|
| Loading | Skeleton untuk 3 stat cards + 2 breakdown sections |
| Empty (no data) | Tampilkan nilai 0 untuk income, expense, net + "Tidak ada transaksi di bulan ini" — EC-013 |
| Error | Error alert: "Gagal memuat summary" + retry |
| Success with data | Cards + breakdown lists dengan data |
| Edge: month/year nav | User bisa ganti bulan: prev/next month buttons atau select dropdown |
| Edge: current month default | Default: bulan dan tahun saat ini |
| Edge: negative net | Net balance bisa negatif (expense > income) — tampilkan di StatCard dengan warna merah |
| Edge: many categories | Category breakdown items diurutkan dari total terbesar ke terkecil |

---

## 2. Data Requirements per FR

| FR | Data Required | Entity Source | Fetch Strategy |
|----|---------------|---------------|----------------|
| FR-001 | Wallet list (id, name, type, initial_balance, current_balance) | Wallet | `useQuery(['wallets'])` — eager fetch |
| FR-002 | Category list (id, name, type, is_default) | Category | `useQuery(['categories'])` — eager fetch |
| FR-003 | Wallet list + Category list (filtered by type) | Wallet, Category | Fetch bersama: `Promise.all([queryClient.fetchQuery(['wallets']), queryClient.fetchQuery(['categories'])])` |
| FR-004 | Transaction list + Wallet name + Category name | Transaction, Wallet, Category | API join response — backend include wallet_name dan category_name |
| FR-005 | Single transaction + Wallet list + Category list | Transaction, Wallet, Category | `useQuery(['transactions', id])` + data dari cache jika sudah ada |
| FR-006 | Transaction id — minimal | Transaction | Tidak perlu fetch — action dari list context |
| FR-007 | Aggregated summary data by month | Transaction, Category | Endpoint dedicated — compute di backend |

---

## 3. UI State Requirements Summary per FR

| FR | Loading | Empty | Error | Lead Edge Case |
|----|---------|-------|-------|----------------|
| FR-001 | Skeleton 4 cards | "Buat wallet pertama" + CTA | Retry alert | No wallet = block create transaction (EC-011) |
| FR-002 | Skeleton tabs | N/A (default exist) | Retry alert | Default vs Custom distinction |
| FR-003 | Form skeleton + select loading | N/A (form) | Inline errors + balance alert | Insufficient balance (EC-001, EC-017) |
| FR-004 | Skeleton 5 rows | "Belum ada transaksi" + CTA | Retry alert | Empty filter results (EC-006) |
| FR-005 | Form skeleton | "Transaksi tidak ditemukan" (EC-016) | Inline errors | Type change + wallet change recalc (EC-002, EC-003) |
| FR-006 | Button spinner | N/A (action) | Toast error | Income vs expense balance reversal (EC-004, EC-005) |
| FR-007 | 3 card skeleton | All values = 0 | Retry alert | Negative net balance |

---

## 4. Cross-cutting Concerns

### 4.1 Auth Context

(source: `doc-02: ASM-001`, `doc-02: BR-001`, `doc-02: BR-019`)

- User assumed authenticated — tidak ada login/register screen di MVP
- Semua API call perlu menyertakan user identifier (dari session/context)
- Tidak perlu auth guard di route level atau component level
- Jika ada kebutuhan auth di masa depan: tambahkan middleware + provider

### 4.2 Navigation Structure

Route structure (perlu dikonfirmasi Agent 4):

```
/                     — Dashboard (mungkin include summary + recent transactions)
/wallets              — Wallet list
/wallets/new          — Create wallet
/categories           — Category management
/transactions         — Transaction list + filters
/transactions/new     — Create transaction
/transactions/:id/edit — Edit transaction
/summary              — Monthly summary
```

Navigation component: `BottomNav` atau `Sidebar` dengan links ke: Dashboard, Wallets, Transactions, Categories, Summary.

### 4.3 Shared Components

| Component | Usage | shadcn/ui |
|-----------|-------|-----------|
| `AppLayout` | Layout wrapper — Header + Nav + Content area | - |
| `LoadingSkeleton` | Generic loading placeholder | Skeleton |
| `ErrorAlert` | Error state dengan retry | Alert |
| `EmptyState` | Empty state dengan icon + message + CTA | Card |
| `Toast` | Success/error feedback | Toast/Sonner |
| `ConfirmDialog` | Konfirmasi aksi destruktif | AlertDialog |
| `PageHeader` | Halaman header dengan title + action button | - |
| `FilterBar` | Generic filter bar — reusable untuk transaction list | - |

### 4.4 Error Handling Strategy

- **API errors:** Intercept di queryClient default `onError` — show toast
- **Network errors:** React Query retry (3x default) + error state component
- **Validation errors:** Inline form errors (Zod)
- **Not found (404):** Tidak dibedakan dengan forbidden (ASM-007) — tampilkan "Data tidak ditemukan"
- **Business errors (422):** Backend return structured error — frontend map ke field-level errors
- **Error boundaries:** Per-route ErrorBoundary untuk unexpected errors

---

## 5. Dependencies between FRs

```
FR-001 (Wallet) ─┬──> FR-003 (Create Transaction) ─┬──> FR-005 (Update Transaction)
FR-002 (Category) ┘                                  │
                                                     ├──> FR-006 (Delete Transaction)
                                                     └──> FR-007 (Monthly Summary)
FR-004 (Transaction History) ──────────────┬─────────┘
                                            │
                                            └──> FR-005 (need to find transaction)
                                            └──> FR-006 (need to find transaction)
```

| Dependency | Type | Rationale |
|------------|------|-----------|
| FR-003 -> FR-001 | Data dependency | Create transaction membutuhkan wallet list untuk select |
| FR-003 -> FR-002 | Data dependency | Create transaction membutuhkan category list untuk select |
| FR-005 -> FR-003 | Pattern reuse | Edit form menggunakan form yang sama dengan create |
| FR-005 -> FR-004 | Navigation | User perlu menemukan transaksi dari list untuk diedit |
| FR-006 -> FR-004 | Navigation | User perlu menemukan transaksi dari list untuk dihapus |
| FR-007 -> FR-003 | Data source | Summary menghitung aggregasi dari transaksi yang dibuat |

**Implementation order:** FR-001 -> FR-002 -> FR-003 -> FR-004 -> FR-007 -> FR-005 -> FR-006

Rationale: Wallet dan Category adalah foundations. Transaction create adalah core. History dan summary consume transaction data. Edit dan delete adalah enhancement dari history.

---

## 6. Confidence Scores

| FR | Score | Rationale |
|----|-------|-----------|
| FR-001 | 1.0 | Wallet create + view explicit di PRD. Route mapping straightforward. |
| FR-002 | 1.0 | Category view + create explicit. Default categories behavior clear. |
| FR-003 | 1.0 | Transaction creation explicit dengan semua validasi dan edge cases tercatat. |
| FR-004 | 1.0 | History + filter specifications explicit. All filter types documented. |
| FR-005 | 0.9 | Update semantics clear. Slight uncertainty on edit UX pattern (page vs modal). |
| FR-006 | 1.0 | Soft delete explicit. Balance reversal behavior clear. |
| FR-007 | 1.0 | Summary fields explicit. Breakdown by category documented. |

---

## 7. Assumptions

| ID | Statement | Impacts | Confidence | Source |
|----|-----------|---------|-----------|--------|
| ASM-001 | User sudah authenticated — tidak ada login page | No auth guard, no login route | 1.0 | `doc-02: ASM-001` |
| ASM-002 | MVP Wallet CRUD terbatas create + view | Route /wallets/:id/edit tidak dibuat | 0.6 | `doc-02: ASM-010` |
| ASM-003 | Category update/delete tidak termasuk MVP | Default category read-only, custom category create-only | 0.6 | `doc-02: ASM-011` |
| ASM-004 | Amount integer (IDR smallest unit) | Input integer, format IDR, no currency selector | 1.0 | `doc-02: ASM-004, ASM-005` |
| ASM-005 | Max date = today, no min date | DatePicker max: today, no lower bound | 0.8 | `doc-02: BR-009, ASM-012` |
| ASM-006 | Summary real-time (no snapshot) | No cache, fetch on every visit | 0.7 | `doc-02: ASM-013` |
| ASM-007 | 404 for not-found + forbidden | Error handler: "Data tidak ditemukan" saja | 0.8 | `doc-02: ASM-014` |
| ASM-008 | Client-side validation before submit | Zod schemas for all forms | 1.0 | inference |
| ASM-009 | Default categories seeded on first use | No empty state for categories | 1.0 | `doc-02: ASM-009` |

---

## 8. DoD Checklist

- [x] Each FR (FR-001 through FR-007) mapped to one or more frontend concerns (routing, state, api, validation, ui)
- [x] Data requirements identified per FR with entity sources
- [x] UI state requirements identified per FR (loading, empty, error, edge cases)
- [x] References doc-02 entities and business rules — all cross-references use provenance markers
- [x] All entity names PascalCase (Wallet, Category, Transaction, User)
- [x] Frontmatter YAML valid and complete with prd_source_hash, agent, schema_version, status, summary
- [x] Requirements array includes all 7 FR with frontend_concern objects
- [x] Assumptions documented in structured format with impacts and confidence
- [x] Cross-cutting concerns documented (auth, navigation, shared components, error handling)
- [x] Dependencies between FRs mapped with implementation order
- [x] Confidence scores per FR with rationale
- [x] No placeholder, TODO, or "TBD"
- [x] Output file matches workflow.yaml: docs/03-frontend-requirement-mapping.md
- [x] All references use proper provenance markers (source: "doc-02: FR-NNN" or source: inference)
