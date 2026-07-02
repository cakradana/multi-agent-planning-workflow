---
prd_source_hash: "sha256:deadbeef"
agent: 5
schema_version: 1
status: complete
summary: "Known blocker fixture — store name 'wallet' lowercase, will not match entity 'Wallet' PascalCase."
stores:
  - name: wallet
    slices: [wallets]
    actions: [updateBalance]
    confidence: 0.90
  - name: TransactionStore
    slices: [transactions]
    actions: [addTransaction]
    confidence: 0.90
query_hooks:
  - name: useTransactions
    key: ["transactions"]
    endpoint: GET /api/transactions
    confidence: 0.90
  - name: useWallets
    key: ["wallets"]
    endpoint: GET /api/wallets
    confidence: 0.90
data_flow:
  - screen: DashboardPage
    store_deps: [wallet]
    query_deps: [useWallets]
  - screen: TransactionListPage
    store_deps: [TransactionStore]
    query_deps: [useTransactions]
---

# State & Data Flow Plan (Known Blocker Fixture)

Store name "wallet" (lowercase) tidak akan match entity "Wallet" (PascalCase) — tapi entity-vs-schema hanya cek doc-07 types dan doc-08 schemas, bukan doc-05 stores. Jadi mismatch ini hanya untuk verifikasi bahwa validator TIDAK false-positive di doc-05.
