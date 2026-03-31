# DRG分组模块需求分析

## 1. 模块概述

### 1.1 功能定位
DRG分组模块是DRG医保控费预警系统的核心功能模块，用于将患者的病案信息按照国家医保DRG分组规则进行智能分组，确定医保支付标准，为医保结算和费用控制提供依据。

### 1.2 业务背景
DRG（疾病诊断相关分组）是医保支付方式改革的重要方向。医保部门根据DRG分组结果确定医保支付标准，医院需要通过DRG分组系统将病案信息准确分组，以获得合理的医保结算收入。DRG分组模块是连接病案信息与医保结算的桥梁。

### 1.3 目标用户
- 医保办管理人员
- 病案室编码员
- 质控人员
- 科室医生
- 财务人员
- 信息科人员

---

## 2. 功能需求

### 2.1 病案数据采集

#### 2.1.1 数据来源
- HIS系统接口获取
- 病案室导入
- 手工录入

#### 2.1.2 采集字段
| 类别 | 字段名称 |
|------|----------|
| 基本信息 | 姓名、性别、年龄、身份证号、住院号 |
| 入院信息 | 入院日期、出院日期、入院科室、入院方式 |
| 出院信息 | 出院科室、出院方式、住院天数 |
| 诊断信息 | 主诊断、次诊断（多个）、诊断编码、诊断名称 |
| 手术信息 | 主手术、次手术（多个）、手术编码、手术名称 |
| 费用信息 | 总费用、各分项费用 |
| 其他信息 | 新生儿体重、呼吸机使用时间、ICU天数等 |

#### 2.1.3 数据校验
- 必填字段完整性校验
- 数据格式校验
- 逻辑一致性校验
- 诊断/手术编码有效性校验

### 2.2 DRG分组引擎

#### 2.2.1 分组流程（后端实现）
```
病案数据 → 分组前校验(CheckRules) → MDC先期分组 → ADRG分组 → DRG细分 → 分组结果
```

#### 2.2.2 分组规则（后端实现）

**第一步：分组前校验 (CheckRules)**
- 检查主诊断是否在不作为分组规则的疾病诊断列表中
- 检查主手术是否在不作为分组规则的手术操作列表中
- 如命中，则无法分组（返回0000组）

**第二步：MDC先期分组 (GroupPreMDC)**
- **MDCA**（高资源消耗）：
  - 器官移植标志 = 1
  - 骨髓移植标志 = 1
  - ECMO标志 = 1
  - 有创呼吸机时长 ≥ 96小时
- **MDCP**（新生儿）：
  - 出生天数 1-28天 或 新生儿标志 = 1
- **MDCY**（HIV感染）：
  - HIV标志 = 1
- **MDCZ**（多发创伤）：
  - 创伤等级 ≥ 2
- **常规MDC**：
  - 通过主诊断编码匹配MDC分类表

**第三步：ADRG分组 (GroupADRG)**
- 结合主要诊断 + 主要手术/操作
- 判断联合分组规则（AC1、AH2、PS1、PS2等）
- 判断入组条件
- 确定ADRG分组

**第四步：DRG细分**
- 结合其他诊断、合并症/并发症
- 年龄、新生儿体重等个体特征
- 确定最终DRG分组

#### 2.2.3 分组算法
- 支持国家医保局发布的DRG分组方案
- 支持多版本（CHS-DRG 1.0/2.0等）
- 支持分省差异化分组规则

### 2.3 分组结果管理

#### 2.3.1 分组结果属性
- 病案ID
- MDC编码
- MDC名称
- ADRG编码
- ADRG名称
- DRG编码
- DRG名称
- 分组时间
- 分组版本
- 分组依据（主要诊断、手术等）
- 未入组原因（如未入组）

#### 2.3.2 分组结果查询
- 按时间范围查询
- 按科室查询
- 按医生查询
- 按MDC/ADRG/DRG查询
- 按入组状态查询（已入组/未入组）
- 分页展示

#### 2.3.3 分组结果详情
- 查看分组详细信息
- 查看分组依据
- 重新分组
- 分组日志

### 2.4 医保支付计算

#### 2.4.1 支付标准
- 根据DRG编码获取医保支付标准
- 支持分省、市不同标准
- 支持不同医院级别差异化标准

#### 2.4.2 费用对比
- 实际费用 vs 支付标准
- 盈亏计算
- 费用结构分析

#### 2.4.3 结算清单生成
- 生成医保结算清单
- 结算数据导出

### 2.5 分组统计

#### 2.5.1 统计维度
- 分组数量统计（按时间、科室、MDC）
- 入组率统计
- 各MDC/ADRG/DRG分布
- 未入组原因分析
- 分组趋势分析

#### 2.5.2 报表功能
- 分组汇总报表
- 分组明细报表
- 入组率统计报表
- 科室分组排行
- 导出Excel/PDF

### 2.6 分组规则维护

#### 2.6.1 规则配置
- MDC分类规则
- ADRG入组规则
- DRG细分规则
- 费用权重配置

#### 2.6.2 规则版本管理
- 支持多版本管理
- 版本对比
- 版本启用/停用

---

## 3. 数据模型

### 3.1 核心表结构

#### 3.1.1 核心ADRG规则表 (CB_DRGCoreGroupsList)
**类名**: `User.CBDRGCoreGroupsList`  
**表名**: `CB_DRGCoreGroupsList`

| 字段名 | 类型 | 说明 |
|--------|------|------|
| ADRG | VARCHAR(10) | ADRG代码 (非空) |
| ADRGDesc | VARCHAR(100) | ADRG名称 (非空) |
| PrincipalDiagnosis | VARCHAR(20) | 主要诊断 |
| PrincipalDiagnosisName | VARCHAR(200) | 主要诊断名称 |
| SecondaryDiagnosis | VARCHAR(20) | 其他诊断 |
| SecondaryDiagnosisName | VARCHAR(200) | 其他诊断名称 |
| ThirdlyDiagnosis | VARCHAR(20) | 第三诊断 |
| ThirdlyDiagnosisName | VARCHAR(200) | 第三诊断名称 |
| MajorProcedure | VARCHAR(20) | 主要手术/操作 |
| MajorProcedureName | VARCHAR(200) | 主要手术/操作名称 |
| SecondaryProcedure | VARCHAR(20) | 其他手术/操作 |
| SecondaryProcedureName | VARCHAR(200) | 其他手术/操作名称 |
| ThirdlyProcedure | VARCHAR(20) | 第三手术/操作 |
| ThirdlyProcedureName | VARCHAR(200) | 第三手术/操作名称 |
| SelectionCriteria | VARCHAR(500) | 入组条件 |
| UnionFlag | VARCHAR(1) | 联合规则标志 (1是0否) |
| ProvinceDr | VARCHAR(50) | 所属省份 (外键) |
| CityDr | VARCHAR(50) | 所属城市 (外键) |
| StartDate | DATE | 生效日期 (非空) |
| StopDate | DATE | 失效日期 |
| CreateDate | DATE | 创建日期 |
| CreateTime | TIME | 创建时间 |
| CreateUserDr | VARCHAR(50) | 创建人 (外键) |

#### 3.1.2 DRG核心算法数据表 (HB_DRGCoreAlgorithmData)
**类名**: `User.HBDRGCoreAlgorithmData`  
**表名**: `HB_DRGCoreAlgorithmData`

| 字段名 | 类型 | 说明 |
|--------|------|------|
| DRG | VARCHAR(10) | DRG编码 |
| DRGDESC | VARCHAR(100) | DRG描述 |
| Points | VARCHAR(20) | 基准点数 |
| PipValue | VARCHAR(20) | 预估点值 |
| DGDOV | VARCHAR(20) | 病组差异系数 |
| PayStandard | VARCHAR(20) | 支付标准 |
| ProvinceDr | VARCHAR(50) | 所属省份 (外键,非空) |
| CityDr | VARCHAR(50) | 所属城市 (外键,非空) |
| StartDate | DATE | 生效日期 (非空) |
| StopDate | DATE | 失效日期 |
| InsuType | VARCHAR(20) | 险种 |
| MdtrtArea | VARCHAR(20) | 就医地区划代码 |
| MedinsLv | VARCHAR(20) | 医疗机构等级 |
| FixmedinsName | VARCHAR(100) | 医疗机构名称 (非空) |
| FixmedinsCode | VARCHAR(50) | 医疗机构代码 (非空) |
| CreateDate | DATE | 创建日期 |
| CreateTime | TIME | 创建时间 |
| CreateUserDr | VARCHAR(50) | 创建人 (外键) |
| Identification | VARCHAR(50) | 标识码 |
| Remark | VARCHAR(99999) | 备注 |

#### 3.1.3 医保结算信息表 (BS_DRGMedInsuSettleMentInfo)
**类名**: `User.BSDRGMedInsuSettleMentInfo`  
**表名**: `BS_DRGMedInsuSettleMentInfo`

| 字段名 | 类型 | 说明 |
|--------|------|------|
| MdtrtId | VARCHAR(50) | 就诊ID (非空,索引) |
| PsnNo | VARCHAR(50) | 人员编号 (非空,索引) |
| SetlId | VARCHAR(50) | 结算ID (非空,索引) |
| CertNo | VARCHAR(50) | 证件号码 |
| MedcasNo | VARCHAR(50) | 病案号 (索引) |
| DclaTime | DATETIME | 申报时间 |
| PsnName | VARCHAR(50) | 姓名 |
| Gend | VARCHAR(10) | 性别 |
| Age | VARCHAR(10) | 年龄 |
| NwbAdmType | VARCHAR(10) | 新生儿入院类型 |
| NwbBirWt | VARCHAR(20) | 新生儿出生体重 |
| NwbAdmWt | VARCHAR(20) | 新生儿入院体重 |
| AdmWay | VARCHAR(10) | 入院途径 |
| TrtType | VARCHAR(10) | 治疗类别 |
| AdmTime | DATETIME | 入院时间 |
| DscgTime | DATETIME | 出院时间 |
| DscgCaty | VARCHAR(20) | 出院科别 |
| VentUsedDura | VARCHAR(20) | 呼吸机使用时长 |
| DscgWay | VARCHAR(10) | 离院方式 |
| DRG | VARCHAR(10) | DRG分组结果 |
| HISAdmID | VARCHAR(50) | HIS就诊流水号 |
| FixmedinsCode | VARCHAR(50) | 医疗机构编号 |
| UpdateDate | DATE | 数据更新日期 |
| UpdateTime | DATETIME | 数据更新时间 |

#### 3.1.4 分组记录表 (BS_DRGGroupRecord)
**类名**: `User.BSDRGGroupRecord`  
**表名**: `HB_DRGDRGGroupRecord`

| 字段名 | 类型 | 说明 |
|--------|------|------|
| DRG | VARCHAR(10) | DRG编码 |
| DRGDr | VARCHAR(50) | DRG算法数据ID (外键) |
| ProvinceDr | VARCHAR(50) | 省份ID (外键,非空) |
| CityDr | VARCHAR(50) | 城市ID (外键,非空) |
| CreateDate | DATE | 创建日期 |
| CreateTime | TIME | 创建时间 |
| CreateUserDr | VARCHAR(50) | 创建人 (外键) |
| FixmedinsCode | VARCHAR(50) | 医疗机构代码 |
| FixmedinsName | VARCHAR(100) | 医疗机构名称 |
| Identification | VARCHAR(50) | 标识码 |
| Remark | VARCHAR(99999) | 备注 |
| HISAdmID | VARCHAR(50) | HIS就诊ID |

#### 3.1.5 DRG基础数据子表 (HB_DRGBasicDataSub)
**类名**: `User.HBDRGBasicDataSub`  
**表名**: `HB_DRGBasicDataSub`

| 字段名 | 类型 | 说明 |
|--------|------|------|
| HBDictionariesDr | VARCHAR(50) | 平台字典ID (外键,非空) |
| Code | VARCHAR(20) | 代码 (非空,索引) |
| Descripts | VARCHAR(100) | 描述 (非空) |
| Identification | VARCHAR(99999) | 标识码-分类 |
| StartDate | DATE | 生效日期 (非空) |
| StopDate | DATE | 失效日期 |
| CreateDate | DATE | 创建日期 |
| CreateTime | TIME | 创建时间 |
| CreateUserDr | VARCHAR(50) | 创建人 (外键) |
| Remark | VARCHAR(99999) | 备注 |

> 注：此表用于存储"不作为分组规则的疾病诊断"和"不作为分组规则的手术操作"列表（通过HBDictionaries_Dr关联到字典表的InsuCode='NoRuleOfDiagnosis'或'NoRuleOfOperation'）

---

## 4. 接口设计

### 4.1 接口列表

| 接口Code | 接口名称 | 服务类 | 方法名 | 说明 |
|----------|----------|--------|--------|------|
| **02010001** | **DRG分组器** | src.DRG.Interface | Device | 执行DRG分组（主入口） |
| 02010035 | SaveDRGGroupRecord | src.DRG.Interface | SaveDRGGroupRecord | 保存DRG分组记录 |
| 02010036 | QueryDRGGroupRecord | src.DRG.Interface | QueryDRGGroupRecord | 查询DRG分组记录 |
| 02010504 | QueryGroupingStatistics | src.DRG.GroupDevice | QueryStatistics | 查询分组统计 |
| 02010505 | CalculatePayment | src.DRG.GroupDevice | CalculatePayment | 计算医保支付 |

### 4.2 接口详情

#### 02010001 DRG分组器 (Device) - 统一接口

> **重要说明**：所有DRG分组功能统一调用此接口，包括：
> - 病案分组（病历分组）
> - 结算清单分组
> - 自定义分组查询

- **功能**：执行DRG分组（主入口方法）
- **服务类**：src.DRG.Interface
- **调用类**：src.DRG.GroupDevice.Device()
- **接口Code**：02010001

**统一入参规范**：

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| MainDiagnosisCode | String | **是** | 主诊断ICD-10编码 |
| DiseInfo | Array | 否 | 诊断信息数组，对象格式：[{MainFlag, DiagSn, DiagCode, DiagName}, ...] |
| MainOperationCode | String | 否 | 主手术ICD-9-CM-3编码 |
| OprnInfo | Array | 否 | 手术信息数组，对象格式：[{MainFlag, OprnSn, OprnCode, OprnName}, ...] |
| Sex | String | 否 | 性别：1=男, 2=女 |
| Age | Integer | 否 | 年龄（岁） |
| AgeGroupDays | Integer | 否 | 新生儿出生天数（0-28） |
| NewbornFlag | String | 否 | 新生儿标志：1=是, 0=否 |
| RespiratorTime | Integer | 否 | 呼吸机时长（≥96h入MDCA） |
| ECMOFlag | String | 否 | ECMO标志：1=是, 0=否 |
| TransplantFlag | String | 否 | 器官移植标志：1=是, 0=否 |
| MarrowTransplantFlag | String | 否 | 骨髓移植标志：1=是, 0=否 |
| HIVFlag | String | 否 | HIV标志：1=是, 0=否 |
| TraumaLevel | Integer | 否 | 多发创伤等级（≥2入MDCZ） |
| Department | String | 否 | 科室 |
| HospitalDays | Integer | 否 | 住院天数 |
| TotalCost | Number | 否 | 总费用 |

**先期分组规则**：

| 参数条件 | 先期分组 | 说明 |
|----------|----------|------|
| TransplantFlag=1 | MDCA | 器官移植病例 |
| MarrowTransplantFlag=1 | MDCA | 骨髓移植病例 |
| ECMOFlag=1 | MDCA | ECMO治疗病例 |
| RespiratorTime ≥ 96 | MDCA | 呼吸机≥96小时 |
| AgeGroupDays 1-28 | MDCP | 新生儿疾病 |
| HIVFlag=1 | MDCY | HIV感染病例 |
| TraumaLevel ≥ 2 | MDCZ | 多发严重创伤 |

**返回结果**：MDC/ADRG/DRG分组结果

**前端调用示例**：
```typescript
// 统一封装在 frontend/src/api/drgGrouping.ts
import { drgGroup, convertMedicalRecordToParams, convertSettlementToParams } from '@/api/drgGrouping';

// 1. 病案分组
const medicalRecord = await queryMedicalRecord({ admissionNo: '12345' });
const params = convertMedicalRecordToParams(medicalRecord);
const result = await drgGroup(params);

// 2. 结算清单分组
const settlement = await querySettlementInfo({ admissionNo: '12345' });
const params = convertSettlementToParams(settlement);
const result = await drgGroup(params);

// 3. 自定义分组（使用正确的入参格式）
const result = await drgGroup({
  MainDiagnosisCode: 'I21.0',
  DiseInfo: [
    { MainFlag: 1, DiagSn: 1, DiagCode: 'I21.0', DiagName: '急性心肌梗死' },
    { MainFlag: 0, DiagSn: 2, DiagCode: 'I10', DiagName: '高血压' }
  ],
  MainOperationCode: '51.23',
  OprnInfo: [
    { MainFlag: '1', OprnSn: 1, OprnCode: '51.23', OprnName: '冠状动脉造影术' }
  ],
  Sex: '1',
  Age: 45,
  AgeGroupDays: 0,
  NewbornFlag: '0',
  RespiratorTime: 0,
  ECMOFlag: '0',
  TransplantFlag: '0',
  MarrowTransplantFlag: '0',
  HIVFlag: '0',
  TraumaLevel: 0,
  Department: '心内科',
  HospitalDays: 10,
  TotalCost: 24680.0
});
```

#### 分组流程（后端实现）
```
1. CheckRules - 分组前校验
   └─ 检查主诊断/主手术是否在不作为分组规则的列表中
   └─ 如在列表中，返回0000组（无法入组）

2. GroupPreMDC - MDC先期分组
   └─ MDCA: 器官移植/骨髓移植/ECMO/呼吸机≥96h
   └─ MDCP: 新生儿病例（出生天数1-28天）
   └─ MDCY: HIV感染病例
   └─ MDCZ: 多发严重创伤（等级≥2）
   └─ 常规MDC: 通过主诊断匹配

3. GroupADRG - ADRG分组
   └─ 先期分组+联合分组规则
   └─ 先期分组+非联合分组规则
   └─ 非先期分组+联合分组规则
   └─ 非先期分组+非联合分组规则+主要诊断
   └─ 非先期分组+非联合分组规则+主要手术操作

4. DRG细分 - 结合其他诊断、合并症/并发症确定最终DRG
```

#### 02010502 QueryGroupingResult
- **功能**：查询分组结果
- **参数**：startDate, endDate, deptCode, doctorCode, mdcCode, adrgCode, drgCode, page, limit
- **返回**：分组结果列表

#### 02010503 QueryDRGDetail
- **功能**：查询DRG详情
- **参数**：drgCode
- **返回**：DRG详细信息（权重、支付标准等）

#### 02010504 QueryGroupingStatistics
- **功能**：查询分组统计
- **参数**：year, month, deptCode, statType
- **返回**：分组统计数据

#### 02010505 CalculatePayment
- **功能**：计算医保支付金额
- **参数**：medicalRecordId, drgCode, totalFee
- **返回**：支付标准、盈亏金额等

---

## 5. 业务流程

### 5.1 分组流程
```
病案数据采集 → 数据校验 → DRG分组 → 结果审核 → 结算清单生成 → 医保结算
```

### 5.2 批量分组流程
```
定时任务触发 → 选取未分组病案 → 批量分组 → 结果存储 → 统计报表生成
```

---

## 6. 性能要求

- 单个病案分组响应时间 < 2秒
- 批量分组（100份）响应时间 < 30秒
- 分组查询响应时间 < 2秒
- 支持1000+并发用户

---

## 7. 安全要求

- 登录验证
- 权限控制
- 操作日志记录
- 数据加密传输

---

## 8. 验收标准

- [ ] 病案数据能够正确采集
- [ ] DRG分组能够正常执行
- [ ] 分组结果查询功能正常
- [ ] 医保支付计算准确
- [ ] 分组统计报表数据准确
- [ ] 分组规则能够正确配置
- [ ] 性能满足要求
- [ ] 界面友好，操作流畅
