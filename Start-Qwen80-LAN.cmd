@echo off
setlocal

set "ROOT=%~dp0"
set "BIN=%ROOT%Release"
set "MODEL=%ROOT%models\Qwen3-Coder-Next-UD-IQ4_XS.gguf"
set "CUDA_BIN=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.4\bin\arm64"
set "EXPECTED_SIZE=38429272064"

if not exist "%BIN%\llama-server.exe" (
  echo ERROR: llama-server.exe was not found in "%BIN%".
  pause
  exit /b 1
)

if not exist "%MODEL%" (
  echo ERROR: The model has not started downloading:
  echo   %MODEL%
  pause
  exit /b 1
)

for %%I in ("%MODEL%") do set "MODEL_SIZE=%%~zI"
if not "%MODEL_SIZE%"=="%EXPECTED_SIZE%" (
  echo The model download is not complete yet.
  powershell.exe -NoProfile -Command "$n=(Get-Item -LiteralPath '%MODEL%').Length; Write-Host ('Downloaded: {0:N2} GiB of 35.79 GiB ({1:N1}%%)' -f ($n/1GB), (100*$n/%EXPECTED_SIZE%))"
  pause
  exit /b 1
)

set "PATH=%CUDA_BIN%;%BIN%;%PATH%"
set "GGML_CUDA_PDL=0"
set "GGML_CUDA_FORCE_MMQ="

echo.
echo Starting Qwen3-Coder-Next on port 8081...
echo Open from another machine: http://THIS-PC-IP:8081
echo OpenAI-compatible endpoint: http://THIS-PC-IP:8081/v1
echo.

"%BIN%\llama-server.exe" ^
  -m "%MODEL%" ^
  -ngl 999 ^
  -c 65536 ^
  -np 1 ^
  -b 32 ^
  -ub 32 ^
  -t 8 ^
  -fa on ^
  -ctk q8_0 ^
  -ctv q8_0 ^
  --cache-prompt ^
  --cache-idle-slots ^
  --cache-ram 8192 ^
  --sleep-idle-seconds -1 ^
  --host 0.0.0.0 ^
  --port 8081

echo.
echo llama-server exited with code %ERRORLEVEL%.
pause
