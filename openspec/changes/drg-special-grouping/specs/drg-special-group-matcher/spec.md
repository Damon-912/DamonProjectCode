## ADDED Requirements

### Requirement: 特异化分组匹配查询
系统 SHALL 在分组流程中查询 `HB_DRGSpecialGroup` 表，根据患者的ADRG编码（从DRGCode前3位过滤）、就诊医疗机构省市信息（从hospinfo中获取）、行政区划代码、分组方案年份，筛选出当前地区当前年份的所有候选特异化分组规则。

#### Scenario: 按ADRG+行政区划+年份查询候选规则
- **WHEN** 患者ADRG编码为"CB2"（从DRGCode前3位过滤），就医地区划代码为"340100"（合肥），分组方案年份为"2026"
- **THEN** 系统查询 `HB_DRGSpecialGroup` 表返回 LEFT(DRGCode,3)='CB2' 且 Admvs='340100'、年份为2026 的所有候选规则

#### Scenario: 无匹配候选规则
- **WHEN** 当前地区/年份无任何特异化分组规则
- **THEN** 系统返回空结果集，分组器继续走标准CHS-DRG流程

### Requirement: 医疗机构信息前置条件
系统 SHALL 仅在分组服务入参中包含医疗机构信息（hospinfo非空）时，才触发特异化分组匹配流程。若hospinfo为空，跳过整个特异化分组匹配步骤。

#### Scenario: 有医疗机构信息——执行特异化分组匹配
- **WHEN** 入参中包含医疗机构信息数组（hospinfo.%Size() > 0）
- **THEN** 系统执行特异化分组匹配步骤

#### Scenario: 无医疗机构信息——跳过特异化分组匹配
- **WHEN** 入参中医疗机构信息为空（hospinfo="" 或 hospinfo.%Size() = 0）
- **THEN** 系统直接跳过特异化分组匹配步骤，继续标准CHS-DRG分组流程

### Requirement: 逐条规则AND匹配算法
系统 SHALL 对候选规则逐条执行 AND 匹配判断：规则中每个非空字段均需与患者对应信息匹配，全部匹配成功则该规则命中。

匹配字段及对应患者信息：
- PrincipalDiagnosis（非空）→ 患者主诊断编码 MUST 匹配该字段中的任一编码
- SecondaryDiagnosis（非空）→ 患者任一其他诊断编码 MUST 匹配该字段中的任一编码
- MajorProcedure（非空）→ 患者主手术编码 MUST 匹配该字段中的任一编码
- SecondaryProcedure（非空）→ 患者任一其他手术编码 MUST 匹配该字段中的任一编码

空字段视为无条件放行（该维度不参与匹配）。

#### Scenario: 全部非空字段均匹配——命中
- **WHEN** 规则 PrincipalDiagnosis="H40.501", MajorProcedure="12.6704"，患者主诊断=H40.501，患者主手术=12.6704
- **THEN** 判断为命中，返回该规则的DRG编码和DRG名称

#### Scenario: 部分字段不匹配——不命中
- **WHEN** 规则 PrincipalDiagnosis="H40.501", MajorProcedure="12.6704"，患者主诊断=H40.501，患者主手术=14.7401
- **THEN** 判断为不命中，继续尝试下一条规则

#### Scenario: 只需要主诊断+主手术匹配（次要诊断/次要手术为空）
- **WHEN** 规则 PrincipalDiagnosis="H25.900", MajorProcedure="13.4101", SecondaryDiagnosis=""（空）, SecondaryProcedure=""（空），患者主诊断=H25.900，患者主手术=13.4101
- **THEN** 判断为命中，次要诊断和次要手术字段为空自动放行

#### Scenario: 存在次要手术条件
- **WHEN** 规则 PrincipalDiagnosis="H25.900", MajorProcedure="13.4100x001", SecondaryProcedure="13.9003"，患者主诊断=H25.900，主手术=13.4100x001，其他手术中包含13.9003
- **THEN** 判断为命中

### Requirement: ICD编码双向包含匹配
系统 SHALL 在每个字段内部的多编码匹配中，使用ICD编码双向包含规则（前缀匹配）：一方是另一方的子串即视为匹配（如 "H25.900" 匹配 "H25.9" 或 "H25"），复用现有的 `IsCodeMatch` 方法。

#### Scenario: 患者编码是配置编码的子类
- **WHEN** 规则 MajorProcedure 字段存储 "13.41"，患者主手术编码为 "13.4101"
- **THEN** 系统通过双向包含判断为匹配（"13.41" 是 "13.4101" 的前缀）

#### Scenario: 配置编码是患者编码的子类
- **WHEN** 规则 MajorProcedure 字段存储 "13.4100x001"，患者主手术编码为 "13.41"
- **THEN** 系统通过双向包含判断为匹配（"13.41" 是 "13.4100x001" 的前缀）

#### Scenario: 精确匹配
- **WHEN** 规则 PrincipalDiagnosis 字段存储 "H25.900"，患者主诊断编码为 "H25.900"
- **THEN** 系统判断为精确匹配

### Requirement: 多匹配结果取第一条
系统 SHALL 对匹配到的多条规则，取第一条规则返回的DRG编码作为最终分组结果。

#### Scenario: 多条规则命中
- **WHEN** ADRG='CB4'下配置了多条主要手术九选一的规则，患者同时命中多条
- **THEN** 系统返回第一条规则的DRG编码（分组结果唯一确定）

### Requirement: 匹配成功返回结果格式
系统 SHALL 在匹配成功时返回成功状态对象，包含 `drgCode`（特异化DRG编码）、`drgDesc`（特异化DRG名称）、`matchRuleId`（匹配到的规则ID）、`groupFactors`（入组因素说明），供 Device 方法直接使用。

#### Scenario: 匹配成功返回
- **WHEN** 规则 ID=1, DRGCode="CB46", DRGName="后入路玻璃体切割术", GroupFactors="主诊断+主手术"
- **THEN** 系统返回 `{"errorCode":"0","errorMessage":"","result":{"drgCode":"CB46","drgDesc":"后入路玻璃体切割术","matchRuleId":"1","groupFactors":"主诊断+主手术"}}`

#### Scenario: 所有规则均不匹配
- **WHEN** 候选规则全部匹配失败
- **THEN** 系统返回 `{"errorCode":"-1","errorMessage":"未命中任何特异化分组规则"}`
