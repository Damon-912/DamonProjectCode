## Why

前端调用后端 IRIS 接口服务的入参结构需要统一规范，添加 session 数组对象以支持用户身份认证和权限控制。当前调用方式缺少统一的会话管理机制，需要更新为标准化结构以便后续扩展和维护。

## What Changes

- **BREAKING**: 更新 `invoke` 函数签名，调整参数顺序为 `(code, params, session?, pagination?)`
- **BREAKING**: 请求体结构新增 `session` 数组作为固定字段
- 新增 `SessionInfo` 接口定义，规范会话信息字段
- 新增 `getDefaultSession` 函数，支持从 localStorage 读取会话信息
- 更新所有 API 模块中的调用方式，适配新的参数顺序

## Capabilities

### New Capabilities
- `api-request-session`: 定义前端接口调用时 session 信息的标准结构和传递方式

### Modified Capabilities
- `api-request-structure`: 更新接口调用入参结构规范，添加 session 支持并调整参数顺序

## Impact

- 所有前端 API 调用代码 (`basicData.ts`, `system.ts` 等) 需要更新参数顺序
- 请求体结构变化影响后端接口解析（后端需兼容新结构）
- 页面组件中直接使用 `invoke` 的调用需要检查参数顺序
- 需要确保 localStorage 中存储的 session 数据格式正确
