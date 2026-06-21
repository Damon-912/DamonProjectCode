/*
DRG表结构部署脚本
使用方法:
  iris compile IRIS 命名空间 类文件路径

示例:
  iris compile USER "C:\path\to\BSDRGWarningRule.cls"
*/

:: 获取脚本所在目录
set SCRIPT_DIR=%~dp0
set IRIS_BIN=C:\InterSystems\IRIS\bin
set NAMESPACE=USER

echo ========================================
echo   DRG医保控费系统 - 表结构部署
echo ========================================
echo.

:: 检查 IRIS 安装路径
if not exist "%IRIS_BIN%\iris.exe" (
    echo 错误: 找不到 IRIS 安装目录
    echo 请修改脚本中的 IRIS_BIN 路径
    pause
    exit /b 1
)

echo 部署表结构到 %NAMESPACE% 命名空间...
echo.

:: 定义表结构文件列表
set TABLES[0]=BSDRGWarningRule
set TABLES[1]=BSDRGWarningRecord
set TABLES[2]=BSDRGProfitAnalysis
set TABLES[3]=BSDRGDeptSummary
set TABLES[4]=BSDRGQCIssue
set TABLES[5]=BSDRGSystemUser
set TABLES[6]=BSDRGSystemRole
set TABLES[7]=BSDRGUserRole
set TABLES[8]=BSDRGSystemMenu
set TABLES[9]=BSDRGRoleMenu
set TABLES[10]=CBHISConnectionConfig

set TABLE_DIR=%SCRIPT_DIR%..\DRG后端表结构

echo 开始编译表结构...
echo.

for /L %%i in (0,1,10) do (
    setlocal
    set "TABLE_NAME=!TABLES[%%i]!"
    if exist "%TABLE_DIR%\!TABLE_NAME!.txt" (
        echo 编译: !TABLE_NAME!.txt
        "%IRIS_BIN%\iris" compile "%TABLE_DIR%\!TABLE_NAME!.txt" -namespace %NAMESPACE% -user _system -password 123456
    )
    endlocal
)

echo.
echo 开始编译服务类...
echo.

set SERVICE_DIR=%SCRIPT_DIR%..\..\src\src\DRG

if exist "%SERVICE_DIR%\Warning.cls" (
    echo 编译: Warning.cls
    "%IRIS_BIN%\iris" compile "%SERVICE_DIR%\Warning.cls" -namespace %NAMESPACE% -user _system -password 123456
)

if exist "%SERVICE_DIR%\Profit.cls" (
    echo 编译: Profit.cls
    "%IRIS_BIN%\iris" compile "%SERVICE_DIR%\Profit.cls" -namespace %NAMESPACE% -user _system -password 123456
)

if exist "%SERVICE_DIR%\QC.cls" (
    echo 编译: QC.cls
    "%IRIS_BIN%\iris" compile "%SERVICE_DIR%\QC.cls" -namespace %NAMESPACE% -user _system -password 123456
)

if exist "%SERVICE_DIR%\System.cls" (
    echo 编译: System.cls
    "%IRIS_BIN%\iris" compile "%SERVICE_DIR%\System.cls" -namespace %NAMESPACE% -user _system -password 123456
)

echo.
echo ========================================
echo   部署完成!
echo ========================================
echo.
pause
