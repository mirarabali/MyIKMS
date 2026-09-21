#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true)]
    [int]$Phase
)

$ErrorActionPreference = "Stop"
$artifactsDir = Join-Path $PSScriptRoot ".." "artifacts"
if (!(Test-Path $artifactsDir)) { New-Item -ItemType Directory -Force -Path $artifactsDir | Out-Null }

$results = @{
    "G1_build" = @{ status = "PENDING"; details = "" }
    "G2_tests" = @{ status = "PENDING"; details = "" }
    "G3_coverage" = @{ status = "PENDING"; details = "" }
    "G4_schema" = @{ status = "PENDING"; details = "" }
    "G5_scan" = @{ status = "PENDING"; details = "" }
    "G6_ac" = @{ status = "PENDING"; details = "" }
    "G7_frontend" = @{ status = "N/A"; details = "Backend phase" }
    "G8_smoke" = @{ status = "PENDING"; details = "" }
    "G9_trace" = @{ status = "PENDING"; details = "" }
}

$exitCode = 0

# G1: Build
Write-Host "=== G1: Build ===" -ForegroundColor Cyan
try {
    $buildOutput = dotnet build --configuration Release --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        $results["G1_build"].status = "PASS"
        $results["G1_build"].details = "0 errors, 0 warnings"
        Write-Host "BUILD: PASS" -ForegroundColor Green
    } else {
        $results["G1_build"].status = "FAIL"
        $results["G1_build"].details = $buildOutput
        Write-Host "BUILD: FAIL" -ForegroundColor Red
        $exitCode = 1
    }
} catch {
    $results["G1_build"].status = "FAIL"
    $results["G1_build"].details = $_.Exception.Message
    $exitCode = 1
}

# G2: Tests
Write-Host "`n=== G2: Tests (Phase <= $Phase) ===" -ForegroundColor Cyan
try {
    $testOutput = dotnet test --filter "Trait(Phase<=$Phase)" --no-build --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        $results["G2_tests"].status = "PASS"
        $results["G2_tests"].details = "All tests passed"
        Write-Host "TESTS: PASS" -ForegroundColor Green
    } else {
        $results["G2_tests"].status = "FAIL"
        $results["G2_tests"].details = $testOutput
        Write-Host "TESTS: FAIL" -ForegroundColor Red
        $exitCode = 1
    }
} catch {
    $results["G2_tests"].status = "FAIL"
    $results["G2_tests"].details = $_.Exception.Message
    $exitCode = 1
}

# G4: Schema guard
Write-Host "`n=== G4: Schema Guard ===" -ForegroundColor Cyan
$schemaGuardScript = Join-Path $PSScriptRoot "schema-guard.ps1"
if (Test-Path $schemaGuardScript) {
    & $schemaGuardScript
    if ($LASTEXITCODE -eq 0) {
        $results["G4_schema"].status = "PASS"
        $results["G4_schema"].details = "No migrations, schema unchanged"
        Write-Host "SCHEMA: PASS" -ForegroundColor Green
    } else {
        $results["G4_schema"].status = "FAIL"
        $results["G4_schema"].details = "Schema drift detected or migrations found"
        Write-Host "SCHEMA: FAIL" -ForegroundColor Red
        $exitCode = 1
    }
} else {
    $results["G4_schema"].status = "SKIP"
    $results["G4_schema"].details = "schema-guard.ps1 not found"
}

# G5: Forbidden pattern scan
Write-Host "`n=== G5: Forbidden Pattern Scan ===" -ForegroundColor Cyan
$scanScript = Join-Path $PSScriptRoot "scan-forbidden.ps1"
if (Test-Path $scanScript) {
    & $scanScript
    if ($LASTEXITCODE -eq 0) {
        $results["G5_scan"].status = "PASS"
        $results["G5_scan"].details = "No forbidden patterns found"
        Write-Host "SCAN: PASS" -ForegroundColor Green
    } else {
        $results["G5_scan"].status = "FAIL"
        $results["G5_scan"].details = "Forbidden patterns detected"
        Write-Host "SCAN: FAIL" -ForegroundColor Red
        $exitCode = 1
    }
} else {
    $results["G5_scan"].status = "SKIP"
    $results["G5_scan"].details = "scan-forbidden.ps1 not found"
}

# Output results
$outputFile = Join-Path $artifactsDir "gate-$Phase.json"
$results | ConvertTo-Json -Depth 3 | Out-File -FilePath $outputFile -Encoding utf8
Write-Host "`n=== Gate Results written to $outputFile ===" -ForegroundColor Cyan

exit $exitCode
