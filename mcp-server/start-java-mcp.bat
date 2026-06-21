@echo off
chcp 65001 >nul
echo.
echo ===============================================
echo DRG医保控费预警系统 - Java MCP服务器启动脚本
echo (使用 IRIS Native API 直接查询数据库)
echo ===============================================
echo.

REM 检查 Java 是否安装
echo 正在检查 Java 环境...
java -version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [错误] Java 未安装或未配置环境变量
    echo.
    echo 请按以下步骤安装 Java:
    echo 1. 访问: https://adoptium.net/
    echo 2. 下载 OpenJDK 17 或更高版本 (Windows x64 .msi)
    echo 3. 安装时勾选 "Set JAVA_HOME variable"
    echo 4. 安装完成后重新打开此窗口
    echo.
    pause
    exit /b 1
)

echo [成功] Java 已安装
java -version
echo.

REM 设置 IRIS 数据库连接参数
echo 正在配置 IRIS 数据库连接...
set IRIS_HOST=111.229.137.113
set IRIS_PORT=1972
set IRIS_NAMESPACE=DRG
set IRIS_USERNAME=_SYSTEM
set IRIS_PASSWORD=123456

echo.
echo 数据库配置:
echo   - 服务器: %IRIS_HOST%:%IRIS_PORT%
echo   - 命名空间: %IRIS_NAMESPACE%
echo   - 用户名: %IRIS_USERNAME%
echo.

REM 检查 JAR 文件是否存在
if not exist "iris-native-mcp-1.0.1.jar" (
    echo [错误] 未找到 iris-native-mcp-1.0.1.jar 文件
    echo 请确保该文件在 mcp-server 目录下
    echo.
    pause
    exit /b 1
)

echo [成功] 找到 MCP 服务器文件
echo.

REM 启动 Java MCP 服务器
echo 正在启动 Java MCP 服务器...
echo ===============================================
echo.

java -jar iris-native-mcp-1.0.1.jar ^
  --iris-host=%IRIS_HOST% ^
  --iris-port=%IRIS_PORT% ^
  --iris-namespace=%IRIS_NAMESPACE% ^
  --iris-username=%IRIS_USERNAME% ^
  --iris-password=%IRIS_PASSWORD% ^
  --server-port=8090 ^
  --server-host=0.0.0.0

echo.
echo ===============================================
if errorlevel 1 (
    echo [错误] 服务器启动失败
    echo 请检查:
    echo   1. IRIS 服务器是否可访问 (%IRIS_HOST%:%IRIS_PORT%)
    echo   2. 用户名和密码是否正确
    echo   3. 命名空间是否存在
) else (
    echo [成功] 服务器已停止
)
echo ===============================================
echo.
pause
