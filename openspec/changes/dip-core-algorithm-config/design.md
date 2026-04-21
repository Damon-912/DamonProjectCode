## Context

DIP（按病种分值付费）核心算法配置是医保控费系统的基础数据管理模块。目前已有的 `User.HBDIPCoreAlgorithmData` 表类定义了 DIP 算法所需的核心字段，包括主要诊断、手术操作、省市信息、分值系数等，但缺少对应的业务操作类（BS 类）和前端管理界面。

参考项目已实现的功能：
- DRG 核心算法配置 (`CoreAlgorithmConfig.tsx`) 提供了完整的增删改查和导入功能
- ICD 信息管理 (`ICDInfo.cls`) 展示了后端 operatetable 模式的标准用法

本项目需要按照同样的架构风格，为 DIP 算法配置实现完整的前后端功能。

## Goals / Non-Goals

**Goals:**
- 实现 DIP 核心算法配置的列表查询（分页、筛选）
- 实现 DIP 核心算法配置的新增/编辑功能（表单验证、关联数据加载）
- 实现 DIP 核心算法配置的删除功能（物理删除 + 操作日志）
- 前端界面风格与现有 DRG 算法配置保持一致
- 后端采用 operatetable 工具类统一处理数据操作

**Non-Goals:**
- 不包含批量导入功能（可在后续迭代中添加）
- 不修改 `User.HBDIPCoreAlgorithmData` 表结构
- 不实现复杂的权限控制（沿用现有菜单权限体系）

## Decisions

### 1. 后端业务类设计
**Decision:** 在已有的 `src.DRG.BasicData.CoreAlgorithm` 类中添加三个 DIP 算法配置方法：
- `QueryDIPCoreAlgorithm` (接口号 02010053) - 查询列表
- `SaveDIPCoreAlgorithm` (接口号 02010054) - 保存（新增/更新）
- `DeleteDIPCoreAlgorithm` (接口号 02010055) - 删除

**Rationale:** 
- 将 DRG 和 DIP 核心算法配置放在同一类中，便于维护和管理
- 复用现有 `IsRecordActive` 等通用方法
- 接口号沿用 020100xx 基础数据管理段，紧接 DRG 算法配置的 02010032-02010034

### 2. 数据操作模式
**Decision:** 统一使用 `src.util.operatetable` 工具类进行 Insert/Update/Delete 操作

**Rationale:**
- 与 ICDInfo 等现有功能保持一致
- 自动记录操作日志，便于审计追溯
- 简化代码，避免重复实现数据校验和日志逻辑

**示例代码模式：**
```objectscript
set insObj={}
set insObj.className="User.HBDIPCoreAlgorithmData"
do data.%Push(dataObj)
set insObj.data=data
set rtn=##class(src.util.operatetable).Update(.insObj)
```

### 3. 前端页面设计
**Decision:** 参考 `CoreAlgorithmConfig.tsx` 实现 `DIPCoreAlgorithmConfig.tsx`

**Rationale:**
- DIP 与 DRG 算法配置在交互模式上高度相似
- 保持界面风格一致性，降低用户学习成本
- 包含相同的省市区联动、医疗机构选择等通用组件

### 4. 字段映射关系
根据 `HBDIPCoreAlgorithmData` 表结构，前后端字段映射如下：

| 前端字段 | 后端字段 | 说明 |
|---------|---------|------|
| principalDiagnosis | PrincipalDiagnosis | 主要诊断代码（必填）|
| principalDiagnosisName | PrincipalDiagnosisName | 主要诊断名称（必填）|
| majorProcedure | MajorProcedure | 主要手术代码 |
| majorProcedureName | MajorProcedureName | 主要手术名称 |
| secondaryProcedure | SecondaryProcedure | 相关手术代码 |
| secondaryProcedureName | SecondaryProcedureName | 相关手术名称 |
| provinceDr | ProvinceDr | 省（必填）|
| cityDr | CityDr | 市（必填）|
| mdtrtArea | MdtrtArea | 就医地区划代码 |
| medinsLv | MedinsLv | 医疗机构等级（必填）|
| scoreValue | ScoreValue | 基准分值（必填）|
| adjustCoefficient | AdjustCoefficient | 调节系数 |
| primaryAdjustCoefficient | PrimaryAdjustCoefficient | 一级调节系数 |
| secondaryAdjustCoefficient | SecondaryAdjustCoefficient | 二级调节系数 |
| thirdAdjustCoefficient | ThirdAdjustCoefficient | 三级调节系数 |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| 省市级联数据量大导致加载慢 | 使用分页下拉组件，支持搜索过滤 |
| 必填字段校验不一致 | 前后端都做必填校验，后端为主 |
| 并发编辑冲突 | operatetable 自动处理版本控制 |
| 接口号冲突 | 使用新的连续接口号段 02010053-02010055 |

## Open Questions

1. 是否需要根据医疗机构等级自动填充对应的调节系数？
   - 建议：首期手动填写，后续可添加自动计算逻辑

2. 查询条件是否需要支持主要诊断和手术的模糊匹配？
   - 建议：支持 code 和 name 的 like 查询
