@echo off
setlocal

cd /d "%~dp0"

set "HF_ENDPOINT="
set "HF_HUB_OFFLINE=1"
set "TRANSFORMERS_OFFLINE=1"

echo ============================================================
echo MuseTalk 1.5
echo NVIDIA GTX 1650 / FP16
echo Local Offline Mode
echo ============================================================
echo.

".venv\Scripts\python.exe" app.py --use_float16

echo.
echo MuseTalk has stop。
pause