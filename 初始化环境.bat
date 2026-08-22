@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
title MuseTalk 1.5 - 初始化环境

echo ============================================================
echo MuseTalk 1.5 Windows 环境初始化 / 恢复
echo 目标环境：Python 3.10 + PyTorch 2.0.1 CUDA 11.8
echo ============================================================
echo.

if not exist "app.py" (
    echo [ERROR] 当前目录不是 MuseTalk 项目根目录。
    echo 请把本文件放到 MuseTalk 根目录后再运行。
    echo 当前目录：%CD%
    pause
    exit /b 1
)

if not exist "requirements-lock.txt" (
    echo [ERROR] 找不到 requirements-lock.txt
    echo 请确保它和本 BAT 放在同一个 MuseTalk 根目录。
    pause
    exit /b 1
)

set "PY310=%LocalAppData%\Programs\Python\Python310\python.exe"

if not exist "%PY310%" (
    echo [WARNING] 未在默认位置找到 Python 3.10：
    echo %PY310%
    echo.
    echo 正在尝试使用 PATH 中的 python...
    python -c "import sys; raise SystemExit(0 if sys.version_info[:2]==(3,10) else 1)" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] 没有找到可用的 Python 3.10。
        echo 请安装 Python 3.10.x 后重新运行。
        echo 推荐版本：Python 3.10.11
        pause
        exit /b 1
    )
    set "PY310=python"
)

echo [OK] Python 3.10：
"%PY310%" --version
echo.

if not exist ".venv\Scripts\python.exe" (
    echo [1/10] 创建 .venv...
    "%PY310%" -m venv ".venv"
    if errorlevel 1 goto :FAIL
) else (
    echo [1/10] .venv 已存在，跳过创建。
)

set "PY=%CD%\.venv\Scripts\python.exe"
set "MIM=%CD%\.venv\Scripts\mim.exe"

"%PY%" -c "import sys; raise SystemExit(0 if sys.version_info[:2]==(3,10) else 1)" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 当前 .venv 不是 Python 3.10。
    echo 请删除项目内 .venv 后重新运行本文件。
    pause
    exit /b 1
)

echo.
echo [2/10] 准备 pip 与 wheel...
"%PY%" -m pip install --upgrade "pip==26.2.1" "wheel==0.48.0"
if errorlevel 1 goto :FAIL

echo.
echo [3/10] 安装 PyTorch 2.0.1 + CUDA 11.8...
"%PY%" -m pip install "torch==2.0.1" "torchvision==0.15.2" "torchaudio==2.0.2" --index-url https://download.pytorch.org/whl/cu118
if errorlevel 1 goto :FAIL

echo.
echo [4/10] 安装 requirements-lock.txt...
"%PY%" -m pip install -r "requirements-lock.txt"
if errorlevel 1 goto :FAIL

echo.
echo [5/10] 安装 chumpy 0.70（禁用 build isolation）...
"%PY%" -m pip install --no-build-isolation "chumpy==0.70"
if errorlevel 1 goto :FAIL

echo 安装 xtcocotools 1.14.2...
"%PY%" -m pip install "xtcocotools==1.14.2"
if errorlevel 1 goto :FAIL

if not exist "%MIM%" (
    echo [ERROR] openmim 未正确安装，找不到 mim.exe
    goto :FAIL
)

echo.
echo [6/10] 安装 MMEngine 0.10.7...
"%MIM%" install "mmengine==0.10.7"
if errorlevel 1 goto :FAIL

echo 安装 MMCV 2.0.1...
"%MIM%" install "mmcv==2.0.1"
if errorlevel 1 goto :FAIL

echo 安装 MMDetection 3.1.0...
"%MIM%" install "mmdet==3.1.0"
if errorlevel 1 goto :FAIL

echo 安装 MMPose 1.1.0...
"%MIM%" install "mmpose==1.1.0"
if errorlevel 1 goto :FAIL

echo.
echo [7/10] 固定关键兼容版本...
"%PY%" -m pip install "rich==13.4.2" "typer==0.12.5" "huggingface_hub==0.30.2"
if errorlevel 1 goto :FAIL

echo.
echo [8/10] 检查核心组件...
"%PY%" -c "import torch, mmengine, mmcv, mmdet, mmpose, gradio, huggingface_hub, transformers; print('torch=',torch.__version__); print('CUDA=',torch.cuda.is_available()); print('torch CUDA=',torch.version.cuda); print('GPU=',torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU'); print('mmengine=',mmengine.__version__); print('mmcv=',mmcv.__version__); print('mmdet=',mmdet.__version__); print('mmpose=',mmpose.__version__); print('gradio=',gradio.__version__); print('huggingface_hub=',huggingface_hub.__version__); print('transformers=',transformers.__version__)"
if errorlevel 1 goto :FAIL

echo.
echo [9/10] 检查依赖完整性...
"%PY%" -m pip check
if errorlevel 1 (
    echo.
    echo [ERROR] pip check 发现依赖冲突。
    pause
    exit /b 1
)

echo.
echo [10/10] 检查 FFmpeg...
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo [WARNING] 系统 PATH 中没有找到 ffmpeg。
    echo MuseTalk 环境已安装，但启动前仍需要配置 FFmpeg。
) else (
    for /f "delims=" %%F in ('where ffmpeg') do (
        echo [OK] FFmpeg：%%F
        goto :FFMPEG_DONE
    )
)
:FFMPEG_DONE

echo.
echo ============================================================
echo [SUCCESS] MuseTalk Python 环境初始化完成
echo ============================================================
echo.
echo 下一步：
echo   1. 如果 models 已删除：运行 下载模型_安全版.bat
echo   2. 如果 models 完整：运行 启动MuseTalk.bat
echo.
echo 注意：
echo   - 不要运行原版 download_weights.bat
echo   - 不要把 huggingface_hub 升级到 1.x
echo   - 当前锁定 huggingface_hub=0.30.2
echo.
pause
exit /b 0

:FAIL
echo.
echo ============================================================
echo [FAILED] 初始化过程中出现错误
echo ============================================================
echo 请保留当前窗口，把最后 30 行错误信息保存下来。
echo.
pause
exit /b 1
