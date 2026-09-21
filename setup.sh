#!/bin/bash
# IKMS Setup Script - Bash

set -e

echo "=== IKMS Setup ==="

# 1. Restore NuGet packages
echo ""
echo "[1/4] Restoring NuGet packages..."
dotnet restore IKMS.sln
echo "DONE"

# 2. Verify connection string
echo ""
echo "[2/4] Verifying database connection..."
APP_SETTINGS="src/IKMS.WebApi/appsettings.Development.json"
if [ ! -f "$APP_SETTINGS" ]; then
    cp appsettings.Example.json "$APP_SETTINGS"
    echo "Created $APP_SETTINGS from template"
    echo "IMPORTANT: Edit $APP_SETTINGS with your database connection!"
fi
echo "DONE (check appsettings.Development.json)"

# 3. Build solution
echo ""
echo "[3/4] Building solution..."
dotnet build IKMS.sln --configuration Release --no-restore
echo "DONE"

# 4. Run schema guard
echo ""
echo "[4/4] Running schema guard..."
bash "$(dirname "$0")/tools/schema-guard.sh"
echo "DONE"

echo ""
echo "=== Setup Complete ==="
echo "Next steps:"
echo "  1. Configure your database connection in src/IKMS.WebApi/appsettings.Development.json"
echo "  2. Ensure the legacy schema is applied to your SQL Server database"
echo "  3. Run: cd src/IKMS.WebApi && dotnet run"
