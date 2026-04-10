# MCP服务器实现指南
## 连接腾讯云IRIS数据库

本文档详细说明如何实现MCP服务器来连接到腾讯云服务器上的InterSystems IRIS数据库。

---

## 1. 系统概述

### 1.1 目标
实现一个MCP（Model Context Protocol）服务器，为DRG医保控费预警系统提供统一的IRIS数据库访问接口。

### 1.2 技术栈
- **后端框架**: Express.js (Node.js)
- **数据库**: InterSystems IRIS 2023.1+
- **协议**: HTTP/RESTful API
- **认证**: API Key + Basic Auth

### 1.3 连接信息
```yaml
服务器地址: http://111.229.137.113:52773
命名空间: USER
账户信息:
  - 用户名: _system
  - 密码: 123456
接口端点: /csp/drg/sysInternalMutiple
```

---

## 2. 配置文件详解

### 2.1 主配置文件 (`mcp-server-config.yaml`)
位于项目根目录，包含完整的MCP服务器配置：

```yaml
# 服务器连接配置
server:
  type: "http"
  base_url: "http://111.229.137.113:52773"
  timeout: 30

# 数据库连接配置  
database:
  type: "intersystems-iris"
  namespace: "USER"
  credentials:
    username: "_system"
    password: "123456"
```

### 2.2 CodeBuddy集成配置 (`.codebuddy/mcp-drg-iris.json`)
专为CodeBuddy IDE设计的MCP集成配置，位于`.codebuddy`目录：

```json
{
  "name": "drg-iris-mcp",
  "type": "mcp-server",
  "configurations": {
    "production": {
      "server_url": "http://111.229.137.113:52773",
      "namespace": "USER"
    }
  }
}
```

### 2.3 客户端配置 (`mcp-client-config.json`)
MCP客户端配置，用于连接MCP服务器：

```json
{
  "mcp": {
    "servers": [{
      "name": "drg-iris-server",
      "url": "http://localhost:8090",
      "auth": {
        "type": "api_key",
        "value": "drg-mcp-access-key-2026"
      }
    }]
  }
}
```

---

## 3. 实现步骤

### 3.1 步骤一：创建MCP服务器
1. **初始化项目**
```bash
mkdir drg-mcp-server
cd drg-mcp-server
npm init -y
npm install express axios body-parser cors
```

2. **创建服务器主文件**
```javascript
// server.js
const express = require('express');
const axios = require('axios');
const app = express();

// 中间件
app.use(express.json());
app.use(cors());

// 代理接口
app.post('/invoke', async (req, res) => {
  const { code, params, session } = req.body;
  
  // 构建请求数据
  const requestData = {
    code: code,
    params: params,
    session: session
  };
  
  // 转发到IRIS服务器
  const response = await axios.post(
    'http://111.229.137.113:52773/csp/drg/sysInternalMutiple',
    requestData,
    {
      auth: {
        username: '_system',
        password: '123456'
      }
    }
  );
  
  res.json(response.data);
});

// 启动服务器
const PORT = 8090;
app.listen(PORT, () => {
  console.log(`MCP服务器运行在 http://localhost:${PORT}`);
});
```

### 3.2 步骤二：配置MCP客户端
1. **Python客户端**
```python
# mcp-drg-iris-python.py
import requests

class DRGIRISMCPClient:
    def __init__(self, base_url, api_key):
        self.base_url = base_url
        self.api_key = api_key
    
    def invoke_interface(self, interface_code, params):
        headers = {
            "X-API-Key": self.api_key,
            "Content-Type": "application/json"
        }
        
        data = {
            "code": interface_code,
            "params": params,
            "session": [{
                "userID": "158",
                "userCode": "admin"
                # ... 其他session字段
            }]
        }
        
        response = requests.post(
            f"{self.base_url}/invoke",
            json=data,
            headers=headers
        )
        
        return response.json()
```

2. **Node.js客户端**
```javascript
// mcp-drg-iris-nodejs.js
const axios = require('axios');

class DRGIRISMCPClient {
  constructor(config) {
    this.config = config;
    this.instance = axios.create({
      baseURL: config.baseURL,
      headers: {
        'X-API-Key': config.apiKey
      }
    });
  }
  
  async invokeInterface(interfaceCode, params) {
    const response = await this.instance.post('/invoke', {
      code: interfaceCode,
      params: params
    });
    
    return response.data;
  }
}
```

### 3.3 步骤三：集成到CodeBuddy
1. **创建CodeBuddy配置文件**
将 `.codebuddy/mcp-drg-iris.json` 放置在项目根目录的 `.codebuddy` 文件夹中。

2. **在CodeBuddy中启用MCP服务器**
- 打开CodeBuddy IDE
- 进入设置 → MCP集成
- 添加新的MCP服务器
- 加载 `mcp-drg-iris.json` 配置文件

3. **测试连接**
```bash
# 启动本地代理服务器
node proxy-server.js

# 测试连接
curl -X POST http://localhost:8090/iris-api/invoke \
  -H "X-API-Key: drg-mcp-access-key-2026" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "02010404",
    "params": []
  }'
```

---

## 4. 接口调用示例

### 4.1 通用请求格式
```json
{
  "code": "接口代码",
  "params": [
    {
      "参数名": "参数值"
    }
  ],
  "session": [
    {
      "userID": "158",
      "userCode": "admin",
      // ... 其他session信息
    }
  ]
}
```

### 4.2 接口调用示例
1. **查询接口服务列表**
```javascript
const result = await client.invokeInterface('02010404', []);
```

2. **查询预警记录**
```javascript
const result = await client.queryWarningRecords({
  startDate: '2026-01-01',
  endDate: '2026-04-09',
  warningLevel: '高',
  page: 1,
  limit: 10
});
```

3. **查询科室盈亏**
```javascript
const result = await client.queryDeptProfit({
  startDate: '2026-01-01',
  endDate: '2026-03-31',
  page: 1,
  limit: 15
});
```

---

## 5. 安全配置

### 5.1 API Key认证
```yaml
authentication:
  api_key:
    enabled: true
    header_name: "X-API-Key"
    required: true
```

### 5.2 IRIS数据库认证
```yaml
database:
  credentials:
    username: "_system"
    password: "123456"
  connection_params:
    charset: "UTF-8"
    pool_size: 10
```

### 5.3 CORS配置
```yaml
security:
  cors:
    enabled: true
    allowed_origins: ["http://localhost:5173", "http://localhost:8090"]
    allowed_methods: ["GET", "POST"]
```

---

## 6. 部署指南

### 6.1 本地开发环境
```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 启动MCP服务器
node server.js
```

### 6.2 生产环境部署
1. **使用PM2进程管理**
```bash
npm install -g pm2
pm2 start server.js --name "drg-mcp-server"
pm2 save
pm2 startup
```

2. **配置反向代理 (Nginx)**
```nginx
server {
    listen 80;
    server_name mcp.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:8090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

3. **设置环境变量**
```bash
export IRIS_HOST="111.229.137.113"
export IRIS_PORT="52773"
export IRIS_USERNAME="_system"
export IRIS_PASSWORD="123456"
export MCP_API_KEY="drg-mcp-access-key-2026"
```

---

## 7. 故障排除

### 7.1 常见问题
| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 连接超时 | 网络问题或IRIS服务器未启动 | 检查服务器状态和网络连接 |
| 认证失败 | 用户名或密码错误 | 验证IRIS账户信息 |
| API调用失败 | 接口代码错误 | 检查接口代码和参数格式 |
| CORS错误 | 浏览器安全策略 | 配置正确的CORS头 |

### 7.2 日志配置
```javascript
// 配置详细日志
const winston = require('winston');
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### 7.3 健康检查
```javascript
// 添加健康检查端点
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    server: 'mcp-drg-server',
    version: '1.0.0'
  });
});
```

---

## 8. 扩展与维护

### 8.1 监控指标
- 接口调用次数
- 平均响应时间
- 错误率
- 并发连接数

### 8.2 性能优化
1. **连接池配置**
```yaml
database:
  connection_params:
    pool_size: 20
    max_lifetime: 600
```

2. **缓存策略**
```yaml
cache:
  enabled: true
  ttl: 300
  max_size: 1000
```

3. **请求限流**
```yaml
security:
  rate_limiting:
    enabled: true
    requests_per_minute: 60
```

---

## 9. 相关资源

### 9.1 文档链接
- [InterSystems IRIS官方文档](https://docs.intersystems.com/iris20231/csp/docbook/DocBook.UI.Page.cls)
- [MCP协议规范](https://spec.modelcontextprotocol.io/)
- [CodeBuddy MCP集成指南](https://www.codebuddy.ai/docs/zh/ide/User-guide/mcp-integration)

### 9.2 示例代码
- 完整示例代码位于项目根目录：
  - `mcp-server-config.yaml` - 服务器配置
  - `mcp-client-config.json` - 客户端配置
  - `mcp-drg-iris-python.py` - Python客户端示例
  - `mcp-drg-iris-nodejs.js` - Node.js客户端示例

### 9.3 联系方式
如需技术支持，请联系DRG开发团队：
- 邮箱：drg-support@yourcompany.com
- 内部文档：http://docs.drg-project.com