# Local Qwen catalog on Windows ARM64

Reproducible setup for serving Qwen3-Coder-Next and Qwen3.8-27B through a
CUDA-enabled llama.cpp router on an NVIDIA RTX Spark N1X.

## Runtime requirements

- Windows ARM64
- NVIDIA CUDA 13.4 installed at
  `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.4`
- Python 3.13 or later
- The validated llama.cpp ARM64 build backed up to OneDrive

The validated server reports:

```text
version: 2 (70cdc82)
built with MSVC 19.44.35228.0 for Windows ARM64
```

## Restore a machine

1. Clone this repository.
2. Restore the validated llama.cpp binaries:

   ```powershell
   .\Restore-Release.ps1
   ```

3. Download and verify the pinned models with Hugging Face Xet:

   ```powershell
   .\Restore-Models.ps1
   ```

4. Start the model catalog:

   ```powershell
   .\Start-Qwen-Catalog-LAN.cmd
   ```

The OpenAI-compatible base URL is `http://127.0.0.1:8081/v1`. The catalog
advertises both models and loads only the selected model. It uses one slot,
Q8 KV cache, full CUDA offload, and a 131,072-token context window.

## Configure Copilot CLI

```powershell
$env:COPILOT_PROVIDER_BASE_URL = "http://127.0.0.1:8081/v1"
$env:COPILOT_PROVIDER_TYPE = "openai"
$env:COPILOT_MODEL = "Qwen3-Coder-Next-UD-IQ4_XS"
copilot
```

Select either advertised model from the provider catalog. Both models support
a native context length of 262,144 tokens, although this launcher allocates
131,072.

## Back up a replacement llama.cpp build

After validating a new `Release` directory, run:

```powershell
.\Backup-Release.ps1
```

This stores the binary archive in OneDrive rather than Git. Models and binaries
are intentionally excluded from this repository. Hugging Face model revisions,
sizes, and SHA-256 hashes are pinned in `Restore-Models.ps1`.

Do not store API keys in this directory. Use environment variables or Windows
Credential Manager.
