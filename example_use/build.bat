@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Lite Simple UI Example - 构建脚本 (批处理版本)
REM 使用方法:
REM   build.bat dev           - 开发模式运行
REM   build.bat apk           - 构建 Android APK
REM   build.bat windows       - 构建 Windows 应用
REM   build.bat web           - 构建 Web 应用
REM   build.bat clean         - 清理构建缓存
REM   build.bat deps          - 获取依赖
REM   build.bat test          - 运行测试
REM   build.bat help          - 显示帮助信息

cd /d "%~dp0"

if "%~1"=="" goto help
if "%~1"=="help" goto help
if "%~1"=="dev" goto dev
if "%~1"=="apk" goto apk
if "%~1"=="aab" goto aab
if "%~1"=="windows" goto windows
if "%~1"=="web" goto web
if "%~1"=="clean" goto clean
if "%~1"=="deps" goto deps
if "%~1"=="test" goto test

echo.
echo [错误] 未知命令：%1
goto help

:help
echo.
echo ========================================
echo  Lite Simple UI Example - 构建工具
echo ========================================
echo.
echo 用法：build.bat [命令]
echo.
echo 可用命令:
echo   dev              开发模式运行 ^(热重载^)
echo   apk              构建 Android APK
echo   aab              构建 Android App Bundle
echo   windows          构建 Windows 应用
echo   web              构建 Web 应用
echo   clean            清理构建缓存
echo   deps             获取依赖
echo   test             运行测试
echo   help             显示此帮助信息
echo.
echo 示例:
echo   build.bat dev              启动开发模式
echo   build.bat apk              构建 APK
echo   build.bat clean ^& build.bat deps  清理并重新获取依赖
echo.
goto end

:check_flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [错误] 未找到 Flutter，请确保 Flutter 已安装并添加到 PATH
    echo.
    exit /b 1
)
goto end_check

:dev
call :check_flutter
echo.
echo ========================================
flutter --version
echo ========================================
echo 启动开发模式 ^(热重载^)...
echo.
flutter run
goto end

:apk
call :check_flutter
echo.
echo ========================================
flutter --version
echo ========================================
echo 开始构建 Android APK...
echo.
flutter build apk --release
if %errorlevel% equ 0 (
    echo.
    echo [成功] APK 构建成功!
    echo 输出位置：build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo ========================================
) else (
    echo.
    echo [失败] APK 构建失败
    exit /b 1
)
goto end

:aab
call :check_flutter
echo.
echo ========================================
flutter --version
echo ========================================
echo 开始构建 Android App Bundle...
echo.
flutter build appbundle --release
if %errorlevel% equ 0 (
    echo.
    echo [成功] App Bundle 构建成功!
    echo 输出位置：build\app\outputs\bundle\release\app-release.aab
    echo.
    echo ========================================
) else (
    echo.
    echo [失败] App Bundle 构建失败
    exit /b 1
)
goto end

:windows
call :check_flutter
echo.
echo ========================================
flutter --version
echo ========================================
echo 开始构建 Windows 应用...
echo.
flutter build windows --release
if %errorlevel% equ 0 (
    echo.
    echo [成功] Windows 应用构建成功!
    echo 输出位置：build\windows\x64\runner\Release\
    echo.
    echo ========================================
) else (
    echo.
    echo [失败] Windows 应用构建失败
    exit /b 1
)
goto end

:web
call :check_flutter
echo.
echo ========================================
flutter --version
echo ========================================
echo 开始构建 Web 应用...
echo.
flutter build web --release
if %errorlevel% equ 0 (
    echo.
    echo [成功] Web 应用构建成功!
    echo 输出位置：build\web\
    echo.
    echo ========================================
) else (
    echo.
    echo [失败] Web 应用构建失败
    exit /b 1
)
goto end

:clean
echo.
echo ========================================
echo 清理构建缓存...
echo.
flutter clean
if exist pubspec.lock del pubspec.lock
echo.
echo [成功] 清理完成!
echo ========================================
goto end

:deps
call :check_flutter
echo.
echo ========================================
echo 获取 Flutter 依赖...
echo.
flutter pub get
if %errorlevel% equ 0 (
    echo.
    echo [成功] 依赖获取成功!
    echo.
    echo ========================================
) else (
    echo.
    echo [失败] 依赖获取失败
    exit /b 1
)
goto end

:test
call :check_flutter
echo.
echo ========================================
echo 运行测试...
echo.
flutter test
if %errorlevel% equ 0 (
    echo.
    echo [成功] 测试通过!
    echo.
    echo ========================================
) else (
    echo.
    echo [失败] 测试失败
    exit /b 1
)
goto end

:end_check
exit /b 0

:end
pause
