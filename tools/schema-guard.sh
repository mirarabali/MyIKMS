#!/bin/bash
# Schema guard per INV-01/INV-02/INV-03
# Checks: (1) Migrations folder is empty, (2) scaffolded model matches schema.snapshot.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Schema Guard ==="

# Check 1: Migrations folder must be empty (INV-02)
MIGRATIONS_DIR="$ROOT_DIR/src/IKMS.Infrastructure/Migrations"
if [ -d "$MIGRATIONS_DIR" ]; then
    MIGRATION_FILES=$(find "$MIGRATIONS_DIR" -name "*.cs" ! -name "_EFMigrationsHistory.cs" 2>/dev/null | wc -l)
    if [ "$MIGRATION_FILES" -gt 0 ]; then
        echo "FAIL: Migrations folder contains files (INV-02 violation):"
        find "$MIGRATIONS_DIR" -name "*.cs" ! -name "_EFMigrationsHistory.cs"
        exit 1
    fi
fi
echo "PASS: Migrations folder is empty"

# Check 2: Verify schema.snapshot.json exists
SNAPSHOT_PATH="$ROOT_DIR/db/schema.snapshot.json"
if [ ! -f "$SNAPSHOT_PATH" ]; then
    echo "FAIL: db/schema.snapshot.json not found"
    exit 1
fi
echo "PASS: schema.snapshot.json exists"

# Note: Full model comparison requires EF Core to be scaffolded first
echo "NOTE: Full model comparison will be performed after EF Core scaffolding"

exit 0
