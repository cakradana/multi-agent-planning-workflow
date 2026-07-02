---
prd_source_hash: "sha256:deadbeef"
agent: 2
schema_version: 1
status: complete
summary: "Sample fixture for PRD analysis — happy path. All entities, rules, stories, edge cases consistently named."
assumptions:
  - id: ASM-001
    statement: "API mengikuti REST convention"
    impacts: [doc07.endpoints, doc05.query_hooks]
    confidence: 0.95
entities:
  - name: Transaction
    fields:
      - name: id
        type: string
        source: PRD line 28
      - name: amount
        type: number
        source: PRD line 29
    relationships: [Category, Wallet]
  - name: Wallet
    fields:
      - name: id
        type: string
        source: PRD line 42
      - name: balance
        type: number
        source: PRD line 43
  - name: Category
    fields:
      - name: id
        type: string
        source: PRD line 50
      - name: name
        type: string
        source: PRD line 51
business_rules:
  - id: BR-001
    description: "Saldo wallet tidak boleh negatif"
    source: PRD line 42
    confidence: 0.98
  - id: BR-002
    description: "Transaksi harus punya kategori"
    source: PRD line 55
    confidence: 0.90
user_stories:
  - id: US-001
    description: "Sebagai user, saya bisa mencatat transaksi pemasukan/pengeluaran"
    gherkin_refs: [G-001, G-002]
    confidence: 0.95
  - id: US-002
    description: "Sebagai user, saya bisa melihat ringkasan saldo per wallet"
    gherkin_refs: [G-003]
    confidence: 0.90
edge_cases:
  - id: EC-001
    description: "Input amount negatif"
    confidence: 0.85
  - id: EC-002
    description: "Kategori dihapus saat transaksi ada"
    confidence: 0.70
---

# PRD Analysis (Sample Fixture)

Fixture untuk happy path test — semua entity, business rule, user story, edge case akan match dengan dokumen downstream.
