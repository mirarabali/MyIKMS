#!/usr/bin/env pwsh
# Schema guard per INV-01/INV-02/INV-03
# Checks: (1) Migrations folder is empty, (2) scaffolded model matches schema.snapshot.json

$ErrorActionPreference = "Continue"
$rootDir = Join-Path $PSScriptRoot ".."
$migrationsDir = Join-Path $rootDir "src" "IKMS.Infrastructure" "Migrations"

Write-Host "=== Schema Guard ===" -ForegroundColor Cyan

# Check 1: Migrations folder must be empty (INV-02)
if (Test-Path $migrationsDir) {
    $migrationFiles = Get-ChildItem -Path $migrationsDir -Filter "*.cs" | Where-Object { $_.Name -ne "_EFMigrationsHistory.cs" }
    if ($migrationFiles.Count -gt 0) {
        Write-Host "FAIL: Migrations folder contains files (INV-02 violation):" -ForegroundColor Red
        foreach ($file in $migrationFiles) {
            Write-Host "  $($file.Name)" -ForegroundColor Yellow
        }
        exit 1
    }
}
Write-Host "PASS: Migrations folder is empty" -ForegroundColor Green

# Check 2: Verify schema.snapshot.json exists
$snapshotPath = Join-Path $rootDir "db" "schema.snapshot.json"
if (!(Test-Path $snapshotPath)) {
    Write-Host "FAIL: db/schema.snapshot.json not found" -ForegroundColor Red
    exit 1
}
Write-Host "PASS: schema.snapshot.json exists" -ForegroundColor Green

# Note: Full model comparison requires EF Core to be scaffolded first
# This check will be enhanced after initial scaffolding
Write-Host "NOTE: Full model comparison will be performed after EF Core scaffolding" -ForegroundColor Yellow

exit 0
