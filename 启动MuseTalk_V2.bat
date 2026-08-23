@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title MuseTalk 1.5 - Local WebUI

set "PY=%~dp0.venv\Scripts\python.exe"
set "URL=http://127.0.0.1:7860"

if not exist "%PY%" (
    echo.
    echo [ERROR] MuseTalk .venv Python not found:
    echo %PY%
    echo.
    pause
    exit /b 1
)

if not exist "%~dp0app.py" (
    echo.
    echo [ERROR] app.py not found.
    echo Put this BAT in the MuseTalk root folder.
    echo.
    pause
    exit /b 1
)

REM Prevent HuggingFace mirror variables from redirecting local model loading.
set "HF_ENDPOINT="

echo.
echo ============================================================
echo MuseTalk 1.5
echo NVIDIA GTX 1650 / FP16
echo Local WebUI: %URL%
echo ============================================================
echo.

REM If MuseTalk is already running, just open the existing page.
powershell -NoProfile -Command "try { $c = New-Object Net.Sockets.TcpClient; $r=$c.BeginConnect('127.0.0.1',7860,$null,$null); if($r.AsyncWaitHandle.WaitOne(500) -and $c.Connected){$c.Close(); exit 0}else{$c.Close(); exit 1} } catch { exit 1 }"
if not errorlevel 1 (
    echo [INFO] MuseTalk WebUI is already running.
    start "" "%URL%"
    exit /b 0
)

REM Wait until Gradio really starts listening on port 7860, then open one browser tab.
start "" powershell -NoProfile -WindowStyle Hidden -Command "$url='http://127.0.0.1:7860'; for($i=0;$i -lt 180;$i++){ try{$c=New-Object Net.Sockets.TcpClient; $r=$c.BeginConnect('127.0.0.1',7860,$null,$null); if($r.AsyncWaitHandle.WaitOne(500) -and $c.Connected){$c.Close(); Start-Process $url; exit}; $c.Close()}catch{}; Start-Sleep -Seconds 1 }; exit"

echo Starting MuseTalk...
echo.

"%PY%" app.py --use_float16

echo.
echo ============================================================
echo MuseTalk has stopped.
echo ============================================================
echo.
pause
endlocal
