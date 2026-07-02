#!/usr/bin/env bash
# scripts/tests/test-push.sh — Unit test untuk push-issues.sh (dry-run only)
# Test: sample-chain fixture → assert dry-run generates .issue-map-dry.json without real push
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures/sample-chain"

PASS=0
FAIL=0

echo "=== test-push.sh ==="
echo ""

# --- Test: Dry-run push from sample-chain ---
echo "Test: Dry-run push from sample-chain fixture"

# push-issues.sh expects 09-atomic-task-breakdown.md in project docs/
# Override by copying fixture task file to project docs temporarily
TASK_FILE="$PROJECT_DIR/docs/09-atomic-task-breakdown.md"
BACKUP_FILE=""

# Backup existing if any
if [ -f "$TASK_FILE" ]; then
  BACKUP_FILE="$TASK_FILE.test-backup"
  cp "$TASK_FILE" "$BACKUP_FILE"
fi

# Copy fixture task file
cp "$FIXTURES_DIR/docs/09-atomic-task-breakdown.md" "$TASK_FILE"

set +e
"$PROJECT_DIR/scripts/push-issues.sh" --dry-run > /tmp/test-push.log 2>&1
EXIT_CODE=$?
set -e

# Restore backup
if [ -n "$BACKUP_FILE" ]; then
  mv "$BACKUP_FILE" "$TASK_FILE"
else
  rm -f "$TASK_FILE"
fi

if [ $EXIT_CODE -ne 0 ]; then
  echo "  ❌ FAIL: push-issues.sh exit code $EXIT_CODE"
  cat /tmp/test-push.log
  FAIL=$((FAIL + 1))
else
  ISSUE_MAP="$PROJECT_DIR/docs/.issue-map-dry.json"
  if [ ! -f "$ISSUE_MAP" ]; then
    echo "  ❌ FAIL: Dry-run issue map not generated"
    FAIL=$((FAIL + 1))
  else
    PYTHON_BIN="${PYTHON_BIN:-python3.13}"
TASK_COUNT=$("$PYTHON_BIN" -c "import json; print(len(json.load(open('$ISSUE_MAP'))))")
    echo "  ✅ PASS: Dry-run push generated $TASK_COUNT issue mappings"
    PASS=$((PASS + 1))
    # Cleanup
    rm -f "$ISSUE_MAP"
  fi
fi

# --- Summary ---
echo ""
echo "========================="
echo "Results: $PASS passed, $FAIL failed"
if [ $FAIL -gt 0 ]; then
  exit 1
fi
echo "All tests passed ✅"
