@echo off
echo ========================================
echo   Mock Data Server - API 测试
echo ========================================
echo.

REM 检查服务器是否运行
curl -s http://localhost:3000 >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 无法连接到服务器
    echo 请先运行 start.bat 或 npm run dev 启动服务器
    echo.
    pause
    exit /b 1
)

echo [成功] 服务器正在运行
echo.

REM 运行测试
echo 开始运行 API 测试...
echo.

node test-api.js

echo.
echo ========================================
echo   测试完成
echo ========================================
echo.
pause
