#!/usr/bin/env pwsh
# IKMS Setup Script - PowerShell

$ErrorActionPreference = "Stop"
Write-Host "=== IKMS Setup ===" -ForegroundColor Cyan

# 1. Restore NuGet packages
Write-Host "`n[1/4] Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore IKMS.sln
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED: dotnet restore" -ForegroundColor Red
    exit 1
}
Write-Host "DONE" -ForegroundColor Green

# 2. Verify connection string
Write-Host "`n[2/4] Verifying database connection..." -ForegroundColor Yellow
$appSettingsPath = "src/IKMS.WebApi/appsettings.Development.json"
if (!(Test-Path $appSettingsPath)) {
    Copy-Item "appsettings.Example.json" $appSettingsPath
    Write-Host "Created $appSettingsPath from template" -ForegroundColor Yellow
    Write-Host "IMPORTANT: Edit $appSettingsPath with your database connection!" -ForegroundColor Red
}
Write-Host "DONE (check appsettings.Development.json)" -ForegroundColor Green

# 3. Build solution
Write-Host "`n[3/4] Building solution..." -ForegroundColor Yellow
dotnet build IKMS.sln --configuration Release --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED: dotnet build" -ForegroundColor Red
    exit 1
}
Write-Host "DONE" -ForegroundColor Green

# 4. Run schema guard
Write-Host "`n[4/4] Running schema guard..." -ForegroundColor Yellow
& "$PSScriptRoot/tools/schema-guard.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAILED: schema guard" -ForegroundColor Red
    exit 1
}
Write-Host "DONE" -ForegroundColor Green

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  1. Configure your database connection in src/IKMS.WebApi/appsettings.Development.json"
Write-Host "  2. Ensure the legacy schema is applied to your SQL Server database"
Write-Host "  3. Run: cd src/IKMS.WebApi && dotnet run"
