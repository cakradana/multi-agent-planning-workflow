#!/usr/bin/env bash
# scripts/assign-sprints.sh — Assign project items to sprint iterations based on task phase
# Dipanggil manual setelah push-issues.sh selesai
# Default: dry-run (tampilkan proposal saja). --confirm untuk execute.
# Idempotent: cek sprint field pada item — skip jika sudah ter-assign.
# Setelah ini, item auto-show di board view "Sprint" iteration lane.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_FILE="$PROJECT_DIR/docs/sprint-config.json"
RUN_LOG="$PROJECT_DIR/docs/.chain-run-log.jsonl"

DRY_RUN=true
if [[ "${1:-}" == "--confirm" ]]; then
  DRY_RUN=false
  echo "=== assign-sprints.sh ==="
else
  echo "=== assign-sprints.sh (DRY RUN) ==="
  echo "Run with --confirm to execute"
fi

if ! command -v gh &> /dev/null; then
  echo "ERROR: GitHub CLI ('gh') not installed."
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "ERROR: Not authenticated with GitHub. Run 'gh auth login'."
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Sprint config not found: $CONFIG_FILE"
  exit 1
fi

DRY_RUN="$DRY_RUN" CHAIN_SCRIPT_DIR="$SCRIPT_DIR" python3 - "$CONFIG_FILE" "$RUN_LOG" "$PROJECT_DIR" << 'PYEOF'
import sys, os, json, re, subprocess, time
from datetime import datetime, timezone

config_file = sys.argv[1]
log_file = sys.argv[2]
project_dir = sys.argv[3]
dry_run = os.environ.get('DRY_RUN', 'true') == 'true'

# ── helpers ──────────────────────────────────────────────

def run_gh(args, timeout=20):
    r = subprocess.run(['gh'] + args, capture_output=True, text=True, timeout=timeout)
    if r.returncode != 0:
        raise RuntimeError(f"gh {' '.join(args)}: {r.stderr.strip()}")
    return r.stdout.strip()

def gh_graphql(query):
    return json.loads(run_gh(['api', 'graphql', '-f', f'query={query}']))

# ── 1. Load config ───────────────────────────────────────

with open(config_file) as f:
    config = json.load(f)

proj_number = config['project']['number']
proj_owner = config['project']['owner']
field_id = config['field']['id']
field_name = config['field']['name']
sprints = config['sprints']

# Build phase → sprint lookup
phase_to_sprint = {}
for s in sprints:
    for p in s['phases']:
        phase_to_sprint[int(p)] = s

# ── 2. Resolve project node ID ───────────────────────────

proj_json = json.loads(run_gh(['project', 'view', str(proj_number),
                                '--owner', proj_owner, '--format', 'json']))
proj_node_id = proj_json['id']

# ── 3. Fetch existing iterations ─────────────────────────

query = f'''query {{
  node(id: "{proj_node_id}") {{
    ... on ProjectV2 {{
      fields(first: 20) {{
        nodes {{
          ... on ProjectV2IterationField {{
            id
            name
            configuration {{
              iterations {{ id title startDate duration }}
              completedIterations {{ id title startDate duration }}
            }}
          }}
        }}
      }}
    }}
  }}
}}'''

api_result = gh_graphql(query)
iterations_existing = []
for f in api_result['data']['node']['fields']['nodes']:
    if 'configuration' in f:
        cfg = f['configuration']
        iterations_existing = (cfg.get('iterations', []) +
                               cfg.get('completedIterations', []))
        break

existing_by_name = {}
for i in iterations_existing:
    key = i.get('title') or i.get('name', '')
    if key:
        existing_by_name[key] = i

# ── 4. Verify all configured sprints have iterations ──────

missing_sprints = []
for s in sprints:
    if s['name'] not in existing_by_name:
        missing_sprints.append(s)

if missing_sprints:
    print("ERROR: Iterations missing in GitHub Project.")
    print("Create them in the GitHub UI first:")
    print(f"  → Project: Pocket (#{proj_number})")
    print(f"  → Field: {field_name}")
    print(f"  → Settings → {field_name} → Add iteration:")
    for s in missing_sprints:
        print(f"      {s['name']}: {s['startDate']}, {s['duration']} days")
    sys.exit(1)

# ── 5. Fetch all project items ────────────────────────────

items_json = json.loads(run_gh(['project', 'item-list', str(proj_number),
                                 '--owner', proj_owner, '--format', 'json']))
items = items_json.get('items', [])

# ── 6. Classify ───────────────────────────────────────────

proposed = {}   # sprint_name → [items]
orphans = []    # no phase or phase not mapped
skipped = []    # already has sprint set

for item in items:
    body = item.get('content', {}).get('body', '')

    if item.get('sprint'):
        skipped.append(item)
        continue

    m = re.search(r'\*\*Phase:\*\*\s*(\d+)', body)
    if not m:
        orphans.append(item)
        continue

    phase = int(m.group(1))
    sprint = phase_to_sprint.get(phase)

    if sprint:
        proposed.setdefault(sprint['name'], []).append(item)
    else:
        orphans.append(item)

# ── 7. Display proposal ───────────────────────────────────

all_phases = set()
for item in items:
    body = item.get('content', {}).get('body', '')
    m = re.search(r'\*\*Phase:\*\*\s*(\d+)', body)
    if m: all_phases.add(int(m.group(1)))

total_assign = sum(len(v) for v in proposed.values())

print(f"\n{'='*60}")
print(f"Project: Pocket (#{proj_number})")
print(f"Total items: {len(items)}")
print(f"Active phases: {sorted(all_phases)}")
print(f"  → To assign: {total_assign}")
print(f"  → Already assigned: {len(skipped)}")
print(f"  → Orphan (no sprint config): {len(orphans)}")
print(f"{'='*60}\n")

for s in sprints:
    s_name = s['name']
    s_items = proposed.get(s_name, [])
    iter_info = existing_by_name.get(s_name, {})
    iter_id = iter_info.get('id', '???')
    s_range = f"{s['startDate']} +{s['duration']}d"
    print(f"## {s_name}  [{s_range}]  iteration={iter_id}")
    print(f"   Phases: {s['phases']}  →  {len(s_items)} items")
    if not s_items:
        print("   (no items to assign)\n")
        continue
    for item in sorted(s_items, key=lambda x: x.get('title', '')):
        it_id = item['id'][-8:]
        ph = re.search(r'\*\*Phase:\*\*\s*(\d+)', item.get('content', {}).get('body', ''))
        ph_str = f"P{ph.group(1)}" if ph else "?"
        print(f"   [{ph_str}] {it_id}  {item.get('title', '?')[:65]}")
    print()

if orphans:
    print(f"## Orphan — no sprint configured for these phases ({len(orphans)})")
    for item in sorted(orphans, key=lambda x: x.get('title', '')):
        body = item.get('content', {}).get('body', '')
        m = re.search(r'\*\*Phase:\*\*\s*(\d+)', body)
        ph = f"P{m.group(1)}" if m else "?"
        it_id = item['id'][-8:]
        print(f"   [{ph}] {it_id}  {item.get('title', '?')[:65]}")
    print()

if skipped:
    show = min(5, len(skipped))
    print(f"## Already assigned ({len(skipped)} items, showing {show})")
    for item in skipped[:show]:
        s = item.get('sprint', {})
        it_id = item['id'][-8:]
        print(f"   → {s.get('title', '?')}  {it_id}  {item.get('title', '?')[:60]}")
    if len(skipped) > show:
        print(f"   ... and {len(skipped) - show} more")
    print()

if total_assign == 0:
    print("Nothing to assign. All done.")
    sys.exit(0)

# ── 8. Execute ────────────────────────────────────────────

if dry_run:
    print("DRY RUN — run with --confirm to execute")
    sys.exit(0)

try:
    answer = input("\nAssign items to sprints? [y/N]: ").strip().lower()
except EOFError:
    print("y (non-interactive)")
    answer = 'y'

if answer != 'y':
    print("Aborted.")
    sys.exit(0)

new_count = 0
skip_count = 0
error_count = 0

for s in sprints:
    s_name = s['name']
    s_items = proposed.get(s_name, [])
    if not s_items:
        continue

    iter_info = existing_by_name.get(s_name)
    iter_id = iter_info['id']

    for item in s_items:
        item_id = item['id']

        try:
            run_gh(['project', 'item-edit',
                    '--id', item_id,
                    '--project-id', proj_node_id,
                    '--field-id', field_id,
                    '--iteration-id', iter_id])
            new_count += 1
            time.sleep(0.3)
            print(f"  OK {item_id[-8:]} → {s_name}")
        except Exception as e:
            print(f"  ERROR {item_id[-8:]}: {e}")
            error_count += 1

# Log
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
entry = json.dumps({
    'ts': ts, 'event': 'sprint-assign.complete',
    'new': new_count, 'skipped': skip_count, 'errors': error_count
})
with open(log_file, 'a') as f:
    f.write(entry + '\n')

print(f"\n{'='*40}")
print(f"Assign complete: {new_count} new, {skip_count} skipped, {error_count} errors")
sys.exit(0 if error_count == 0 else 1)
PYEOF

echo "Done."
