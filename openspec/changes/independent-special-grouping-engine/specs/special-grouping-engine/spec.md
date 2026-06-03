## ADDED Requirements

### Requirement: Engine provides standalone matching API

DRG 特异化分组匹配引擎 SHALL 提供一个独立的公开入口方法 `Match`，接受患者诊断/手术数据和地区信息作为输入，返回匹配到的 DRG 编码和描述信息，无需依赖 GroupDevice 或其他分组器组件。

#### Scenario: Match CB54 with diagnosis + major + secondary procedure

- **WHEN** 调用 `Match(patientInfo, regionInfo, "2026")`，其中 `patientInfo` 包含 `mainDiagnosisCode="H25.900"`、`mainOperationCode="13.4100x001"`、次要手术 `oprnInfo` 包含 `oprnCode="13.9003"`，且 `regionInfo` 含 `provinceDr="12"`、`cityDr="98"`、`admvs="340100"`
- **THEN** 引擎 SHALL 匹配到 DRGCode="CB54" 的记录（GroupFactors="主要诊断+主要手术+次要手术"）
- **AND** 返回 `{ errorCode: "0", result: { drgCode: "CB54", drgDesc: "老年性白内障的白内障超声乳化抽吸术伴晶状体囊袋张力环植入术（特异化分组：主要诊断+主要手术+次要手术）", matchRuleId: <ID>, groupFactors: "主要诊断+主要手术+次要手术", remark: "主要诊断、主要手术和次要手术均唯一" } }`

#### Scenario: Match CB26 with secondary procedure check

- **WHEN** 调用 `Match(patientInfo, regionInfo, "2026")`，其中 `patientInfo` 含 `mainDiagnosisCode="H35.303"`、`mainOperationCode="13.4100x001"`、次要手术 `oprnInfo` 含 `oprnCode="14.7401"`
- **THEN** 引擎 SHALL 匹配到 CB26 id=3 的记录（GroupFactors="主要诊断+主要手术+次要手术"，SecondaryProcedure=14.7401 匹配）
- **AND** Remark 随结果透传

#### Scenario: No match found

- **WHEN** 调用 `Match(patientInfo, regionInfo, "2026")`，其中患者诊断和手术编码不与任何规则匹配（如 H25.900 + 13.3x01）
- **THEN** 引擎 SHALL 返回 `{ errorCode: "-1", errorMessage: "未命中特异化分组规则" }`

#### Scenario: Empty region info

- **WHEN** 调用 `Match(patientInfo, {}, "2026")`，其中 `regionInfo` 无省市信息
- **THEN** 引擎 SHALL 返回 `{ errorCode: "-1", errorMessage: "缺少地区信息，无法执行特异化分组匹配" }`

---

### Requirement: Engine parses GroupFactors structured expression

引擎 SHALL 解析 `GroupFactors` 字段的结构化语法：`+` 表示 AND（且），`或` 表示 OR（或），并据此动态决定匹配逻辑。

#### Scenario: Parse "主要诊断+主要手术"

- **WHEN** 规则的 `GroupFactors` 为 `"主要诊断+主要手术"`
- **THEN** 解析结果 SHALL 为 `[ [1], [3] ]`（主诊断 AND 主手术）

#### Scenario: Parse "主要诊断或次要诊断+主要手术"

- **WHEN** 规则的 `GroupFactors` 为 `"主要诊断或次要诊断+主要手术"`
- **THEN** 解析结果 SHALL 为 `[ [1, 2], [3] ]`（(主诊断 OR 次要诊断) AND 主手术）

#### Scenario: Parse "主要手术"

- **WHEN** 规则的 `GroupFactors` 为 `"主要手术"`
- **THEN** 解析结果 SHALL 为 `[ [3] ]`（仅主要手术参与匹配）

#### Scenario: Empty GroupFactors auto-builds AND from non-empty fields

- **WHEN** 规则的 `GroupFactors` 为空，且 PrincipalDiagnosis="H25.900"、MajorProcedure="13.4101"，其余字段为空
- **THEN** 引擎 SHALL 自动构建 `[ [1], [3] ]`（等价于"主要诊断+主要手术"）

---

### Requirement: Engine supports ICD bidirectional prefix matching

引擎 SHALL 使用 `$FIND` 实现严格前缀关系判断。

#### Scenario: Subclass matches parent (H25.900 → H25.9)

- **WHEN** 入参 `"H25.900"`，规则 `"H25.9"`
- **THEN** `IsCodeMatch` SHALL 返回 true

#### Scenario: Parent matches subclass (H25 → H25.900)

- **WHEN** 入参 `"H25"`，规则 `"H25.900"`
- **THEN** `IsCodeMatch` SHALL 返回 true

#### Scenario: Sibling codes do NOT match (H25.900 vs H25.100)

- **WHEN** 入参 `"H25.900"`，规则 `"H25.100"`
- **THEN** `IsCodeMatch` SHALL 返回 false（同级兄弟，互不为前缀）

---

### Requirement: SplitCodes excludes + as delimiter

`SplitCodes` 方法 SHALL 支持英文逗号 `,`、中文逗号 `，`、分号 `;`、斜杠 `/`、空格 ` ` 作为分隔符。`+` SHALL NOT 作为分隔符。

#### Scenario: ICD compound code preserved

- **WHEN** `SplitCodes("e88.906+h28.1*")`
- **THEN** 返回 `[ "e88.906+h28.1*" ]`（不拆分）

#### Scenario: Comma-separated codes split

- **WHEN** `SplitCodes("14.7401,13.4100x001")`
- **THEN** 返回 `[ "14.7401", "13.4100x001" ]`

---

### Requirement: Engine supports multiple codes per field

引擎 SHALL 对规则中每个编码字段调用 SplitCodes 拆分后逐一匹配。

#### Scenario: Major procedure with multiple codes

- **WHEN** 规则 `MajorProcedure="14.7401,13.4100x001"`，患者 `mainOperationCode="13.4100x001"`
- **THEN** 主手术匹配 SHALL 成功

---

### Requirement: Engine filters by region and year

引擎 SHALL 根据 regionInfo 的 Province_Dr、City_Dr、Admvs 和 groupYear 筛选候选规则。

#### Scenario: District code prefix matching

- **WHEN** `regionInfo.admvs="340100"`
- **THEN** SQL WHERE SHALL 匹配 `Admvs='340100' OR LEFT(Admvs,4)='3401' OR Admvs=''`

---

### Requirement: Engine passes Remark through without parsing

引擎 SHALL 在 SQL 中查询 Remark 字段，匹配成功后将其放入结果 `result.remark`，但不解析其内容参与匹配判断。

#### Scenario: Remark in result

- **WHEN** 命中的规则 Remark 为"主要手术9选1"
- **THEN** 返回结果中 SHALL 包含 `remark: "主要手术9选1"`
