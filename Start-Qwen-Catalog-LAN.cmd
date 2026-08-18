@echo off
setlocal

set "ROOT=%~dp0"
set "BIN=%ROOT%Release"
set "MODELS=%ROOT%models"
set "CUDA_BIN=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.4\bin\arm64"

if not exist "%BIN%\llama-server.exe" (
  echo ERROR: llama-server.exe was not found in "%BIN%".
  pause
  exit /b 1
)

if not exist "%MODELS%" (
  echo ERROR: The models directory was not found:
  echo   %MODELS%
  pause
  exit /b 1
)

set "PATH=%CUDA_BIN%;%BIN%;%PATH%"
set "GGML_CUDA_PDL=0"
set "GGML_CUDA_FORCE_MMQ="

echo.
echo Starting the Qwen model catalog on port 8081...
echo OpenAI-compatible endpoint: http://localhost:8081/v1
echo Models are loaded on demand, one at a time.
echo.

"%BIN%\llama-server.exe" ^
  --models-dir "%MODELS%" ^
  --models-max 1 ^
  --models-autoload ^
  -ngl 999 ^
  -c 131072 ^
  -np 1 ^
  -b 32 ^
  -ub 32 ^
  -t 8 ^
  -fa on ^
  -ctk q8_0 ^
  -ctv q8_0 ^
  --cache-prompt ^
  --host 0.0.0.0 ^
  --port 8081

echo.
echo llama-server exited with code %ERRORLEVEL%.
pause
