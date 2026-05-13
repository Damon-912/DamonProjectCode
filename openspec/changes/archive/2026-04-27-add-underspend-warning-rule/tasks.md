## 1. 后端：预警触发逻辑

- [x] 1.1 在 `src/DRG/Warning.cls` 的 `CheckWarningTrigger` 方法中增加 `ruleType="06"` 分支，触发逻辑为 `totalFee < drgPayStandard * (100 - thresholdValue) / 100`
- [x] 1.2 在 `src/DRG/Warning.cls` 的 `QueryWarningStats` 方法的类型统计映射中增加 `rs.WarningType="06":"费用过低"`

## 2. 后端：预警消息差异化

- [x] 2.1 修改 `src/DRG/Warning.cls` 的 `GenerateWarningMessage` 方法，增加 `ruleType` 参数，根据不同规则类型生成差异化语义前缀的预警消息（01→费用超支预警，02→低倍率预警，03→高倍率预警，04→编码异常预警，05→分解住院预警，06→费用过低预警）
- [x] 2.2 修改 `AddWarningRecord` 方法中调用 `GenerateWarningMessage` 的位置，增加传入 `ruleTypeVal` 参数

## 3. 前端：预警规则页面（Rules.tsx）

- [x] 3.1 在 `RULE_TYPES` 常量中增加 `'06': '费用过低'`
- [x] 3.2 在搜索表单的规则类型 Select 中增加 `<Option value="06">费用过低</Option>`
- [x] 3.3 在新增/编辑弹窗的规则类型 Select 中增加 `<Option value="06">费用过低</Option>`
- [x] 3.4 修改预览弹窗中的预警示例描述逻辑，将 `ruleType === '02'` 判断改为集合判断 `['02', '06'].includes(ruleType)` 以正确显示"超过"或"低于"

## 4. 前端：预警记录页面（Records.tsx）

- [x] 4.1 在 `RULE_TYPES` 常量中增加 `'06': '费用过低'`
- [x] 4.2 在规则类型筛选 Select 中增加 `<Option value="06">费用过低</Option>`

## 5. 前端：预警监控中心（Center.tsx）

- [x] 5.1 检查并更新 Center.tsx 中的规则类型相关常量和筛选选项，如有遗漏则增加"费用过低"

## 6. 前端：API 类型定义（warning.ts）

- [x] 6.1 在 `WarningStats` 接口的 `typeStats` 字段中增加 `'06'?: number` 属性

## 7. 文档更新

- [x] 7.1 更新 `系统设计/03-费用预警模块设计.md` 中的规则类型表，增加 `06=费用过低` 行
