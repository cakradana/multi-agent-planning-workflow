#!/usr/bin/env bash
# scripts/push-issues.sh — Push atomic tasks to GitHub Issues + Project
# Dipanggil oleh /chain-run setelah Agent 9 + generate-rtm.sh selesai
# Idempotent: .issue-map.json sebagai checkpoint — re-run hanya proses task baru
# Skip jika --dry-run
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DOCS_DIR="$PROJECT_DIR/docs"
ISSUE_MAP="$DOCS_DIR/.issue-map.json"
TASK_FILE="$DOCS_DIR/09-atomic-task-breakdown.md"
RUN_LOG="$DOCS_DIR/.chain-run-log.jsonl"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  ISSUE_MAP="$DOCS_DIR/.issue-map-dry.json"
  echo "=== push-issues.sh (DRY RUN) ==="
else
  echo "=== push-issues.sh ==="
fi

# Prerequisites
if ! command -v gh &> /dev/null; then
  echo "ERROR: GitHub CLI ('gh') not installed."
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "ERROR: Not authenticated with GitHub. Run 'gh auth login'."
  exit 1
fi

if [ ! -f "$TASK_FILE" ]; then
  echo "ERROR: Task file not found: $TASK_FILE"
  exit 1
fi

# Parse tasks from frontmatter
echo "Parsing tasks from $TASK_FILE..."

PYTHON_BIN="${PYTHON_BIN:-python3.13}"
CHAIN_SCRIPT_DIR="$SCRIPT_DIR" "$PYTHON_BIN" - "$TASK_FILE" "$ISSUE_MAP" "$DRY_RUN" "$RUN_LOG" "$PROJECT_DIR" << 'PYEOF'
import sys, os, json, re, time, subprocess
from datetime import datetime, timezone

# Import shared YAML parser
sys.path.insert(0, os.environ.get('CHAIN_SCRIPT_DIR', os.path.join(os.getcwd(), 'scripts')))
from _yaml_parser import parse_frontmatter

task_file = sys.argv[1]
issue_map_file = sys.argv[2]
dry_run = sys.argv[3].lower() == 'true'
log_file = sys.argv[4]
project_dir = sys.argv[5]

# --- Parse frontmatter via shared parser ---
fm = parse_frontmatter(task_file)
if fm is None:
    print("ERROR: Cannot parse frontmatter from task file")
    sys.exit(1)

tasks = fm.get('tasks', [])
if not tasks:
    print("ERROR: No tasks found in frontmatter")
    sys.exit(1)

# Sort by priority then id, then topological (blockers before blocked)
priority_order = {'P0': 0, 'P1': 1, 'P2': 2, 'P3': 3}
tasks.sort(key=lambda t: (priority_order.get(t.get('priority', 'P3'), 9), t.get('id', 'ZZZ')))

# Topological reorder: ensure blocker tasks appear before tasks that depend on them
# Only enforces single-hop ordering — multi-hop chains depend on initial sort
task_ids_ordered = [t['id'] for t in tasks]
def _blocker_index(task):
    blocked_by = task.get('blockedBy', [])
    if not blocked_by:
        return -1
    return max((task_ids_ordered.index(b) if b in task_ids_ordered else -1) for b in blocked_by)

for i in range(3):  # iterate to stable convergence (3 passes enough for 36 tasks)
    tasks.sort(key=lambda t: (_blocker_index(t), priority_order.get(t.get('priority', 'P3'), 9)))

print(f"Topological order: blocker-first (3 passes)")

# --- Project config (cache IDs once) ---
PROJECT_NUMBER = 1
PROJECT_OWNER = 'cakradana'

def _get_project_ids():
    """Fetch project node ID, Status field ID, and Todo option ID."""
    project_id, status_field_id, todo_option_id = None, None, None
    try:
        r = subprocess.run(['gh', 'project', 'view', str(PROJECT_NUMBER),
                            '--owner', PROJECT_OWNER, '--format', 'json'],
                           capture_output=True, text=True, timeout=10)
        if r.returncode == 0:
            project_id = json.loads(r.stdout).get('id')
    except Exception:
        pass
    try:
        r = subprocess.run(['gh', 'project', 'field-list', str(PROJECT_NUMBER),
                            '--owner', PROJECT_OWNER, '--format', 'json'],
                           capture_output=True, text=True, timeout=10)
        if r.returncode == 0:
            fields = json.loads(r.stdout).get('fields', [])
            for f in fields:
                if f['name'] == 'Status':
                    status_field_id = f['id']
                    for opt in f.get('options', []):
                        if opt['name'] == 'Todo':
                            todo_option_id = opt['id']
                    break
    except Exception:
        pass
    return project_id, status_field_id, todo_option_id

def _set_project_status(issue_url, proj_id, field_id, option_id):
    """Find the project item for issue_url and set its status field."""
    # Extract issue number from URL
    m = re.match(r'.*/issues/(\d+)$', issue_url.strip())
    if not m:
        return False
    issue_num = int(m.group(1))
    try:
        r = subprocess.run(['gh', 'project', 'item-list', str(PROJECT_NUMBER),
                            '--owner', PROJECT_OWNER, '--format', 'json'],
                           capture_output=True, text=True, timeout=15)
        if r.returncode != 0:
            return False
        items = json.loads(r.stdout).get('items', [])
        for item in items:
            if item.get('content', {}).get('number') == issue_num:
                item_id = item['id']
                r2 = subprocess.run(['gh', 'project', 'item-edit',
                                     '--id', item_id,
                                     '--project-id', proj_id,
                                     '--field-id', field_id,
                                     '--single-select-option-id', option_id],
                                    capture_output=True, text=True, timeout=10)
                return r2.returncode == 0
    except Exception:
        pass
    return False

proj_id, status_field_id, todo_option_id = _get_project_ids()
if proj_id and status_field_id and todo_option_id:
    print(f"Project: Pocket (Status→Todo ready)")
else:
    print(f"WARNING: Could not resolve project/status IDs — status won't be set on issues")

# --- Load existing issue map ---
issue_map = {}
if os.path.exists(issue_map_file):
    with open(issue_map_file) as f:
        issue_map = json.load(f)
    print(f"Loaded {len(issue_map)} existing issue mappings from .issue-map.json")

# --- Push tasks ---
new_count = 0
skip_count = 0
error_count = 0

for i, task in enumerate(tasks):
    task_id = task.get('id', f'T-{i+1:03d}')

    # Skip if already pushed (idempotent)
    if task_id in issue_map:
        print(f"  SKIP {task_id}: already pushed → {issue_map[task_id]}")
        skip_count += 1
        continue

    title = task.get('title', 'Untitled')
    description = task.get('description', '')
    acceptance = task.get('acceptance_criteria', [])
    priority = task.get('priority', 'P2')
    labels = task.get('labels', [])
    estimated_hours = task.get('estimated_hours', '?')
    phase = task.get('phase', '?')
    source = task.get('source', '')
    blocked_by = task.get('blockedBy', [])

    # Build issue body
    body_lines = [
        f"**Task:** {task_id}",
        f"**Phase:** {phase}",
        f"**Priority:** {priority}",
        f"**Estimated:** {estimated_hours}h",
        "",
        "## Description",
        "",
        description,
        "",
    ]
    if acceptance:
        body_lines.append("## Acceptance Criteria")
        body_lines.append("")
        for ac in acceptance:
            body_lines.append(f"- [ ] {ac}")
        body_lines.append("")

    if blocked_by:
        body_lines.append(f"**Blocked by:** {', '.join(blocked_by)}")
        body_lines.append("")

    if source:
        body_lines.append(f"**Source:** {source}")

    body_lines.append("")
    body_lines.append("---")
    body_lines.append("🤖 Generated with [Claude Code](https://claude.com/claude-code)")

    body = '\n'.join(body_lines)
    label_args = ','.join(labels) if labels else ''

    if dry_run:
        print(f"  [DRY-RUN] {task_id}: \"{title}\" [{priority}] labels={label_args}")
        issue_map[task_id] = f"https://github.com/placeholder/DRY-RUN-{task_id}"
        new_count += 1
        continue

    # Real push via gh CLI
    # Resolve first blockedBy to parent issue number
    parent_num = None
    if blocked_by:
        for b_id in blocked_by:
            b_url = issue_map.get(b_id)
            if b_url:
                m = re.match(r'.*/issues/(\d+)$', b_url.strip())
                if m:
                    parent_num = int(m.group(1))
                    break

    cmd = ['gh', 'issue', 'create',
           '--title', f"[{task_id}] {title}",
           '--body', body,
           '--project', 'Pocket']
    if parent_num:
        cmd.extend(['--parent', str(parent_num)])
        print(f"  → parent: #{parent_num} ({blocked_by[0]})")
    if label_args:
        cmd.extend(['--label', label_args])

    for attempt in range(3):
        try:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=project_dir, timeout=30)
            if result.returncode == 0:
                issue_url = result.stdout.strip()
                issue_map[task_id] = issue_url
                new_count += 1

                # Save checkpoint after each success
                tmp = issue_map_file + '.tmp'
                with open(tmp, 'w') as f:
                    json.dump(issue_map, f, indent=2)
                os.rename(tmp, issue_map_file)

                # Rate limit: 1.5s between issues
                time.sleep(1.5)
                break
            else:
                stderr = result.stderr.strip()
                # Check for rate limiting
                if '429' in stderr or 'rate limit' in stderr.lower():
                    wait = min((attempt + 1) * 5, 30)
                    print(f"  Rate limited for {task_id}, waiting {wait}s...")
                    time.sleep(wait)
                else:
                    print(f"  ERROR {task_id}: {stderr}")
                    error_count += 1
                    break
        except subprocess.TimeoutExpired:
            print(f"  TIMEOUT {task_id} (attempt {attempt+1}/3)")
            time.sleep(5)
        except Exception as e:
            print(f"  ERROR {task_id}: {e}")
            error_count += 1
            break

# --- Batch set project Status → Todo for all issues (retry race condition) ---
if not dry_run and proj_id and status_field_id and todo_option_id:
    pending = issue_map.copy()
    for attempt in range(5):
        if not pending:
            break
        time.sleep(3)
        still_pending = {}
        for task_id, issue_url in pending.items():
            if _set_project_status(issue_url, proj_id, status_field_id, todo_option_id):
                print(f"  STATUS {task_id}: Todo")
            else:
                still_pending[task_id] = issue_url
        if still_pending:
            print(f"  STATUS retry {attempt+1}/5: {len(still_pending)} pending...")
        pending = still_pending
    if pending:
        print(f"  STATUS WARNING: {len(pending)} issues still unindexed after 5 retries")
    else:
        print(f"  STATUS: All issues set to Todo")

# --- Save final map ---
tmp = issue_map_file + '.tmp'
with open(tmp, 'w') as f:
    json.dump(issue_map, f, indent=2)
os.rename(tmp, issue_map_file)

# --- Log ---
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
entry = json.dumps({
    'ts': ts, 'event': 'push.complete',
    'new': new_count, 'skipped': skip_count, 'errors': error_count, 'dryRun': dry_run
})
with open(log_file, 'a') as f:
    f.write(entry + '\n')

# --- Summary ---
print(f"\n{'='*40}")
print(f"Push complete: {new_count} new, {skip_count} skipped, {error_count} errors")
if dry_run:
    print(f"DRY RUN — no issues pushed to GitHub")
    print(f"Dry-run map saved to: {issue_map_file}")
else:
    print(f"Issue map saved to: {issue_map_file}")
sys.exit(0 if error_count == 0 else 1)
PYEOF

echo "Done."
