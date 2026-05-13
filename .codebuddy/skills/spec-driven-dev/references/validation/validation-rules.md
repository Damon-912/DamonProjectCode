# 校验规则

> 半自动文档校验的规则引擎规范

---

## 1. 规则类别

| 类别 | 优先级 | 自动检查 | 人工审查 |
|------|--------|----------|----------|
| 严重 | 高 | 是 | 失败时 |
| 警告 | 中 | 是 | 推荐 |
| 信息 | 低 | 可选 | 可选 |

---

## 2. 需求追溯规则

### RULE-RT-001：所有需求有模块分配

**类型：** 严重
**自动检查：** 是

```
对于 requirements-spec.md 中的每个需求 FR-*：
  在任意 module-design.md 的 requirements_mapping 中查找 requirement_id
  如果未找到：
    报告错误："需求 {id} 未分配到任何模块"
```

**通过条件：** 所有 FR-* 编号至少出现在一个模块设计中

### RULE-RT-002：所有非功能需求在规范中已处理

**类型：** 严重
**自动检查：** 是

```
对于 requirements-spec.md 中的每个 NFR-*：
  在以下位置查找 nfr_id 或描述：
    - architecture-spec.md
    - backend-spec.md
    - ui-ux-spec.md（用于 UX 非功能需求）
  如果未找到：
    报告警告："非功能需求 {id} 未显式处理"
```

**通过条件：** 每个非功能需求在相关规范中被引用或处理

### RULE-RT-003：无孤立模块

**类型：** 警告
**自动检查：** 是

```
对于 module-planning.md 中的每个模块：
  在 module-design.md 文件中查找 module_id
  如果未找到：
    报告警告："模块 {id} 无详细设计"
```

---

## 3. API 一致性规则

### RULE-API-001：端点命名约定

**类型：** 严重
**自动检查：** 是

```
对于 module-design.md 文件中的每个端点：
  验证：
    - 路径以 /api/v{N}/ 开头
    - 使用复数名词（如 /users 而非 /user）
    - 无尾部斜杠
    - 多词路径使用 kebab-case
  如果无效：
    报告错误："端点 {path} 违反命名约定"
```

**约定：**
```
✓ /api/v1/users
✓ /api/v1/order-items
✗ /api/user
✗ /api/v1/Users
✗ /api/v1/order_items
```

### RULE-API-002：响应格式一致性

**类型：** 严重
**自动检查：** 是

```
对于 module-design.md 中的每个端点响应：
  验证响应结构与 backend-spec.md 匹配：
    - 有 "data" 或 "error" 根键
    - 有带 requestId 和 timestamp 的 "meta"
    - 错误格式有 "code"、"message"、"details"
  如果无效：
    报告错误："端点 {endpoint} 响应格式不一致"
```

### RULE-API-003：HTTP 状态码使用

**类型：** 警告
**自动检查：** 是

```
对于 module-design.md 中的每个端点：
  验证状态码与 backend-spec.md 标准匹配：
    - 200 用于 GET 成功
    - 201 用于 POST 创建成功
    - 204 用于 DELETE 成功
    - 400 用于校验错误
    - 401 用于认证错误
    - 403 用于权限错误
    - 404 用于未找到
    - 500 用于服务器错误
  如果非标准：
    报告警告："端点 {endpoint} 使用非标准状态码 {code}"
```

### RULE-API-004：错误码前缀一致性

**类型：** 警告
**自动检查：** 是

```
对于 module-design.md 中的每个错误码：
  验证前缀与类别匹配：
    - AUTH_* 用于认证错误
    - PERM_* 用于授权错误
    - VAL_* 用于校验错误
    - RES_* 用于资源错误
    - SYS_* 用于系统错误
  如果前缀无效：
    报告警告："错误码 {code} 前缀不一致"
```

---

## 4. 数据模型规则

### RULE-DM-001：实体-表映射

**类型：** 严重
**自动检查：** 是

```
对于 module-design.md 文件中的每个实体：
  在 database-spec.md 中查找对应表
  如果未找到：
    报告错误："实体 {name} 无数据库表定义"
```

### RULE-DM-002：字段类型兼容性

**类型：** 严重
**自动检查：** 是

```
对于 module-design.md 中的每个实体字段：
  在 database-spec.md 表中查找列
  验证类型兼容性：
    - string ↔ VARCHAR/TEXT
    - number ↔ INTEGER/DECIMAL
    - boolean ↔ BOOLEAN
    - Date ↔ TIMESTAMP/TIMESTAMPTZ
    - object ↔ JSONB/JSON
  如果不兼容：
    报告错误："{entity}.{field} 类型不匹配"
```

### RULE-DM-003：必填字段对齐

**类型：** 严重
**自动检查：** 是

```
对于每个实体字段：
  如果字段在 module-design.md 中为必填：
    验证列在 database-spec.md 中有 NOT NULL
  如果字段在 module-design.md 中为可选：
    验证列为 NULLABLE 或有 DEFAULT
  如果不匹配：
    报告错误："{entity}.{field} 必填状态不匹配"
```

### RULE-DM-004：关系完整性

**类型：** 警告
**自动检查：** 是

```
对于 module-design.md 中的每个关系：
  在 database-spec.md 中查找对应外键
  如果未找到：
    报告警告："关系 {name} 无外键定义"
  验证：
    - 指定了 ON DELETE 操作
    - 指定了 ON UPDATE 操作
```

---

## 5. UI/UX 规则

### RULE-UI-001：组件令牌使用

**类型：** 警告
**自动检查：** 部分（需要设计文件解析）

```
对于 module-design.md 中的每个组件规范：
  验证使用 ui-ux-spec.md 中的设计令牌：
    - 颜色使用 --color-* 令牌
    - 间距使用 --space-* 令牌
    - 排版使用 --text-* 令牌
  如果硬编码值：
    报告警告："{component} 中有硬编码值"
```

### RULE-UI-002：无障碍要求

**类型：** 严重
**自动检查：** 部分

```
对于 module-design.md 中的每个交互元素：
  验证：
    - 有无障碍标签
    - 定义了焦点状态
    - 错误状态可访问
  如果缺失：
    报告错误："{element} 无障碍不完整"
```

### RULE-UI-003：响应式断点

**类型：** 警告
**自动检查：** 是

```
对于 module-design.md 中的每个屏幕/布局：
  验证断点与 ui-ux-spec.md 匹配：
    - sm: 640px
    - md: 768px
    - lg: 1024px
    - xl: 1280px
  如果非标准：
    报告警告："{screen} 使用非标准断点"
```

---

## 6. 安全规则

### RULE-SEC-001：认证一致性

**类型：** 严重
**自动检查：** 是

```
对于 module-design.md 中的每个端点：
  如果需要认证：
    验证方法与 backend-spec.md 匹配：
      - JWT Bearer 令牌
      - 令牌验证方式
  如果不一致：
    报告错误："端点 {endpoint} 认证方法不一致"
```

### RULE-SEC-002：授权规范

**类型：** 严重
**自动检查：** 是

```
对于 module-design.md 中的每个端点：
  验证授权已指定：
    - 所需角色
    - 所需权限
    - 或显式标记为"公开"访问
  如果未指定：
    报告错误："端点 {endpoint} 未指定授权"
```

### RULE-SEC-003：PII 处理

**类型：** 严重
**自动检查：** 部分

```
对于 module-design.md 中标记为 PII 的每个字段：
  在 database-spec.md 中验证：
    - 指定了加密 或
    - 定义了访问控制
  如果未找到：
    报告错误："PII 字段 {field} 缺少保护规范"
```

---

## 7. 命名规则

### RULE-NAME-001：实体名称一致性

**类型：** 警告
**自动检查：** 是

```
对于每个实体：
  从以下位置提取名称：
    - requirements-spec.md（术语表）
    - module-design.md（实体）
    - database-spec.md（表）
  如果名称不同（排除大小写/复数形式）：
    报告警告："实体命名不一致：{variants}"
```

### RULE-NAME-002：状态值一致性

**类型：** 警告
**自动检查：** 是

```
对于每个有状态字段的实体：
  从以下位置提取状态值：
    - module-design.md（业务逻辑）
    - database-spec.md（CHECK 约束）
  如果值不同：
    报告错误："{entity} 状态值不一致"
```

### RULE-NAME-003：字段命名约定

**类型：** 信息
**自动检查：** 是

```
对于每个字段：
  验证命名约定：
    - API/模块设计中使用 camelCase
    - 数据库中使用 snake_case
  如果混合：
    报告信息："字段命名约定：{field}"
```

---

## 8. 完整性规则

### RULE-COMP-001：必需文档章节

**类型：** 严重
**自动检查：** 是

```
对于每种文档类型：
  验证必需章节存在：
    requirements-spec.md：
      - 执行摘要
      - 功能需求
      - 非功能需求
    module-design.md：
      - 需求映射
      - API 契约
      - 数据模型
    database-spec.md：
      - 表定义
      - 索引
      - 约束
  如果缺失：
    报告错误："{document} 缺少必需章节"
```

### RULE-COMP-002：API 文档完整性

**类型：** 警告
**自动检查：** 是

```
对于每个端点：
  验证包含：
    - 描述
    - 请求参数/体 Schema
    - 响应 Schema（成功）
    - 错误响应
    - 认证要求
  如果缺失：
    报告警告："端点 {endpoint} API 文档不完整"
```

---

## 9. 校验严重级别

| 级别 | 描述 | 所需操作 |
|------|------|----------|
| **错误** | 必须在继续前修复 | 阻断校验通过 |
| **警告** | 应该修复，可以继续 | 审查并决定 |
| **信息** | 仅供参考，可选修复 | 仅记录 |

---

## 10. 校验执行顺序

```
1. 解析所有文档
2. 构建交叉引用索引：
   - 需求 → 模块
   - 模块 → 规范
   - 实体 → 表
   - 端点 → 规范
3. 运行严重规则
4. 如果有任何严重失败：
     停止并报告
   否则：
     运行警告规则
5. 运行信息规则
6. 生成报告：
   - 汇总统计
   - 按类别的详细发现
   - 建议操作
```

---

## 11. 校验报告 Schema

```typescript
interface ValidationReport {
  timestamp: string;
  project: string;
  summary: {
    total: number;
    passed: number;
    errors: number;
    warnings: number;
    info: number;
  };
  results: ValidationResult[];
  crossReferences: {
    requirements: RequirementTrace[];
    entities: EntityTrace[];
    endpoints: EndpointTrace[];
  };
}

interface ValidationResult {
  ruleId: string;
  severity: 'error' | 'warning' | 'info';
  status: 'pass' | 'fail';
  message: string;
  location: {
    file: string;
    section?: string;
    line?: number;
  };
  recommendation?: string;
}
```

---

## 12. 扩展规则

添加新校验规则：

1. 定义带唯一 ID 的规则（如 `RULE-CAT-XXX`）
2. 指定类型（严重/警告/信息）
3. 定义检查逻辑（伪代码或正则）
4. 定义通过条件
5. 添加到适当的类别章节
6. 如需要，更新校验执行
