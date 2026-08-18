[CmdletBinding()]
param(
    [string]$Destination = (Join-Path $PSScriptRoot 'models')
)

$ErrorActionPreference = 'Stop'

$models = @(
    @{
        Repository = 'unsloth/Qwen3-Coder-Next-GGUF'
        Revision   = 'ce09c67b53bc8739eef83fe67b2f5d293c270632'
        File       = 'Qwen3-Coder-Next-UD-IQ4_XS.gguf'
        Bytes      = 38429272064
        Sha256     = 'abf56d7fe8a0a99c15d220c13de4aa57b69cfba6ef4c2a007b56e34d7b40cd11'
    }
    @{
        Repository = 'ggml-org/Qwen3.8-27B-GGUF'
        Revision   = '0669b98607d47046c7c2b3f801011d54a08cfccf'
        File       = 'Qwen3.8-27B-Q4_K_M.gguf'
        Bytes      = 18973870432
        Sha256     = '31629f53165ab6a7dad8c9847dcfd1fdf55829dac1e6e748f4a68581b0033d34'
    }
)

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw 'Python is required to install the Hugging Face downloader.'
}

if (-not (Get-Command hf -ErrorAction SilentlyContinue)) {
    python -m pip install --upgrade 'huggingface_hub[hf_xet]'
    if ($LASTEXITCODE -ne 0) {
        throw 'Failed to install huggingface_hub with Xet acceleration.'
    }
}

if (-not (Get-Command hf -ErrorAction SilentlyContinue)) {
    throw 'The hf command is not on PATH. Restart PowerShell and run this script again.'
}

New-Item -ItemType Directory -Force -Path $Destination | Out-Null
$env:HF_XET_HIGH_PERFORMANCE = '1'

foreach ($model in $models) {
    $path = Join-Path $Destination $model.File

    if (Test-Path -LiteralPath $path) {
        $file = Get-Item -LiteralPath $path
        if ($file.Length -eq $model.Bytes) {
            $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($hash -eq $model.Sha256) {
                Write-Host "$($model.File) is already downloaded and verified."
                continue
            }
        }

        throw "Existing model failed verification: $path"
    }

    Write-Host "Downloading $($model.File) with Hugging Face Xet..."
    hf download $model.Repository $model.File `
        --revision $model.Revision `
        --local-dir $Destination
    if ($LASTEXITCODE -ne 0) {
        throw "Download failed: $($model.File)"
    }

    $file = Get-Item -LiteralPath $path
    if ($file.Length -ne $model.Bytes) {
        throw "Unexpected size for $($model.File): $($file.Length) bytes"
    }

    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne $model.Sha256) {
        throw "SHA-256 verification failed for $($model.File)"
    }
    Write-Host "Verified $($model.File)."
}
}
