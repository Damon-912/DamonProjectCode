## Context

DRG核心算法配置是医保控费系统的基础数据模块，操作HB_DRGCoreAlgorithmData表，存储DRG代码、基准点数、预估点值、病组差异系数、支付标准等核心算法参数。当前系统已实现单条数据的增删改查（接口02010032/02010033/02010034），但缺少批量导入能力。

ICD编码导入功能（前端ICDQuery.tsx、后端InterFace.cls 02010038/02010039/02010040）提供了成熟的三步导入模式：上传文件→预览校验→确认导入。本次需求完全参考该实现模式，为DRG算法配置增加导入功能。

## Goals / Non-Goals

**Goals:**
- 提供DRG算法数据的标准CSV导入模板下载（字段：DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard）
- 实现与ICD编码导入一致的三步交互流程（上传→预览→结果）
- 导入时关联省、市、医疗机构信息（MdtrtArea、FixmedinsCode、FixmedinsName、MedinsLv）
- 后端新增02010050/02010051/02010052三个接口，使用operatetable操作HB_DRGCoreAlgorithmData表
- 支持必填字段校验、数值格式校验、重复数据检测

**Non-Goals:**
- 不支持Excel格式（仅支持CSV，与ICD导入保持一致）
- 不实现复杂的业务规则校验（仅基础数据格式校验）
- 不涉及DRG分组逻辑算法的修改

## Decisions

### 1. 完全复用ICD编码导入的前端交互模式
参考ICDQuery.tsx的实现，采用相同的三步导入流程（Steps组件）、相同的弹框布局、相同的文件上传处理方式（Base64编码）。

**Rationale**：保持用户体验一致性，减少前端开发工作量，降低用户学习成本。

### 2. 后端接口编号采用02010050-02010052
在InterFace.cls中新增三个接口方法：
- 02010050 PreviewImportDRGCoreAlgorithm - 预览/校验
- 02010051 ConfirmImportDRGCoreAlgorithm - 确认导入
- 02010052 DownloadDRGCoreAlgorithmTemplate - 下载模板

**Rationale**：延续现有接口编号体系（02010032-02010034为DRG算法配置CURD，02010038-02010040为ICD导入），便于接口管理和维护。

### 3. 行政区划和医疗机构关联策略
导入弹框要求用户必选省、市、医疗机构：
- **省**：用于设置Province_Dr字段，并作为获取市列表的参数
- **市**：市接口返回值中的Code字段作为MdtrtArea（行政区划代码）
- **医疗机构**：从医疗机构接口获取OrganizationCode→FixmedinsCode、Descripts→FixmedinsName、HospGrade_Dr→MedinsLv

**Rationale**：与ICD导入相比，DRG算法数据需要更精确的机构定位，通过前置选择确保数据归属准确。

### 4. CSV解析采用与ICD导入相同的Base64解码逻辑
使用`$zcvt(fileData, "I", "BASE64")`或`##class(%SYSTEM.Encryption).Base64Decode`进行解码，支持UTF-8和GB18030编码自动适配。

**Rationale**：复用经过验证的编码处理逻辑，避免中文乱码问题。

### 5. 数据重复判定策略
以DRG代码+行政区划代码（MdtrtArea）+医疗机构代码（FixmedinsCode）为唯一性判定条件。

**Rationale**：同一DRG代码在不同地区、不同机构可以有不同的算法参数，需要支持多维度重复检测。

## Risks / Trade-offs

| 风险 | 缓解措施 |
|------|----------|
| 市接口返回值中Code字段可能不是标准的行政区划代码 | 与后端确认接口返回值字段，必要时增加字段映射配置 |
| 医疗机构接口返回的HospGrade_Dr可能需要转换 | 确认机构等级字段的数据字典映射关系 |
| 大批量导入可能导致性能问题 | 限制单次导入最大行数（建议1000行），超出分批处理 |
| CSV格式不标准导致解析失败 | 提供标准模板下载，模板中包含数据示例和格式说明 |

## Migration Plan

1. **后端开发**：
   - CoreAlgorithm.cls新增PreviewImportDRGCoreAlgorithm方法
   - CoreAlgorithm.cls新增ConfirmImportDRGCoreAlgorithm方法  
   - CoreAlgorithm.cls新增DownloadDRGCoreAlgorithmTemplate方法
   - InterFace.cls新增02010050/02010051/02010052接口代理方法

2. **前端开发**：
   - 在DRGCoreAlgorithm.tsx页面增加导入按钮
   - 创建导入弹框组件（参考ICDQuery.tsx的Import Modal实现）
   - 实现模板下载、文件上传、数据预览、确认导入功能
   - 新增API接口调用（previewDrgImport、confirmDrgImport、downloadDrgTemplate）

3. **接口联调**：验证省/市/医疗机构选择→参数传递→数据保存的完整流程

4. **测试验证**：功能测试、性能测试、边界场景测试（空文件、超大文件、格式错误等）

5. **上线部署**：无数据迁移需求，直接部署前后端代码

## Open Questions

- 医疗机构接口的具体返回值字段需要确认（OrganizationCode、Descripts、HospGrade_Dr）
- 是否需要支持导入数据的修改（覆盖）功能，还是仅新增？
- 单次导入的最大行数限制为多少合适？
