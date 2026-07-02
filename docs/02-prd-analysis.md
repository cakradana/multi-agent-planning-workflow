---
title: PRD Analysis
description: Entity extraction, business rules, user stories, edge cases, and functional requirements from Pocket PRD
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 2
schema_version: 1
status: complete
summary: >
  Pocket is a personal finance lite application for recording daily income and
  expense transactions. The MVP scope covers five areas: Wallet Management,
  Category Management, Transaction Management, Transaction History and Filtering,
  and Monthly Financial Summary. Four domain entities were extracted: User,
  Wallet, Category, and Transaction. User is inferred as the owner entity since
  the PRD assumes pre-authenticated users. Wallet stores name, type (cash, bank,
  e-wallet), initial balance, and current balance. Category supports two types
  (income, expense) with both default system categories and user-custom categories.
  Transaction connects Wallet and Category, supports income and expense types,
  and uses soft delete. Fifteen business rules were extracted covering data
  isolation (BR-001), wallet ownership (BR-002), category validation (BR-003),
  transaction integrity (BR-004 through BR-009), edit and delete semantics (BR-010
  through BR-012), summary calculation (BR-013), and default category provisioning
  (BR-014, BR-015). Eleven user stories were identified with priorities: seven
  high-priority (wallet CRUD, category usage, transaction recording, monthly
  summary) and four medium-priority (filtering, edit, delete, category breakdown).
  Seven functional requirements detail Wallet Management (FR-001), Category
  Management (FR-002), Create Transaction (FR-003), Transaction History (FR-004),
  Update Transaction (FR-005), Delete Transaction (FR-006), and Monthly Summary
  (FR-007). Eleven edge cases from the PRD edge cases table plus seven error
  states were catalogued. Seven acceptance criteria sets and fifteen Gherkin
  scenarios provide detailed behavioral specifications. The PRD excludes
  authentication, bank integration, OCR, multi-currency, shared wallets,
  recurring transactions, budget planning, and export features from MVP scope.
  Seven open questions remain about wallet update/delete, default category
  mutability, backdating limits, summary computation strategy, not-found vs
  forbidden semantics, and initial balance mutability.
entities:
  - name: User
    fields:
      - name: id
        type: integer
        source: inference
    relationships:
      - has_many: Wallet
      - has_many: Category
      - has_many: Transaction
    confidence: 0.8
  - name: Wallet
    fields:
      - name: id
        type: integer
        source: PRD line 364
      - name: user_id
        type: integer
        source: PRD line 365
      - name: name
        type: string
        source: PRD line 366
      - name: type
        type: enum (cash, bank, e-wallet)
        source: PRD line 367
      - name: initial_balance
        type: integer
        source: PRD line 368
      - name: current_balance
        type: integer
        source: PRD line 369
      - name: created_at
        type: timestamp
        source: PRD line 370
      - name: updated_at
        type: timestamp
        source: PRD line 371
      - name: deleted_at
        type: timestamp
        source: PRD line 372
    relationships:
      - belongs_to: User
      - has_many: Transaction
    confidence: 1.0
  - name: Category
    fields:
      - name: id
        type: integer
        source: PRD line 377
      - name: user_id
        type: integer
        source: PRD line 378
      - name: name
        type: string
        source: PRD line 379
      - name: type
        type: enum (income, expense)
        source: PRD line 380
      - name: is_default
        type: boolean
        source: PRD line 381
      - name: created_at
        type: timestamp
        source: PRD line 382
      - name: updated_at
        type: timestamp
        source: PRD line 383
      - name: deleted_at
        type: timestamp
        source: PRD line 384
    relationships:
      - belongs_to: User (nullable for system default)
      - has_many: Transaction
    confidence: 1.0
  - name: Transaction
    fields:
      - name: id
        type: integer
        source: PRD line 389
      - name: user_id
        type: integer
        source: PRD line 390
      - name: wallet_id
        type: integer
        source: PRD line 391
      - name: category_id
        type: integer
        source: PRD line 392
      - name: type
        type: enum (income, expense)
        source: PRD line 393
      - name: amount
        type: integer
        source: PRD line 394
      - name: transaction_date
        type: date
        source: PRD line 395
      - name: note
        type: string
        source: PRD line 396
      - name: created_at
        type: timestamp
        source: PRD line 397
      - name: updated_at
        type: timestamp
        source: PRD line 398
      - name: deleted_at
        type: timestamp
        source: PRD line 399
    relationships:
      - belongs_to: User
      - belongs_to: Wallet
      - belongs_to: Category
    confidence: 1.0

business_rules:
  - id: BR-001
    description: Setiap user hanya dapat melihat dan mengelola data miliknya sendiri.
    source: PRD line 121
    confidence: 1.0
  - id: BR-002
    description: Wallet wajib dimiliki oleh user.
    source: PRD line 122
    confidence: 1.0
  - id: BR-003
    description: Category wajib dimiliki oleh user atau berasal dari default system category.
    source: PRD line 123
    confidence: 1.0
  - id: BR-004
    description: Transaction wajib memiliki wallet, category, type, amount, dan transaction date.
    source: PRD line 124
    confidence: 1.0
  - id: BR-005
    description: Amount transaksi harus lebih besar dari 0.
    source: PRD line 125
    confidence: 1.0
  - id: BR-006
    description: Transaction type hanya boleh income atau expense.
    source: PRD line 126
    confidence: 1.0
  - id: BR-007
    description: Category type harus sesuai dengan transaction type.
    source: PRD line 127
    confidence: 1.0
  - id: BR-008
    description: Expense tidak boleh membuat wallet balance menjadi negatif.
    source: PRD line 128
    confidence: 1.0
  - id: BR-009
    description: Transaction date tidak boleh lebih dari tanggal hari ini.
    source: PRD line 129
    confidence: 1.0
  - id: BR-010
    description: Transaction dapat diedit selama masih aktif.
    source: PRD line 130
    confidence: 1.0
  - id: BR-011
    description: Transaction yang dihapus tidak muncul di history dan summary.
    source: PRD line 131
    confidence: 1.0
  - id: BR-012
    description: Wallet yang memiliki transaksi tidak boleh hard delete.
    source: PRD line 132
    confidence: 1.0
  - id: BR-013
    description: Summary bulanan dihitung berdasarkan bulan dan tahun transaksi.
    source: PRD line 133
    confidence: 1.0
  - id: BR-014
    description: Default category tersedia untuk income dan expense.
    source: PRD line 134
    confidence: 1.0
  - id: BR-015
    description: User dapat membuat custom category sesuai tipe transaksi.
    source: PRD line 135
    confidence: 1.0
  - id: BR-016
    description: Amount disimpan dalam bentuk integer.
    source: PRD line 109 (Assumptions section)
    confidence: 1.0
  - id: BR-017
    description: Currency default adalah IDR.
    source: PRD line 108 (Assumptions section)
    confidence: 1.0
  - id: BR-018
    description: Delete transaksi menggunakan soft delete.
    source: PRD line 112 (Assumptions section)
    confidence: 1.0
  - id: BR-019
    description: Data antar-user tidak boleh saling terlihat.
    source: PRD line 107 (Assumptions section)
    confidence: 1.0
  - id: BR-020
    description: Summary dihitung dari transaksi aktif (tidak termasuk soft-deleted).
    source: PRD line 111 (Assumptions section)
    confidence: 1.0
  - id: BR-021
    description: Soft-deleted transaksi tidak dapat diedit oleh user.
    source: PRD line 571 (Deletion section)
    confidence: 1.0

user_stories:
  - id: US-001
    description: Sebagai user, saya ingin membuat wallet agar saya dapat mengelompokkan sumber uang pribadi saya.
    as_a: user
    i_want: membuat wallet
    so_that: saya dapat mengelompokkan sumber uang pribadi saya
    priority: High
    acceptance_criteria:
      - User dapat membuat wallet dengan nama, tipe, dan saldo awal (AC-001 No 1)
      - Nama wallet wajib diisi (AC-001 No 2)
      - Tipe wallet harus salah satu dari cash, bank, atau e-wallet (AC-001 No 3)
      - Saldo awal tidak boleh kurang dari 0 (AC-001 No 4)
    source: PRD line 143
    confidence: 1.0
  - id: US-002
    description: Sebagai user, saya ingin melihat daftar wallet agar saya mengetahui wallet yang saya miliki.
    as_a: user
    i_want: melihat daftar wallet
    so_that: saya mengetahui wallet yang saya miliki
    priority: High
    acceptance_criteria:
      - User hanya dapat melihat wallet miliknya sendiri (AC-001 No 5)
    source: PRD line 144
    confidence: 1.0
  - id: US-003
    description: Sebagai user, saya ingin menggunakan kategori transaksi agar pemasukan dan pengeluaran saya terorganisir.
    as_a: user
    i_want: menggunakan kategori transaksi
    so_that: pemasukan dan pengeluaran saya terorganisir
    priority: High
    acceptance_criteria:
      - User dapat melihat daftar kategori income dan expense (AC-002 No 1)
      - User dapat membuat custom category (AC-002 No 2)
      - Nama category wajib diisi (AC-002 No 3)
      - Category type harus income atau expense (AC-002 No 4)
      - Category expense tidak dapat digunakan untuk transaksi income (AC-002 No 5)
      - Category income tidak dapat digunakan untuk transaksi expense (AC-002 No 6)
    source: PRD line 145
    confidence: 1.0
  - id: US-004
    description: Sebagai user, saya ingin mencatat transaksi income agar pemasukan saya tercatat.
    as_a: user
    i_want: mencatat transaksi income
    so_that: pemasukan saya tercatat
    priority: High
    acceptance_criteria:
      - User dapat membuat transaksi income (AC-003 No 1)
      - Amount wajib lebih besar dari 0 (AC-003 No 3)
      - Wallet wajib valid dan milik user (AC-003 No 4)
      - Category wajib valid dan sesuai dengan transaction type (AC-003 No 5)
      - Income menambah saldo wallet (AC-003 No 7)
    source: PRD line 146
    confidence: 1.0
  - id: US-005
    description: Sebagai user, saya ingin mencatat transaksi expense agar pengeluaran saya tercatat.
    as_a: user
    i_want: mencatat transaksi expense
    so_that: pengeluaran saya tercatat
    priority: High
    acceptance_criteria:
      - User dapat membuat transaksi expense (AC-003 No 2)
      - Amount wajib lebih besar dari 0 (AC-003 No 3)
      - Wallet wajib valid dan milik user (AC-003 No 4)
      - Category wajib valid dan sesuai dengan transaction type (AC-003 No 5)
      - Expense mengurangi saldo wallet (AC-003 No 8)
      - Expense ditolak jika saldo wallet tidak cukup (AC-003 No 9)
    source: PRD line 147
    confidence: 1.0
  - id: US-006
    description: Sebagai user, saya ingin melihat riwayat transaksi agar saya dapat meninjau catatan keuangan saya.
    as_a: user
    i_want: melihat riwayat transaksi
    so_that: saya dapat meninjau catatan keuangan saya
    priority: High
    acceptance_criteria:
      - User dapat melihat daftar transaksi aktif (AC-004 No 1)
      - Transaksi yang sudah dihapus tidak muncul (AC-004 No 2)
      - Hasil transaksi diurutkan dari tanggal terbaru (AC-004 No 8)
    source: PRD line 148
    confidence: 1.0
  - id: US-007
    description: Sebagai user, saya ingin memfilter transaksi berdasarkan tanggal, tipe, kategori, dan wallet agar pencarian lebih mudah.
    as_a: user
    i_want: memfilter transaksi berdasarkan tanggal, tipe, kategori, dan wallet
    so_that: pencarian lebih mudah
    priority: Medium
    acceptance_criteria:
      - User dapat memfilter transaksi berdasarkan date range (AC-004 No 3)
      - User dapat memfilter transaksi berdasarkan type (AC-004 No 4)
      - User dapat memfilter transaksi berdasarkan wallet (AC-004 No 5)
      - User dapat memfilter transaksi berdasarkan category (AC-004 No 6)
      - User dapat mencari transaksi berdasarkan note (AC-004 No 7)
    source: PRD line 149
    confidence: 1.0
  - id: US-008
    description: Sebagai user, saya ingin mengubah transaksi agar saya dapat memperbaiki data yang salah.
    as_a: user
    i_want: mengubah transaksi
    so_that: saya dapat memperbaiki data yang salah
    priority: Medium
    acceptance_criteria:
      - User dapat mengubah transaksi aktif (AC-005 No 1)
      - Update amount memengaruhi saldo wallet (AC-005 No 2)
      - Update wallet memindahkan efek transaksi ke wallet baru (AC-005 No 3)
      - Update category harus tetap sesuai dengan transaction type (AC-005 No 4)
      - Update ditolak jika menyebabkan saldo wallet tidak valid (AC-005 No 5)
      - User tidak dapat mengubah transaksi milik user lain (AC-005 No 6)
    source: PRD line 150
    confidence: 1.0
  - id: US-009
    description: Sebagai user, saya ingin menghapus transaksi agar data yang tidak valid tidak lagi muncul.
    as_a: user
    i_want: menghapus transaksi
    so_that: data yang tidak valid tidak lagi muncul
    priority: Medium
    acceptance_criteria:
      - User dapat menghapus transaksi aktif (AC-006 No 1)
      - Delete transaksi bersifat soft delete (AC-006 No 2)
      - Saldo wallet disesuaikan setelah transaksi dihapus (AC-006 No 3)
      - Transaksi yang dihapus tidak muncul pada history (AC-006 No 4)
      - Transaksi yang dihapus tidak dihitung pada summary (AC-006 No 5)
    source: PRD line 151
    confidence: 1.0
  - id: US-010
    description: Sebagai user, saya ingin melihat summary bulanan agar saya mengetahui total income, expense, dan net balance.
    as_a: user
    i_want: melihat summary bulanan
    so_that: saya mengetahui total income, expense, dan net balance
    priority: High
    acceptance_criteria:
      - User dapat melihat summary berdasarkan bulan dan tahun (AC-007 No 1)
      - Summary menampilkan total income (AC-007 No 2)
      - Summary menampilkan total expense (AC-007 No 3)
      - Summary menampilkan net balance (AC-007 No 4)
      - Summary menampilkan jumlah transaksi aktif (AC-007 No 5)
      - Summary tidak menghitung transaksi yang sudah dihapus (AC-007 No 8)
    source: PRD line 152
    confidence: 1.0
  - id: US-011
    description: Sebagai user, saya ingin melihat breakdown transaksi berdasarkan kategori agar saya tahu kategori pemasukan dan pengeluaran terbesar.
    as_a: user
    i_want: melihat breakdown transaksi berdasarkan kategori
    so_that: saya tahu kategori pemasukan dan pengeluaran terbesar
    priority: Medium
    acceptance_criteria:
      - Summary menampilkan breakdown income by category (AC-007 No 6)
      - Summary menampilkan breakdown expense by category (AC-007 No 7)
    source: PRD line 153
    confidence: 1.0

edge_cases:
  - id: EC-001
    scenario: User membuat expense lebih besar dari saldo wallet
    expected_behavior: Request ditolak
    severity: High
    source: PRD line 579
    confidence: 1.0
  - id: EC-002
    scenario: User update income menjadi expense
    expected_behavior: Sistem memvalidasi ulang category dan saldo
    severity: High
    source: PRD line 580
    confidence: 1.0
  - id: EC-003
    scenario: User update wallet pada transaksi lama
    expected_behavior: Saldo wallet lama dan baru harus disesuaikan
    severity: High
    source: PRD line 581
    confidence: 1.0
  - id: EC-004
    scenario: User delete transaksi income
    expected_behavior: Saldo wallet dikurangi sesuai amount income yang dihapus
    severity: High
    source: PRD line 582
    confidence: 1.0
  - id: EC-005
    scenario: User delete transaksi expense
    expected_behavior: Saldo wallet dikembalikan sesuai amount expense yang dihapus
    severity: High
    source: PRD line 583
    confidence: 1.0
  - id: EC-006
    scenario: User filter tanggal tanpa transaksi
    expected_behavior: Sistem menampilkan empty state
    severity: Medium
    source: PRD line 584
    confidence: 1.0
  - id: EC-007
    scenario: User menggunakan category yang sudah dihapus
    expected_behavior: Request ditolak
    severity: High
    source: PRD line 585
    confidence: 1.0
  - id: EC-008
    scenario: User mengakses data milik user lain
    expected_behavior: Sistem menolak akses atau mengembalikan not found
    severity: High
    source: PRD line 586
    confidence: 1.0
  - id: EC-009
    scenario: User membuat transaksi dengan amount 0
    expected_behavior: Request ditolak
    severity: High
    source: PRD line 587
    confidence: 1.0
  - id: EC-010
    scenario: User membuat transaksi dengan tanggal masa depan
    expected_behavior: Request ditolak
    severity: High
    source: PRD line 588
    confidence: 1.0
  - id: EC-011
    scenario: Wallet belum tersedia saat user membuka aplikasi
    expected_behavior: Sistem menampilkan empty state dan meminta user membuat wallet
    severity: Medium
    source: PRD line 472
    confidence: 1.0
  - id: EC-012
    scenario: Transaction belum tersedia (history kosong)
    expected_behavior: Sistem menampilkan empty state transaksi
    severity: Medium
    source: PRD line 473
    confidence: 1.0
  - id: EC-013
    scenario: Summary tidak memiliki data untuk bulan dipilih
    expected_behavior: Sistem menampilkan nilai 0 untuk income, expense, dan net balance
    severity: Medium
    source: PRD line 474
    confidence: 1.0
  - id: EC-014
    scenario: Wallet tidak ditemukan saat akses
    expected_behavior: Sistem mengembalikan error data tidak ditemukan
    severity: High
    source: PRD line 475
    confidence: 1.0
  - id: EC-015
    scenario: Category tidak ditemukan saat akses
    expected_behavior: Sistem mengembalikan error data tidak ditemukan
    severity: High
    source: PRD line 476
    confidence: 1.0
  - id: EC-016
    scenario: Transaction tidak ditemukan saat akses
    expected_behavior: Sistem mengembalikan error data tidak ditemukan
    severity: High
    source: PRD line 477
    confidence: 1.0
  - id: EC-017
    scenario: Wallet balance tidak cukup untuk expense
    expected_behavior: Sistem mengembalikan error business validation
    severity: High
    source: PRD line 478
    confidence: 1.0
  - id: EC-018
    scenario: Input tidak valid (validasi gagal)
    expected_behavior: Sistem mengembalikan validation error
    severity: High
    source: PRD line 479
    confidence: 1.0

functional_requirements:
  - id: FR-001
    description: Wallet Management - Sistem menyediakan kemampuan untuk membuat dan melihat wallet milik user. Wallet memiliki informasi dasar seperti nama wallet, tipe wallet (cash, bank, e-wallet), saldo awal, dan saldo saat ini.
    related_entities:
      - Wallet
    related_user_stories:
      - US-001
      - US-002
    source: PRD line 159
    confidence: 1.0
  - id: FR-002
    description: Category Management - Sistem menyediakan kategori transaksi untuk income dan expense. Kategori dapat berupa default category atau custom category milik user. Kategori income hanya dapat digunakan untuk transaksi income. Kategori expense hanya dapat digunakan untuk transaksi expense.
    related_entities:
      - Category
    related_user_stories:
      - US-003
    source: PRD line 169
    confidence: 1.0
  - id: FR-003
    description: Create Transaction - User dapat membuat transaksi income atau expense. Transaksi harus terhubung ke wallet dan category. Income menambah saldo wallet. Expense mengurangi saldo wallet dan ditolak jika saldo tidak cukup.
    related_entities:
      - Transaction
      - Wallet
      - Category
    related_user_stories:
      - US-004
      - US-005
    source: PRD line 178
    confidence: 1.0
  - id: FR-004
    description: Transaction History - User dapat melihat daftar transaksi miliknya. Riwayat dapat difilter berdasarkan date range, transaction type, wallet, category, dan keyword pada note. Daftar ditampilkan descending berdasarkan transaction date terbaru.
    related_entities:
      - Transaction
    related_user_stories:
      - US-006
      - US-007
    source: PRD line 186
    confidence: 1.0
  - id: FR-005
    description: Update Transaction - User dapat mengubah transaksi aktif. Perubahan harus memperbarui saldo wallet secara konsisten. Jika menyebabkan saldo wallet tidak valid, sistem menolak perubahan.
    related_entities:
      - Transaction
      - Wallet
    related_user_stories:
      - US-008
    source: PRD line 198
    confidence: 1.0
  - id: FR-006
    description: Delete Transaction - User dapat menghapus transaksi aktif menggunakan soft delete. Transaksi dihapus tidak muncul di riwayat dan tidak dihitung di summary. Saldo wallet dikembalikan sesuai efek transaksi.
    related_entities:
      - Transaction
      - Wallet
    related_user_stories:
      - US-009
    source: PRD line 202
    confidence: 1.0
  - id: FR-007
    description: Monthly Summary - User dapat melihat summary keuangan per bulan menampilkan total income, total expense, net balance, total transaction count, expense breakdown by category, dan income breakdown by category.
    related_entities:
      - Transaction
      - Category
    related_user_stories:
      - US-010
      - US-011
    source: PRD line 205
    confidence: 1.0

assumptions:
  - id: ASM-001
    statement: User sudah dianggap login — sistem tidak menangani authentication penuh di MVP.
    impacts:
      - Route design (no login page)
      - API design (user_id from session, not auth header)
      - Data isolation (user_id-based filtering)
    confidence: 1.0
  - id: ASM-002
    statement: Setiap data wallet, category, dan transaction terikat pada satu user.
    impacts:
      - All DB schemas must include user_id
      - All queries must filter by user_id
      - Data isolation enforcement
    confidence: 1.0
  - id: ASM-003
    statement: Data antar-user tidak boleh saling terlihat.
    impacts:
      - API authorization layer
      - Query scoping per user
      - UI does not show multi-user features
    confidence: 1.0
  - id: ASM-004
    statement: Currency default adalah IDR.
    impacts:
      - No currency selector in UI
      - Amount displayed with IDR formatting
      - Rate conversion logic excluded
    confidence: 1.0
  - id: ASM-005
    statement: Amount disimpan dalam bentuk integer (smallest unit, e.g., rupiah).
    impacts:
      - Backend stores amount as integer
      - Frontend parsing/formatting must handle integer-to-display conversion
      - No floating-point rounding issues
    confidence: 1.0
  - id: ASM-006
    statement: "Transaction hanya memiliki dua tipe: income dan expense."
    impacts:
      - No transfer, refund, or adjustment types
      - Transaction type enum is binary
      - UI toggle between two modes
    confidence: 1.0
  - id: ASM-007
    statement: Summary dihitung dari transaksi aktif (soft-deleted excluded).
    impacts:
      - Summary query must filter deleted_at IS NULL
      - Deleted transactions reverse their balance effect
    confidence: 1.0
  - id: ASM-008
    statement: Delete transaksi menggunakan soft delete.
    impacts:
      - All entity tables need deleted_at column
      - All list queries need IS NULL filter
      - Hard delete prevented for wallets with transactions
    confidence: 1.0
  - id: ASM-009
    statement: Default category tersedia saat user pertama kali menggunakan aplikasi.
    impacts:
      - Seed data required on user creation
      - 4 income + 8 expense default categories (PRD lines 409-427)
      - User sees categories immediately without setup
    confidence: 1.0
  - id: ASM-010
    statement: Wallet update, delete, dan editability of initial balance adalah open question (PRD Open Questions No 1 and No 6).
    impacts:
      - Wallet CRUD scope is uncertain
      - May need wallet edit/delete endpoints or not
      - Initial balance may be immutable after first transaction
    confidence: 0.5
  - id: ASM-011
    statement: Default category mungkin readonly (tidak bisa diubah oleh user) — open question PRD No 2.
    impacts:
      - UI may show default categories as non-editable
      - Only custom categories can be updated/deleted
    confidence: 0.5
  - id: ASM-012
    statement: Transaction date mungkin boleh backdate tanpa batas — open question PRD No 3.
    impacts:
      - No lower-bound date validation
      - Summary period filtering relies on transaction_date regardless of how far back
    confidence: 0.5
  - id: ASM-013
    statement: Summary dihitung secara real-time, bukan dari snapshot — open question PRD No 4.
    impacts:
      - No summary cache/storage table needed
      - Summary computed on every request
      - Performance depends on transaction count per period
    confidence: 0.5
  - id: ASM-014
    statement: Not found vs forbidden untuk data user lain bisa dikembalikan sebagai not found (tidak membedakan) — open question PRD No 5.
    impacts:
      - API returns 404 for both not-found and forbidden access
      - No 403 responses needed
      - Security through obscurity
    confidence: 0.4

---

# 02 — PRD Analysis

## Rationale and Trade-off Decisions

### Entity Extraction

Empat entity domain diidentifikasi dari PRD. **User** tidak memiliki tabel field eksplisit di Data Requirement section (PRD lines 358-401), tetapi dirujuk melalui `user_id` di semua entity lain dan melalui Asumsi PRD (line 105: "User sudah dianggap login"). User diinferensikan sebagai entity dengan identifier minimal (id) dan hubungan one-to-many ke Wallet, Category, dan Transaction. Confidence 0.8 karena meskipun kehadiran User jelas dari konteks, PRD tidak mendefinisikan field User secara eksplisit.

**Wallet**, **Category**, dan **Transaction** memiliki tabel field lengkap di Data Requirement section (lines 360-401) — confidence 1.0 untuk semua field.

**Category** memiliki field `user_id` yang nullable untuk default system category (`is_default: true`). Ini adalah inference dari BR-003 ("Category wajib dimiliki oleh user atau berasal dari default system category") — default category tidak memiliki user pemilik spesifik. Field `user_id` bisa NULL saat `is_default = true`.

### Business Rules

15 business rules eksplisit dari tabel PRD (lines 121-136) — semuanya confidence 1.0. Ditambah 6 rules tambahan dari Assumptions dan Supporting Information sections (BR-016 through BR-021) yang juga confidence 1.0 karena directly stated.

BR-008 (line 128) dan BR-009 (line 129) memiliki konsekuensi langsung pada UI behavior: form validation harus cek balance sebelum submit expense, dan date picker harus membatasi maksimal hari ini.

BR-012 (line 132) menyiratkan bahwa wallet delete harus cek apakah wallet memiliki transaksi terkait sebelum mengizinkan hard delete. Jika wallet memiliki transaksi, sistem hanya mengizinkan soft delete.

### User Stories

11 user stories dari tabel PRD (lines 141-154). Prioritas dibagi menjadi High (US-001 through US-006, US-010) dan Medium (US-007, US-008, US-009, US-011). Tidak ada Low priority stories di PRD.

Pemetaan acceptance criteria ke setiap user story dilakukan dengan menautkan acceptance criteria tables (AC-001 through AC-007, lines 218-301) ke story yang relevan. Beberapa acceptance criteria mencakup multiple stories (misal AC-003 mencakup US-004 dan US-005 untuk income dan expense).

### Edge Cases

11 edge cases dari tabel eksplisit (lines 577-589) ditambah 7 error states dari Error & Empty State table (lines 468-480). Total 18 edge cases. Yang dari tabel eksplisit semuanya confidence 1.0. Yang dari error states table juga confidence 1.0 karena langsung dari PRD.

Edge case EC-008 (user mengakses data milik user lain) memiliki dua kemungkinan behavior dari PRD: "menolak akses atau mengembalikan not found" (PRD line 480, 586). Ini adalah open question No 5 (line 613) yang perlu diputuskan di perencanaan downstream.

### Functional Requirements

7 FR dari PRD (lines 157-214). Setiap FR dipetakan ke entity terkait dan user stories. Tidak semua FR mencakup semua entity yang terlibat — misalnya FR-004 (Transaction History) hanya melibatkan Transaction entity, meskipun filtering by wallet dan category membutuhkan join.

### Key Trade-off: Summary Computation

PRD Open Question No 4 (line 612) menanyakan apakah summary perlu disimpan sebagai snapshot atau dihitung real-time. Untuk MVP dengan jumlah transaksi personal normal, real-time computation lebih sederhana (no sync/invalidation logic). Tapi jika transaksi volume besar, snapshot mungkin diperlukan. Assumption ASM-013 mengadopsi real-time dengan confidence 0.5.

### Open Questions from PRD

PRD memiliki 7 open questions (lines 605-615) yang mempengaruhi downstream decisions:
1. Wallet update/delete scope (mempengaruhi route design, API contract)
2. Default category mutability (mempengaruhi UI editability)
3. Backdate limits (mempengaruhi date validation)
4. Summary computation strategy (mempengaruhi API design, caching)
5. Not-found vs forbidden semantics (mempengaruhi error response design)
6. Initial balance mutability (mempengaruhi wallet edit rules)
7. (Implicit) Transaction date timezone handling — PRD line 543 menyebut "tanggal lokal user" tanpa detail implementasi

Ketergantungan downstream: Agent 3 (frontend-requirement-mapping) dan Agent 8 (validation-and-edge-case-plan) paling terpengaruh oleh open questions ini.

## Confidence Scores by Section

| Section | Confidence | Rationale |
|---------|-----------|-----------|
| Entities | 0.95 | Wallet, Category, Transaction: 1.0 (explicit field tables). User: 0.8 (inferred). Rata-rata. |
| Business Rules | 1.0 | 15 rules explicit in table + 6 rules from assumptions/supporting sections, all directly stated. |
| User Stories | 1.0 | 11 stories explicit in table with priorities. No ambiguity. |
| Edge Cases | 1.0 | 11 cases explicit in table + 7 from error states table. All directly stated. |
| Functional Requirements | 1.0 | 7 FR explicit in PRD sections. Entity/story mapping done manually but from clear connections. |
| Assumptions | 0.72 | PRD assumptions (ASM-001 through ASM-009): 1.0. Open question inferences (ASM-010 through ASM-014): 0.4-0.5 average. Overall weighted. |

## Cross-Document References

Documents that will reference this file downstream:

- doc-03 (frontend-requirement-mapping): uses entities[], functional_requirements[]
- doc-04 (screen-route-mapping): uses entities[]
- doc-07 (api-integration-plan): uses entities[]
- doc-08 (validation-and-edge-case-plan): uses business_rules[], edge_cases[]
- doc-09 (atomic-task-breakdown): uses user_stories[]

Validation rules from doc-01 that reference this document:
- `entity-vs-schema` (BLOCKER): doc-02 entities[] must have type in doc-07 types[] or schema in doc-08 schemas[]
- `business-rule-vs-validation` (WARNING): doc-02 business_rules[] must have validation in doc-08
- `edge-case-vs-handling` (INFO): doc-02 edge_cases[] must have handling in doc-08 state_handling[]
- `user-story-vs-task` (WARNING): doc-02 user_stories[] must be covered by doc-09 tasks[]

## DoD Checklist

- [x] All entities extracted with fields and types (Wallet, Category, Transaction, User)
- [x] All business rules (BR-001 through BR-021) documented
- [x] All user stories (US-001 through US-011) documented with priority
- [x] All edge cases (EC-001 through EC-018) documented with expected handling
- [x] All functional requirements (FR-001 through FR-007) analyzed per frontend concern
- [x] Provenance markers on all extractions (source: PRD line N)
- [x] All entity names PascalCase
- [x] Frontmatter includes prd_source_hash matching chain state (2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3)
- [x] No placeholder, TODO, or TBD
- [x] Output file matches docs/02-prd-analysis.md
- [x] Confidence scores documented per section
- [x] Assumptions use structured format ({id, statement, impacts, confidence})
- [x] Cross-document references documented with validation rules
