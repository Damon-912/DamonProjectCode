## Why

DIP（按病种分值付费）核心算法配置是医保控费系统的关键基础数据。目前系统已有 DRG 算法配置功能，但缺少对应的 DIP 算法配置管理模块。为了完善 DIP 付费模式的支持，需要根据已有的 `User.HBDIPCoreAlgorithmData` 表类开发完整的前后端功能，包括查询、新增、编辑、删除等操作。

## What Changes

- **新增前端页面**: 创建 DIP 核心算法配置管理页面，包含列表查询、新增/编辑弹窗、删除确认功能
- **扩展后端业务类**: 在已有的 `src.DRG.BasicData.CoreAlgorithm` 类中添加 DIP 算法配置的查询、保存、删除方法
- **采用 operatetable 模式**: 后端更新/删除操作统一使用 `src.util.operatetable` 工具类，保持与现有功能一致
- **前端 API 集成**: 在 `basicData.ts` 中添加 DIP 算法配置相关的类型定义和 API 函数
- **菜单路由配置**: 在 App.tsx 和 MenuContext.tsx 中添加 DIP 算法配置菜单项

## Capabilities

### New Capabilities
- `dip-core-algorithm-query`: DIP 核心算法配置查询功能（列表分页查询）
- `dip-core-algorithm-save`: DIP 核心算法配置保存功能（新增/更新）
- `dip-core-algorithm-delete`: DIP 核心算法配置删除功能

### Modified Capabilities
- 无（此变更为全新功能，不涉及现有功能修改）

## Impact

- **前端**: 
  - 新增页面文件 `frontend/src/pages/BasicData/DIPCoreAlgorithmConfig.tsx`
  - 修改 `frontend/src/api/basicData.ts` 添加 API 定义
  - 修改 `frontend/src/App.tsx` 添加路由映射
  - 修改 `frontend/src/context/MenuContext.tsx` 添加菜单项
  
- **后端**:
  - 在现有 `src/src/DRG/BasicData/CoreAlgorithm.cls` 中添加三个 DIP 接口方法（查询、保存、删除）
  - 参考 `HBDIPCoreAlgorithmData` 表结构和现有 DRG 方法实现方式

- **数据库**: 使用现有 `User.HBDIPCoreAlgorithmData` 表，无需修改表结构
