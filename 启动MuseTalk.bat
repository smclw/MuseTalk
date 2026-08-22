@echo off
setlocal

cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] 找不到 .venv
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
echo MuseTalk 已停止。
pause