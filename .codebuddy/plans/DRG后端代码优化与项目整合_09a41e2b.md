---
name: DRG后端代码优化与项目整合
overview: 分析优化用户已有的后端DRG分组器代码和表结构，整合到OpenSpec项目架构中，修复代码问题并补充缺失功能
todos:
  - id: explore-existing-code
    content: 使用[subagent:code-explorer]全面分析现有后端代码结构和逻辑
    status: completed
  - id: review-code-standards
    content: 使用[skill:iris代码规范]审查代码规范问题，生成优化建议
    status: completed
    dependencies:
      - explore-existing-code
  - id: optimize-groupdevice
    content: 优化GroupDevice分组器代码，修复Bug，完善ADRG规则
    status: completed
    dependencies:
      - review-code-standards
  - id: create-base-service
    content: 创建BaseService基类，提取公共方法(返回封装、日志、错误处理)
    status: completed
    dependencies:
      - review-code-standards
  - id: refactor-model-classes
    content: 重构表结构类到Model层，优化索引和关系定义
    status: completed
    dependencies:
      - review-code-standards
  - id: create-grouping-service
    content: 创建DRG.GroupingService.cls整合优化后的分组逻辑
    status: completed
    dependencies:
      - optimize-groupdevice
      - create-base-service
  - id: create-medicalrecord-service
    content: 创建DRG.MedicalRecordService.cls整合病历服务
    status: completed
    dependencies:
      - create-base-service
  - id: create-rest-api
    content: 创建REST接口层，提供分组和病历查询API
    status: completed
    dependencies:
      - create-grouping-service
      - create-medicalrecord-service
  - id: integrate-to-project
    content: 将优化后的代码整合到项目目录结构中，更新设计文档
    status: completed
    dependencies:
      - create-rest-api
---

## 需求描述

用户已将DRG/DIP医保控费预警系统的后端表结构和服务类开发完成，需要对这些代码进行分析优化并整合到项目结构中。

### 现有代码资产

- **27个表结构类**: 包含病案首页(BSDRGMedInsuMedicalRecord)、诊断(BSDRGPatientDiagnosis)、手术(BSDRGPatientOperation)、费用明细(BSDRGFeeDetail)、ADRG规则表(CBDRGCoreGroupsList)等
- **服务类**: 
- GroupDevice.txt - DRG分组器核心算法(4步分组流程)
- MedicalRecord.txt - 病历服务(HIS对接)
- MIService.txt - 医保接口服务
- BasicData/ - 基础数据服务

### 待解决问题

1. 变量名拼写错误(iCounA/iCountA)
2. 部分ADRG分组规则未实现(IB1/JA1/JA2/NA1等)
3. QY组和0000组处理不完整
4. 缺少DRG权重查询功能
5. 代码结构需优化整合

### 目标

将现有代码优化整合到项目架构中，形成完整的后端服务层，提供REST API接口。

## 技术方案

### 技术栈确认

- **后端平台**: InterSystems IRIS/Cache 2019+
- **编程语言**: ObjectScript
- **架构模式**: 分层架构(服务层/模型层/接口层)

### 代码优化策略

#### 1. 目录结构调整

```
backend/cls/
├── DRG/                    # 业务服务层
│   ├── GroupingService.cls    # 分组器服务(整合GroupDevice.txt)
│   ├── MedicalRecordService.cls # 病历服务(整合MedicalRecord.txt)
│   ├── MIService.cls          # 医保服务(整合MIService.txt)
│   └── BaseService.cls        # 服务基类(提取公共方法)
├── Model/                  # 数据模型层
│   ├── PatientCase.cls        # 病案类(优化BSDRGMedInsuMedicalRecord)
│   ├── Diagnosis.cls          # 诊断类(优化BSDRGPatientDiagnosis)
│   ├── Operation.cls          # 手术类(优化BSDRGPatientOperation)
│   ├── DRGResult.cls          # 分组结果类(优化BSDRGGroupRecord)
│   ├── FeeDetail.cls          # 费用明细类(优化BSDRGFeeDetail)
│   └── DRGRule.cls            # DRG规则类(优化CBDRGCoreGroupsList)
├── REST/                   # REST接口层
│   ├── GroupingAPI.cls        # 分组API
│   ├── MedicalRecordAPI.cls   # 病历API
│   └── BaseAPI.cls            # API基类
└── Common/                 # 公共类
    ├── BaseService.cls
    ├── Utils.cls
    └── Constants.cls
```

#### 2. 关键优化点

| 优化项 | 具体措施 |
| --- | --- |
| 代码规范 | 使用iris代码规范技能，统一命名规范 |
| Bug修复 | 修复变量名拼写错误，完善SQL语句 |
| 规则完善 | 补充缺失的ADRG分组规则(IB1/JA1/JA2等) |
| 功能增强 | 增加权重查询、QY组处理、异常处理 |
| 架构优化 | 提取公共方法到基类，统一返回格式 |


#### 3. 分组算法优化方案

- 完善先期分组逻辑(MDCA/MDCP/MDCY/MDCZ)
- 补充ADRG联合分组规则(AC1/AH2/BB1/CB2等)
- 实现QY组(歧义组)判定逻辑
- 增加0000组(无法入组)处理
- 添加权重和费用标准查询

#### 4. REST API设计

- 统一接口返回格式(code/message/data)
- JWT认证集成
- 错误处理和日志记录
- 批量任务异步处理

## Agent扩展使用

### Skill

- **iris代码规范**
- 用途: 确保ObjectScript代码符合IRIS开发规范，包括命名规范、类定义、方法编写、SQL使用等
- 预期结果: 生成符合普瑞HIS系统标准的代码，统一代码风格

### SubAgent

- **code-explorer**
- 用途: 深入分析用户现有代码文件，提取关键逻辑和结构
- 预期结果: 完整理解GroupDevice.txt、MedicalRecord.txt等文件的实现细节，为整合提供依据