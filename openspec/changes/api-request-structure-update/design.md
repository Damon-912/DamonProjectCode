## Context

当前前端调用后端 IRIS 接口服务的入参结构缺少统一的会话管理机制。随着系统功能扩展，需要在每次 API 请求中携带用户身份和权限信息，以便后端进行权限验证和审计记录。

现有的 `invoke` 函数签名是 `(code, params, pagination?)`，其中 `pagination` 作为可选的第三个参数。这种设计导致：
1. 无法传递会话信息
2. 参数顺序不够清晰（分页和会话混在一起）

## Goals / Non-Goals

**Goals:**
- 标准化 API 请求结构，添加 `session` 数组作为固定字段
- 更新 `invoke` 函数签名，使参数顺序更清晰：code → params → session → pagination
- 提供 `SessionInfo` TypeScript 接口定义
- 实现 `getDefaultSession` 函数，自动从 localStorage 读取会话信息
- 更新所有 API 模块调用，适配新的参数顺序

**Non-Goals:**
- 修改后端 IRIS 接口服务代码
- 修改页面组件中的业务逻辑
- 添加新的 API 接口
- 修改身份认证流程

## Decisions

### 1. 参数顺序设计
**决策**: `invoke(code, params?, session?, pagination?)`

**理由**:
- `code` 和 `params` 是每次调用必需的
- `session` 虽然是固定的，但允许调用时覆盖（如切换用户场景）
- `pagination` 只有查询接口使用，放在最后最合理

**替代方案考虑**:
- 使用对象参数：`invoke({ code, params, session, pagination })` - 过于冗长
- 保持原有顺序：`invoke(code, params, pagination?, session?)` - 不符合使用频率

### 2. Session 存储位置
**决策**: 从 localStorage 读取默认 session

**理由**:
- localStorage 可以跨页面保持会话
- 不需要每次调用都传入 session
- 与现有前端状态管理方式一致

**替代方案考虑**:
- 使用 React Context - 需要包裹组件，侵入性大
- 使用全局变量 - 不利于测试和维护

### 3. Session 字段设计
**决策**: 包含 18 个字段，覆盖用户、科室、医院、语言等信息

**字段列表**:
```typescript
interface SessionInfo {
  userID: string;
  userCode: string;
  userName: string;
  locID: string;
  locDesc: string;
  groupID: string;
  groupDesc: string;
  hospID: string;
  hospCode: string;
  hospDesc: string;
  langID: number;
  langDesc: string;
  changeFlag: string;
  changeDesc: string;
  defaultMenuType: string;
  mainInterface: string;
  path: string;
  sessionID: string;
}
```

**理由**:
- 字段来源于云 HIS 系统的标准会话结构
- 与后端 IRIS 系统的 User 对象结构对应
- 足够支持权限控制和审计需求

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| [风险] 后端接口不兼容新结构 | → 后端需要同步更新，在接收端兼容新旧两种结构 |
| [风险] localStorage 中无 session 数据 | → `getDefaultSession` 返回空对象，不会报错 |
| [风险] 现有调用代码需要修改 | → 已通过批量替换完成，非分页调用无需修改 |
| [风险] session 数据格式不一致 | → 使用 TypeScript 接口强制类型检查 |

## Migration Plan

### 前端更新步骤（已完成）
1. ✅ 更新 `request.ts` - 添加 SessionInfo 接口和 getDefaultSession 函数
2. ✅ 更新 `invoke` 函数签名
3. ✅ 更新 `basicData.ts` - 9个查询接口添加 `undefined` 作为 session 参数
4. ✅ 更新 `system.ts` - 1个查询接口添加 `undefined` 作为 session 参数

### 后端兼容要求
- IRIS 接口服务需要更新请求体解析逻辑
- 从 `session` 数组中提取用户信息进行权限验证
- 保持向后兼容，处理无 session 字段的旧请求

### 验证步骤
1. 测试非分页接口调用（如保存、删除）
2. 测试分页接口调用（如查询列表）
3. 验证 session 数据是否正确传递
4. 验证 localStorage 读取逻辑

## Open Questions

1. **Session 过期处理**: 当 session 过期时，是否需要在前端自动刷新或跳转登录页？
2. **Session 同步**: 多标签页场景下，session 变更如何同步？
3. **敏感信息**: session 中是否包含敏感信息，需要加密存储？
