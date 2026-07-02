---
prd_source_hash: "sha256:deadbeef"
agent: 5
schema_version: 1
status: complete
summary: "Sample fixture for state-data-flow plan — happy path. Query hooks match doc-07 endpoints."
stores:
  - name: TransactionStore
    slices: [transactions, filters]
    actions: [addTransaction, deleteTransaction, setFilter]
    confidence: 0.90
  - name: WalletStore
    slices: [wallets]
    actions: [updateBalance]
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
  - name: useCategories
    key: ["categories"]
    endpoint: GET /api/categories
    confidence: 0.90
data_flow:
  - screen: DashboardPage
    store_deps: [WalletStore]
    query_deps: [useWallets]
  - screen: TransactionListPage
    store_deps: [TransactionStore]
    query_deps: [useTransactions]
  - screen: WalletPage
    store_deps: [WalletStore]
    query_deps: [useWallets]
  - screen: CategoryPage
    store_deps: []
    query_deps: [useCategories]
---

# State & Data Flow Plan (Sample Fixture)

Query hook names akan match dengan doc-07 endpoints[].related_query_hook.
