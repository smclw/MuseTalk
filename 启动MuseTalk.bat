@echo off
setlocal

cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Not_found .venv
    pause
    exit /b 1
)

set "HF_ENDPOINT="

echo ============================================================
echo MuseTalk 1.5
echo NVIDIA GTX 1650 / FP16
echo ============================================================
echo.

".venv\Scripts\python.exe" app.py --use_float16

echo.
echo MuseTalk has stop。
pause