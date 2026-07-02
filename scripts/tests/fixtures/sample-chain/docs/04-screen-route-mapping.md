---
prd_source_hash: "sha256:deadbeef"
agent: 4
schema_version: 1
status: complete
summary: "Sample fixture for screen-route mapping — happy path. screen_names will match doc-06 component_tree."
routes:
  - path: "/"
    screen_name: DashboardPage
    metadata:
      title: "Dashboard"
    confidence: 0.95
  - path: "/transactions"
    screen_name: TransactionListPage
    metadata:
      title: "Transactions"
    confidence: 0.90
  - path: "/wallets"
    screen_name: WalletPage
    metadata:
      title: "Wallets"
    confidence: 0.90
  - path: "/categories"
    screen_name: CategoryPage
    metadata:
      title: "Categories"
    confidence: 0.85
---

# Screen-Route Mapping (Sample Fixture)

Semua screen_name akan match dengan doc-06 component_tree[].page.
