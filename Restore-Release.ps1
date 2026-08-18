[CmdletBinding()]
param(
    [string]$Archive
)

$ErrorActionPreference = 'Stop'
$release = Join-Path $PSScriptRoot 'Release'

if (-not $env:OneDrive) {
    throw 'OneDrive is not configured for this Windows account.'
}

if (-not $Archive) {
    $Archive = Join-Path $env:OneDrive 'Backups\llama-cpp-ant\llama-cpp-ant-Release-70cdc82.zip'
}

if (-not (Test-Path -LiteralPath $Archive)) {
    throw "llama.cpp backup not found: $Archive"
}

if (Test-Path -LiteralPath $release) {
    throw "Release directory already exists: $release"
}

Expand-Archive -LiteralPath $Archive -DestinationPath $PSScriptRoot

$version = (& (Join-Path $release 'llama-server.exe') --version 2>&1 | Out-String)
if ($version -notmatch '70cdc82') {
    throw "Restored an unexpected llama.cpp build:`n$version"
}

Write-Host 'Restored and verified llama.cpp build 70cdc82.'
