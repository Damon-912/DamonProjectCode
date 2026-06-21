@echo off
chcp 65001 >nul
echo.
echo ===============================================
echo DRG医保控费预警系统 - MCP服务器启动脚本
echo ===============================================
echo.
echo 当前目录: %cd%
echo.
echo 环境检查:
echo.
echo 1. 检查Node.js版本...
node --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Node.js 未安装或未添加到系统路径
    echo 请安装 Node.js 18.0 或更高版本
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version') do (
        echo   Node.js版本: %%i
    )
)

echo.
echo 2. 检查npm包依赖...
if not exist "node_modules" (
    echo 未找到 node_modules，正在安装依赖...
    call npm install
) else (
    echo 依赖已安装。
)

echo.
echo 3. 设置环境变量...
set IRIS_HOST=111.229.137.113
set IRIS_PORT=52773
set IRIS_NAMESPACE=DRG
set IRIS_USERNAME=_SYSTEM
set IRIS_PASSWORD=123456
set MCP_API_KEY=drg-mcp-access-key-2026

echo.
echo 服务器配置:
echo   - 服务器地址: %IRIS_HOST%:%IRIS_PORT%
echo   - 命名空间: %IRIS_NAMESPACE%
echo   - 用户名: %IRIS_USERNAME%
echo   - API密钥: %MCP_API_KEY%

echo.
echo 4. 测试连接...
echo ===============================================
echo 连接测试:
echo ===============================================
node test-connection-simple.js

echo.
echo 5. 启动MCP服务器...
echo ===============================================
echo 服务器日志:
echo ===============================================
echo 按 Ctrl+C 停止服务器...
echo.
node server.js

if errorlevel 1 (
    echo.
    echo ===============================================
    echo 服务器启动失败!
    echo 请检查:
    echo   1. IRIS服务器状态 (http://%IRIS_HOST%:%IRIS_PORT%)
    echo   2. 用户名和密码是否正确
    echo   3. 网络连接是否正常
    echo ===============================================
    pause
) else (
    echo.
    echo ===============================================
    echo 服务器已正常关闭。
    echo ===============================================
)

pause