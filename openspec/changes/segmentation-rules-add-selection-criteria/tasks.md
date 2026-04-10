## 1. 数据库表结构修改

- [x] 1.1 在 `User.HBDRGSegmentationRules.cls` 中新增 `SelectionCriteria` 属性（%String类型，非必填，SqlColumnNumber=9），后续系统字段SqlColumnNumber顺延(UpdateDate=10,UpdateTime=11,UpdateUserDr=12)
- [x] 1.2 更新Storage映射，在SegmentationFlag(Value name=8)之后增加SelectionCriteria(Value name=9)，后续系统字段节点顺延

## 2. 后端接口服务修改

- [x] 2.1 修改 `DRGRSegmentationRules.cls` 的 GetDRGSegmentationRulesList 方法：SQL查询增加 SelectionCriteria 字段，返回 dataObj 增加 selectionCriteria 属性
- [x] 2.2 修改 `DRGRSegmentationRules.cls` 的 SaveDRGSegmentationRules 方法：读取 params.selectionCriteria 参数，dataObj 增加 SelectionCriteria 属性

## 3. 前端API类型修改

- [x] 3.1 在 `basicData.ts` 的 `HBDRGSegmentationRulesItem` 接口中增加 `selectionCriteria: string` 字段
- [x] 3.2 在 `basicData.ts` 的 `SaveHBDRGSegmentationRulesParams` 接口中增加 `selectionCriteria?: string` 字段

## 4. 前端页面修改

- [x] 4.1 在 `DRGSegmentationRules.tsx` 的表格列定义中，在"细分标志"列之后增加"入组规则"列（dataIndex=selectionCriteria, width=200, ellipsis）
- [x] 4.2 在 `DRGSegmentationRules.tsx` 的编辑弹窗中，增加"入组规则"输入框（非必填）
