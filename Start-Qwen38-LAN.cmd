@echo off
setlocal

set "ROOT=%~dp0"
set "BIN=%ROOT%Release"
set "MODEL=%ROOT%models\Qwen3.8-27B-Q4_K_M.gguf"
set "CUDA_BIN=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.4\bin\arm64"
set "EXPECTED_SIZE=18973870432"

if not exist "%BIN%\llama-server.exe" (
  echo ERROR: llama-server.exe was not found in "%BIN%".
  pause
  exit /b 1
)

if not exist "%MODEL%" (
  echo ERROR: The model was not found:
  echo   %MODEL%
  pause
  exit /b 1
)

for %%I in ("%MODEL%") do set "MODEL_SIZE=%%~zI"
if not "%MODEL_SIZE%"=="%EXPECTED_SIZE%" (
  echo ERROR: The model file is incomplete or unexpected.
  echo Expected %EXPECTED_SIZE% bytes, found %MODEL_SIZE% bytes.
  pause
  exit /b 1
)

set "PATH=%CUDA_BIN%;%BIN%;%PATH%"
set "GGML_CUDA_PDL=0"
set "GGML_CUDA_FORCE_MMQ="

echo.
echo Starting Qwen3.8-27B on port 8081...
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
