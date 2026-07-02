#!/usr/bin/env bash
# scripts/validate-chain.sh — Cross-document validation
# Dipanggil oleh /chain-run (setelah Agent 8) atau /chain-validate (manual)
# Rules dibaca dari docs/workflow.yaml
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

WORKFLOW_FILE="${CHAIN_WORKFLOW_FILE:-$PROJECT_DIR/docs/workflow.yaml}"
DOCS_DIR="${CHAIN_DOCS_DIR:-$PROJECT_DIR/docs}"
REPORT_FILE="$DOCS_DIR/validation-report.md"
CHAIN_STATE="$DOCS_DIR/.chain-state.json"
RUN_LOG="$DOCS_DIR/.chain-run-log.jsonl"

MODE="${1:-full}"  # full | quick | agent-N

echo "=== validate-chain.sh ==="
echo "Mode: $MODE"

# Check prerequisites
if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "ERROR: workflow.yaml not found at $WORKFLOW_FILE"
  exit 1
fi

PYTHON_BIN="${PYTHON_BIN:-python3.13}"
CHAIN_SCRIPT_DIR="$SCRIPT_DIR" "$PYTHON_BIN" - "$WORKFLOW_FILE" "$DOCS_DIR" "$MODE" "$REPORT_FILE" "$CHAIN_STATE" "$RUN_LOG" << 'PYEOF'
import sys, os, json, hashlib, re
from datetime import datetime, timezone

# Import shared YAML parser from same directory
sys.path.insert(0, os.environ.get('CHAIN_SCRIPT_DIR', os.path.join(os.getcwd(), 'scripts')))

workflow_file = sys.argv[1]
docs_dir = sys.argv[2]
mode = sys.argv[3]
report_file = sys.argv[4]
state_file = sys.argv[5]
log_file = sys.argv[6]

from _yaml_parser import parse_frontmatter, split_refs, expand_range, atomic_update_json

# --- Index builder ---
def build_index(docs_dir, agent_files):
    """Parse frontmatter from all agent output files, build in-memory index."""
    index = {}
    for agent_id, filename in agent_files.items():
        filepath = os.path.join(docs_dir, filename)
        fm = parse_frontmatter(filepath)
        if fm is None:
            print(f"  WARNING: Cannot parse {filename} — skipping")
            continue
        index[agent_id] = fm
        print(f"  OK  {filename}: agent={fm.get('agent')}, status={fm.get('status')}")
    return index

# --- Validation rules ---
def validate(config, index):
    """Run all validation rules against the index. Returns report dict."""
    results = []
    validation = config.get('validation', {})
    rules = validation.get('rules', [])

    for rule in rules:
        name = rule['name']
        severity = rule['severity']
        failures = []

        if name == 'route-vs-screen':
            doc04 = index.get(4, {})
            doc06 = index.get(6, {})
            routes = doc04.get('routes', [])
            pages = [p.get('page') for p in doc06.get('component_tree', [])]
            for r in routes:
                screen = r.get('screen_name', '')
                if screen and screen not in pages:
                    failures.append({
                        'item': f"screen_name={screen} (path={r.get('path', '?')})",
                        'reason': f"screen_name '{screen}' not found in doc06 component_tree[].page"
                    })

        elif name == 'api-vs-state':
            doc07 = index.get(7, {})
            doc05 = index.get(5, {})
            endpoints = doc07.get('endpoints', [])
            query_hook_names = [qh.get('name', '') for qh in doc05.get('query_hooks', [])]
            for ep in endpoints:
                hook_ref = ep.get('related_query_hook', '')
                if hook_ref and hook_ref not in query_hook_names:
                    failures.append({
                        'item': f"endpoint={ep.get('method', '?')} {ep.get('path', '?')}",
                        'reason': f"related_query_hook '{hook_ref}' not found in doc05.query_hooks[]"
                    })

        elif name == 'entity-vs-schema':
            doc02 = index.get(2, {})
            doc07 = index.get(7, {})
            doc08 = index.get(8, {})
            entities = doc02.get('entities', [])
            type_names = [t.get('name', '') for t in doc07.get('types', [])]
            schema_names = [s.get('name', '') for s in doc08.get('schemas', [])]
            for ent in entities:
                ent_name = ent.get('name', '')
                if ent_name and ent_name not in type_names and ent_name not in schema_names:
                    failures.append({
                        'item': f"entity={ent_name}",
                        'reason': f"Entity '{ent_name}' has no type in doc07.types[] AND no schema in doc08.schemas[]"
                    })

        elif name == 'business-rule-vs-validation':
            doc02 = index.get(2, {})
            doc08 = index.get(8, {})
            rules_br = doc02.get('business_rules', [])
            schemas = doc08.get('schemas', [])
            schema_br_refs = set()
            for s in schemas:
                for ref in split_refs(s.get('related_business_rule', '')):
                    schema_br_refs.add(ref)
            for br in rules_br:
                br_id = br.get('id', '')
                if br_id and br_id not in schema_br_refs:
                    failures.append({
                        'item': f"business_rule={br_id}",
                        'reason': f"Business rule '{br_id}' has no related Zod schema/validation in doc08"
                    })

        elif name == 'user-story-vs-task':
            doc02 = index.get(2, {})
            doc09 = index.get(9, {})
            stories = doc02.get('user_stories', [])
            tasks = doc09.get('tasks', [])
            # Collect all covered US IDs from task source fields
            covered_ids = set()
            for t in tasks:
                src = t.get('source', '')
                if not src:
                    continue
                covered_ids.update(expand_range(src, 'US-'))
                # Also check direct substring match
                for us_id in [s.get('id', '') for s in stories]:
                    if us_id and us_id in src:
                        covered_ids.add(us_id)
            for us in stories:
                us_id = us.get('id', '')
                if us_id and us_id not in covered_ids:
                    failures.append({
                        'item': f"user_story={us_id}",
                        'reason': f"User story '{us_id}' not covered by any task in doc09"
                    })

        elif name == 'edge-case-vs-handling':
            doc02 = index.get(2, {})
            doc08 = index.get(8, {})
            edge_cases = doc02.get('edge_cases', [])
            state_handling = doc08.get('state_handling', [])
            sh_ec_refs = set()
            for sh in state_handling:
                for ref in split_refs(sh.get('related_edge_case', '')):
                    sh_ec_refs.add(ref)
            for ec in edge_cases:
                ec_id = ec.get('id', '')
                if ec_id and ec_id not in sh_ec_refs:
                    failures.append({
                        'item': f"edge_case={ec_id}",
                        'reason': f"Edge case '{ec_id}' has no handling in doc08.state_handling[]"
                    })

        status = "pass" if not failures else "fail"
        results.append({
            'name': name,
            'description': rule.get('description', ''),
            'severity': severity,
            'status': status,
            'failures': failures
        })
        symbol = "✅" if status == "pass" else "❌"
        print(f"  {symbol} {name}: {len(failures)} failures [{severity}]")

    return results

# --- Main ---
print("Loading workflow.yaml...")
try:
    import yaml
    with open(workflow_file) as f:
        config = yaml.safe_load(f)
except ImportError:
    print("ERROR: PyYAML not installed. Run: pip install pyyaml")
    sys.exit(1)

wf = config.get('workflow', config)
agents_list = wf.get('agents', [])

# Map agent id to expected output filename
agent_files = {}
for a in agents_list:
    outputs = a.get('output', [])
    if isinstance(outputs, str):
        outputs = [outputs]
    filename = outputs[0].replace('docs/', '') if outputs else f"{a['id']:02d}-unknown.md"
    agent_files[a['id']] = filename

print(f"Found {len(agent_files)} agent outputs expected")

# Build index
print("\nParsing frontmatter...")
index = build_index(docs_dir, agent_files)

# Validate
print("\nRunning validation rules...")
results = validate(wf, index)

# Count
blocker_count = sum(1 for r in results if r['severity'] == 'BLOCKER' and r['status'] == 'fail')
warning_count = sum(1 for r in results if r['severity'] == 'WARNING' and r['status'] == 'fail')
info_count = sum(1 for r in results if r['severity'] == 'INFO' and r['status'] == 'fail')
total_fail = blocker_count + warning_count + info_count

# Generate report
print(f"\nGenerating report: {report_file}")
report_lines = []
report_lines.append("---")
report_lines.append("prd_source_hash: \"\"")
report_lines.append("validation_status: " + ("pass" if blocker_count == 0 else "fail"))
report_lines.append(f"blocker_count: {blocker_count}")
report_lines.append(f"warning_count: {warning_count}")
report_lines.append(f"info_count: {info_count}")
report_lines.append("schema_version: 1")
report_lines.append("generated_at: \"" + datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ") + "\"")
report_lines.append("rules:")
for r in results:
    report_lines.append(f"  - name: \"{r['name']}\"")
    report_lines.append(f"    severity: \"{r['severity']}\"")
    report_lines.append(f"    status: \"{r['status']}\"")
    report_lines.append(f"    failures:")
    for f_item in r['failures']:
        report_lines.append(f"      - item: \"{f_item['item']}\"")
        report_lines.append(f"        reason: \"{f_item['reason']}\"")
report_lines.append("---")
report_lines.append("")
report_lines.append("# Validation Report")
report_lines.append("")
report_lines.append(f"**Status:** {'✅ PASS' if blocker_count == 0 else '❌ FAIL'} | ")
report_lines.append(f"BLOCKER: {blocker_count} | WARNING: {warning_count} | INFO: {info_count}")
report_lines.append("")

# Summary table
report_lines.append("| Rule | Severity | Status | Failures |")
report_lines.append("|------|----------|--------|----------|")
for r in results:
    icon = "✅" if r['status'] == 'pass' else "❌"
    report_lines.append(f"| {r['name']} | {r['severity']} | {icon} {r['status']} | {len(r['failures'])} |")

if blocker_count > 0:
    report_lines.append("")
    report_lines.append("## 🚫 Blockers")
    for r in results:
        if r['severity'] == 'BLOCKER' and r['failures']:
            report_lines.append(f"### {r['name']}")
            for f_item in r['failures']:
                report_lines.append(f"- **{f_item['item']}**: {f_item['reason']}")

if warning_count > 0:
    report_lines.append("")
    report_lines.append("## ⚠️ Warnings")
    for r in results:
        if r['severity'] == 'WARNING' and r['failures']:
            report_lines.append(f"### {r['name']}")
            for f_item in r['failures']:
                report_lines.append(f"- **{f_item['item']}**: {f_item['reason']}")

if info_count > 0:
    report_lines.append("")
    report_lines.append("## ℹ️ Info")
    for r in results:
        if r['severity'] == 'INFO' and r['failures']:
            report_lines.append(f"### {r['name']}")
            for f_item in r['failures']:
                report_lines.append(f"- **{f_item['item']}**: {f_item['reason']}")

with open(report_file, 'w') as f:
    f.write('\n'.join(report_lines) + '\n')

# Update chain state if present (CAS — detects concurrent writes)
if os.path.exists(state_file):
    def _update(state):
        state['validation'] = {
            'status': 'complete' if blocker_count == 0 else 'failed',
            'reportPath': 'docs/validation-report.md'
        }
        return state
    def _conflict(old_ts, current_ts):
        print("  ⚠️  Concurrent write detected — re-applying on top of newer state")
    atomic_update_json(state_file, _update, _conflict)
    print("Updated .chain-state.json validation status")

# Log
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
log_entry = json.dumps({
    'ts': ts, 'event': 'validate.result',
    'blockerCount': blocker_count, 'warningCount': warning_count, 'infoCount': info_count
})
with open(log_file, 'a') as f:
    f.write(log_entry + '\n')

print(f"\n{'='*40}")
print(f"Validation complete: {blocker_count} BLOCKER, {warning_count} WARNING, {info_count} INFO")
exit_code = 1 if blocker_count > 0 else 0
sys.exit(exit_code)
PYEOF
