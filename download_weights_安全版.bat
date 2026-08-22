@echo off
setlocal EnableExtensions

title MuseTalk 1.5 安全模型下载
cd /d "%~dp0"

echo ============================================================
echo MuseTalk 1.5 安全模型检查 / 补下载
echo ============================================================
echo.

REM ============================================================
REM 只使用当前项目虚拟环境
REM ============================================================

set "PY=%~dp0.venv\Scripts\python.exe"
set "HFCLI=%~dp0.venv\Scripts\huggingface-cli.exe"

if not exist "%PY%" (
    echo [ERROR] 找不到项目虚拟环境：
    echo %PY%
    echo.
    echo 请先建立 .venv
    pause
    exit /b 1
)

if not exist "%HFCLI%" (
    echo [ERROR] 找不到 huggingface-cli：
    echo %HFCLI%
    pause
    exit /b 1
)

REM ============================================================
REM 关键：禁止使用之前出问题的 hf-mirror
REM 使用 Hugging Face 官方地址
REM ============================================================

set "HF_ENDPOINT="

REM ============================================================
REM 固定 MuseTalk 当前兼容版本
REM 不允许自动升级到 huggingface_hub 1.x
REM ============================================================

echo [1/8] 检查 huggingface_hub...
"%PY%" -m pip install "huggingface_hub==0.30.2"

if errorlevel 1 (
    echo.
    echo [ERROR] huggingface_hub 版本设置失败
    pause
    exit /b 1
)

echo.
echo [2/8] MuseTalk V1.5...

if not exist "models\musetalkV15\musetalk.json" (
    "%HFCLI%" download TMElyralab/MuseTalk musetalkV15/musetalk.json --local-dir models
) else (
    echo [OK] musetalk.json
)

if not exist "models\musetalkV15\unet.pth" (
    "%HFCLI%" download TMElyralab/MuseTalk musetalkV15/unet.pth --local-dir models
) else (
    echo [OK] unet.pth
)

echo.
echo [3/8] SD-VAE...

if not exist "models\sd-vae\config.json" (
    "%HFCLI%" download stabilityai/sd-vae-ft-mse config.json --local-dir models\sd-vae
) else (
    echo [OK] config.json
)

if not exist "models\sd-vae\diffusion_pytorch_model.bin" (
    "%HFCLI%" download stabilityai/sd-vae-ft-mse diffusion_pytorch_model.bin --local-dir models\sd-vae
) else (
    echo [OK] diffusion_pytorch_model.bin
)

echo.
echo [4/8] Whisper...

if not exist "models\whisper\config.json" (
    "%HFCLI%" download openai/whisper-tiny config.json --local-dir models\whisper
) else (
    echo [OK] config.json
)

if not exist "models\whisper\pytorch_model.bin" (
    "%HFCLI%" download openai/whisper-tiny pytorch_model.bin --local-dir models\whisper
) else (
    echo [OK] pytorch_model.bin
)

if not exist "models\whisper\preprocessor_config.json" (
    "%HFCLI%" download openai/whisper-tiny preprocessor_config.json --local-dir models\whisper
) else (
    echo [OK] preprocessor_config.json
)

echo.
echo [5/8] DWPose...

if not exist "models\dwpose\dw-ll_ucoco_384.pth" (
    "%HFCLI%" download yzd-v/DWPose dw-ll_ucoco_384.pth --local-dir models\dwpose
) else (
    echo [OK] dw-ll_ucoco_384.pth
)

echo.
echo [6/8] SyncNet...

if not exist "models\syncnet\latentsync_syncnet.pt" (
    "%HFCLI%" download ByteDance/LatentSync latentsync_syncnet.pt --local-dir models\syncnet
) else (
    echo [OK] latentsync_syncnet.pt
)

echo.
echo [7/8] Face Parse...

if not exist "models\face-parse-bisent\79999_iter.pth" (
    "%HFCLI%" download ManyOtherFunctions/face-parse-bisent 79999_iter.pth --local-dir models\face-parse-bisent
) else (
    echo [OK] 79999_iter.pth
)

if not exist "models\face-parse-bisent\resnet18-5c106cde.pth" (
    "%HFCLI%" download ManyOtherFunctions/face-parse-bisent resnet18-5c106cde.pth --local-dir models\face-parse-bisent
) else (
    echo [OK] resnet18-5c106cde.pth
)

echo.
echo [8/8] 最终检查...
echo.

set "MISSING=0"

if not exist "models\musetalkV15\unet.pth" set "MISSING=1"
if not exist "models\musetalkV15\musetalk.json" set "MISSING=1"

if not exist "models\sd-vae\config.json" set "MISSING=1"
if not exist "models\sd-vae\diffusion_pytorch_model.bin" set "MISSING=1"

if not exist "models\whisper\config.json" set "MISSING=1"
if not exist "models\whisper\pytorch_model.bin" set "MISSING=1"
if not exist "models\whisper\preprocessor_config.json" set "MISSING=1"

if not exist "models\dwpose\dw-ll_ucoco_384.pth" set "MISSING=1"

if not exist "models\syncnet\latentsync_syncnet.pt" set "MISSING=1"

if not exist "models\face-parse-bisent\79999_iter.pth" set "MISSING=1"
if not exist "models\face-parse-bisent\resnet18-5c106cde.pth" set "MISSING=1"

if "%MISSING%"=="0" (
    echo ============================================================
    echo [SUCCESS] MuseTalk 1.5 所需模型全部完整
    echo ============================================================
) else (
    echo ============================================================
    echo [WARNING] 仍有模型文件缺失，请查看上面的下载错误
    echo ============================================================
)

echo.
"%PY%" -m pip check

echo.
pause
endlocal