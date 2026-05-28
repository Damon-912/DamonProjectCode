## MODIFIED Requirements

### Requirement: Device方法改动前备案
系统 SHALL 在修改 `GroupDevice.Device` 方法之前，先将现有 `Device` 方法的完整代码复制为 `DeviceOLD` 方法，作为备案留存，确保紧急情况下可回退。

#### Scenario: DeviceOLD备份成功
- **WHEN** 开始实施Device方法改动
- **THEN** `GroupDevice.cls` 中存在 `DeviceOLD` 类方法，其代码逻辑与改动前的 `Device` 方法完全一致

### Requirement: 分组器Device方法流程
系统 SHALL 在 `GroupDevice.Device` 方法中按以下顺序执行分组流程：

1. Step 1: CheckRules（分组前校验）
2. Step 2: GroupPreMDC（MDC先期分组）
3. Step 3: CheckGroupQY（QY歧义组判断）
4. Step 4: GroupADRG（ADRG分组）
5. **Step 4B: GroupSpecialMatch（特异化分组匹配——新增，仅hospinfo非空时执行）**
6. Step 5: GroupComplication（并发症CC/MCC确认）
7. Step 6: GroupDRG（DRG细分分组）
8. Step 7: 查询DRG算法配置（支付标准、基准点数等）
9. Step 8: 保存分组记录

当入参包含医疗机构信息（hospinfo非空）且 Step 4B 特异化分组匹配成功时，系统 SHALL 直接使用特异化DRG编码，跳过 Step 5（并发症确认）和 Step 6（标准DRG细分分组），直接进入 Step 7（查询DRG算法配置）。

当 hospinfo 为空或 Step 4B 未命中时，系统 SHALL 继续执行原有的 Step 5 → Step 6 标准流程，行为与改造前完全一致。

#### Scenario: 传入医疗机构信息且特异化分组匹配成功，跳过标准流程
- **WHEN** 入参包含医疗机构信息（hospinfo非空），且患者就诊信息命中合肥市2026年特异化分组规则（如CB4→CB46，主诊断H25.900+主手术14.7401）
- **THEN** 系统直接使用DRG编码 "CB46" 作为分组结果，跳过并发症CC/MCC确认和标准DRG细分分组，直接进入算法配置查询

#### Scenario: 未传入医疗机构信息，跳过特异化分组
- **WHEN** 入参中hospinfo为空
- **THEN** 系统不执行特异化分组匹配步骤，依次执行Step 5并发症确认和Step 6标准DRG细分分组

#### Scenario: 特异化分组匹配成功，DRG描述含入组因素
- **WHEN** 特异化分组匹配成功
- **THEN** 返回的DRGDesc包含入组因素说明，格式为"DRG名称（特异化分组：入组因素）"

#### Scenario: 无特异化分组规则，走标准流程
- **WHEN** 当前行政区划/年份无特异化分组配置
- **THEN** 系统行为与改造前完全一致，依次执行Step 5并发症确认和Step 6标准DRG细分分组

#### Scenario: 有特异化规则但未匹配，走标准流程
- **WHEN** 当前行政区划/年份有特异化分组配置，但患者诊断/手术信息不匹配任何规则
- **THEN** 系统继续执行Step 5并发症确认和Step 6标准DRG细分分组

### Requirement: 入参扩展
系统 SHALL 在 `Device` 方法入参中新增 `groupYear`（分组方案年份）字段，默认值为当前年份。用于匹配对应年份的特异化分组方案和DRG算法配置。

#### Scenario: 传入分组方案年份
- **WHEN** 前端传入 `groupYear="2026"`
- **THEN** 系统使用2026年的特异化分组方案和DRG算法配置进行分组

#### Scenario: 未传入分组方案年份
- **WHEN** 前端未传入 groupYear 参数或传入空字符串
- **THEN** 系统默认使用当前年份（`$PIECE($ZDATE($HOROLOG,3),"-",1)`）
