#!/usr/bin/env bash
# scripts/generate-rtm.sh — Requirements Traceability Matrix generator
# Dipanggil oleh /chain-run setelah Agent 9 selesai
# Input: semua frontmatter YAML dari docs/0?-*.md
# Output: docs/traceability-matrix.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DOCS_DIR="${CHAIN_DOCS_DIR:-$PROJECT_DIR/docs}"
OUTPUT_FILE="$DOCS_DIR/traceability-matrix.md"
CHAIN_STATE="$DOCS_DIR/.chain-state.json"
RUN_LOG="$DOCS_DIR/.chain-run-log.jsonl"

echo "=== generate-rtm.sh ==="

PYTHON_BIN="${PYTHON_BIN:-python3.13}"
CHAIN_SCRIPT_DIR="$SCRIPT_DIR" "$PYTHON_BIN" - "$DOCS_DIR" "$OUTPUT_FILE" "$CHAIN_STATE" "$RUN_LOG" << 'PYEOF'
import sys, os, json, re, hashlib
from datetime import datetime, timezone
from collections import defaultdict

# Import shared YAML parser from same directory
sys.path.insert(0, os.environ.get('CHAIN_SCRIPT_DIR', os.path.join(os.getcwd(), 'scripts')))
from _yaml_parser import parse_frontmatter, split_refs, expand_range, atomic_update_json

docs_dir = sys.argv[1]
output_file = sys.argv[2]
state_file = sys.argv[3]
log_file = sys.argv[4]

# --- Load all documents ---
print("Loading documents...")
doc_pattern = re.compile(r'^0[2-9]-.*\.md$')
docs = {}
for fname in sorted(os.listdir(docs_dir)):
    if not doc_pattern.match(fname):
        continue
    filepath = os.path.join(docs_dir, fname)
    fm = parse_frontmatter(filepath)
    if fm is None:
        print(f"  SKIP {fname}: cannot parse frontmatter")
        continue
    # Extract agent number from frontmatter agent field (avoid filename collision e.g. 09-atomic-task vs 09-validation-report)
    agent_num = fm.get('agent')
    if agent_num is None or not isinstance(agent_num, int):
        print(f"  SKIP {fname}: no valid agent field")
        continue
    docs[agent_num] = {'filename': fname, 'fm': fm}
    print(f"  OK  {fname}: agent={agent_num}")

# --- Build traceability index ---
print("\nBuilding traceability index...")
rtm = {
    'entities': defaultdict(lambda: {'name': '', 'covered_by': defaultdict(list)}),
    'business_rules': defaultdict(lambda: {'id': '', 'covered_by': defaultdict(list)}),
    'user_stories': defaultdict(lambda: {'id': '', 'covered_by': defaultdict(list)}),
    'edge_cases': defaultdict(lambda: {'id': '', 'covered_by': defaultdict(list)}),
}

# Source: doc-02 (entities, business_rules, user_stories, edge_cases)
doc02 = docs.get(2, {}).get('fm', {})

for ent in doc02.get('entities', []):
    name = ent.get('name', '')
    if name:
        rtm['entities'][name]['name'] = name

for br in doc02.get('business_rules', []):
    bid = br.get('id', '')
    if bid:
        rtm['business_rules'][bid]['id'] = bid

for us in doc02.get('user_stories', []):
    uid = us.get('id', '')
    if uid:
        rtm['user_stories'][uid]['id'] = uid

for ec in doc02.get('edge_cases', []):
    eid = ec.get('id', '')
    if eid:
        rtm['edge_cases'][eid]['id'] = eid

# Trace entities through all downstream docs
def find_entity_refs(doc_key, field_path, items, entity_idx):
    """For each item, check if its name matches any entity (case-insensitive fuzzy)."""
    doc_label = f"doc-{doc_key:02d}"
    for item in items:
        item_name = item.get('name', item.get('page', item.get('component', item.get('screen_name', ''))))
        if not item_name:
            continue
        # Exact match first
        for ent_name in entity_idx:
            if item_name == ent_name or item_name.lower() == ent_name.lower():
                entity_idx[ent_name]['covered_by'][doc_label].append(item_name)

entity_idx = rtm['entities']
for doc_key, doc_data in docs.items():
    fm = doc_data['fm']
    for field, label in [('routes', 'routes'), ('stores', 'stores'),
                          ('component_tree', 'component_tree'),
                          ('query_hooks', 'query_hooks'), ('types', 'types'),
                          ('schemas', 'schemas'), ('state_handling', 'state_handling')]:
        items = fm.get(field, [])
        if items:
            find_entity_refs(doc_key, field, items, entity_idx)

# Trace business rules → doc-08 validation
doc08 = docs.get(8, {}).get('fm', {})
schemas = doc08.get('schemas', [])
error_boundaries = doc08.get('error_boundaries', [])
state_handling = doc08.get('state_handling', [])

for br_id, br_data in rtm['business_rules'].items():
    for s in schemas:
        if br_id in split_refs(s.get('related_business_rule', '')):
            br_data['covered_by']['doc-08'].append(f"schema:{s.get('name', '?')}")
    for eb in error_boundaries:
        if br_id in split_refs(eb.get('related_business_rule', '')):
            br_data['covered_by']['doc-08'].append(f"error_boundary:{eb.get('scope', '?')}")

# Trace user stories → doc-09 tasks
doc09 = docs.get(9, {}).get('fm', {})
tasks = doc09.get('tasks', [])

for us_id, us_data in rtm['user_stories'].items():
    for t in tasks:
        src = t.get('source', '')
        if us_id in src or us_id in expand_range(src, 'US-'):
            us_data['covered_by']['doc-09'].append(t.get('id', '?'))

# Trace edge cases → doc-08 state handling
for ec_id, ec_data in rtm['edge_cases'].items():
    for sh in state_handling:
        if ec_id in split_refs(sh.get('related_edge_case', '')):
            ec_data['covered_by']['doc-08'].append(f"component:{sh.get('component', '?')}")

# --- Coverage stats ---
print("\nCoverage stats:")
entity_covered = sum(1 for e in rtm['entities'].values() if any(e['covered_by'].values()))
br_covered = sum(1 for b in rtm['business_rules'].values() if any(b['covered_by'].values()))
us_covered = sum(1 for u in rtm['user_stories'].values() if any(u['covered_by'].values()))
ec_covered = sum(1 for e in rtm['edge_cases'].values() if any(e['covered_by'].values()))

total_entities = len(rtm['entities'])
total_br = len(rtm['business_rules'])
total_us = len(rtm['user_stories'])
total_ec = len(rtm['edge_cases'])

pct = lambda c, t: f"{c}/{t} ({c*100//t}%)" if t > 0 else "0/0 (N/A)"
print(f"  Entities:      {pct(entity_covered, total_entities)}")
print(f"  Business Rules: {pct(br_covered, total_br)}")
print(f"  User Stories:   {pct(us_covered, total_us)}")
print(f"  Edge Cases:     {pct(ec_covered, total_ec)}")

# --- Generate report ---
print(f"\nGenerating: {output_file}")

now_ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
total_covered = entity_covered + br_covered + us_covered + ec_covered
total_all = total_entities + total_br + total_us + total_ec
overall_pct = (total_covered * 100 // total_all) if total_all > 0 else 0

lines = []
lines.append("---")
lines.append("prd_source_hash: \"\"")
lines.append(f"generated_at: \"{now_ts}\"")
lines.append("schema_version: 1")
lines.append("coverage:")
lines.append(f"  entities: {pct(entity_covered, total_entities)}")
lines.append(f"  business_rules: {pct(br_covered, total_br)}")
lines.append(f"  user_stories: {pct(us_covered, total_us)}")
lines.append(f"  edge_cases: {pct(ec_covered, total_ec)}")
lines.append(f"  overall: \"{overall_pct}%\"")
lines.append("---")
lines.append("")
lines.append("# Requirements Traceability Matrix")
lines.append("")
lines.append(f"**Generated:** {now_ts}  ")
lines.append(f"**Overall Coverage:** {overall_pct}% ({total_covered}/{total_all})")
lines.append("")
lines.append("## Summary")
lines.append("")
lines.append("| Category | Total | Covered | Coverage |")
lines.append("|----------|-------|---------|----------|")
lines.append(f"| Entities | {total_entities} | {entity_covered} | {pct(entity_covered, total_entities)} |")
lines.append(f"| Business Rules | {total_br} | {br_covered} | {pct(br_covered, total_br)} |")
lines.append(f"| User Stories | {total_us} | {us_covered} | {pct(us_covered, total_us)} |")
lines.append(f"| Edge Cases | {total_ec} | {ec_covered} | {pct(ec_covered, total_ec)} |")
lines.append("")

# Entities section
lines.append("## Entities")
lines.append("")
lines.append("| Entity | doc-04 (Routes) | doc-05 (State) | doc-06 (Components) | doc-07 (Types) | doc-08 (Schemas) | doc-09 (Tasks) |")
lines.append("|--------|-----------------|----------------|---------------------|----------------|------------------|----------------|")
for name in sorted(rtm['entities']):
    e = rtm['entities'][name]
    cov = e['covered_by']
    def cell(key):
        refs = cov.get(key, [])
        return ", ".join(refs[:3]) + ("..." if len(refs) > 3 else "") if refs else "—"

    lines.append(f"| {name} | {cell('doc-04')} | {cell('doc-05')} | {cell('doc-06')} | {cell('doc-07')} | {cell('doc-08')} | {cell('doc-09')} |")

lines.append("")

# Business Rules section
lines.append("## Business Rules")
lines.append("")
lines.append("| Rule ID | doc-08 (Validation) |")
lines.append("|---------|---------------------|")
for bid in sorted(rtm['business_rules']):
    b = rtm['business_rules'][bid]
    cov = b['covered_by'].get('doc-08', [])
    lines.append(f"| {bid} | {', '.join(cov) if cov else '❌ Uncovered'} |")
lines.append("")

# User Stories section
lines.append("## User Stories")
lines.append("")
lines.append("| Story ID | doc-09 (Tasks) |")
lines.append("|----------|----------------|")
for uid in sorted(rtm['user_stories']):
    u = rtm['user_stories'][uid]
    cov = u['covered_by'].get('doc-09', [])
    lines.append(f"| {uid} | {', '.join(cov) if cov else '❌ Uncovered'} |")
lines.append("")

# Edge Cases section
lines.append("## Edge Cases")
lines.append("")
lines.append("| Case ID | doc-08 (State Handling) |")
lines.append("|---------|--------------------------|")
for eid in sorted(rtm['edge_cases']):
    e = rtm['edge_cases'][eid]
    cov = e['covered_by'].get('doc-08', [])
    lines.append(f"| {eid} | {', '.join(cov) if cov else '❌ Uncovered'} |")
lines.append("")

# Legend
lines.append("---")
lines.append("")
lines.append("**Legend:**  ")
lines.append("- ✅ Covered — requirement has at least one downstream reference  ")
lines.append("- ❌ Uncovered — requirement has zero downstream references (gap)")
lines.append("")
lines.append(f"*Generated by scripts/generate-rtm.sh at {now_ts}*")

with open(output_file, 'w') as f:
    f.write('\n'.join(lines) + '\n')

# Update chain state with CAS
if os.path.exists(state_file):
    def _update(state):
        state['rtm'] = {
            'status': 'complete',
            'outputPath': 'docs/traceability-matrix.md',
            'coverage_pct': overall_pct
        }
        return state
    atomic_update_json(state_file, _update)

# Log
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
entry = json.dumps({'ts': ts, 'event': 'rtm.complete', 'coverage_pct': overall_pct})
with open(log_file, 'a') as f:
    f.write(entry + '\n')

print(f"\nRTM generated: {output_file}")
print(f"Coverage: {overall_pct}% ({total_covered}/{total_all})")
PYEOF
