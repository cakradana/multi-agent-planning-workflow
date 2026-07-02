---
prd_source_hash: "sha256:deadbeef"
agent: 6
schema_version: 1
status: complete
summary: "Sample fixture for component-and-ui plan — happy path. component_tree[].page matches doc-04 screen_names."
component_tree:
  - page: DashboardPage
    organism: [DashboardSummary, WalletCardList]
    molecule: [BalanceDisplay, QuickAddButton]
    atom: [AmountText, IconButton]
  - page: TransactionListPage
    organism: [TransactionTable, FilterBar]
    molecule: [TransactionRow, DateFilter]
    atom: [Badge, EmptyState]
  - page: WalletPage
    organism: [WalletDetail, TransactionHistory]
    molecule: [WalletHeader, BalanceChart]
    atom: [CurrencyText, ProgressBar]
  - page: CategoryPage
    organism: [CategoryGrid, CategoryForm]
    molecule: [CategoryCard, ColorPicker]
    atom: [IconCircle, DeleteButton]
shared_components:
  - name: AmountText
    shadcn_source: custom
    props: [value, currency, size]
  - name: EmptyState
    shadcn_source: custom
    props: [icon, message, action]
  - name: Badge
    shadcn_source: shadcn/ui
    props: [variant, children]
---

# Component & UI Plan (Sample Fixture)

component_tree[].page exact match dengan doc-04 routes[].screen_name.
