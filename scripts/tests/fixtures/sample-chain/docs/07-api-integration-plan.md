---
prd_source_hash: "sha256:deadbeef"
agent: 7
schema_version: 1
status: complete
summary: "Sample fixture for API integration plan — happy path. Types cover all entities, endpoints ref query hooks."
endpoints:
  - method: GET
    path: /api/transactions
    request_type: null
    response_type: Transaction[]
    related_query_hook: useTransactions
    confidence: 0.90
  - method: GET
    path: /api/wallets
    request_type: null
    response_type: Wallet[]
    related_query_hook: useWallets
    confidence: 0.90
  - method: GET
    path: /api/categories
    request_type: null
    response_type: Category[]
    related_query_hook: useCategories
    confidence: 0.90
  - method: POST
    path: /api/transactions
    request_type: CreateTransaction
    response_type: Transaction
    related_query_hook: useTransactions
    confidence: 0.85
types:
  - name: Transaction
    fields:
      - name: id
        type: string
      - name: amount
        type: number
      - name: currency
        type: string
      - name: categoryId
        type: string
      - name: walletId
        type: string
  - name: Wallet
    fields:
      - name: id
        type: string
      - name: balance
        type: number
  - name: Category
    fields:
      - name: id
        type: string
      - name: name
        type: string
  - name: CreateTransaction
    fields:
      - name: amount
        type: number
      - name: categoryId
        type: string
      - name: walletId
        type: string
---

# API Integration Plan (Sample Fixture)

types[].name match dengan doc-02 entities[].name (Transaction, Wallet, Category).
endpoints[].related_query_hook match dengan doc-05 query_hooks[].name.
