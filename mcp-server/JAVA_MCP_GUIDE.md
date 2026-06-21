# Java MCP 服务器使用指南

## 概述

Java MCP 服务器 (`iris-native-mcp-1.0.1.jar`) 使用 IRIS Native API 直接连接 IRIS 数据库，提供以下功能：

- ✅ 执行 SQL 查询
- ✅ 调用 IRIS 类方法
- ✅ 查询表数据
- ✅ 插入/更新数据
- ✅ 直接访问 IRIS 数据库对象

## 前置要求

### 1. 安装 Java

**下载地址**: https://adoptium.net/

**推荐版本**: OpenJDK 17 (LTS) 或更高

**安装步骤**:
1. 访问 https://adoptium.net/
2. 选择 **Windows x64** 和 **.msi** 格式
3. 下载并运行安装程序
4. **重要**: 安装时勾选 **"Set JAVA_HOME variable"**
5. 完成安装后，**重新打开 PowerShell**

**验证安装**:
```powershell
java -version
```

应该看到类似输出:
```
openjdk version "17.0.9" 2023-10-17
OpenJDK Runtime Environment Temurin-17.0.9+9 (build 17.0.9+9)
OpenJDK 64-Bit Server VM Temurin-17.0.9+9 (build 17.0.9+9, mixed mode, sharing)
```

### 2. 检查文件

确保以下文件在 `mcp-server` 目录中:
- ✅ `iris-native-mcp-1.0.1.jar` (已复制)
- ✅ `iris-mcp-config.json` (已创建)
- ✅ `start-java-mcp.bat` (已创建)

## 快速启动

### 方法 1: 使用启动脚本 (推荐)

```powershell
cd "d:\AI开发\CodeBuddy\DRG医保控费预警系统开发项目\mcp-server"
.\start-java-mcp.bat
```

### 方法 2: 手动启动

```powershell
cd "d:\AI开发\CodeBuddy\DRG医保控费预警系统开发项目\mcp-server"

java -jar iris-native-mcp-1.0.1.jar ^
  --iris-host=111.229.137.113 ^
  --iris-port=1972 ^
  --iris-namespace=DRG ^
  --iris-username=_SYSTEM ^
  --iris-password=123456 ^
  --server-port=8090
```

## 测试连接

启动服务器后，在**另一个 PowerShell 窗口**中运行:

```powershell
cd "d:\AI开发\CodeBuddy\DRG医保控费预警系统开发项目\mcp-server"
node test-java-mcp.js
```

如果看到 `✅ 所有测试通过！`，说明 MCP 服务器工作正常。

## 可用工具

### 1. execute_sql - 执行 SQL 查询

**请求示例**:
```json
{
  "tool": "execute_sql",
  "parameters": {
    "sql": "SELECT * FROM DRG_User.UserInfo WHERE ID < ?",
    "params": [10]
  }
}
```

**调用方式**:
```powershell
$body = @{
  tool = 'execute_sql'
  parameters = @{
    sql = 'SELECT TOP 5 * FROM DRG_User.UserInfo'
    params = @()
  }
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://localhost:8090/mcp/call' `
  -Method POST `
  -Body $body `
  -ContentType 'application/json' `
  -Headers @{'X-API-Key' = 'drg-mcp-access-key-2026'}
```

### 2. call_class_method - 调用 IRIS 类方法

**请求示例**:
```json
{
  "tool": "call_class_method",
  "parameters": {
    "class_name": "DRG.HISData.SyncEngine",
    "method_name": "SyncAll",
    "arguments": []
  }
}
```

### 3. query_table - 查询表数据

**请求示例**:
```json
{
  "tool": "query_table",
  "parameters": {
    "table": "DRG_User.UserInfo",
    "fields": ["ID", "UserCode", "UserName"],
    "where": "ID < 10",
    "limit": 5
  }
}
```

### 4. insert_data - 插入数据

**请求示例**:
```json
{
  "tool": "insert_data",
  "parameters": {
    "table": "DRG_User.UserInfo",
    "data": {
      "UserCode": "test001",
      "UserName": "测试用户",
      "Password": "123456"
    }
  }
}
```

### 5. update_data - 更新数据

**请求示例**:
```json
{
  "tool": "update_data",
  "parameters": {
    "table": "DRG_User.UserInfo",
    "data": {
      "UserName": "更新后的名称"
    },
    "where": "UserCode = 'test001'"
  }
}
```

## 配置 CodeBuddy 使用 MCP 服务器

### 方法 1: HTTP 模式 (推荐)

在 CodeBuddy 设置中添加 MCP 服务器:

```json
{
  "name": "iris-native-mcp",
  "type": "http",
  "url": "http://localhost:8090",
  "auth": {
    "type": "api_key",
    "header": "X-API-Key",
    "value": "drg-mcp-access-key-2026"
  }
}
```

### 方法 2: Stdio 模式

如果 Java MCP 服务器支持 Stdio 模式:

```json
{
  "name": "iris-native-mcp",
  "type": "stdio",
  "command": "java",
  "args": [
    "-jar",
    "iris-native-mcp-1.0.1.jar",
    "--mode=stdio"
  ],
  "env": {
    "IRIS_HOST": "111.229.137.113",
    "IRIS_PORT": "1972",
    "IRIS_NAMESPACE": "DRG",
    "IRIS_USERNAME": "_SYSTEM",
    "IRIS_PASSWORD": "123456"
  }
}
```

## 常见问题

### 1. Java 未安装

**错误信息**: `'java' 不是内部或外部命令`

**解决方案**: 安装 Java 并配置环境变量 (参见上面的"安装 Java"部分)

### 2. 无法连接到 IRIS

**错误信息**: `Connection refused` 或 `Timeout`

**解决方案**:
- 检查 IRIS 服务器是否运行: `111.229.137.113:1972`
- 检查用户名和密码是否正确
- 检查防火墙设置

### 3. 端口被占用

**错误信息**: `Port 8090 already in use`

**解决方案**:
- 更改配置文件中的端口号
- 或停止占用端口的程序

```powershell
# 查找占用端口的进程
netstat -ano | findstr :8090

# 停止进程
taskkill /PID <进程ID> /F
```

## 下一步

1. ✅ 安装 Java
2. ✅ 启动 Java MCP 服务器
3. ✅ 测试连接
4. ✅ 在 CodeBuddy 中配置 MCP 服务器
5. ✅ 开始使用 MCP 工具查询 IRIS 数据库

## 参考文档

- IRIS Native API 文档: https://docs.intersystems.com/
- MCP 协议文档: https://modelcontextprotocol.io/
- OpenJDK 下载: https://adoptium.net/
