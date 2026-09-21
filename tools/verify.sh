#!/bin/bash
set -e

PHASE=$1
if [ -z "$PHASE" ]; then
    echo "Usage: ./verify.sh <phase_number>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACTS_DIR="$(dirname "$SCRIPT_DIR")/artifacts"
mkdir -p "$ARTIFACTS_DIR"

echo "=== IKMS Gate Verification - Phase $PHASE ==="

# G1: Build
echo "=== G1: Build ==="
dotnet build --configuration Release --verbosity quiet
BUILD_STATUS=$?
if [ $BUILD_STATUS -eq 0 ]; then
    echo "BUILD: PASS"
else
    echo "BUILD: FAIL"
fi

# G2: Tests
echo ""
echo "=== G2: Tests (Phase <= $PHASE) ==="
dotnet test --filter "Trait(Phase<=$PHASE)" --no-build --verbosity quiet
TEST_STATUS=$?
if [ $TEST_STATUS -eq 0 ]; then
    echo "TESTS: PASS"
else
    echo "TESTS: FAIL"
fi

# G4: Schema Guard
echo ""
echo "=== G4: Schema Guard ==="
if [ -f "$SCRIPT_DIR/schema-guard.sh" ]; then
    bash "$SCRIPT_DIR/schema-guard.sh"
    SCHEMA_STATUS=$?
    if [ $SCHEMA_STATUS -eq 0 ]; then
        echo "SCHEMA: PASS"
    else
        echo "SCHEMA: FAIL"
    fi
else
    echo "SCHEMA: SKIP (schema-guard.sh not found)"
fi

# G5: Forbidden Pattern Scan
echo ""
echo "=== G5: Forbidden Pattern Scan ==="
if [ -f "$SCRIPT_DIR/scan-forbidden.sh" ]; then
    bash "$SCRIPT_DIR/scan-forbidden.sh"
    SCAN_STATUS=$?
    if [ $SCAN_STATUS -eq 0 ]; then
        echo "SCAN: PASS"
    else
        echo "SCAN: FAIL"
    fi
else
    echo "SCAN: SKIP (scan-forbidden.sh not found)"
fi

# Output results
OUTPUT_FILE="$ARTIFACTS_DIR/gate-$PHASE.json"
cat > "$OUTPUT_FILE" << EOF
{
  "G1_build": {"status": "$([ $BUILD_STATUS -eq 0 ] && echo PASS || echo FAIL)"},
  "G2_tests": {"status": "$([ $TEST_STATUS -eq 0 ] && echo PASS || echo FAIL)"},
  "G4_schema": {"status": "PENDING"},
  "G5_scan": {"status": "PENDING"}
}
EOF

echo ""
echo "=== Gate Results written to $OUTPUT_FILE ==="

if [ $BUILD_STATUS -ne 0 ] || [ $TEST_STATUS -ne 0 ]; then
    exit 1
fi
exit 0
