@echo off
REM Flutter 运行脚本 - 自动获取局域网 IP (Windows 版本)
REM 使用方法: run_with_auto_ip.bat [device_id]

echo 🔍 正在获取局域网 IP...

REM 获取第一个非 127.0.0.1 的 IPv4 地址
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /r "IPv4" ^| findstr /v "127.0.0.1"') do (
    set LOCAL_IP=%%a
    goto :found
)

:found
REM 去除空格
set LOCAL_IP=%LOCAL_IP: =%

if "%LOCAL_IP%"=="" (
    echo ❌ 无法获取局域网 IP，请手动配置
    pause
    exit /b 1
)

echo ✅ 检测到局域网 IP: %LOCAL_IP%
echo.

REM 检查参数
set DEVICE_PARAM=
if not "%1"=="" (
    set DEVICE_PARAM=-d %1
    echo 📱 目标设备: %1
)

echo 🚀 启动 Flutter 应用...
echo    API Host: %LOCAL_IP%
echo    API Port: 3000
echo.

REM 运行 Flutter，通过 --dart-define 传递环境变量
flutter run ^
    --dart-define=API_HOST=%LOCAL_IP% ^
    --dart-define=API_PORT=3000 ^
    %DEVICE_PARAM%

pause
