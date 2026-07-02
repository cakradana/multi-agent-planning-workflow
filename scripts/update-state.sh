#!/usr/bin/env bash
# scripts/update-state.sh — Deterministic chain state manager
# Dipanggil oleh /chain-run untuk baca/tulis .chain-state.json
# Gantikan LLM yang rawan corrupt JSON, salah timestamp, lupa atomic write
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DOCS_DIR="${CHAIN_DOCS_DIR:-$PROJECT_DIR/docs}"
STATE_FILE="${CHAIN_STATE_FILE:-$DOCS_DIR/.chain-state.json}"
WORKFLOW_FILE="${CHAIN_WORKFLOW_FILE:-$PROJECT_DIR/docs/workflow.yaml}"
PYTHON_BIN="${PYTHON_BIN:-python3.13}"

usage() {
  cat << 'EOF'
Usage: update-state.sh <command> [options]

Commands:
  init                                Buat state baru dari workflow.yaml
  read                                Print state JSON ke stdout
  agent <N> --status <s> [options]    Update agent status
  validation --status <s> [options]   Update validation
  rtm --coverage-pct <N>              Update RTM
  lock acquire|release                Manage .chain-lock
  log <event_type> [key=value ...]    Append ke .chain-run-log.jsonl

Agent options:
  --status running|complete|failed
  --output-hash HASH
  --agent-version VER
  --retry-count N

Validation options:
  --status pass|fail
  --report-path PATH

EOF
  exit 1
}

"$PYTHON_BIN" - "$@" << 'PYEOF'
import sys, os, json, hashlib
from datetime import datetime, timezone

def now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

def atomic_write(path, data):
    tmp = path + '.tmp'
    with open(tmp, 'w') as f:
        json.dump(data, f, indent=2)
    os.rename(tmp, path)

# --- Main ---
args = sys.argv[1:]
if not args:
    print("ERROR: no command", file=sys.stderr)
    sys.exit(1)

state_file = os.environ.get('CHAIN_STATE_FILE',
    os.path.join(os.environ.get('CHAIN_DOCS_DIR', os.path.join(os.path.dirname(os.path.abspath(__file__)), '../..', 'docs')), '.chain-state.json'))
docs_dir = os.path.dirname(state_file)
workflow_file = os.environ.get('CHAIN_WORKFLOW_FILE',
    os.path.join(os.path.dirname(os.path.abspath(__file__)), '../..', 'docs', 'workflow.yaml'))
lock_file = os.path.join(docs_dir, '.chain-lock')
log_file = os.path.join(docs_dir, '.chain-run-log.jsonl')

cmd = args[0]

# READ
if cmd == 'read':
    if os.path.exists(state_file):
        with open(state_file) as f:
            print(f.read())
    else:
        print('{"status": "not_started"}')
    sys.exit(0)

# INIT
elif cmd == 'init':
    import yaml
    with open(workflow_file) as f:
        wf = yaml.safe_load(f)
    wf = wf.get('workflow', wf)
    agents_list = wf.get('agents', [])

    chain_id = f"chain-{now()[:10].replace('-','')}-{now()[11:19].replace(':','')}"
    branch = f"planning/{chain_id}"

    agents = {}
    for a in agents_list:
        agents[str(a['id'])] = {
            "status": "pending",
            "startedAt": None,
            "completedAt": None,
            "output": a.get('output', '') if isinstance(a.get('output', ''), str) else a.get('output', [''])[0],
            "outputHash": None,
            "agentVersion": a.get('agent_version', '1.0.0'),
            "retryCount": 0
        }

    state = {
        "version": 1,
        "workflow": wf.get('name', 'unknown'),
        "chainId": chain_id,
        "status": "ready",
        "currentAgent": 0,
        "startedAt": None,
        "updatedAt": now(),
        "prdHash": None,
        "branch": branch,
        "agents": agents,
        "schemaVersion": 1,
        "validation": {"status": "pending", "reportPath": "docs/validation-report.md"},
        "rtm": {"status": "pending"},
        "history": []
    }

    atomic_write(state_file, state)
    print(f"State initialized: {chain_id}")
    print(json.dumps(state, indent=2))
    sys.exit(0)

# LOCK — doesn't need state (except acquire)
# LOG — doesn't need state
if cmd == 'lock':
    import time, re
    sub = args[1] if len(args) > 1 else 'status'

    if sub == 'status':
        if os.path.exists(lock_file):
            lock = {}
            with open(lock_file) as f:
                for line in f:
                    m = re.match(r'^(\w+):\s*(.+)$', line.strip())
                    if m:
                        lock[m.group(1)] = m.group(2).strip()
            started = lock.get('startedAt', '')
            try:
                t = datetime.fromisoformat(started.replace('Z', '+00:00'))
                age_min = (datetime.now(timezone.utc) - t).total_seconds() / 60
                lock['ageMinutes'] = round(age_min, 1)
                lock['stale'] = age_min > 30
            except:
                lock['ageMinutes'] = 0
                lock['stale'] = False
            print(json.dumps(lock, indent=2))
        else:
            print('{"exists": false}')

    elif sub == 'release':
        if os.path.exists(lock_file):
            os.remove(lock_file)
            print("Lock released")
        else:
            print("No lock to release")

    elif sub == 'acquire':
        # acquire needs state — lazy-load it
        if not os.path.exists(state_file):
            print("ERROR: state file not found. Run 'init' first.", file=sys.stderr)
            sys.exit(1)
        with open(state_file) as f:
            _state = json.load(f)
        session_id = os.environ.get('CLAUDE_SESSION_ID', 'unknown')
        chain_id = _state.get('chainId', 'unknown')
        lk = {
            "sessionId": session_id,
            "chainId": chain_id,
            "agent": _state.get('currentAgent', 0),
            "startedAt": now()
        }
        with open(lock_file, 'w') as f:
            json.dump(lk, f, indent=2)
        print(f"Lock acquired: chainId={chain_id}")

    sys.exit(0)

elif cmd == 'log':
    event_type = args[1] if len(args) > 1 else 'unknown'
    kv = {}
    for a in args[2:]:
        if '=' in a:
            k, v = a.split('=', 1)
            kv[k] = v
    entry = {"ts": now(), "event": event_type, **kv}
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    with open(log_file, 'a') as f:
        f.write(json.dumps(entry) + '\n')
    print(f"Logged: {event_type}")
    sys.exit(0)

# All remaining commands need existing state
if not os.path.exists(state_file):
    print("ERROR: state file not found. Run 'init' first.", file=sys.stderr)
    sys.exit(1)

with open(state_file) as f:
    state = json.load(f)

# AGENT
if cmd == 'agent':
    agent_id = args[1]
    status = None
    output_hash = None
    agent_version = None
    retry_count = None

    i = 2
    while i < len(args):
        if args[i] == '--status' and i+1 < len(args):
            status = args[i+1]; i += 2
        elif args[i] == '--output-hash' and i+1 < len(args):
            output_hash = args[i+1]; i += 2
        elif args[i] == '--agent-version' and i+1 < len(args):
            agent_version = args[i+1]; i += 2
        elif args[i] == '--retry-count' and i+1 < len(args):
            retry_count = int(args[i+1]); i += 2
        else:
            i += 1

    if status not in ('running', 'complete', 'failed', 'pending'):
        print("ERROR: --status required (running|complete|failed)", file=sys.stderr)
        sys.exit(1)

    agent_key = str(agent_id)
    if agent_key not in state['agents']:
        print(f"ERROR: agent {agent_id} not found in state", file=sys.stderr)
        sys.exit(1)

    agent = state['agents'][agent_key]
    ts = now()

    # History event (skip for pending/reset)
    event_map = {'running': 'agent.start', 'complete': 'agent.complete', 'failed': 'agent.fail', 'pending': 'agent.reset'}
    state['history'].append({
        "agent": int(agent_id),
        "event": event_map[status],
        "ts": ts
    })

    agent['status'] = status
    state['updatedAt'] = ts

    if status == 'running':
        agent['startedAt'] = ts
        agent['completedAt'] = None
        agent['outputHash'] = None
        state['currentAgent'] = int(agent_id)
        state['status'] = 'running'

    elif status == 'pending':
        agent['startedAt'] = None
        agent['completedAt'] = None
        agent['outputHash'] = None
        agent['retryCount'] = 0
        state['currentAgent'] = int(agent_id)

    elif status == 'complete':
        agent['completedAt'] = ts
        if output_hash:
            agent['outputHash'] = output_hash
        if agent_version:
            agent['agentVersion'] = agent_version
        # Update currentAgent to next pending
        for aid in sorted(state['agents'].keys(), key=int):
            if state['agents'][aid]['status'] == 'pending':
                state['currentAgent'] = int(aid)
                break
        else:
            state['currentAgent'] = len(state['agents'])
            state['status'] = 'complete'
        state['history'].append({
            "agent": int(agent_id),
            "event": "agent.complete",
            "ts": ts,
            "outputHash": output_hash
        })

    elif status == 'failed':
        agent['completedAt'] = ts
        state['status'] = 'failed'
        if retry_count is not None:
            agent['retryCount'] = retry_count

    atomic_write(state_file, state)
    print(f"Agent {agent_id}: {status}")
    sys.exit(0)

# VALIDATION
elif cmd == 'validation':
    val_status = None
    report_path = None
    i = 1
    while i < len(args):
        if args[i] == '--status' and i+1 < len(args):
            val_status = args[i+1]; i += 2
        elif args[i] == '--report-path' and i+1 < len(args):
            report_path = args[i+1]; i += 2
        else:
            i += 1

    state['validation'] = {
        "status": val_status or 'pending',
        "reportPath": report_path or state['validation'].get('reportPath', 'docs/validation-report.md')
    }
    state['updatedAt'] = now()
    atomic_write(state_file, state)
    print(f"Validation: {state['validation']['status']}")
    sys.exit(0)

# RTM
elif cmd == 'rtm':
    coverage_pct = None
    i = 1
    while i < len(args):
        if args[i] == '--coverage-pct' and i+1 < len(args):
            coverage_pct = int(args[i+1]); i += 2
        else:
            i += 1

    state['rtm'] = {
        "status": "complete",
        "outputPath": "docs/traceability-matrix.md",
        "coverage_pct": coverage_pct or state.get('rtm', {}).get('coverage_pct', 0)
    }
    state['updatedAt'] = now()
    atomic_write(state_file, state)
    print(f"RTM: {state['rtm']['coverage_pct']}%")
    sys.exit(0)

else:
    print(f"ERROR: unknown command '{cmd}'", file=sys.stderr)
    sys.exit(1)
PYEOF
