---
prd_source_hash: "sha256:deadbeef"
agent: 9
schema_version: 1
status: complete
summary: "Sample fixture for atomic task breakdown — happy path. Tasks cover all user stories."
tasks:
  - id: T-001
    phase: 1
    title: "Setup Next.js project dengan Tailwind dan shadcn/ui"
    description: "Inisialisasi project Next.js App Router, install dependencies, konfigurasi Tailwind dan shadcn/ui."
    acceptance_criteria:
      - "Project bisa dijalankan dengan npm run dev"
      - "Tailwind styles muncul di halaman"
      - "shadcn/ui components bisa di-import"
    priority: P0
    blockedBy: []
    blocks: [T-002, T-003, T-004]
    labels: [setup, frontend]
    estimated_hours: 4
    source: "US-001, US-002"
    confidence: 0.95
  - id: T-002
    phase: 2
    title: "Buat TransactionStore dengan Zustand"
    description: "Implement store untuk state transaksi: list, filter, add, delete."
    acceptance_criteria:
      - "Store bisa menyimpan list transaksi"
      - "Action addTransaction menambah transaksi baru"
      - "Action deleteTransaction menghapus transaksi"
    priority: P1
    blockedBy: [T-001]
    blocks: [T-005]
    labels: [state, zustand]
    estimated_hours: 4
    source: "US-001"
    confidence: 0.90
  - id: T-003
    phase: 2
    title: "Buat WalletStore dengan Zustand"
    description: "Implement store untuk state wallet: list, balance update."
    acceptance_criteria:
      - "Store bisa menyimpan list wallet"
      - "Balance ter-update setelah transaksi"
    priority: P1
    blockedBy: [T-001]
    blocks: [T-006]
    labels: [state, zustand]
    estimated_hours: 3
    source: "US-002"
    confidence: 0.90
  - id: T-004
    phase: 2
    title: "Setup MSW handlers untuk semua endpoint"
    description: "Buat mock service worker handlers untuk GET/POST /api/transactions, /api/wallets, /api/categories."
    acceptance_criteria:
      - "MSW server berjalan di development"
      - "Semua endpoint mengembalikan mock data yang valid"
    priority: P0
    blockedBy: [T-001]
    blocks: [T-005, T-006]
    labels: [api, msw, testing]
    estimated_hours: 6
    source: "US-001, US-002"
    confidence: 0.85
  - id: T-005
    phase: 3
    title: "Buat halaman TransactionListPage"
    description: "Halaman daftar transaksi dengan filter, empty state, loading skeleton."
    acceptance_criteria:
      - "Menampilkan list transaksi dari API"
      - "Filter by date dan category berfungsi"
      - "Loading state: skeleton"
      - "Empty state: pesan 'Belum ada transaksi'"
      - "Error state: tombol retry"
    priority: P1
    blockedBy: [T-002, T-004]
    blocks: []
    labels: [component, page]
    estimated_hours: 8
    source: "US-001"
    confidence: 0.85
  - id: T-006
    phase: 3
    title: "Buat halaman DashboardPage"
    description: "Halaman dashboard dengan ringkasan wallet dan quick-add transaksi."
    acceptance_criteria:
      - "Menampilkan ringkasan saldo per wallet"
      - "Tombol quick-add membuka form transaksi"
      - "Loading state: skeleton cards"
      - "Empty state: 'Data belum tersedia'"
      - "Error state: pesan error + retry"
    priority: P1
    blockedBy: [T-003, T-004]
    blocks: []
    labels: [component, page]
    estimated_hours: 6
    source: "US-002"
    confidence: 0.85
  - id: T-007
    phase: 4
    title: "Unit test untuk TransactionStore dan WalletStore"
    description: "Tulis unit test dengan Vitest untuk semua store actions."
    acceptance_criteria:
      - "addTransaction test pass"
      - "deleteTransaction test pass"
      - "updateBalance test pass"
      - "Coverage > 80% untuk stores"
    priority: P2
    blockedBy: [T-002, T-003]
    blocks: []
    labels: [testing, vitest]
    estimated_hours: 4
    source: "US-001, US-002"
    confidence: 0.85
phase_summary:
  - phase: 1
    name: "Foundation"
    task_count: 1
    total_hours: 4
  - phase: 2
    name: "Core Infrastructure"
    task_count: 3
    total_hours: 13
  - phase: 3
    name: "Pages"
    task_count: 2
    total_hours: 14
  - phase: 4
    name: "Testing"
    task_count: 1
    total_hours: 4
---

# Atomic Task Breakdown (Sample Fixture)

Semua user story (US-001, US-002) tercakup oleh task. Task punya dependency eksplisit dan acceptance criteria konkret.
