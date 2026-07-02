#!/usr/bin/env bash
# scripts/tests/test-validate.sh — Unit test untuk validate-chain.sh
# Test 1: sample-chain fixture → assert 0 BLOCKER (happy path)
# Test 2: known-blocker fixture → assert ≥1 BLOCKER
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

PASS=0
FAIL=0

echo "=== test-validate.sh ==="
echo ""

# --- Test 1: Happy path, 0 BLOCKER ---
echo "Test 1: sample-chain fixture → expect 0 BLOCKER"
WORKFLOW_FILE="$FIXTURES_DIR/sample-chain/workflow.yaml"

PYTHON_BIN="${PYTHON_BIN:-python3.13}"
# Create minimal workflow.yaml for fixture
"$PYTHON_BIN" - "$WORKFLOW_FILE" << 'PYEOF'
import sys, os
path = sys.argv[1]
os.makedirs(os.path.dirname(path), exist_ok=True)
import yaml
wf = {
    'workflow': {
        'name': 'test-chain',
        'version': 1,
        'agents': [
            {'id': 2, 'name': 'prd-analysis', 'output': 'docs/02-prd-analysis.md', 'depends_on': []},
            {'id': 4, 'name': 'screen-route-mapping', 'output': 'docs/04-screen-route-mapping.md', 'depends_on': [2]},
            {'id': 5, 'name': 'state-data-flow-plan', 'output': 'docs/05-state-data-flow-plan.md', 'depends_on': [4]},
            {'id': 6, 'name': 'component-and-ui-plan', 'output': 'docs/06-component-and-ui-plan.md', 'depends_on': [3, 4]},
            {'id': 7, 'name': 'api-integration-plan', 'output': 'docs/07-api-integration-plan.md', 'depends_on': [5]},
            {'id': 8, 'name': 'validation-and-edge-case-plan', 'output': 'docs/08-validation-and-edge-case-plan.md', 'depends_on': [2, 5, 6, 7]},
            {'id': 9, 'name': 'atomic-task-breakdown', 'output': 'docs/09-atomic-task-breakdown.md', 'depends_on': [8]},
        ],
        'validation': {
            'rules': [
                {'name': 'route-vs-screen', 'severity': 'BLOCKER', 'description': 'screen in doc04 must be in doc06'},
                {'name': 'api-vs-state', 'severity': 'BLOCKER', 'description': 'endpoint must have related_query_hook'},
                {'name': 'entity-vs-schema', 'severity': 'BLOCKER', 'description': 'entity must have type or schema'},
                {'name': 'business-rule-vs-validation', 'severity': 'WARNING', 'description': 'BR must have validation'},
                {'name': 'user-story-vs-task', 'severity': 'WARNING', 'description': 'US must have task'},
                {'name': 'edge-case-vs-handling', 'severity': 'INFO', 'description': 'EC must have handling'},
            ]
        }
    }
}
with open(path, 'w') as f:
    yaml.dump(wf, f)
PYEOF

set +e
CHAIN_WORKFLOW_FILE="$WORKFLOW_FILE" \
CHAIN_DOCS_DIR="$FIXTURES_DIR/sample-chain/docs" \
  "$PROJECT_DIR/scripts/validate-chain.sh" > /tmp/test-validate-sample.log 2>&1
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -eq 0 ]; then
  echo "  ✅ PASS: exit code 0 (no blockers)"
  PASS=$((PASS + 1))
else
  echo "  ❌ FAIL: exit code $EXIT_CODE (expected 0)"
  cat /tmp/test-validate-sample.log
  FAIL=$((FAIL + 1))
fi

# --- Test 2: Known blocker → expect ≥1 BLOCKER ---
echo ""
echo "Test 2: known-blocker fixture → expect ≥1 BLOCKER"
WORKFLOW_FILE="$FIXTURES_DIR/known-blocker/workflow.yaml"

"$PYTHON_BIN" - "$WORKFLOW_FILE" << 'PYEOF'
import sys, os
path = sys.argv[1]
import yaml
wf = {
    'workflow': {
        'name': 'test-chain-blocker',
        'version': 1,
        'agents': [
            {'id': 2, 'name': 'prd-analysis', 'output': 'docs/02-prd-analysis.md', 'depends_on': []},
            {'id': 5, 'name': 'state-data-flow-plan', 'output': 'docs/05-state-data-flow-plan.md', 'depends_on': [4]},
            {'id': 7, 'name': 'api-integration-plan', 'output': 'docs/07-api-integration-plan.md', 'depends_on': [5]},
        ],
        'validation': {
            'rules': [
                {'name': 'route-vs-screen', 'severity': 'BLOCKER', 'description': 'screen in doc04 must be in doc06'},
                {'name': 'api-vs-state', 'severity': 'BLOCKER', 'description': 'endpoint must have related_query_hook'},
                {'name': 'entity-vs-schema', 'severity': 'BLOCKER', 'description': 'entity must have type or schema'},
                {'name': 'business-rule-vs-validation', 'severity': 'WARNING', 'description': 'BR must have validation'},
                {'name': 'user-story-vs-task', 'severity': 'WARNING', 'description': 'US must have task'},
                {'name': 'edge-case-vs-handling', 'severity': 'INFO', 'description': 'EC must have handling'},
            ]
        }
    }
}
with open(path, 'w') as f:
    yaml.dump(wf, f)
PYEOF

set +e
CHAIN_WORKFLOW_FILE="$WORKFLOW_FILE" \
CHAIN_DOCS_DIR="$FIXTURES_DIR/known-blocker/docs" \
  "$PROJECT_DIR/scripts/validate-chain.sh" > /tmp/test-validate-blocker.log 2>&1
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -ne 0 ]; then
  echo "  ✅ PASS: exit code $EXIT_CODE (expected non-zero)"
  PASS=$((PASS + 1))
else
  echo "  ❌ FAIL: exit code 0 (expected non-zero, ≥1 BLOCKER)"
  cat /tmp/test-validate-blocker.log
  FAIL=$((FAIL + 1))
fi

# --- Cleanup fixture workflow files ---
rm -f "$FIXTURES_DIR/sample-chain/workflow.yaml" "$FIXTURES_DIR/known-blocker/workflow.yaml"

# --- Summary ---
echo ""
echo "========================="
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -gt 0 ]; then
  exit 1
fi
echo "All tests passed ✅"
