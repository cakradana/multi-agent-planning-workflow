---
title: Planning Workflow
description: Rules chain, dependency order, naming conventions, output format for Pocket frontend planning
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 1
schema_version: 1
status: complete
summary: >
  This document defines foundational conventions for the 9-agent Pocket frontend planning chain.
  Chain runs serially — Agent 1 through Agent 9 — with review gates at Agents 1, 4, 8, and 9.
  Agent 1 documents the rules. Agent 2 analyzes the PRD. Agent 3 maps functional requirements
  to frontend concerns. Agent 4 maps screens to Next.js App Router routes. Agent 5 plans
  Zustand stores and React Query hooks. Agent 6 designs the component tree and shadcn/ui
  selections. Agent 7 defines API integration contracts and MSW handlers. Agent 8 specifies
  Zod schemas, form validation, error boundaries, and edge-case handling. Agent 9 breaks
  everything into atomic tasks for GitHub Issues. Post-agent scripts run deterministic
  validation, RTM generation, and issue push. 10 documents total across 9 agents. Branch
  naming follows planning/chain-{timestamp}. Document naming follows docs/{NN}-{slug}.md.
  All agents share a common YAML frontmatter schema with prd_source_hash, agent ID,
  schema_version, status, and summary fields. Entity names use PascalCase. Confidence
  scoring uses 0.0-1.0 self-assessment. Assumptions use structured {id, statement, impacts,
  confidence} format. Provenance markers distinguish PRD-sourced vs inferred assertions.
  Context budget rules for Agent 5+ use summary fields from upstream documents rather than
  full re-reads. Cross-document validation (3 BLOCKER, 2 WARNING, 1 INFO rules) enforces
  consistency between screens/routes, API/state, entities/schemas, business rules/validation,
  stories/tasks, and edge-cases/handling.

conventions:
  naming:
    entities: PascalCase
    documents: "docs/{NN}-{slug}.md"
    branches: "planning/chain-{timestamp}"
    frontmatter_fields: [prd_source_hash, agent, schema_version, status, summary, title, description]
  output_format:
    all_documents: |
      ---
      YAML frontmatter (title, description, prd_source_hash, agent, schema_version, status, summary)
      ---
      # {NN} — {Title}
      ## Structured sections per document type
      ## All cross-document references use relative paths: docs/{NN}-{slug}.md
      ## Provenance markers on every assertion
      ## Confidence scores on assumptions
      ## DoD checklist at end
    frontmatter_required:
      - field: prd_source_hash
        type: string
        description: sha256 hex digest of PRD.md at chain start
      - field: agent
        type: integer
        description: Agent number (1-9)
      - field: schema_version
        type: integer
        description: Schema version (currently 1)
      - field: status
        type: string
        enum: [draft, complete, blocked]
      - field: summary
        type: string
        description: ~250 word narrative summary for context budget optimization
      - field: title
        type: string
        description: Document title
      - field: description
        type: string
        description: One-line document purpose
  dependency_order: serial

agents:
  - id: 1
    name: planning-workflow
    output_file: docs/01-planning-workflow.md
    responsibility: Rules chain, dependency order, naming conventions, output format
  - id: 2
    name: prd-analysis
    output_file: docs/02-prd-analysis.md
    responsibility: Extract entities, business rules, user stories, edge cases from PRD
  - id: 3
    name: frontend-requirement-mapping
    output_file: docs/03-frontend-requirement-mapping.md
    responsibility: Map functional requirements to frontend concerns
  - id: 4
    name: screen-route-mapping
    output_file: docs/04-screen-route-mapping.md
    responsibility: Map PRD screens to Next.js App Router routes
  - id: 5
    name: state-data-flow-plan
    output_file: docs/05-state-data-flow-plan.md
    responsibility: Zustand stores, React Query keys and hooks, data flow
  - id: 6
    name: component-and-ui-plan
    output_file: docs/06-component-and-ui-plan.md
    responsibility: Component tree, shared vs page-specific, shadcn/ui selections
  - id: 7
    name: api-integration-plan
    output_file: docs/07-api-integration-plan.md
    responsibility: MSW handler definitions, request/response types
  - id: 8
    name: validation-and-edge-case-plan
    output_file: docs/08-validation-and-edge-case-plan.md
    responsibility: Zod schemas, form rules, error boundaries, state handling
  - id: 9
    name: atomic-task-breakdown
    output_file: docs/09-atomic-task-breakdown.md
    responsibility: Break into atomic LLM-sized tasks, RTM, push to GitHub Issues
---

# 01 — Planning Workflow

## Chain Overview

Chain runs 9 agents in serial execution. Each agent writes one document to `docs/` directory. Post-agent scripts add 2 more documents plus 1 JSON artifact.

**Execution strategy:** serial (from `workflow.yaml execution_strategy`).
**Review gates:** Agents 1, 4, 8, 9 require human approval before next step.
**Outputs:** 10 markdown documents + 1 JSON map.
**Post-agent scripts:** validation, RTM generation, GitHub Issues push.

### Execution Flow

```
Agent 1 documents rules
  → Agent 2 analyzes PRD
    → Agent 3 maps FR to frontend
    → Agent 4 maps screens to routes
      → Agent 5 plans state management
      → Agent 6 plans components
        → Agent 7 defines API contracts
        → Agent 8 defines validation
          → validate script runs (post-Agent 8 gate)
            → Agent 9 creates tasks
              → RTM + Push scripts run (final gate)
```

## Agent Dependencies (Topological Order)

Dependencies derived from `workflow.yaml agents[].depends_on`:

| Order | ID | Name | Depends On | Output File | Responsibility |
|-------|----|------|------------|-------------|----------------|
| 1 | 1 | planning-workflow | [] | docs/01-planning-workflow.md | Document chain rules, conventions |
| 2 | 2 | prd-analysis | [1] | docs/02-prd-analysis.md | Extract entities, rules, stories, cases |
| 3 | 3 | frontend-requirement-mapping | [2] | docs/03-frontend-requirement-mapping.md | Map FR to frontend concerns |
| 4 | 4 | screen-route-mapping | [2, 3] | docs/04-screen-route-mapping.md | Screens to Next.js routes |
| 5 | 5 | state-data-flow-plan | [4] | docs/05-state-data-flow-plan.md | Zustand, RQ hooks, data flow |
| 6 | 6 | component-and-ui-plan | [3, 4] | docs/06-component-and-ui-plan.md | Component tree, shadcn/ui |
| 7 | 7 | api-integration-plan | [5] | docs/07-api-integration-plan.md | MSW handlers, types |
| 8 | 8 | validation-and-edge-case-plan | [2, 5, 6, 7] | docs/08-validation-and-edge-case-plan.md | Zod, forms, errors |
| 9 | 9 | atomic-task-breakdown | [8] | docs/09-atomic-task-breakdown.md | Tasks, RTM, Issues |

### Dependency Graph

```
Agent 1 (review gate)
  └─ Agent 2
       ├─ Agent 3
       │    ├─ Agent 6
       │    └─ Agent 4 (review gate)
       │         ├─ Agent 5
       │         │    ├─ Agent 7
       │         │    │    └─ Agent 8 ── Agent 9 (review gate)
       │         │    └─ Agent 8
       │         └─ Agent 6
       └─ Agent 4
         Agent 8 depends on [2, 5, 6, 7]
```

Diamond dependencies: Agent 8 depends on Agent 2, 5, 6, 7 -- widest dependency set in chain. Agent 9 depends only on Agent 8.

## Naming Conventions

### Branch Naming

From `workflow.yaml git.branch_prefix`:

```
planning/chain-{YYYYMMDD}-{HHmmss}
```

Example: `planning/chain-20260703-012119`

PR base: `main`. PR auto-created by orchestration engine after final review gate approval.

### Document Naming

All chain output documents follow pattern from `workflow.yaml agents[].output`:

```
docs/{NN}-{slug}.md
```

Where `{NN}` is zero-padded agent ID (01-10) and `{slug}` is kebab-case descriptor.

### Exact Output Filenames

From `workflow.yaml`:

| File | Source | Purpose |
|------|--------|---------|
| docs/01-planning-workflow.md | Agent 1 output | Chain rules and conventions |
| docs/02-prd-analysis.md | Agent 2 output | PRD analysis and extraction |
| docs/03-frontend-requirement-mapping.md | Agent 3 output | FR to frontend mapping |
| docs/04-screen-route-mapping.md | Agent 4 output | Screen and route mapping |
| docs/05-state-data-flow-plan.md | Agent 5 output | State management plan |
| docs/06-component-and-ui-plan.md | Agent 6 output | Component and UI plan |
| docs/07-api-integration-plan.md | Agent 7 output | API integration contracts |
| docs/08-validation-and-edge-case-plan.md | Agent 8 output | Validation and edge cases |
| docs/09-atomic-task-breakdown.md | Agent 9 output | Atomic task breakdown |
| docs/validation-report.md | validate script | Cross-document validation report |
| docs/traceability-matrix.md | rtm script | Traceability matrix |
| docs/.issue-map.json | push script | GitHub Issue mapping artifact |

### Entity/Type/Schema Naming

All domain entities, TypeScript types, interfaces, and Zod schemas use **PascalCase**.

From PRD:

| Entity | PascalCase | Fields Convention |
|--------|------------|-------------------|
| Wallet | `Wallet` | camelCase in frontend code |
| Category | `Category` | camelCase in frontend code |
| Transaction | `Transaction` | camelCase in frontend code |
| User | `User` | camelCase in frontend code |

Field naming:

| Context | Convention | Example |
|---------|-----------|---------|
| TypeScript interfaces | camelCase | `walletId`, `createdAt` |
| API JSON responses | snake_case | `wallet_id`, `created_at` |
| Zod schemas | PascalCase type name | `TransactionSchema` |
| React Query keys | camelCase array | `["wallets", walletId]` |
| Zustand stores | camelCase | `useWalletStore` |

### Enum/String Literal Naming

| Domain | TypeScript (PascalCase) | API (snake_case) |
|--------|------------------------|------------------|
| Wallet types | `Cash`, `Bank`, `EWallet` | `cash`, `bank`, `e-wallet` |
| Transaction types | `Income`, `Expense` | `income`, `expense` |
| Category types | `Income`, `Expense` | `income`, `expense` |

### Frontmatter YAML Constraints (REQUIRED — parser-enforced)

Frontmatter YAML HARUS valid untuk `yaml.safe_load()`. Validator menggunakan sanitizer sebagai fallback, tapi hasilnya tidak dijamin untuk nilai kompleks.

**NILAI FRONTMATTER TIDAK BOLEH MENGANDUNG:**
1. Inline TypeScript/JSON code dengan `{`, `}`, `[`, `]` — gunakan body markdown
2. Karakter pipe `|` di nilai skalar — quote dengan double-quote
3. Colon-space `: ` di nilai yang bukan URL — quote dengan double-quote

**REFERENCE FIELDS HARUS PAKAI YAML ARRAY, BUKAN COMMA-STRING:**

```yaml
# ❌ SALAH — akan gagal cross-document matching
related_business_rule: BR-004, BR-016
related_edge_case: EC-011, EC-012

# ✅ BENAR — validator support split_refs() fallback, tapi array lebih reliable
related_business_rule:
  - BR-004
  - BR-016
related_edge_case:
  - EC-011
  - EC-012
```

**SOURCE FIELD HARUS MENGGUNAKAN FORMAT TERSTRUKTUR DENGAN covers ARRAY:**

```yaml
# ❌ SALAH — range notation tidak otomatis di-expand
source: "doc-02: US-001..US-011 (foundational for all)"

# ✅ BENAR
source: "doc-02: foundational for all user stories"
covers:
  - US-001
  - US-002
  - US-003
```
(sumber: convention, confidence: 1.0)

Validation scripts (`validate-chain.sh`, `generate-rtm.sh`) menggunakan shared parser `scripts/_yaml_parser.py`. Jangan duplikasi parser di script lain — import dari modul ini.

## Output Format Specification

### Universal Frontmatter Schema

Every chain document MUST begin with YAML frontmatter between `---` markers:

```yaml
---
title: <string>
description: <string>
prd_source_hash: <string>   # SHA-256 hex digest of PRD.md (from .chain-state.json prdHash)
agent: <integer>            # Agent number 1-9
schema_version: 1           # Fixed at 1 for current chain
status: draft|complete|blocked
summary: <string>           # ~250 word narrative summary
---
```

**Field rules:**

| Field | Required | Type | Constraints |
|-------|----------|------|-------------|
| title | yes | string | Max 80 chars |
| description | yes | string | Max 200 chars |
| prd_source_hash | yes | string | 64 hex chars |
| agent | yes | integer | 1-9 |
| schema_version | yes | integer | Fixed 1 |
| status | yes | string | One of: draft, complete, blocked |
| summary | yes | string | 200-350 words |

### prd_source_hash

Computed as SHA-256 hex digest of `PRD.md` at chain initialization. Stored in `.chain-state.json prdHash`. Each agent reads this value from chain state, not from re-computation.

Current hash: `2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3`
Source: `.chain-state.json prdHash`

If PRD.md changes mid-chain (hash mismatch), chain is BLOCKED. Restart with `--force` to override.

### summary Field (Context Budget Optimization)

The `summary` field is the primary context budget mechanism for Agent 5+. Summary MUST be generated by each agent when writing their document. Downstream agents MUST read summaries, not full prose. Full prose re-read only when specific detail is needed.

Rule from chain-run skill: "TIDAK melakukan auto-summarization. Summary sudah di-generate oleh agent saat menulis output."

### Per-Document Structure Requirements

Minimum sections every chain document MUST contain:

1. **YAML frontmatter** per universal schema
2. **Heading** `# {NN} — {Title}`
3. **Structured sections** with `##` headings
4. **Tables** for structured data (entities, routes, components, states)
5. **Cross-document references** using pattern `doc-{NN}: [field]`
6. **Provenance markers** on every assertion
7. **Confidence scores** on assumptions and inferences
8. **DoD checklist** in final section

### Confidence Scoring

All agents MUST self-assess confidence for each non-trivial assertion, inference, or design decision:

| Score | Meaning | When |
|-------|---------|------|
| 1.0 | Certain | Directly from authoritative source (PRD, spec, framework docs) |
| 0.8-0.9 | High confidence | Strong inference from multiple sources, clear pattern |
| 0.6-0.7 | Medium confidence | Reasonable inference, plausible but unconfirmed |
| 0.4-0.5 | Low confidence | Speculative, needs validation |
| 0.0-0.3 | Guess | No clear signal, explicit uncertainty |

Rules:
- Confidence is relative intra-document. Do not compare scores across documents.
- Display low-confidence items (score < 0.6) prominently for review gate attention.
- Scores below 0.6 MUST include provenance explaining why confidence is low.

### Assumptions Format

Every assumption MUST use structured format:

```json
{
  "id": "ASM-{NNN}",
  "statement": "Wallet supports update and delete on MVP",
  "impacts": ["Route design", "API contract", "Component state"],
  "confidence": 0.7
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | yes | Sequential: `ASM-001`, `ASM-002`, ... |
| statement | string | yes | Clear, falsifiable assertion |
| impacts | string[] | yes | Areas affected if assumption wrong |
| confidence | float (0.0-1.0) | yes | Per confidence scoring rules |

### Provenance Markers

Every claim, assertion, or data point MUST include provenance:

| Marker | Meaning | Example |
|--------|---------|---------|
| `source: "PRD line N"` | Direct quote from PRD.md line N | `source: "PRD line 121"` |
| `source: "PRD section Title"` | Derived from PRD section | `source: "PRD section Business Rules"` |
| `source: inference` | Agent reasoning from available data | `source: inference` |
| `source: framework-docs` | From framework documentation | `source: framework-docs` |
| `source: convention` | From this document (01-planning-workflow.md) | `source: convention` |
| `source: chaining` | From upstream agent document | `source: chaining: doc-04` |

Provenance appears inline or parenthetical: `(source: "PRD line 121")`.

## Cross-Document Linking

### Reference Pattern

Documents reference each other using:

```
doc-{NN}: [{document field path}]
```

Where `{NN}` is the zero-padded agent ID (02-09) and field path follows document schema.

Direct file links use relative paths from project root:

```
docs/02-prd-analysis.md
docs/04-screen-route-mapping.md
```

### Field Path References

| Reference | Targets | Used By |
|-----------|---------|---------|
| doc-02: entities[] | Entity list | Agent 3, 4, 7, 8 |
| doc-02: business_rules[] | Business rules (BR-001 through BR-015) | Agent 8 |
| doc-02: user_stories[] | User stories (US-001 through US-011) | Agent 9 |
| doc-02: edge_cases[] | Edge cases | Agent 8 |
| doc-03: frontend_concerns[] | FR-to-frontend mappings | Agent 4, 6 |
| doc-04: routes[] | Route definitions with screen_name | Agent 5, 6 |
| doc-05: query_hooks[] | React Query hooks and keys | Agent 7, 8 |
| doc-05: stores[] | Zustand store definitions | Agent 8 |
| doc-06: component_tree[] | Component hierarchy per page | Agent 8 |
| doc-07: endpoints[] | API endpoint definitions | Agent 8 |
| doc-07: types[] | Request/response TypeScript types | Agent 8 |
| doc-08: schemas[] | Zod validation schemas | Agent 9 |
| doc-08: state_handling[] | Edge case state handling | Agent 9 |

### Cross-Document Validation Rules

From `workflow.yaml validation.rules`. Enforced by `scripts/validate-chain.sh` after Agent 8 complete:

| Rule | Severity | Check |
|------|----------|-------|
| route-vs-screen | BLOCKER | doc-04 routes[].screen_name IN doc-06 component_tree[].page |
| api-vs-state | BLOCKER | doc-07 endpoints[] HAS query_hook IN doc-05 query_hooks[] |
| entity-vs-schema | BLOCKER | doc-02 entities[] HAS type IN doc-07 types[] OR schema IN doc-08 schemas[] |
| business-rule-vs-validation | WARNING | doc-02 business_rules[] HAS validation IN doc-08 |
| user-story-vs-task | WARNING | doc-02 user_stories[] COVERED_BY doc-09 tasks[] |
| edge-case-vs-handling | INFO | doc-02 edge_cases[] HAS handling IN doc-08 state_handling[] |

BLOCKER rules MUST pass before Agent 9 runs. WARNING and INFO shown for awareness.

## Quality Gates

### Review Gates (Human Approval Required)

Agents 1, 4, 8, 9 are review gates. Each gate shows:
1. Agent output summary
2. DoD checklist results
3. Low-confidence items (score < 0.6)
4. Validation report (after Agent 8 only)

Gate decision options: Continue, Stop, or Restart Agent.

### Definition of Complete per Agent

**Agent 1 (this document):**
- [x] All 9 agents from workflow.yaml documented
- [x] Naming conventions, output format, dependency order clear
- [x] Frontmatter YAML valid and complete per schema
- [x] No placeholder, TODO, or "TBD"
- [x] Output file matches docs/01-planning-workflow.md
- [x] All entity/type/schema names PascalCase exact
- [x] Cross-document linking rules defined
- [x] Quality gates for all agents defined

**Agent 2 — prd-analysis — docs/02-prd-analysis.md:**
- [ ] All entities extracted with fields and types (Wallet, Category, Transaction)
- [ ] All business rules (BR-001 through BR-015) documented
- [ ] All user stories (US-001 through US-011) documented with priority
- [ ] All edge cases documented with expected handling
- [ ] All functional requirements (FR-001 through FR-007) analyzed per frontend concern
- [ ] Provenance markers on all extractions (source: "PRD line N")
- [ ] All entity names PascalCase
- [ ] Frontmatter includes prd_source_hash matching chain state

**Agent 3 — frontend-requirement-mapping — docs/03-frontend-requirement-mapping.md:**
- [ ] Each FR mapped to one or more frontend concerns
- [ ] Data requirements identified per FR
- [ ] UI state requirements identified per FR
- [ ] References doc-02 entities and business rules

**Agent 4 — screen-route-mapping — docs/04-screen-route-mapping.md:**
- [ ] All 9 screens from PRD mapped to Next.js App Router routes
- [ ] Dynamic route params documented (`/:id/edit`)
- [ ] Layout structure defined (shared vs nested)
- [ ] Loading and error states identified per route
- [ ] Navigation flow between screens documented
- [ ] References doc-02 and doc-03

**Agent 5 — state-data-flow-plan — docs/05-state-data-flow-plan.md:**
- [ ] Zustand stores defined with state shape and actions
- [ ] React Query hooks defined with query keys and fetcher functions
- [ ] Data flow for each screen defined
- [ ] Cache invalidation strategy documented
- [ ] Context budget rules applied (summary-based reads from upstream)
- [ ] References doc-04

**Agent 6 — component-and-ui-plan — docs/06-component-and-ui-plan.md:**
- [ ] Component tree for each screen defined
- [ ] Shared components identified (layout, navigation, cards, forms)
- [ ] Page-specific components identified
- [ ] shadcn/ui component selections with rationale per component
- [ ] Props interface sketches for key components
- [ ] References doc-03 and doc-04

**Agent 7 — api-integration-plan — docs/07-api-integration-plan.md:**
- [ ] All endpoints identified with method, path, request params, response shape
- [ ] Request/response types in TypeScript using PascalCase
- [ ] MSW handler definitions for each endpoint
- [ ] Error response types documented
- [ ] References doc-05

**Agent 8 — validation-and-edge-case-plan — docs/08-validation-and-edge-case-plan.md:**
- [ ] Zod schemas for all entities (Wallet, Category, Transaction)
- [ ] Form validation rules for create and edit forms
- [ ] Error boundary strategy for each page
- [ ] All BR-001 through BR-015 translated to Zod rules or validation logic
- [ ] All edge cases from doc-02 have concrete handling
- [ ] State handling for loading, error, empty, edge case conditions
- [ ] References doc-02, doc-05, doc-06, doc-07

**Agent 9 — atomic-task-breakdown — docs/09-atomic-task-breakdown.md:**
- [ ] Tasks sized for single LLM execution (one task, one output artifact)
- [ ] All user stories covered by at least one task
- [ ] Dependency order between tasks documented
- [ ] Task format compatible with GitHub Issues
- [ ] RTM complete: all entities, business rules, user stories traceable

### Post-Agent Script Gates

| Script | When | Input | Output | Gate |
|--------|------|-------|--------|------|
| validate | After Agent 8 | All docs 01-08 | docs/validation-report.md | BLOCKER pass required |
| rtm | After Agent 9 | All docs 01-09 | docs/traceability-matrix.md | Review gate |
| push | After final gate | docs/09-atomic-task-breakdown.md | docs/.issue-map.json + GitHub Issues | Dry-run preview then approve |

Validation runs `scripts/validate-chain.sh` which checks all 6 rules from workflow.yaml. BLOCKER failures block Agent 9. WARNING and INFO are advisory.

## Context Budget Rules for Agent 5+

Agent 5 and above operate under context budget constraints to prevent cumulative document volume exceeding LLM context window.

**Rules:**
1. Read only the YAML frontmatter `summary` field from each upstream document
2. Full prose re-read only when specific detail is needed (e.g., exact route path, component name, field type)
3. Do NOT auto-summarize — summaries are author-generated in each document's frontmatter
4. Use cross-document link pattern to reference upstream data
5. Reserve maximum context window for current agent's reasoning and output generation

**Rationale:** By Agent 5, cumulative upstream content exceeds typical LLM context window (200K tokens). Frontmatter summaries (~250 words each) provide sufficient context for planning while fitting within budget.

## Confidence Scoring in This Document

All assertions in this document derive from `workflow.yaml` (machine-readable specification), existing `.chain-state.json`, and established conventions. Confidence is 1.0 on all assertions.

Source references:
- Chain structure: `workflow.yaml agents[]`, `workflow.yaml review_gates`, `workflow.yaml execution_strategy`
- Naming: `workflow.yaml git.branch_prefix`, `workflow.yaml agents[].output`
- Validation rules: `workflow.yaml validation.rules[]`
- prd_source_hash: `.chain-state.json prdHash`
- Context budget rules: `.claude/skills/chain-run/SKILL.md`

## DoD Checklist

- [x] All 9 agents from workflow.yaml documented
- [x] Naming conventions, output format, dependency order clear
- [x] Frontmatter YAML valid and complete per schema
- [x] No placeholder, TODO, or "TBD"
- [x] Output file matches `workflow.yaml agents[id=1].output` = docs/01-planning-workflow.md
- [x] Format output follows conventions documented in this document
- [x] All entity/type/schema names PascalCase exact
- [x] Cross-document linking rules defined with field path references
- [x] Quality gates for all 9 agents defined with per-document checklists
- [x] Context budget rules for Agent 5+ defined with rationale
- [x] Confidence scoring guideline documented (0.0-1.0 scale with meanings)
- [x] Assumptions format defined ({id, statement, impacts, confidence})
- [x] Provenance markers defined (source: "PRD line N" | inference | convention | chaining)
- [x] Exact output filenames table from workflow.yaml
- [x] Review gates documented (Agents 1, 4, 8, 9)
- [x] prd_source_hash matches .chain-state.json: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
