## ADDED Requirements

### Requirement: DIP分组分值查询接口
系统 SHALL 提供 `GetDIPGroupScore` 接口方法，接收主诊断代码（必填）、主手术代码（选填）、行政区划代码（选填）、医疗机构代码/名称（选填），通过模糊匹配 `HB_DIPCoreAlgorithmData` 表的 `PrincipalDiagnosis` 和 `MajorProcedure` 字段，结合行政区划和省市关联筛选，返回匹配记录的完整算法配置数据。

#### Scenario: 仅传主诊断查询
- **WHEN** 前端传入 `mainDiagnosisCode` 且 `mainOperationCode` 为空，无行政区划和医疗机构参数
- **THEN** 系统使用 `PrincipalDiagnosis LIKE 'mainDiagnosisCode%'` 条件查询 `HB_DIPCoreAlgorithmData` 表，返回所有主诊断前缀匹配的记录，包含 PrincipalDiagnosisName、MajorProcedure、MajorProcedureName、SecondaryProcedure、SecondaryProcedureName、ProvinceDesc、CityDesc、MdtrtArea、MedinsLv、ScoreValue、AdjustCoefficient、PrimaryAdjustCoefficient、SecondaryAdjustCoefficient、ThirdAdjustCoefficient、AverageCost 字段

#### Scenario: 传主诊断和主手术联合查询
- **WHEN** 前端同时传入 `mainDiagnosisCode` 和 `mainOperationCode`
- **THEN** 系统使用 `PrincipalDiagnosis LIKE 'mainDiagnosisCode%' AND MajorProcedure LIKE 'mainOperationCode%'` 条件联合查询，返回同时匹配主诊断和主手术前缀的记录

#### Scenario: 主诊断为空
- **WHEN** 前端未传入 `mainDiagnosisCode` 或该参数为空
- **THEN** 系统返回错误码 "-1"，错误信息为 "主诊断不能为空！"

#### Scenario: 查询无匹配结果
- **WHEN** 查询条件无匹配记录
- **THEN** 系统返回 `errorCode="0"`，`result` 为空数组，`totalCount=0`

#### Scenario: 传行政区划代码筛选
- **WHEN** 前端传入 `mdtrtArea` 参数
- **THEN** 系统追加 `AND MdtrtArea = ?` 等值条件筛选匹配行政区划代码的记录

#### Scenario: 传医疗机构代码关联筛选
- **WHEN** 前端传入 `fixmedinsCode` 参数
- **THEN** 系统先通过 `CB_Hospital.OrganizationCode = fixmedinsCode` 查询获取 `ProvID_Dr` 和 `CityID_Dr`，再追加 `AND Province_Dr = ? AND City_Dr = ?` 条件筛选DIP算法配置数据

#### Scenario: 传医疗机构名称关联筛选（无机构代码时）
- **WHEN** 前端传入 `fixmedinsName` 参数但 `fixmedinsCode` 为空
- **THEN** 系统通过 `CB_Hospital.Descripts LIKE '%fixmedinsName%'` 模糊匹配查询获取 `ProvID_Dr` 和 `CityID_Dr`（取第一条结果），再追加 `AND Province_Dr = ? AND City_Dr = ?` 条件筛选

#### Scenario: 医疗机构代码和名称同时传入
- **WHEN** 前端同时传入 `fixmedinsCode` 和 `fixmedinsName`
- **THEN** 系统优先使用 `fixmedinsCode` 精确查询 `CB_Hospital` 获取省市ID，忽略 `fixmedinsName`

#### Scenario: CB_Hospital中查不到医疗机构
- **WHEN** 前端传入的 `fixmedinsCode` 在 `CB_Hospital` 表中无匹配记录
- **THEN** 系统返回错误码 "-1"，错误信息为 "未找到对应医疗机构信息！"

### Requirement: 参数合法性校验
系统 SHALL 对入参进行合法性校验，确保 `params` 参数存在且非空，`mainDiagnosisCode` 必填，且行政区划代码（`mdtrtArea`）与医疗机构代码/名称（`fixmedinsCode`/`fixmedinsName`）不能同时为空。

#### Scenario: params参数缺失
- **WHEN** 请求体中 `params` 缺失或为空
- **THEN** 系统返回错误码 "-1"，错误信息为 "入参异常：缺少params参数或参数为空"

#### Scenario: 主诊断为空
- **WHEN** `params` 中 `mainDiagnosisCode` 为空字符串
- **THEN** 系统返回错误码 "-1"，错误信息为 "主诊断不能为空！"

#### Scenario: 行政区划代码和医疗机构代码/名称同时为空
- **WHEN** `mdtrtArea`、`fixmedinsCode`、`fixmedinsName` 三个参数均为空
- **THEN** 系统返回错误码 "-1"，错误信息为 "行政区划代码和医疗机构代码/名称不能同时为空！"

### Requirement: 查询结果返回格式
系统 SHALL 使用 `SetJarraySuccessResult(rows, totalCount)` 格式返回查询结果数组。

#### Scenario: 正常返回结果
- **WHEN** 查询成功且有匹配记录
- **THEN** 返回 `{"errorCode":"0","errorMessage":"","result":[...],"totalCount":N}` 格式，每条记录包含 id、principalDiagnosis、principalDiagnosisName、majorProcedure、majorProcedureName、secondaryProcedure、secondaryProcedureName、provinceID、provinceDesc、cityID、cityDesc、mdtrtArea、medinsLv、scoreValue、adjustCoefficient、primaryAdjustCoefficient、secondaryAdjustCoefficient、thirdAdjustCoefficient、averageCost 字段

### Requirement: 异常处理
系统 SHALL 捕获所有运行时异常，记录错误日志并返回标准化错误响应。

#### Scenario: SQL执行异常
- **WHEN** 查询过程中发生SQL执行异常
- **THEN** 系统调用 `##class(src.Interface.Message).InsErrRecord("04000007", errorInfo, errorMsg)` 记录错误日志，返回 `errorCode="-99"` 和包含日志ID的错误信息

### Requirement: 模糊匹配查询效率
系统 SHALL 使用前置模糊匹配（`LIKE 'xxx%'`）而非全模糊匹配（`LIKE '%xxx%'`），利用 `HB_DIPCoreAlgorithmData` 表的组合索引 `(PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv)` 第一列的索引前缀匹配能力保证查询效率。

#### Scenario: 前置模糊匹配走索引
- **WHEN** 使用 `PrincipalDiagnosis LIKE 'K25%'` 查询
- **THEN** 数据库可利用组合索引第一列 PrincipalDiagnosis 的B-tree前缀匹配，避免全表扫描

### Requirement: SQL注入防护
系统 SHALL 使用 `%SQL.Statement` 参数化查询（`?` 占位符 + `%Execute` 传参）构建LIKE条件，防止SQL注入攻击。

#### Scenario: 参数包含特殊字符
- **WHEN** 用户输入的主诊断或主手术包含SQL特殊字符（如单引号）
- **THEN** 参数化查询自动转义，不产生SQL注入风险
