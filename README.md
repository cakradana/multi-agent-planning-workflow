# Multi-Agent Chain Workflow — Pocket Frontend Planning

9 agent sekuensial menghasilkan dokumen perencanaan frontend dari PRD, dengan validasi otomatis dan push ke GitHub Issues.

## Prasyarat

- [Claude Code](https://claude.ai/code) CLI
- Python 3.13+ dengan PyYAML (`pip install pyyaml`)
- [GitHub CLI](https://cli.github.com/) (`gh auth login`) — untuk push issues
- Git

## Quick Start

```bash
# 0. Pastikan PRD.md sudah di-commit (wajib — worktree butuh file tracked)
git add PRD.md && git commit -m "add PRD"

# 1. Jalankan chain dari awal
/chain-run

# 2. Lanjut dari state terakhir (resume)
/chain-run --continue

# 4. Reset & mulai dari Agent 1
/chain-run --restart

# 5. Lanjut meskipun PRD berubah (force)
/chain-run --force
```

## Validasi Manual

```bash
# Cross-document validation (6 aturan)
/chain-validate

# Atau langsung via script:
bash scripts/validate-chain.sh

# RTM generation:
bash scripts/generate-rtm.sh
```

## Struktur

### Agent Outputs

| File | Source | Isi |
|------|--------|-----|
| `docs/01-planning-workflow.md` | Agent 1 | Rules chain, naming conventions, output format |
| `docs/02-prd-analysis.md` | Agent 2 | Entity, business rules, user stories, edge cases |
| `docs/03-frontend-requirement-mapping.md` | Agent 3 | FR → routing, state, API, validation, UI mapping |
| `docs/04-screen-route-mapping.md` | Agent 4 | Screens → Next.js App Router routes |
| `docs/05-state-data-flow-plan.md` | Agent 5 | Zustand stores, React Query hooks, data flow |
| `docs/06-component-and-ui-plan.md` | Agent 6 | Component tree, shared vs page-specific, shadcn/ui |
| `docs/07-api-integration-plan.md` | Agent 7 | API contracts, TS types, MSW handlers |
| `docs/08-validation-and-edge-case-plan.md` | Agent 8 | Zod schemas, form rules, error boundaries |
| `docs/09-atomic-task-breakdown.md` | Agent 9 | Atomic tasks, dependency graph, GitHub Issue format |

### Script Outputs

| File | Script | Isi |
|------|--------|-----|
| `docs/validation-report.md` | `validate-chain.sh` | Cross-document validation hasil |
| `docs/traceability-matrix.md` | `generate-rtm.sh` | Requirements traceability matrix |
| `docs/.issue-map.json` | `push-issues.sh` | Task ID → GitHub Issue URL mapping |

### Runtime State (gitignored)

| File | Fungsi |
|------|--------|
| `docs/.chain-state.json` | Agent status, output hash, progress tracker |
| `docs/.chain-lock` | Session lock (stale >30 menit → auto-overwrite) |
| `docs/.chain-run-log.jsonl` | Audit log semua event chain |

### Config

| Path | Fungsi |
|------|--------|
| `docs/workflow.yaml` | Planning manifest — agents, dependencies, validation rules |
| `PRD.md` | Product Requirements Document (input) |
| `.claude/agents/*.md` | 9 agent system prompts |
| `.claude/skills/chain-run/SKILL.md` | Orchestration engine |
| `.claude/skills/chain-validate/SKILL.md` | Validation wrapper |
| `scripts/validate-chain.sh` | Cross-document validation (Python heredoc) |
| `scripts/generate-rtm.sh` | RTM generator (Python heredoc) |
| `scripts/push-issues.sh` | GitHub Issues + Project push (Python heredoc) |
| `scripts/tests/` | Test fixtures

## Flow

```
PRD.md
  ↓
Agent 1 (planning-workflow) ──→ docs/01-planning-workflow.md
  ↓                              [Review Gate]
Agent 2 (prd-analysis) ───────→ docs/02-prd-analysis.md
  ↓
Agent 3 (frontend-requirement) → docs/03-frontend-requirement-mapping.md
  ↓
Agent 4 (screen-route) ───────→ docs/04-screen-route-mapping.md
  ↓                              [Review Gate]
Agent 5 (state-data-flow) ────→ docs/05-state-data-flow-plan.md
  ↓
Agent 6 (component-ui) ───────→ docs/06-component-and-ui-plan.md
  ↓
Agent 7 (api-integration) ────→ docs/07-api-integration-plan.md
  ↓
Agent 8 (validation-edge-case) → docs/08-validation-and-edge-case-plan.md
  ↓                              [Review Gate]
validate-chain.sh ─────────────→ docs/validation-report.md
  ↓
Agent 9 (atomic-task) ────────→ docs/09-atomic-task-breakdown.md
  ↓                              [Review Gate]
generate-rtm.sh ───────────────→ docs/traceability-matrix.md
  ↓
Review Gate (preview issues)
  ↓
push-issues.sh ────────────────→ GitHub Issues + Project
  ↓
Siap implementasi — branch planning/chain-* jadi workspace
```

## 9 Agent

| # | Agent | Output | Tools |
|---|-------|--------|-------|
| 1 | planning-workflow | `01-planning-workflow.md` | Read, Write, Glob, Grep |
| 2 | prd-analysis | `02-prd-analysis.md` | Read, Write, Glob |
| 3 | frontend-requirement-mapping | `03-frontend-requirement-mapping.md` | Read, Write, Glob, WebFetch |
| 4 | screen-route-mapping | `04-screen-route-mapping.md` | Read, Write, Glob, WebFetch |
| 5 | state-data-flow-plan | `05-state-data-flow-plan.md` | Read, Write, Glob, WebFetch |
| 6 | component-and-ui-plan | `06-component-and-ui-plan.md` | Read, Write, Glob, WebFetch |
| 7 | api-integration-plan | `07-api-integration-plan.md` | Read, Write, Glob, WebFetch |
| 8 | validation-and-edge-case-plan | `08-validation-and-edge-case-plan.md` | Read, Write, Glob |
| 9 | atomic-task-breakdown | `09-atomic-task-breakdown.md` | Read, Write, Glob |

Review gates di Agent 1, 4, 8, 9 — human wajib review sebelum lanjut.

## 6 Aturan Validasi

| Aturan | Severity | Cek |
|--------|----------|-----|
| route-vs-screen | **BLOCKER** | Screen di doc-04 harus ada di doc-06 component_tree |
| api-vs-state | **BLOCKER** | Endpoint di doc-07 harus punya query_hook di doc-05 |
| entity-vs-schema | **BLOCKER** | Entity di doc-02 harus punya type (doc-07) atau schema (doc-08) |
| business-rule-vs-validation | WARNING | BR di doc-02 harus punya validasi di doc-08 |
| user-story-vs-task | WARNING | US di doc-02 harus tercakup task di doc-09 |
| edge-case-vs-handling | INFO | Edge case di doc-02 harus punya handling di doc-08 |

## Scripts

### validate-chain.sh

```bash
bash scripts/validate-chain.sh           # Full — semua aturan
bash scripts/validate-chain.sh quick     # Quick — hanya aturan relevan
```

### generate-rtm.sh

```bash
bash scripts/generate-rtm.sh
```

### push-issues.sh

```bash
bash scripts/push-issues.sh              # Push beneran
bash scripts/push-issues.sh --dry-run    # Preview task list tanpa push
```

## Environment Variables

| Variable | Default | Keterangan |
|----------|---------|-----------|
| `CHAIN_WORKFLOW_FILE` | `docs/workflow.yaml` | Override path manifest |
| `CHAIN_DOCS_DIR` | `docs/` | Override directory dokumen |
| `PYTHON_BIN` | `python3.13` | Override Python binary |

## Testing

```bash
bash scripts/tests/test-validate.sh   # Validasi happy path + known blocker
bash scripts/tests/test-rtm.sh        # RTM generation
bash scripts/tests/test-push.sh       # Dry-run push
```

## Git Branch Strategy

- `/chain-run` membuat branch `planning/chain-<timestamp>` sebelum Agent 1
- Hook PostToolUse auto-commit setiap `docs/0?-*.md` ditulis
- Setelah chain complete + review approved → push branch, siap implementasi kode

## GitHub Issues & Project

Setelah Agent 9 selesai, `push-issues.sh` membuat GitHub Issues dengan:

- **36 task** → 36 GitHub Issues dengan format `[T-001] Title`
- **24 label** — `setup`, `component`, `page`, `api`, `wallet`, `category`, `transaction`, `summary`, `testing`, `e2e`, dll
- **Parent relationships** — `T-002` sub-issue dari `T-001` (via `blockedBy` di task YAML)
- **Project Pocket** — semua issue otomatis masuk project board
- **Status Todo** — semua issue start di kolom Todo
- **Start Date & Target Date** — computed dari dependency graph + estimated hours (resource-leveled, 1 dev, 8h/hari)
- **Assignee** — `@cakradana` (via `--add-assignee @me`)
- **Idempotent** — `.issue-map.json` sebagai checkpoint; re-run hanya proses task baru

Preview dulu dengan `push-issues.sh --dry-run` sebelum push.

### Hasil Chain Terakhir

| Metric | Value |
|--------|-------|
| Chain ID | `chain-20260703-012119` |
| Branch | `planning/chain-20260703-012119` |
| Issues | 36 (#1–#36) |
| Project | [Pocket](https://github.com/users/cakradana/projects/1) |
| Coverage | 81% (44/54) — 0 BLOCKER |
| Timeline | Jul 7 → Aug 4, 2026 (21 hari kerja, 162h) |

## Keadaan Gagal

| Skenario | Fix |
|----------|-----|
| Agent gagal (timeout/API error) | Auto-retry 3x. Jika masih gagal: `/chain-run --continue` |
| Review gate tidak muncul (agent lanjut tanpa tanya) | `/chain-run --continue` — baca state, deteksi agent terakhir, lanjut dari gate berikutnya |
| Chain stall (agent output masuk sesi lain) | `/chain-run --continue` — output sudah di disk, tinggal update state |
| YAML parser crash (`validate-chain.sh` error) | Buka file yang disebut di error → cari `:` atau `\|` atau `{}` di nilai YAML tanpa quote → quote manual. Parser punya fallback sanitizer, tapi tidak covers semua edge case |
| State corruption (2 sesi nulis `.chain-state.json` paralel) | Hapus `.chain-state.json` + `.chain-lock`, `/chain-run --restart`. Semua agent output tetap di disk |
| Label not found saat push issues | Buat label via `gh label create` (lihat `labels:` di task YAML), re-run `push-issues.sh` (idempotent) |
| PRD berubah saat chain jalan | Hook block. `/chain-run --restart` dari awal |
| Chain corrupt | Hapus `docs/.chain-state.json` + `docs/.chain-lock`, `/chain-run --restart` |
| File output < 200 bytes | Hook block. Hapus file, `/chain-run --continue` |
| `.chain-lock` stale (>30 menit) | Auto-overwrite oleh `/chain-run` berikutnya |
| State hilang (worktree dibersihkan) tapi output files ada | Mulai dari awal: `/chain-run --restart` |

## Tech Stack

Next.js App Router + Zustand + TanStack Query + shadcn/ui + Tailwind + MSW + Vitest + Playwright
