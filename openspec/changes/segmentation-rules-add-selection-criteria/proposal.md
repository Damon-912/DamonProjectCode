## Why

ADRG细分规则表(HB_DRGSegmentationRules)当前缺少入组规则(SelectionCriteria)字段，无法记录每条细分规则的具体入组判定条件。入组规则是DRG分组算法中决定病例是否满足细分条件的关键配置，缺少该字段导致细分规则配置不完整，影响分组算法的精确执行。

## What Changes

- 在 `User.HBDRGSegmentationRules` 持久化类中新增 `SelectionCriteria` 属性（%String类型，SQL字段名 SelectionCriteria）
- 更新Storage映射，增加SelectionCriteria数据节点
- 后端查询接口(02010044)返回结果增加 selectionCriteria 字段
- 后端保存接口(02010045)参数增加 selectionCriteria 字段
- 前端API类型定义 `HBDRGSegmentationRulesItem` 增加 selectionCriteria 字段
- 前端API类型定义 `SaveHBDRGSegmentationRulesParams` 增加 selectionCriteria 字段
- 前端页面表格增加"入组规则"列
- 前端编辑弹窗增加"入组规则"输入框

## Capabilities

### New Capabilities

### Modified Capabilities
- `adrg-segmentation-rules-crud`: 增加SelectionCriteria(入组规则)字段，影响数据库表结构、后端接口数据结构、前端展示和编辑

## Impact

- **数据库**: 修改 `User.HBDRGSegmentationRules` 类，新增 SelectionCriteria 属性和Storage映射
- **后端**: 修改 `src/src/DRG/BasicData/DRGRSegmentationRules.cls` 的查询和保存方法
- **前端**: 修改 `frontend/src/api/basicData.ts` 类型定义、`frontend/src/pages/BasicData/DRGSegmentationRules.tsx` 页面
