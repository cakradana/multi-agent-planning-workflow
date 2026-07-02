---
prd_source_hash: "sha256:deadbeef"
agent: 7
schema_version: 1
status: complete
summary: "Known blocker fixture — type name WalletAccount berbeda dengan entity Wallet. Trigger entity-vs-schema BLOCKER."
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
    response_type: WalletAccount[]
    related_query_hook: useWallets
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
  - name: WalletAccount
    fields:
      - name: id
        type: string
      - name: balance
        type: number
  - name: CreateTransaction
    fields:
      - name: amount
        type: number
---

# API Integration Plan (Known Blocker Fixture)

type.name "WalletAccount" ≠ entity.name "Wallet" → validator entity-vs-schema rule HARUS mendeteksi ini sebagai BLOCKER.

Entity "Wallet" tidak punya matching type di doc-07 (WalletAccount ≠ Wallet) dan tidak punya schema di doc-08 (tidak ada doc-08 di fixture ini).
