---
prd_source_hash: "sha256:deadbeef"
agent: 8
schema_version: 1
status: complete
summary: "Sample fixture for validation-and-edge-case plan — happy path. Schemas cover all types, state handling covers all edge cases."
schemas:
  - name: Transaction
    zod_definition: "z.object({ id: z.string(), amount: z.number(), currency: z.string(), categoryId: z.string(), walletId: z.string() })"
    error_messages:
      amount: "Amount harus berupa angka"
      categoryId: "Kategori wajib dipilih"
    related_business_rule: BR-002
    source: "PRD line 55"
    confidence: 0.90
  - name: Wallet
    zod_definition: "z.object({ id: z.string(), balance: z.number().min(0) })"
    error_messages:
      balance: "Saldo tidak boleh negatif"
    related_business_rule: BR-001
    source: "PRD line 42"
    confidence: 0.95
  - name: CreateTransaction
    zod_definition: "z.object({ amount: z.number().positive(), categoryId: z.string(), walletId: z.string() })"
    error_messages:
      amount: "Amount harus positif"
    related_business_rule: BR-002
    source: "PRD line 55"
    confidence: 0.90
error_boundaries:
  - scope: DashboardPage
    fallback: "Gagal memuat dashboard. Coba refresh."
  - scope: TransactionListPage
    fallback: "Gagal memuat transaksi. Coba lagi nanti."
  - scope: WalletPage
    fallback: "Gagal memuat wallet. Periksa koneksi."
  - scope: CategoryPage
    fallback: "Gagal memuat kategori. Coba refresh."
state_handling:
  - component: TransactionTable
    loading: "Skeleton table dengan 5 baris"
    empty: "Belum ada transaksi. Tambah transaksi pertama."
    error: "Gagal memuat. Tombol retry."
    related_edge_case: EC-001
    source: "PRD line 28"
    confidence: 0.85
  - component: CategoryGrid
    loading: "Skeleton grid 2x3"
    empty: "Belum ada kategori. Buat kategori baru."
    error: "Gagal memuat. Tombol retry."
    related_edge_case: EC-002
    source: "PRD line 50"
    confidence: 0.80
  - component: DashboardSummary
    loading: "Skeleton cards"
    empty: "Data belum tersedia."
    error: "Gagal memuat ringkasan."
    related_edge_case: null
    source: "inference"
    confidence: 0.75
  - component: WalletDetail
    loading: "Skeleton wallet detail"
    empty: "Wallet tidak ditemukan."
    error: "Gagal memuat wallet."
    related_edge_case: null
    source: "inference"
    confidence: 0.75
---

# Validation & Edge Case Plan (Sample Fixture)

schema.name match dengan doc-07 types[].name dan doc-02 entities[].name.
schema.related_business_rule match dengan doc-02 business_rules[].id.
state_handling.related_edge_case match dengan doc-02 edge_cases[].id.
