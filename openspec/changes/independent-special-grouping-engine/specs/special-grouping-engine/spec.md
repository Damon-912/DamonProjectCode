## ADDED Requirements

### Requirement: Engine provides standalone matching API

DRG 特异化分组匹配引擎 SHALL 提供一个独立的公开入口方法 `Match`，接受患者诊断/手术数据和地区信息作为输入，返回匹配到的 DRG 编码和描述信息，无需依赖 GroupDevice 或其他分组器组件。

#### Scenario: Match with diagnosis and surgery

- **WHEN** 调用 `Match(patientInfo, regionInfo, "2026")`，其中 `patientInfo` 包含 `mainDiagnosisCode="H25.900"`、`mainOperationCode="13.4100x001"`、次要手术 `oprnInfo` 包含 `oprnCode="13.9003"`，且 `regionInfo` 包含 `provinceDr="34"`、`cityDr="3401"`、`admvs="340100"`
- **THEN** 引擎查询 `HB_DRGSpecialGroup` 表中 `Province_Dr=34 AND City_Dr=3401 AND Year=2026` 的规则
- **AND** 引擎 SHALL 匹配到 DRGCode="CB54" 的记录，因为主诊断 H25.900 匹配 PrincipalDiagnosis、主手术 13.4100x001 匹配 MajorProcedure、次要手术 13.9003 匹配 SecondaryProcedure
- **AND** 返回 `{ errorCode: "0", result: { drgCode: "CB54", drgDesc: "老年性白内障的白内障超声乳化抽吸术伴晶状体囊袋张力环植入术（特异化分组：主要诊断+主要手术+次要手术）", matchRuleId: <规则ID>, groupFactors: "主要诊断+主要手术+次要手术" } }`

#### Scenario: Match with only procedure conditions

- **WHEN** 调用 `Match(patientInfo, regionInfo, "2026")`，其中 `patientInfo` 包含 `mainOperationCode="13.7000"`、次要手术 `oprnInfo` 包含 `oprnCode="13.4100x001"`，且无主要诊断
- **THEN** 引擎 SHALL 匹配到 DRGCode="CB58" 的记录（GroupFactors="主要手术+次要手术"）
- **AND** 返回 `{ errorCode: "0", result: { drgCode: "CB58", ... } }`

#### Scenario: No match found

- **WHEN** 调用 `Match(patientInfo, regionInfo, "2026")`，其中患者诊断和手术编码不与任何规则匹配
- **THEN** 引擎 SHALL 返回 `{ errorCode: "-1", errorMessage: "未命中特异化分组规则" }`

#### Scenario: Empty region info

- **WHEN** 调用 `Match(patientInfo, {}, "2026")`，其中 `regionInfo` 不包含 `provinceDr`、`cityDr`、`admvs`
- **THEN** 引擎 SHALL 返回 `{ errorCode: "-1", errorMessage: "缺少地区信息，无法执行特异化分组匹配" }`

---

### Requirement: Engine parses GroupFactors structured expression

引擎 SHALL 解析 `GroupFactors` 字段的结构化语法：`+` 表示 AND（且），`或` 表示 OR（或），并据此动态决定匹配逻辑。

#### Scenario: Parse "主要诊断+主要手术"

- **WHEN** 规则的 `GroupFactors` 字段为 `"主要诊断+主要手术"`
- **THEN** 解析结果 SHALL 为 `[ [1], [3] ]`（两个 AND 组：主要诊断 AND 主要手术）
- **AND** 匹配时主诊断匹配 AND 主手术匹配均通过才视为命中

#### Scenario: Parse "主要诊断或次要诊断+主要手术"

- **WHEN** 规则的 `GroupFactors` 字段为 `"主要诊断或次要诊断+主要手术"`
- **THEN** 解析结果 SHALL 为 `[ [1, 2], [3] ]`（第一个 AND 组：主要诊断 OR 次要诊断，第二个 AND 组：主要手术）
- **AND** 匹配时 (主诊断匹配 OR 次要诊断匹配) AND 主手术匹配 通过才视为命中

#### Scenario: Parse "主要手术"

- **WHEN** 规则的 `GroupFactors` 字段为 `"主要手术"`
- **THEN** 解析结果 SHALL 为 `[ [3] ]`（一个 AND 组：主要手术）
- **AND** 其他诊断字段不参与匹配

#### Scenario: Empty GroupFactors with non-empty fields

- **WHEN** 规则的 `GroupFactors` 为空，但 `PrincipalDiagnosis` 和 `MajorProcedure` 非空
- **THEN** 引擎 SHALL 默认为所有非空字段的 AND 关系（等价于 "主要诊断+主要手术"）

---

### Requirement: Engine supports ICD code bidirectional prefix matching

引擎 SHALL 实现 ICD 编码的双向前缀匹配算法：入参编码是存储编码的子类（如 H25.900 → H25.9）或父类（如 H25 → H25.900）时均视为匹配。

#### Scenario: Subclass matches parent

- **WHEN** 入参编码为 `"H25.900"`，规则中存储的编码为 `"H25.9"`
- **THEN** `IsCodeMatch("H25.900", "H25.9")` SHALL 返回 `1`（true）

#### Scenario: Parent matches subclass

- **WHEN** 入参编码为 `"H25"`，规则中存储的编码为 `"H25.900"`
- **THEN** `IsCodeMatch("H25", "H25.900")` SHALL 返回 `1`（true）

#### Scenario: Exact match

- **WHEN** 入参编码为 `"h40.501"`，规则中存储的编码为 `"h40.501"`
- **THEN** `IsCodeMatch("h40.501", "h40.501")` SHALL 返回 `1`（true）

#### Scenario: No match

- **WHEN** 入参编码为 `"H50.100"`，规则中存储的编码为 `"H40.501"`
- **THEN** `IsCodeMatch("H50.100", "H40.501")` SHALL 返回 `0`（false）

---

### Requirement: Engine supports multiple codes per field

引擎 SHALL 支持规则中的每个编码字段（PrincipalDiagnosis、MajorProcedure 等）包含多个逗号分隔的编码，匹配时任意一个编码匹配即视为该字段匹配成功。

#### Scenario: Major procedure multi-select

- **WHEN** 规则 `MajorProcedure` 为 `"14.4100,14.4900x001,14.4901,14.7401"`，患者主手术编码为 `"14.7401"`
- **THEN** 主手术匹配 SHALL 成功（14.7401 命中其中一个编码）

#### Scenario: Principal diagnosis multi-select

- **WHEN** 规则 `PrincipalDiagnosis` 为 `"h25.900,e88.906+h28.1*,h26.200"`，患者主诊断为 `"h26.200"`
- **THEN** 主诊断匹配 SHALL 通过 IsCodeMatch 检查，h26.200 命中其中一个编码

---

### Requirement: Engine returns on first match

引擎 SHALL 按 DRGCode 排序遍历候选规则，在首次匹配成功时立即返回结果。

#### Scenario: Multiple rules for same DRGCode

- **WHEN** CB26 有 4 条规则记录，患者数据匹配到第 2 条（诊断 H35.303 + 手术 13.4100x001）
- **THEN** 引擎 SHALL 遍历到第 2 条记录时返回匹配结果
- **AND** 不再继续检查 CB26 的后续记录或其他 DRGCode 的规则

---

### Requirement: Engine supports region-based rule filtering

引擎 SHALL 根据 `regionInfo` 中的省市和行政区划信息，从 `HB_DRGSpecialGroup` 表中筛选候选规则。

#### Scenario: Province-level filter

- **WHEN** `regionInfo` 包含 `provinceDr="34"` 且 `cityDr=""`、`admvs=""`
- **THEN** SQL WHERE 条件 SHALL 包含 `Province_Dr='34'`
- **AND** City_Dr 和 Admvs 条件不添加

#### Scenario: District code prefix matching

- **WHEN** `regionInfo` 包含 `admvs="340100"`
- **THEN** SQL WHERE 条件 SHALL 匹配 `Admvs='340100' OR LEFT(Admvs,4)='3401' OR Admvs=''`
- **AND** 支持市本级（完整6位）和省直（前4位前缀）两种匹配模式

---

### Requirement: GroupDevice delegates to new engine

GroupDevice 中的 `GroupSpecialMatch` 方法 SHALL 将其核心匹配逻辑委托给 `src.DRG.SpecialGroupEngine`，仅保留参数适配功能。

#### Scenario: Delegation call

- **WHEN** GroupDevice.Device() 在分组流程中调用 `..GroupSpecialMatch(jsonObj, MDC, jaADRG, hospinfo, groupYear)`
- **THEN** GroupSpecialMatch SHALL 从 jsonObj 和 hospinfo 中提取 `patientInfo` 和 `regionInfo`
- **AND** 委托调用 `##class(src.DRG.SpecialGroupEngine).Match(patientInfo, regionInfo, groupYear)`
- **AND** 直接透传返回结果，不修改返回格式

#### Scenario: Empty hospinfo

- **WHEN** hospinfo 为空或元素个数为 0
- **THEN** GroupSpecialMatch SHALL 直接返回未命中结果（`errorCode="-1"`），不调用新引擎
- **AND** 行为与修改前完全一致
