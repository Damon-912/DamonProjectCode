# 后端开发规范模板

> 阶段 4 模板：后端开发标准

---

## 文档信息

| 字段 | 值 |
|------|-----|
| 项目名称 | `{项目名称}` |
| 版本 | `1.0.0` |
| 创建日期 | `{日期}` |

---

## 1. API 设计标准

### 1.1 API 风格

| 属性 | 值 |
|------|-----|
| 风格 | REST / GraphQL / gRPC |
| 基础 URL | `/api/v1` |
| 协议 | 仅 HTTPS |

### 1.2 URL 规范

| 规范 | 示例 | 描述 |
|------|------|------|
| 使用名词 | `/users`, `/orders` | 资源用名词表示 |
| 复数形式 | `/users` 而非 `/user` | 统一使用复数 |
| 嵌套资源 | `/users/{id}/orders` | 最多 2 层 |
| 查询参数 | `?page=1&limit=20` | 过滤、分页 |

### 1.3 HTTP 方法

| 方法 | 用途 | 幂等 | 安全 |
|------|------|------|------|
| GET | 获取资源 | 是 | 是 |
| POST | 创建资源 | 否 | 否 |
| PUT | 全量更新 | 是 | 否 |
| PATCH | 部分更新 | 否 | 否 |
| DELETE | 删除资源 | 是 | 否 |

### 1.4 HTTP 状态码

| 状态码 | 含义 | 使用场景 |
|--------|------|----------|
| 200 | 成功 | GET、PUT、PATCH 成功 |
| 201 | 已创建 | POST 成功 |
| 204 | 无内容 | DELETE 成功 |
| 400 | 错误请求 | 校验错误 |
| 401 | 未认证 | 缺少/无效认证 |
| 403 | 禁止访问 | 权限不足 |
| 404 | 未找到 | 资源不存在 |
| 409 | 冲突 | 重复/约束违反 |
| 422 | 无法处理 | 校验失败 |
| 429 | 请求过多 | 触发限流 |
| 500 | 服务器错误 | 未知错误 |
| 502 | 网关错误 | 上游故障 |
| 503 | 服务不可用 | 维护/过载 |

---

## 2. 请求/响应格式

### 2.1 请求头

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
X-Request-ID: {uuid}
X-Correlation-ID: {uuid}
```

### 2.2 标准响应结构

#### 成功响应

```json
{
  "data": {
    // 响应数据
  },
  "meta": {
    "requestId": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### 分页响应

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5,
    "hasNext": true,
    "hasPrev": false
  },
  "meta": {
    "requestId": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

#### 错误响应

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "请求包含无效数据",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "必须是有效的邮箱地址"
      }
    ],
    "requestId": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### 2.3 错误码分类

| 前缀 | 分类 | 示例 |
|------|------|------|
| `AUTH_` | 认证 | AUTH_TOKEN_EXPIRED, AUTH_INVALID_CREDENTIALS |
| `PERM_` | 授权 | PERM_DENIED, PERM_INSUFFICIENT |
| `VAL_` | 校验 | VAL_REQUIRED, VAL_INVALID_FORMAT, VAL_OUT_OF_RANGE |
| `RES_` | 资源 | RES_NOT_FOUND, RES_ALREADY_EXISTS |
| `SYS_` | 系统 | SYS_INTERNAL_ERROR, SYS_SERVICE_UNAVAILABLE |

---

## 3. 认证与授权

### 3.1 认证方式

| 属性 | 值 |
|------|-----|
| 类型 | JWT Bearer Token |
| 令牌有效期 | 访问令牌: 15分钟, 刷新令牌: 7天 |
| 算法 | RS256 |

### 3.2 JWT 载荷

```json
{
  "sub": "user-uuid",
  "iat": 1705312800,
  "exp": 1705313700,
  "iss": "your-app",
  "aud": "your-app-api",
  "roles": ["user", "admin"],
  "permissions": ["read:users", "write:users"]
}
```

### 3.3 授权模型

| 模型 | 用途 |
|------|------|
| RBAC | 基于角色访问（admin, user, guest） |
| ABAC | 基于属性细粒度控制 |
| 资源所有权 | 用户只能访问自己的资源 |

### 3.4 权限中间件

```typescript
// 权限检查示例
function requirePermission(permission: string) {
  return async (req, res, next) => {
    const user = req.user;

    if (!user.permissions.includes(permission)) {
      return res.status(403).json({
        error: {
          code: 'PERM_DENIED',
          message: `缺少必要权限: ${permission}`
        }
      });
    }

    next();
  };
}

// 使用
app.delete('/users/:id',
  authenticate,
  requirePermission('delete:users'),
  deleteUser
);
```

---

## 4. 校验标准

### 4.1 输入校验层级

| 层级 | 职责 |
|------|------|
| 路由 | Schema 校验（请求结构） |
| 服务 | 业务规则校验 |
| 仓储 | 数据完整性 |

### 4.2 校验库

使用统一的校验库（如 Zod, Joi, class-validator）。

```typescript
// Zod 示例
const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
  name: z.string().min(1).max(100).optional()
});

// 在路由处理中使用
const validated = createUserSchema.parse(req.body);
```

### 4.3 常用校验规则

| 字段 | 规则 |
|------|------|
| 邮箱 | 有效格式，标准化（小写、去空格） |
| 密码 | 最少 8 字符，最多 100，复杂度规则 |
| UUID | 有效的 UUID v4 格式 |
| 日期 | ISO 8601 格式 |
| 分页 | page >= 1, limit 1-100 |

---

## 5. 错误处理

### 5.1 错误层级

```typescript
class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 500,
    public details?: any[]
  ) {
    super(message);
  }
}

class ValidationError extends AppError {
  constructor(details: ValidationErrorDetail[]) {
    super('VALIDATION_ERROR', '校验失败', 400, details);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string) {
    super('RES_NOT_FOUND', `${resource} 不存在`, 404);
  }
}

class UnauthorizedError extends AppError {
  constructor(message: string = '未授权') {
    super('AUTH_UNAUTHORIZED', message, 401);
  }
}
```

### 5.2 全局错误处理器

```typescript
app.use((err, req, res, next) => {
  // 记录错误
  logger.error({
    error: err,
    requestId: req.id,
    path: req.path,
    method: req.method
  });

  // 处理已知错误
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
        requestId: req.id,
        timestamp: new Date().toISOString()
      }
    });
  }

  // 处理未知错误
  return res.status(500).json({
    error: {
      code: 'SYS_INTERNAL_ERROR',
      message: '发生未知错误',
      requestId: req.id,
      timestamp: new Date().toISOString()
    }
  });
});
```

---

## 6. 日志标准

### 6.1 日志级别

| 级别 | 使用场景 |
|------|----------|
| ERROR | 异常、操作失败 |
| WARN | 可恢复问题、废弃用法 |
| INFO | 业务事件、请求开始/结束 |
| DEBUG | 详细诊断信息 |
| TRACE | 非常详细的调试（生产环境禁用） |

### 6.2 结构化日志格式

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "INFO",
  "message": "用户创建成功",
  "context": {
    "requestId": "uuid",
    "userId": "uuid",
    "module": "user-service"
  },
  "data": {
    "userId": "new-user-uuid"
  }
}
```

### 6.3 请求日志中间件

```typescript
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    logger.info({
      message: '请求完成',
      context: {
        requestId: req.id,
        method: req.method,
        path: req.path,
        statusCode: res.statusCode,
        duration: Date.now() - start
      }
    });
  });

  next();
});
```

---

## 7. 限流

### 7.1 限流配置

| 端点类型 | 限制 | 时间窗口 | 键 |
|----------|------|----------|-----|
| 公开 API | 100 次 | 1 分钟 | IP 地址 |
| 认证 API | 300 次 | 1 分钟 | 用户 ID |
| 认证接口 | 5 次 | 1 分钟 | IP + 邮箱 |
| 密码重置 | 3 次 | 1 小时 | 邮箱 |

### 7.2 限流响应头

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705313100
```

### 7.3 限流响应

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "请求过多，请稍后重试。",
    "retryAfter": 60
  }
}
```

---

## 8. 缓存策略

### 8.1 缓存层级

| 层级 | 技术 | 用途 |
|------|------|------|
| 应用层 | 内存 (LRU) | 高频、小数据 |
| 分布式 | Redis | 共享数据、会话 |
| CDN | CloudFront/Cloudflare | 静态资源、API 响应 |

### 8.2 缓存头

| 头 | 值 | 用途 |
|----|-----|------|
| `Cache-Control` | `max-age=300` | 客户端缓存 |
| `ETag` | `"{hash}"` | 条件请求 |
| `Last-Modified` | `ISO 日期` | 条件请求 |

### 8.3 缓存失效

| 策略 | 触发时机 | 实现方式 |
|------|----------|----------|
| TTL | 基于时间 | 自动过期 |
| 事件驱动 | 更新时 | 发布失效事件 |
| 标签驱动 | 批量 | 标签关联键 |

---

## 9. 代码结构

### 9.1 目录结构

```
src/
├── modules/
│   ├── user/
│   │   ├── user.controller.ts
│   │   ├── user.service.ts
│   │   ├── user.repository.ts
│   │   ├── user.dto.ts
│   │   ├── user.entity.ts
│   │   └── user.test.ts
│   └── order/
│       └── ...
├── common/
│   ├── middleware/
│   ├── guards/
│   ├── decorators/
│   ├── filters/
│   └── interceptors/
├── config/
│   └── configuration.ts
├── database/
│   ├── migrations/
│   └── seeds/
└── main.ts
```

### 9.2 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 文件 | kebab-case | `user-service.ts` |
| 类 | PascalCase | `UserService` |
| 函数 | camelCase | `getUserById` |
| 常量 | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| 接口 | PascalCase + 前缀 | `IUserRepository` |

### 9.3 依赖注入

```typescript
// 定义接口
interface IUserRepository {
  findById(id: string): Promise<User | null>;
}

// 实现
@Injectable()
class UserRepository implements IUserRepository {
  constructor(private readonly db: DatabaseService) {}

  async findById(id: string): Promise<User | null> {
    return this.db.users.findUnique({ where: { id } });
  }
}

// 服务
@Injectable()
class UserService {
  constructor(
    @Inject('IUserRepository')
    private readonly userRepo: IUserRepository
  ) {}
}
```

---

## 10. 测试标准

### 10.1 测试类型

| 类型 | 覆盖目标 | 重点 |
|------|----------|------|
| 单元测试 | 80% | 单个函数/方法 |
| 集成测试 | 60% | API 端点、服务 |
| E2E 测试 | 关键路径 | 用户流程 |

### 10.2 测试结构

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('应该用有效数据创建用户', async () => {
      // 准备
      const dto = { email: 'test@example.com', password: 'password123' };

      // 执行
      const result = await userService.createUser(dto);

      // 断言
      expect(result.email).toBe(dto.email);
    });

    it('应该对无效邮箱抛出校验错误', async () => {
      // ...
    });
  });
});
```

### 10.3 测试数据库

- 使用独立的测试数据库
- 测试间重置
- 使用工厂生成测试数据

---

## 11. 性能标准

### 11.1 响应时间目标

| 端点类型 | P50 | P95 | P99 |
|----------|-----|-----|-----|
| 读取（简单） | 50ms | 100ms | 200ms |
| 读取（复杂） | 100ms | 300ms | 500ms |
| 写入 | 100ms | 300ms | 500ms |
| 批量 | 500ms | 1s | 2s |

### 11.2 数据库查询标准

| 规则 | 描述 |
|------|------|
| N+1 预防 | 使用预加载或批处理 |
| 索引使用 | 所有查询使用索引 |
| 分页 | 列表端点必须分页 |
| 连接池 | 使用连接池 |

### 11.3 异步处理

| 操作类型 | 策略 |
|----------|------|
| 邮件发送 | 队列（后台） |
| 文件处理 | 队列（后台） |
| 报表生成 | 队列 + 轮询 |
| 实时更新 | WebSocket |

---

## 12. 安全检查清单

### 12.1 输入安全

- [ ] 所有输入已校验和清理
- [ ] SQL 注入防护（参数化查询）
- [ ] XSS 防护（输出编码）
- [ ] CSRF 防护（状态变更操作）
- [ ] 文件上传校验（类型、大小、内容）

### 12.2 认证安全

- [ ] 密码使用 bcrypt/scrypt/argon2 哈希
- [ ] 认证端点限流
- [ ] 安全令牌存储（httpOnly cookies）
- [ ] 刷新时令牌轮换

### 12.3 数据安全

- [ ] 敏感数据静态加密
- [ ] PII 字段日志脱敏
- [ ] 敏感操作审计日志
- [ ] 数据保留策略已实现

---

## 校验清单

- [ ] API 设计遵循 REST 规范
- [ ] 错误响应一致
- [ ] 认证正确实现
- [ ] 授权已强制执行
- [ ] 输入校验完整
- [ ] 日志结构化且完整
- [ ] 限流已配置
- [ ] 代码结构有序
- [ ] 测试覆盖关键路径
- [ ] 安全检查清单完成
