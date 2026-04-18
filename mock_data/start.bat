@echo off
echo ========================================
echo   Mock Data Server - 启动脚本
echo ========================================
echo.

REM 检查 Node.js 是否安装
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未检测到 Node.js，请先安装 Node.js
    pause
    exit /b 1
)

echo [信息] Node.js 版本:
node --version
echo.

REM 检查 MongoDB 是否运行
echo [信息] 检查 MongoDB 服务状态...
sc query MongoDB | find "RUNNING" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [警告] MongoDB 服务可能未运行
    echo [提示] 如果尚未安装 MongoDB，请先安装并启动
    echo [提示] 或者使用 MongoDB Atlas 云数据库
    echo.
    set /p continue="是否继续启动服务器？(y/n): "
    if /i not "%continue%"=="y" exit /b 1
) else (
    echo [成功] MongoDB 服务正在运行
)
echo.

REM 检查 node_modules 是否存在
if not exist "node_modules\" (
    echo [信息] 首次运行，正在安装依赖...
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo [错误] 依赖安装失败
        pause
        exit /b 1
    )
    echo [成功] 依赖安装完成
    echo.
)

REM 检查 .env 文件
if not exist ".env" (
    echo [信息] 创建默认 .env 文件...
    copy .env.example .env >nul
    echo [成功] .env 文件已创建
    echo.
)

echo ========================================
echo   启动服务器...
echo ========================================
echo.
echo 服务器地址: http://localhost:3000
echo API 地址: http://localhost:3000/api/mock-data
echo.
echo 按 Ctrl+C 停止服务器
echo.

REM 启动开发服务器
call npm run dev
