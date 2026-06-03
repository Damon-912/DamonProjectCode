## Why

DRG核心算法配置目前仅包含基准点数、预估点值、病组差异系数和支付标准四个数值字段，缺少医保控费预警所需的高倍率、低倍率和权重参数。这些参数是费用预警判定的关键依据——高倍率用于判定费用异常偏高病例、低倍率用于判定费用异常偏低病例、权重用于病组间比较和费用分摊。当前系统无法针对DRG病组进行基于倍率的精细化费用预警，急需补充这三项数值字段。

## What Changes

- **数据库表结构**：`HB_DRGCoreAlgorithmData` 表新增 `HighMultiplier`（高倍率）、`LowMultiplier`（低倍率）、`Weight`（权重）三个数值型字段
- **后端API接口**：`src.DRG.BasicData.CoreAlgorithm` 类的保存、查询、删除、导入预览、导入确认、模板下载方法全部支持新字段
- **前端界面**：DRG核心算法配置页面的表格列、新增/编辑表单、导入预览均增加对应的输入和展示
- **前端类型定义**：`CoreAlgorithmItem`、`SaveCoreAlgorithmParams` 等类型增加新字段

## Capabilities

### New Capabilities
- `drg-algorithm-multiplier-weight`: DRG核心算法配置新增高倍率、低倍率、权重三个数值字段，支持在配置表中存储和展示这些参数，用于医保控费预警的费用倍率判定。

### Modified Capabilities
<!-- 本次变更仅新增字段，不修改已有功能的规格级别行为，无需修改现有specs -->

## Impact

- **数据库**：`User.HBDRGCoreAlgorithmData` 表结构变更，需新增3列（SqlColumnNumber 23-25），`Storage Default` 块需同步更新
- **后端API**：`src/src/DRG/BasicData/CoreAlgorithm.cls`（DRG相关方法）需修改
- **前端API层**：`frontend/src/api/basicData.ts` 类型定义和接口需更新
- **前端页面**：`frontend/src/pages/BasicData/DRGCoreAlgorithmConfig.tsx` 表格列、表单、导入功能需更新
- **无破坏性变更**：三个新字段均为可选（非Required），不影响已有数据和已有功能
