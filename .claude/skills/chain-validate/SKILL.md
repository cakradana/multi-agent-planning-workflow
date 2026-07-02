---
name: chain-validate
description: Validasi konsistensi cross-document — wrapper untuk scripts/validate-chain.sh
context: fork
---

# Chain Validate — Cross-Document Validation

Wrapper untuk `scripts/validate-chain.sh`. Validasi dijalankan oleh script (deterministik, nol token cost), skill ini hanya menyajikan hasil ke user.

## Invocation

```
/chain-validate                    # Validasi semua dokumen
/chain-validate --quick            # Hanya rule yang melibatkan file yang baru berubah
/chain-validate --agent N          # Hanya rule yang melibatkan agent N
```

## Flow

```
1. Panggil scripts/validate-chain.sh (dengan flag sesuai invocation)
2. Baca docs/validation-report.md
3. Tampilkan ringkasan ke user:
   - BLOCKER count + WARNING count + INFO count
   - Detail per rule: item mana yang fail + kenapa
4. Jika BLOCKER > 0:
   - Tampilkan list BLOCKER
   - AskUserQuestion: "Fix dulu atau lanjut paksa?"
   - Log keputusan ke .chain-run-log.jsonl
```

## Validation Rules

Script `validate-chain.sh` membaca rules dari `docs/workflow.yaml validation.rules`:

| Rule | Severity | Check |
|------|----------|-------|
| route-vs-screen | BLOCKER | `doc04.routes[].screen_name IN doc06.component_tree[].page` |
| api-vs-state | BLOCKER | `doc07.endpoints[] HAS query_hook IN doc05.query_hooks[]` |
| entity-vs-schema | BLOCKER | `doc02.entities[] HAS type IN doc07.types[] OR schema IN doc08.schemas[]` |
| business-rule-vs-validation | WARNING | `doc02.business_rules[] HAS validation IN doc08` |
| user-story-vs-task | WARNING | `doc02.user_stories[] COVERED_BY doc09.tasks[]` |
| edge-case-vs-handling | INFO | `doc02.edge_cases[] HAS handling IN doc08.state_handling[]` |

## Output

`docs/validation-report.md` dengan YAML frontmatter:
- `validation_status: pass|fail`
- `blocker_count`, `warning_count`, `info_count`
- `rules`: array per-rule dengan `name`, `status`, `failures: [{item, reason}]`

## Location in Chain

- **Otomatis:** `/chain-run` panggil setelah Agent 8 complete, sebelum Agent 9
- **Manual:** User bisa panggil `/chain-validate` kapan saja untuk cek inkremental
