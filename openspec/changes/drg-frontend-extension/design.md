## Context

### 背景
后端DRG/DIP分组服务已完成开发，包括：
- 病案首页查询/保存接口（Code: 02010027, 02010026）
- 结算清单查询/保存接口（Code: 02010031, 02010030）
- DRG分组接口（Code: 02010001）
- 分组记录查询/保存（Code: 02010036, 02010035）
- CB_MapInterface表存储接口映射关系

### 当前状态
- 数据库表结构：BS_DRGMedInsuMedicalRecord、BS_DRGGroupRecord等
- 接口规范：统一返回DynamicObject，包含errorCode、errorMessage、result
- 前端缺失：尚无用户界面，需基于React+Ant Design开发

### 约束条件
- 必须遵循现有后端接口规范（Code编号、参数格式、返回结构）
- 新接口需按CB_MapInterface表规范注册
- 新表名需按BS_前缀规范命名
- 前端需与后端接口字段命名保持一致（驼峰式）

### 利益相关方
- 医保办：需要费用监控和预警功能
- 临床科室：需要分组结果查询界面
- 病案室：需要质控检查工具
- 系统管理员：需要接口和菜单配置功能

## Goals / Non-Goals

**Goals:**
- 实现完整的前端菜单体系（DRG工作台、预警中心、盈亏分析等）
- 基于已有后端接口开发前端页面
- 扩展预警、盈亏、质控等业务功能的后端接口
- 按CB_MapInterface规范注册所有新接口
- 按BS_表结构规范创建新数据表

**Non-Goals:**
- 不修改已有病案查询/保存核心业务逻辑
- 不修改DRG分组算法
- 不直接对接HIS（通过后端转发）

## Decisions

### 1. 前端架构设计
**决策**: 采用React 18 + Ant Design 5 + React Router 6

**理由**:
- Ant Design提供丰富的企业级组件（表格、表单、图表）
- 与后端接口通过Axios交互，保持松耦合
- 支持响应式布局，适配不同屏幕

**替代方案考虑**: Vue 3 + Element Plus
- 拒绝原因：团队React技术栈更熟悉

### 2. 接口Code编号规则
**决策**: 新接口按0201xxxx编号，与已有0201系列保持一致

**分配规则**:
- 020100xx：病案/分组基础接口（已有）
- 020101xx：预警相关接口（新增）
- 020102xx：盈亏分析接口（新增）
- 020103xx：病案质控接口（新增）
- 020104xx：系统管理接口（新增）

### 3. 前后端数据字段映射
**决策**: 前端字段使用驼峰命名，与后端DynamicObject字段一致

**示例**:
- 后端：`dataObj.mdtrtId = result.%Get("MdtrtId")`
- 前端：`const { mdtrtId, psnName } = record;`

### 4. 菜单权限存储
**决策**: 菜单和权限数据存储在BS_DRGSystemMenu和BS_DRGUserRight表

**理由**:
- 与现有表结构规范一致
- 支持动态菜单配置
- 便于权限控制

## Risks / Trade-offs

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 前后端字段命名不一致 | 高 | 建立字段映射文档，统一使用驼峰命名 |
| 接口Code冲突 | 高 | 按020101xx-020104xx范围分配，预留足够空间 |
| 性能问题（大数据量查询） | 中 | 使用分页查询，添加loading状态 |
| 浏览器兼容性 | 低 | 使用Ant Design 5，支持现代浏览器 |

## Migration Plan

### 部署步骤
1. **数据库初始化**
   - 创建BS_DRGWarningRule、BS_DRGWarningRecord等表
   - 初始化CB_MapInterface新接口记录
   - 初始化BS_DRGSystemMenu菜单数据

2. **后端部署**
   - 部署新增预警、盈亏、质控服务类
   - 验证接口可通过CB_MapInterface正确路由

3. **前端部署**
   - 构建React应用
   - 配置Nginx反向代理
   - 部署到静态资源服务器

### 回滚策略
- 数据库变更使用事务包装
- 前端采用蓝绿部署
- 保留旧版本接口兼容

## Open Questions

1. 是否需要支持多院区数据隔离？
2. 前端是否需要支持暗黑模式？
3. 报表导出是否需要支持PDF格式？
4. 是否需要移动端适配？
