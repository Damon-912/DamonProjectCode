## ADDED Requirements

### Requirement: 系统支持费用过低预警规则类型
系统 SHALL 支持规则类型编码 `06`（费用过低），当医疗费用低于DRG支付标准设定比例时触发预警。

#### Scenario: 创建费用过低预警规则
- **WHEN** 用户在预警规则配置页面选择规则类型为"费用过低"（编码06）
- **THEN** 系统保存该规则，规则类型字段值为"06"

#### Scenario: 费用过低规则触发预警
- **WHEN** 病例费用低于DRG支付标准的 (100-阈值)% 时
- **THEN** 系统生成预警记录，WarningType 字段值为"06"

#### Scenario: 费用过低规则不触发预警
- **WHEN** 病例费用不低于DRG支付标准的 (100-阈值)% 时
- **THEN** 系统不触发该规则预警

### Requirement: 前端规则类型选项包含费用过低
前端预警规则页面的规则类型下拉选项 SHALL 包含"费用过低"选项，值为"06"。

#### Scenario: 搜索表单显示费用过低选项
- **WHEN** 用户在搜索表单中点击规则类型下拉框
- **THEN** 下拉选项列表包含"费用过低"（值06）选项

#### Scenario: 编辑弹窗显示费用过低选项
- **WHEN** 用户在新增/编辑规则弹窗中选择规则类型
- **THEN** 下拉选项列表包含"费用过低"（值06）选项

### Requirement: 前端预警记录筛选支持费用过低类型
前端预警记录页面和预警监控中心的规则类型筛选 SHALL 包含"费用过低"选项。

#### Scenario: 预警记录页筛选费用过低类型
- **WHEN** 用户在预警记录页面的规则类型筛选中选择"费用过低"
- **THEN** 列表仅显示WarningType为"06"的预警记录

### Requirement: 预警预览根据规则类型显示正确方向
前端规则预览弹窗的预警示例描述 SHALL 根据规则类型正确显示"超过"或"低于"方向词。

#### Scenario: 费用超支类型预览显示超过
- **WHEN** 预览规则类型为01(费用超支)、03(高倍率)或05(分解住院)
- **THEN** 预警示例描述显示"当病例费用超过DRG支付标准的..."

#### Scenario: 费用过低类型预览显示低于
- **WHEN** 预览规则类型为02(低倍率)或06(费用过低)
- **THEN** 预警示例描述显示"当病例费用低于DRG支付标准的..."

### Requirement: 后端统计接口支持费用过低类型
后端 `QueryWarningStats` 方法的类型统计映射 SHALL 包含 `06=费用过低` 的映射。

#### Scenario: 统计结果包含费用过低类型
- **WHEN** 预警记录中存在 WarningType="06" 的记录
- **THEN** 统计结果的 typeStats 数组中包含 type="费用过低" 的统计项

### Requirement: 前端类型统计支持费用过低
前端 `WarningStats` 类型定义的 `typeStats` 字段 SHALL 支持 `'06'` 属性。

#### Scenario: 类型统计渲染费用过低
- **WHEN** 预警统计数据返回包含'06'类型的统计
- **THEN** 前端正确渲染"费用过低"类型统计卡片或图表

### Requirement: 预警消息根据规则类型生成差异化描述
后端 `GenerateWarningMessage` 方法 SHALL 接受 `ruleType` 参数，根据不同规则类型生成具有业务语义前缀和差异化措辞的预警消息。

#### Scenario: 费用超支类型生成超支预警消息
- **WHEN** 调用 `GenerateWarningMessage` 时 ruleType="01"
- **THEN** 生成的预警消息以"费用超支预警"为前缀，包含费用超出标准金额的描述

#### Scenario: 费用过低类型生成过低预警消息
- **WHEN** 调用 `GenerateWarningMessage` 时 ruleType="06"
- **THEN** 生成的预警消息以"费用过低预警"为前缀，包含费用低于标准金额的描述

#### Scenario: 低倍率类型生成低倍率预警消息
- **WHEN** 调用 `GenerateWarningMessage` 时 ruleType="02"
- **THEN** 生成的预警消息以"低倍率预警"为前缀，包含费用低于标准金额的描述

#### Scenario: 高倍率类型生成高倍率预警消息
- **WHEN** 调用 `GenerateWarningMessage` 时 ruleType="03"
- **THEN** 生成的预警消息以"高倍率预警"为前缀，包含费用超出标准金额的描述

#### Scenario: 编码异常类型生成编码异常预警消息
- **WHEN** 调用 `GenerateWarningMessage` 时 ruleType="04"
- **THEN** 生成的预警消息以"编码异常预警"为前缀，仅包含费用总额信息

#### Scenario: 分解住院类型生成分解住院预警消息
- **WHEN** 调用 `GenerateWarningMessage` 时 ruleType="05"
- **THEN** 生成的预警消息以"分解住院预警"为前缀，仅包含费用总额信息

#### Scenario: AddWarningRecord调用时传递ruleType
- **WHEN** `AddWarningRecord` 方法触发预警并调用 `GenerateWarningMessage`
- **THEN** 调用时传入当前规则的 `ruleTypeVal` 参数，使消息包含正确的业务语义
