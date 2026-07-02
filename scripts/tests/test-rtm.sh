#!/usr/bin/env bash
# scripts/tests/test-rtm.sh — Unit test untuk generate-rtm.sh
# Test: sample-chain fixture → assert RTM generated with coverage > 0%
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures/sample-chain"

PASS=0
FAIL=0

echo "=== test-rtm.sh ==="
echo ""

# --- Test: RTM generation from sample-chain ---
echo "Test: RTM generation from sample-chain fixture"

set +e
CHAIN_DOCS_DIR="$FIXTURES_DIR/docs" \
  "$PROJECT_DIR/scripts/generate-rtm.sh" > /tmp/test-rtm.log 2>&1
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -ne 0 ]; then
  echo "  ❌ FAIL: generate-rtm.sh exit code $EXIT_CODE"
  cat /tmp/test-rtm.log
  FAIL=$((FAIL + 1))
else
  RTM_FILE="$FIXTURES_DIR/docs/traceability-matrix.md"
  if [ ! -f "$RTM_FILE" ]; then
    echo "  ❌ FAIL: RTM file not generated at $RTM_FILE"
    FAIL=$((FAIL + 1))
  else
    # Check coverage percentage is present
    if grep -q "Overall Coverage" "$RTM_FILE"; then
      COV_LINE=$(grep "Overall Coverage" "$RTM_FILE" | head -1)
      echo "  ✅ PASS: RTM generated — $COV_LINE"
      PASS=$((PASS + 1))
    else
      echo "  ❌ FAIL: Coverage line not found in RTM"
      FAIL=$((FAIL + 1))
    fi
    # Cleanup generated file
    rm -f "$RTM_FILE"
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
