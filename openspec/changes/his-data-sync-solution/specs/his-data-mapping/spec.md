## ADDED Requirements

### Requirement: HIS接口数据准确映射到IRIS数据库表

系统SHALL定义HIS接口返回数据与IRIS数据库表字段之间的映射规则，确保数据准确入库。映射规则SHALL覆盖以下数据对象：

1. **患者就诊主信息**（`result[]`中的顶层字段 → `DRG_HIS_PatientAdm`表）：
   - `patID` → `PatID`
   - `admID` → `AdmID`（主键）
   - `patName` → `PatName`
   - `patSexCode` → `PatSexCode`
   - `patSexDesc` → `PatSexDesc`
   - `patNo` → `PatNo`
   - `patMedicalNo` → `PatMedicalNo`
   - `admDocDesc` → `AdmDocDesc`
   - `admNurDesc` → `AdmNurDesc`
   - `admDateTime` → `AdmDateTime`
   - `admInDays` → `AdmInDays`
   - `admDiag` → `AdmDiag`
   - `inLocDesc` → `InLocDesc`
   - `inWardDesc` → `InWardDesc`

2. **DRG分组参数**（`result[].drgParams.result` → `DRG_HIS_DRGParams`表）：
   - `admID` → `AdmID`（外键，关联患者就诊主表）
   - `psnNo` → `PsnNo`
   - `insuranceAreaCode` → `InsuranceAreaCode`
   - `mdtrtareaAreaCode` → `MdtrtareaAreaCode`
   - `insuType` → `InsuType`
   - `mainDiagnosisCode` → `MainDiagnosisCode`
   - `mainOperationCode` → `MainOperationCode`
   - `sex` → `Sex`
   - `age` → `Age`
   - `totalCost` → `TotalCost`
   - （其他字段按接口返回逐条映射）

3. **手术信息**（`result[].drgParams.result.oprnInfo[]` → `DRG_HIS_OprnInfo`表）：
   - `admID` + `oprnSn` → 联合主键
   - `mainFlag` → `MainFlag`
   - `oprnCode` → `OprnCode`
   - `oprnName` → `OprnName`
   - `oprnDate` → `OprnDate`

#### Scenario: 解析并映射单条患者就诊数据

- **WHEN** HIS接口返回一条完整的就诊数据（包含`patID`、`admID`、`drgParams`等所有字段）
- **THEN** 系统SHALL将顶层字段写入`DRG_HIS_PatientAdm`表，将`drgParams.result`字段写入`DRG_HIS_DRGParams`表，将`drgParams.result.oprnInfo`数组逐条写入`DRG_HIS_OprnInfo`表

---

#### Scenario: HIS接口返回数据中drgParams为错误状态

- **WHEN** 某条记录的`drgParams.errorCode`不为`"0"`（如`errorCode: "1", errorMessage: "该患者无医保信息"`）
- **THEN** 系统SHALL仍然写入患者就诊主表（`DRG_HIS_PatientAdm`），但`DRG_HIS_DRGParams`表中该`admID`的记录留空或标记`DrgParamsStatus: "error"`，不影响主表数据入库

---

### Requirement: 数据映射层处理字段类型转换

系统SHALL在映射过程中自动处理HIS接口返回数据类型与IRIS表字段类型之间的差异：
- 字符串日期（如`"2026-06-11 09:22"`）转换为IRIS `%TimeStamp`类型
- 数字字符串（如`"5999886"`）转换为IRIS `%Integer`类型
- 金额字符串（如`"1146.96"`）转换为IRIS `%Numeric`类型

#### Scenario: 日期字符串正确转换为IRIS时间类型

- **WHEN** HIS接口返回`admDateTime: "2026-06-11 09:22"`
- **THEN** 系统SHALL将其转换为IRIS `%TimeStamp`格式（`2026-06-11 09:22:00`）后存入数据库

---

#### Scenario: 金额字段正确转换为数值类型

- **WHEN** HIS接口返回`drgParams.result.totalCost: 1146.96`（JSON数字类型）
- **THEN** 系统SHALL直接将其作为`%Numeric`类型存入`DRG_HIS_DRGParams.TotalCost`字段

---

### Requirement: 数据映射层对关键字段进行非空校验

系统SHALL对以下关键字段进行非空校验，若校验失败则记录错误并跳过该条数据：
- `admID`（就诊ID）：不能为空，作为唯一键
- `patID`（患者ID）：不能为空
- `patMedicalNo`（病案号）：不能为空

#### Scenario: 关键字段admID为空

- **WHEN** HIS接口返回的数据中某条记录缺少`admID`字段或`admID`为`null`
- **THEN** 系统SHALL跳过该条数据，记录错误日志（`"admID为空，跳过该条数据"`），不影响其他数据的同步

---

#### Scenario: 所有关键字段均有效

- **WHEN** HIS接口返回的数据中，每条记录的`admID`、`patID`、`patMedicalNo`均非空
- **THEN** 系统SHALL正常执行映射和入库操作，不记录校验错误
