# Proposal: 新增基础数据管理模块

## 变更名称
`add-basic-data-management`

## 背景与动机

当前前端导航栏的菜单结构中，缺少一个统一管理DRG基础数据的功能模块。以下功能分散在不同位置或尚不存在：

1. **DRG基础数据维护** - 标准库管理下的基础数据维护功能，目前状态为"待开发"
2. **ICD编码映射** - ICD编码映射关系管理，目前状态为"待开发"
3. **ICD编码查询** - ICD-10/ICD-9-CM-3编码库查询，目前状态为"待开发"
4. **ADRG分组规则维护** - ADRG分组规则配置，目前状态为"待开发"
5. **接口映射管理** - 当前在"系统管理"下，与系统管理关联度不高，应归入基础数据管理

这些功能都属于DRG分组引擎的基础配置数据，统一放在"基础数据管理"模块下更符合业务逻辑。

## 变更目标

1. 在左侧导航栏中新增 **"基础数据管理"** 一级菜单
2. 包含以下子菜单：
   - DRG基础数据维护
   - ICD编码映射
   - ICD编码查询
   - ADRG分组规则维护
   - 接口映射管理（从"系统管理"移入）
3. 将"系统管理"下的"接口服务配置"和"接口日志"移至"基础数据管理"模块
4. 创建各子菜单对应的前端页面组件（骨架页面）

## 影响范围

### 修改文件
- `frontend/src/App.tsx` - 菜单配置和路由

### 新增文件
- `frontend/src/pages/BasicData/BasicDataMaintenance.tsx` - DRG基础数据维护
- `frontend/src/pages/BasicData/ICDMapping.tsx` - ICD编码映射
- `frontend/src/pages/BasicData/ICDQuery.tsx` - ICD编码查询
- `frontend/src/pages/BasicData/ADRGRuleMaintenance.tsx` - ADRG分组规则维护
- `frontend/src/pages/BasicData/InterfaceMapping.tsx` - 接口映射管理（复用或迁移现有组件）

### 删除/移除
- `App.tsx` 中系统管理下的 `system-api` 和 `system-logs` 菜单项移至基础数据管理

## 约束条件

- 菜单顺序：放在"分组规则"之前、"系统管理"之后
- 使用 Ant Design 图标 `DatabaseOutlined` 或 `ContainerOutlined` 作为模块图标
- 所有字段命名使用小驼峰(camelCase)
- 接口调用遵循项目统一请求规范
