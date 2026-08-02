$ErrorActionPreference = 'Stop'

if (-not (Get-Command dsc -ErrorAction SilentlyContinue)) {
    throw "dsc command was not found. Install DSC v3 first."
}

$windowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$elevated = $windowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $elevated) {
    throw "This script must be run from an elevated PowerShell session. Start PowerShell as Administrator and run it again."
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $repoRoot 'configs/ssh-server.dsc.json'

if (-not (Test-Path $configPath)) {
    throw "Configuration file not found: $configPath"
}

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

foreach ($r in $config.resources) {
    Write-Host "Querying resource: $($r.resource)"
    $inputJson = $r.input | ConvertTo-Json -Compress -Depth 10
    dsc resource get --resource $r.resource --input $inputJson
}