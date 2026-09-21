#!/bin/bash
# Scans for forbidden patterns per INV-04/INV-05

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Scanning for forbidden patterns in: $ROOT_DIR"

FOUND_ISSUES=0

# Forbidden patterns
PATTERNS=("TODO" "FIXME" "HACK" "NotImplementedException" "throw new Exception\(")

for pattern in "${PATTERNS[@]}"; do
    RESULTS=$(grep -r --include="*.cs" --include="*.csproj" --include="*.json" --include="*.md" --include="*.ps1" --include="*.sh" \
        -n "$pattern" "$ROOT_DIR" 2>/dev/null | grep -v "scan-forbidden" | grep -v "verify\." || true)
    
    if [ -n "$RESULTS" ]; then
        echo ""
        echo "FORBIDDEN PATTERN FOUND: $pattern"
        echo "$RESULTS"
        FOUND_ISSUES=1
    fi
done

# Check for Docker artifacts (INV-04)
DOCKER_ARTIFACTS=("Dockerfile" "docker-compose.yml" "docker-compose.yaml" ".dockerignore")
for artifact in "${DOCKER_ARTIFACTS[@]}"; do
    if [ -f "$ROOT_DIR/$artifact" ]; then
        echo ""
        echo "DOCKER ARTIFACT FOUND (INV-04 violation): $artifact"
        FOUND_ISSUES=1
    fi
done

if [ $FOUND_ISSUES -eq 0 ]; then
    echo ""
    echo "No forbidden patterns found."
    exit 0
else
    echo ""
    echo "Forbidden pattern scan FAILED."
    exit 1
fi
