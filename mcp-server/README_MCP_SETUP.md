# DRG医保控费预警系统 - MCP服务器配置指南

## 概述
本文档指导您如何配置MCP（Model Context Protocol）服务器，连接到腾讯云服务器上的InterSystems IRIS数据库，为DRG医保控费预警系统提供数据访问服务。

---

## 1. 已创建的配置文件

### 1.1 CodeBuddy MCP配置
- **位置**: `c:\Users\83739\.codebuddy\mcp.json`
- **功能**: CodeBuddy IDE的MCP服务器配置，包含三个服务器：
  - `iris`: 连接到IRIS数据库的通用MCP服务器
  - `drg-api`: DRG专用MCP服务器（Node.js实现）
  - `drg-python`: DRG专用MCP服务器（Python实现）

### 1.2 项目文件
- **`mcp-server-config.yaml`**: 完整的MCP服务器配置
- **`mcp-client-config.json`**: MCP客户端配置
- **`mcp-drg-server.js`**: Node.js MCP服务器实现
- **`mcp-drg-iris-python.py`**: Python MCP客户端示例
- **`mcp-drg-iris-nodejs.js`**: Node.js MCP客户端示例
- **`package.json`**: Node.js项目依赖配置
- **`start-mcp-server.bat`**: Windows一键启动脚本

---

## 2. 配置详情

### 2.1 服务器连接参数
```yaml
服务器地址: http://111.229.137.113:52773
命名空间: DRG
账户信息:
  - 用户名: _SYSTEM
  - 密码: 123456
API密钥: drg-mcp-access-key-2026
```

### 2.2 支持的接口服务
| 模块 | 接口代码 | 功能 |
|------|----------|------|
| DRG分组 | 02010001 | DRG分组器 |
| 费用预警 | 02010101-02010106 | 预警规则和记录管理 |
| 盈亏分析 | 02010201-02010206 | 科室、医生、病种盈亏分析 |
| 系统管理 | 02010401-02010415 | 用户、菜单、角色管理 |

---

## 3. 快速启动指南

### 3.1 步骤一：安装依赖
```bash
# 确保已安装Node.js 18.0+
node --version

# 安装依赖包
cd "d:/AI开发/CodeBuddy/DRG医保控费预警系统开发项目"
npm install
```

### 3.2 步骤二：启动MCP服务器

#### 方法一：使用批处理脚本（推荐）
1. 双击 `start-mcp-server.bat`
2. 脚本将自动检查环境并启动服务器
3. 保持命令行窗口打开（不要关闭）

#### 方法二：手动启动
```bash
cd "d:/AI开发/CodeBuddy/DRG医保控费预警系统开发项目"
node mcp-drg-server.js
```

#### 方法三：使用Python客户端
```bash
python mcp-drg-iris-python.py
```

### 3.3 步骤三：在CodeBuddy中启用

1. **重启CodeBuddy IDE**
2. **检查MCP连接状态**:
   - 在CodeBuddy中查看"连接状态"或"MCP集成"
   - 确认 `iris`、`drg-api`、`drg-python` 三个服务器状态为"已连接"

3. **测试连接**:
   - 在CodeBuddy中使用MCP工具查询数据
   - 例如: 查询医院列表、预警记录等

---

## 4. 接口使用示例

### 4.1 查询医院信息
```python
from mcp_drg_iris import DRGIRISMCPClient

client = DRGIRISMCPClient()
result = client.query_system_users(filters={"hospitalCode": "H03"})
```

### 4.2 查询预警记录
```javascript
const { DRGIRISMCPClient } = require('./mcp-drg-iris-nodejs.js');

const client = new DRGIRISMCPClient({
  baseURL: 'http://111.229.137.113:52773',
  apiKey: 'drg-mcp-access-key-2026'
});

client.queryWarningRecords({
  startDate: '2026-01-01',
  endDate: '2026-04-09',
  warningLevel: '高'
}).then(result => {
  console.log(result);
});
```

### 4.3 调用通用接口
```javascript
const result = await client.invokeInterface('02010404', []);
// 02010404: 查询接口服务列表
```

---

## 5. 工具和资源

### 5.1 可用工具（通过MCP调用）

| 工具名称 | 描述 |
|----------|------|
| `invoke_drg_interface` | 调用任意IRIS接口 |
| `query_warning_records` | 查询预警记录 |
| `query_hospitals` | 查询医院信息 |
| `query_basic_data` | 查询基础数据（省份、城市、区域、政策类型） |
| `test_connection` | 测试服务器连接 |

### 5.2 可用资源（通过MCP访问）

| 资源名称 | URI | 描述 |
|----------|-----|------|
| 服务器信息 | `iris://server-info` | IRIS服务器连接信息 |
| 接口文档 | `drg://interface-docs` | DRG系统接口文档 |
| 数据模型 | `drg://data-model` | DRG系统数据模型定义 |

---

## 6. 故障排除

### 6.1 常见问题

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 无法连接IRIS服务器 | 网络不通或服务器宕机 | 1. 检查网络连接<br>2. 确认IRIS服务器状态<br>3. 检查防火墙设置 |
| 认证失败 | 用户名或密码错误 | 1. 验证账户信息<br>2. 检查命名空间权限 |
| API调用返回错误 | 接口代码或参数格式错误 | 1. 确认接口代码<br>2. 检查参数格式<br>3. 查看错误信息详情 |
| MCP服务器无法启动 | Node.js版本过低或依赖缺失 | 1. 升级Node.js到18.0+<br>2. 运行 `npm install` |

### 6.2 连接测试

#### 手动测试IRIS连接：
```bash
# 测试HTTP连接
curl -I http://111.229.137.113:52773/csp/drg/sysInternalMutiple

# 测试认证（注意：在命令行中执行时需注意安全）
curl -u "_SYSTEM:123456" http://111.229.137.113:52773/csp/drg/sysInternalMutiple -X POST -H "Content-Type: application/json" -d '{"code":"02010404","params":[]}'
```

#### 通过浏览器访问管理门户：
```
http://111.229.137.113:52773/csp/sys/UtilHome.csp
```

---

## 7. 安全注意事项

### 7.1 凭证管理
- **API密钥**: 在生产环境中定期更换
- **IRIS账户**: 使用专用的服务账户，而非 `_SYSTEM` 账户
- **环境变量**: 敏感信息通过环境变量传递

### 7.2 访问控制
- **网络隔离**: 限制MCP服务器访问范围
- **API限流**: 防止接口滥用
- **日志审计**: 记录所有访问日志



### 7.3 生产部署建议

1. **使用专用服务器账户**
```yaml
# 创建专用账户
用户名: drg_mcp_service
权限: 只读访问必要的表和类
```

2. **配置SSL/TLS**
```yaml
security:
  ssl:
    enabled: true
    cert_path: "/path/to/cert.pem"
    key_path: "/path/to/key.pem"
```

3. **启用访问日志**
```yaml
monitoring:
  access_log:
    enabled: true
    format: "combined"
    retention_days: 30
```

---

## 8. 维护和监控

### 8.1 健康检查
```
# 通过HTTP接口检查
curl http://localhost:8090/health

# 通过MCP工具检查
test_connection()
```

### 8.2 性能监控

#### 关键指标：
- 接口调用成功率
- 平均响应时间
- 并发连接数
- 错误率统计

#### 日志位置：
- 控制台输出（启动时可见）
- 应用日志（可通过配置输出到文件）
- 系统日志（Windows事件查看器）

---

## 9. 技术支持

### 9.1 联系方式
- **邮箱**: drg-support@yourcompany.com
- **内部文档**: http://docs.drg-project.com
- **紧急联系人**: 内部通讯录中的DRG技术支持

### 9.2 问题报告
当遇到问题时，请提供以下信息：
1. 错误消息详情
2. 操作步骤
3. 服务器日志片段
4. 环境信息（操作系统、Node.js版本等）

### 9.3 文档更新
本文档将随系统更新而更新，最新版本请参考项目文档仓库。

---

## 10. 附录

### 10.1 接口调用格式
```json
{
  "code": "02010404",
  "params": [
    {
      "searchText": "关键词",
      "page": 1,
      "limit": 20
    }
  ],
  "session": [
    {
      "userID": "158",
      "userCode": "admin",
      "locID": "2300",
      "hospID": "25"
    }
  ]
}
```

### 10.2 错误码参考

| 错误码 | 描述 |
|--------|------|
| 0 | 成功 |
| -1 | 业务逻辑失败 |
| -99 | 系统异常 |
| 1001 | 参数错误 |
| 1002 | 会话过期 |
| 1003 | 权限不足 |
| 2001 | 数据不存在 |
| 2002 | 数据已存在 |
| 3001 | 服务器内部错误 |

### 10.3 相关文件
- `MCP_IMPLEMENTATION_GUIDE.md` - 详细实现指南
- `mcp-server-config.yaml` - 完整服务器配置
- `mcp-client-config.json` - 客户端配置示例