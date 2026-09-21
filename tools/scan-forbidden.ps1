#!/usr/bin/env pwsh
# Scans for forbidden patterns per INV-04/INV-05

$ErrorActionPreference = "Continue"
$rootDir = Join-Path $PSScriptRoot ".."
$foundIssues = $false

$forbiddenPatterns = @(
    "TODO",
    "FIXME", 
    "HACK",
    "NotImplementedException",
    "throw new Exception\(",
    "\[Skip",
    "Skip\s*=",
    "it\.skip",
    "describe\.skip",
    "xit\("
)

Write-Host "Scanning for forbidden patterns in: $rootDir" -ForegroundColor Cyan

foreach ($pattern in $forbiddenPatterns) {
    $results = Get-ChildItem -Path $rootDir -Include *.cs,*.csproj,*.json,*.md,*.ps1,*.sh -Recurse |
        Select-String -Pattern $pattern -CaseSensitive:$false |
        Where-Object { $_.Line -notmatch "scan-forbidden" -and $_.Line -notmatch "verify\." }
    
    if ($results.Count -gt 0) {
        Write-Host "`nFORBIDDEN PATTERN FOUND: $pattern" -ForegroundColor Red
        foreach ($result in $results) {
            Write-Host "  $($result.Path):$($result.LineNumber)" -ForegroundColor Yellow
            Write-Host "    $($result.Line.Trim())" -ForegroundColor Gray
        }
        $foundIssues = $true
    }
}

# Check for Docker/compose artifacts (INV-04)
$dockerArtifacts = @("Dockerfile", "docker-compose.yml", "docker-compose.yaml", ".dockerignore")
foreach ($artifact in $dockerArtifacts) {
    $path = Join-Path $rootDir $artifact
    if (Test-Path $path) {
        Write-Host "`nDOCKER ARTIFACT FOUND (INV-04 violation): $artifact" -ForegroundColor Red
        $foundIssues = $true
    }
}

if (-not $foundIssues) {
    Write-Host "`nNo forbidden patterns found." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nForbidden pattern scan FAILED." -ForegroundColor Red
    exit 1
}
