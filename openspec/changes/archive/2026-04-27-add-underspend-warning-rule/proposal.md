## Why

当前预警规则类型中只有"费用超支"(01)针对费用偏高场景，而"低倍率"(02)和"高倍率"(03)仅基于倍率判断。缺少专门的"费用过低"预警规则类型，无法对医疗费用远低于DRG支付标准的情况进行有效监控。费用过低可能暗示医疗服务不足、推诿重症患者或编码高靠等问题，需要分别针对费用盈亏情况进行差异化预警。

## What Changes

- 新增规则类型编码 `06`（费用过低），用于识别医疗费用明显低于DRG支付标准的病例
- 前端预警规则页面（Rules.tsx）在规则类型下拉框中增加"费用过低"选项
- 前端预警记录页面（Records.tsx）和预警监控中心（Center.tsx）的规则类型筛选中增加"费用过低"选项
- 后端 `CheckWarningTrigger` 方法增加 `ruleType="06"` 的触发判断逻辑（费用低于DRG支付标准某比例时触发）
- 后端 `QueryWarningStats` 方法的类型统计映射中增加 `06=费用过低`
- 后端 `GenerateWarningMessage` 方法增加 `ruleType` 参数，根据不同预警类型生成差异化语义的预警消息描述
- 前端预览弹窗中的预警示例描述需要根据规则类型区分"超过"和"低于"
- 前端 API 类型定义 `WarningStats.typeStats` 中增加 `'06'` 类型

## Capabilities

### New Capabilities
- `underspend-warning-rule`: 费用过低预警规则类型（06），包括后端触发逻辑、前端UI选项和统计展示的完整支持

### Modified Capabilities
- `warning-message-generation`: 预警消息生成逻辑（GenerateWarningMessage），从纯数值描述改为根据规则类型生成差异化语义消息

## Impact

- **前端文件**: `Rules.tsx`（规则类型选项、预览示例）、`Records.tsx`（筛选选项）、`Center.tsx`（如有规则类型筛选）
- **前端类型**: `warning.ts` 中 `WarningStats.typeStats` 类型定义
- **后端文件**: `src/DRG/Warning.cls` 中 `CheckWarningTrigger`、`QueryWarningStats` 和 `GenerateWarningMessage` 方法
- **数据库**: 无表结构变更，RuleType 字段为字符串类型，新增编码值 `06` 天然兼容
- **接口**: 无新增接口，仅修改现有接口的枚举值范围
