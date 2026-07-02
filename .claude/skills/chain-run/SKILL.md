---
name: chain-run
description: Jalankan chain planning workflow dari start sampai selesai
disable-model-invocation: true
context: fork
---

# Chain Run — Orchestration Engine

Jalankan multi-agent chain planning workflow berdasarkan `docs/workflow.yaml`.

## Invocation

```
/chain-run                  # Mulai dari awal atau lanjut dari state terakhir
/chain-run --restart        # Reset state, hapus semua output, mulai dari Agent 1
/chain-run --continue       # Resume dari agent terakhir yang status != "complete"
/chain-run --force          # Lanjutkan meskipun staleness terdeteksi
```

## Flow

### 1. Init & State Check

```
1. Baca docs/workflow.yaml → validasi agents, depends_on, output filenames
2. Cek docs/.chain-lock:
   - Jika lock exists + < 30 menit → BLOCK: "Chain sedang berjalan di session [sessionId]"
   - Jika lock exists + > 30 menit → WARNING + overwrite lock
3. Jika docs/.chain-state.json tidak ada → buat baru dari workflow.yaml
4. Jika ada → validasi schemaVersion, tentukan agent berikutnya
```

### 2. State Machine

Baca/tulis `.chain-state.json` di setiap step:

```json
{
  "version": 1,
  "workflow": "frontend-planning",
  "chainId": "chain-<timestamp>",
  "status": "running",
  "currentAgent": N,
  "startedAt": "<ISO>",
  "updatedAt": "<ISO>",
  "prdHash": "<sha256>",
  "branch": "planning/chain-<timestamp>",
  "agents": {
    "1": { "status": "complete", "output": "docs/01-...", "outputHash": "...", "agentVersion": "1.0.0", "retryCount": 0, "startedAt": "...", "completedAt": "..." }
  },
  "schemaVersion": 1,
  "validation": { "status": "pending", "reportPath": "docs/validation-report.md" },
  "history": []
}
```

**Atomic write:** Tulis ke `.chain-state.tmp` dulu, lalu `mv` ke `.chain-state.json`.

### 3. Invoke Agent N

Untuk setiap agent dalam urutan topological (dari `workflow.yaml agents[].depends_on`):

```
1. Cek depends_on: semua dependency harus status = "complete"
2. Cek PRD staleness: sha256(PRD.md) != .chain-state.json prdHash → BLOCK (kecuali Agent 1 atau --force)
3. Update state: agents[N].status = "running", agents[N].startedAt = now
4. Log: agent.start
5. Invoke Agent N via Agent tool dengan subagent_type = agents[N].name
6. Setelah selesai:
   a. Update state: agents[N].status = "complete", outputHash = sha256(output)
   b. Log: agent.complete (dengan estimatedTokens, estimatedCost, durationMs)
7. Review gate jika N in [1, 4, 8, 9]:

   **Step A — tampilkan ringkasan (text output):**
   - Agent name, output file, DoD checklist, Low Confidence Items

   **Step B — WAJIB invoke AskUserQuestion TOOL (bukan teks!):**
   ```
   Gunakan AskUserQuestion tool dengan parameter:
     questions[0].question: "Agent [N] ([name]) complete. Lanjutkan?"
     questions[0].header: "Review Gate"
     questions[0].options: [
       {label: "Continue", description: "Lanjut ke agent berikutnya"},
       {label: "Stop", description: "Hentikan chain"},
       {label: "Restart Agent [N]", description: "Ulangi Agent [N]"}
     ]

   PENTING: Kamu HARUS memanggil tool AskUserQuestion. JANGAN hanya menulis teks pertanyaan.
   Tool AskUserQuestion akan merender interactive prompt ke user.
   Tunggu jawaban user sebelum melanjutkan.
   ```

   **Step C — setelah user menjawab:**
   - "Continue" → log: review.gate (decision: continue), lanjut agent berikutnya
   - "Stop" → log: review.gate (decision: stop), berhenti
   - "Restart Agent [N]" → log: review.gate (decision: restart), reset state agent[N], invoke ulang Agent N
```

### 4. Context Budget untuk Agent 5+

Untuk Agent 5+, berikan instruksi ke agent untuk membaca:
1. Frontmatter YAML dari SEMUA dokumen upstream (structured data)
2. `summary` field dari frontmatter tiap dokumen upstream (~250 kata)
3. Full prose HANYA jika butuh detail spesifik

TIDAK melakukan auto-summarization. Summary sudah di-generate oleh agent saat menulis output.

### 5. Post-Agent Scripts

```
Setelah Agent 8 complete:
  → scripts/validate-chain.sh → docs/validation-report.md
  → Jika BLOCKER: tampilkan, tanya "Fix atau lanjut?"

Setelah Agent 9 complete:
  → scripts/generate-rtm.sh → docs/traceability-matrix.md
  → Review gate final: task summary + RTM + preview (scripts/push-issues.sh --dry-run) - task list + labels + dependencies ditampilkan
    - Issue BELUM dipush — user lihat preview dulu sebelum approve
  → Jika approved: scripts/push-issues.sh → GitHub Issues + Project #1
```

### 6. Git Branching

```
1. Sebelum Agent 1: git checkout -b planning/chain-<timestamp>
2. Semua AutoCommit hook commit di branch ini
3. Setelah Agent 9 + scripts + review gate approved:
   git push origin planning/chain-<timestamp>
   # Branch siap untuk implementasi — PR ke main setelah kode selesai
```

### 7. Retry Strategy

Agent gagal → cek tipe error:

| Error Type | Retry? | Behavior |
|-----------|--------|----------|
| LLM timeout / API error | ✅ 3x | backoff 5s→10s→20s |
| Context overflow | ✅ 1x | summarize lebih agresif |
| Rate limit (429) | ✅ 5x | backoff dari Retry-After header |
| Validation block | ❌ | User fix dulu |
| Staleness | ❌ | User --restart |
| File write error | ✅ 2x | Mungkin disk/permission |

### 8. Lock Management

```
- Buat docs/.chain-lock sebelum Agent 1
- Update lock setiap agent start
- Hapus lock saat chain complete ATAU normal exit
- Stale lock (>30 menit) → overwrite dengan warning
```

### 9. Progress Display

Tampilkan progress setiap selesai agent:
```
Agent 5/9 complete | Cost so far: $1.24 | ETA: 3 agents left
  ✅ Agent 1: planning-workflow (0:45, $0.12)
  ✅ Agent 2: prd-analysis (2:10, $0.34)
  ✅ Agent 3: frontend-requirement-mapping (1:30, $0.28)
  ✅ Agent 4: screen-route-mapping (1:15, $0.22)
  ✅ Agent 5: state-data-flow-plan (2:05, $0.28)
  ⏳ Agent 6: component-and-ui-plan (running...)
  ⬜ Agent 7: api-integration-plan
  ⬜ Agent 8: validation-and-edge-case-plan
  ⬜ Agent 9: atomic-task-breakdown
```
