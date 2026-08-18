[CmdletBinding()]
param(
    [string]$DestinationDirectory
)

$ErrorActionPreference = 'Stop'
$release = Join-Path $PSScriptRoot 'Release'

if (-not $env:OneDrive) {
    throw 'OneDrive is not configured for this Windows account.'
}

if (-not $DestinationDirectory) {
    $DestinationDirectory = Join-Path $env:OneDrive 'Backups\llama-cpp-ant'
}

if (-not (Test-Path -LiteralPath $release)) {
    throw "Release directory not found: $release"
}

$version = (& (Join-Path $release 'llama-server.exe') --version 2>&1 | Out-String)
if ($version -notmatch '\(([0-9a-f]+)\)') {
    throw 'Could not determine the llama.cpp build revision.'
}

$revision = $Matches[1]
$archive = Join-Path $DestinationDirectory "llama-cpp-ant-Release-$revision.zip"

New-Item -ItemType Directory -Force -Path $DestinationDirectory | Out-Null
Compress-Archive -LiteralPath $release -DestinationPath $archive -Force
Write-Host "Backed up llama.cpp build to $archive"
