---
prd_source_hash: "sha256:deadbeef"
agent: 2
schema_version: 1
status: complete
summary: "Known blocker fixture — entity Wallet (PascalCase) will mismatch with doc-07 type WalletAccount and doc-05 store wallet (lowercase)."
entities:
  - name: Wallet
    fields:
      - name: id
        type: string
        source: PRD line 42
      - name: balance
        type: number
        source: PRD line 43
  - name: Transaction
    fields:
      - name: id
        type: string
        source: PRD line 28
      - name: amount
        type: number
        source: PRD line 29
business_rules:
  - id: BR-001
    description: "Saldo wallet tidak boleh negatif"
    source: PRD line 42
    confidence: 0.98
user_stories:
  - id: US-001
    description: "User bisa mencatat transaksi"
    confidence: 0.95
edge_cases:
  - id: EC-001
    description: "Input amount negatif"
    confidence: 0.85
---

# PRD Analysis (Known Blocker Fixture)

Entity "Wallet" (PascalCase) akan menjadi BLOCKER karena:
- doc-07 type name = "WalletAccount" (beda nama)
- doc-05 store name = "wallet" (lowercase, mismatch)

Validator rule `entity-vs-schema` severity BLOCKER harus menangkap ini.
