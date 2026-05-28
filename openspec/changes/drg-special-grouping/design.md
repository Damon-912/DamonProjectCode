## Context

当前 `GroupDevice.Device` 方法的分组流程为：

```
Step 1: CheckRules（分组前校验）
Step 2: GroupPreMDC（MDC先期分组）
Step 3: CheckGroupQY（QY歧义组判断）
Step 4: GroupADRG（ADRG分组）→ 返回ADRG编码列表
Step 5: GroupComplication（并发症CC/MCC确认）
Step 6: GroupDRG（DRG细分分组）→ 拼装最终DRG编码
Step 7: 查询DRG算法配置（支付标准、基准点数等）
Step 8: 保存分组记录
```

当前系统仅支持标准CHS-DRG分组规则，无法处理各地医保局发布的"特异化分组方案"（细分组方案内涵表）。例如合肥市2026年发布的分组内涵表中，某些诊断编码和手术编码组合会直接对应到特定的DRG编码，而非通过标准ADRG→细分规则→DRG的流程。

**约束**：
- IRIS ObjectScript 2019+ 语法
- 前后端分离架构，后端通过 `src.DRG.BasicData.InterFace` 入口统一路由
- 分组器 `GroupDevice.cls` 为现有核心代码，改动需最小化侵入
- 必须兼容存量逻辑——无特异化配置时，行为完全相同

## Goals / Non-Goals

**Goals:**
1. 新增 `HB_DRGSpecialGroup` 数据表，支持存储各地特异化分组方案的诊断/手术编码匹配规则
2. 在 `Device` 方法中增加特异化分组匹配步骤，命中时直接返回特异化DRG编码，覆盖标准分组结果
3. 提供后端CRUD接口（查询/新增/编辑/删除），支持按省市和年份筛选
4. 提供前端维护页面，支持省市联动筛选、新增/编辑弹窗
5. 通用化设计——不仅支持合肥，任何地区均可通过配置使用

**Non-Goals:**
- 不修改标准CHS-DRG分组流程的内部逻辑
- 不涉及DIP分组的特异化规则
- 不在前端预警流程中增加特异化分组的独立处理，仅后端分组器支持即可

## Decisions

### 决策0：Device方法改动的安全备案

**选择**: 改动 `Device` 方法前，先将现有完整方法代码复制生成 `DeviceOLD` 方法作为备案。

**理由**:
- Device 方法是分组器的核心入口，任何改动需有回退机制
- DeviceOLD 保留原始全部代码，确保紧急情况下可切换回旧版本
- 符合生产系统变更管理规范

### 决策1：特异化分组在分组流程中的插入位置及前置条件

**选择**: 在 ADRG 分组完成后（Step 4之后）、DRG细分分组前（Step 6之前）插入"特异化分组匹配"步骤。**且仅当调用分组服务时入参包含医疗机构信息（hospinfo非空）时才执行该步骤**。

**理由**:
- 特异化分组方案是地方性的，需要知道患者就诊的医疗机构所属行政区划才能正确匹配（通过hospinfo获取省市信息）
- 如果调用方未传入医疗机构信息（如无医院关联的分组场景），执行特异化分组匹配没有意义且可能误匹配
- ADRG分组完成后已有ADRG编码，可通过DRG编码前缀（前3位）作为过滤维度关联特异化规则中的DRG编码
- 若特异化分组匹配成功，则跳过后续的 CC/MCC 并发症判断和标准DRG细分规则，直接使用特异化DRG编码

**替代方案考虑**:
- 无医疗机构信息时也执行匹配：可能跨地区误匹配，且无法确定应使用哪个地区的特异化方案
- 在Step 6 GroupDRG内部判断：会导致GroupDRG方法逻辑过于复杂，且需传递额外参数
- 在Step 2 GroupPreMDC中判断：特异化分组方案按DRG编码分类（DRG编码前缀=ADRG编码），此时尚未获得ADRG，判断时机过早

### 决策2：GroupFactors 结构化入组因素——驱动匹配逻辑

**选择**: `GroupFactors` 字段不再仅作为文本说明，而是作为**结构化入组因素**，由分组器解析后**动态决定匹配逻辑**。支持 `+`（AND）和 `或`（OR）两种运算符。

**GroupFactors 结构化语法**:

```
入组因素格式:  <字段组> [运算符 <字段组>] ...
运算符:        "+" = AND（且）, "或" = OR（或）
字段组:        "主要诊断" | "次要诊断" | "主要手术" | "次要手术"
```

**解析规则与匹配逻辑**:

| GroupFactors 示例 | 解析后的匹配逻辑 |
|-------------------|-----------------|
| `主要诊断+主要手术` | 主诊断匹配 AND 主手术匹配 |
| `主要诊断+主要手术+次要手术` | 主诊断匹配 AND 主手术匹配 AND 次要手术匹配 |
| `主要诊断或次要诊断+主要手术` | (主诊断匹配 OR 次要诊断匹配) AND 主手术匹配 |
| `主要手术` | 仅主手术匹配（其余字段不参与） |
| `主要诊断+次要诊断+主要手术` | 主诊断匹配 AND 次要诊断匹配 AND 主手术匹配 |

**匹配算法流程**:

```
对每条候选规则执行:
  1. 解析 GroupFactors 字段为结构化表达式
  2. 按运算符优先级执行匹配判断:
     - OR 组内: 任一非空编码字段匹配即通过
     - AND 连接: 所有组合全部通过才算命中
  3. 各编码字段内部: 拆分逗号分隔编码，任一匹配即通过（ICD双向包含）
  4. 空编码字段: 视为无条件通过
```

**理由**:
- 合肥方案中某些规则存在"主要诊断3选1"（同一字段多编码）和"主要诊断或次要诊断"（跨字段OR）的需求，纯AND逻辑无法覆盖
- 结构化语法简洁直观：`+` 对应 AND，`或` 对应 OR，与业务描述语言一致
- 字段内部的多编码逗号分隔仍是 OR 关系（任选其一），不影响现有设计
- ICD编码层级匹配继续使用已有的 `IsCodeMatch` 方法，支持双向包含

**实现要点**:
- `GroupSpecialMatch` 方法中新增 `ParseGroupFactors` 子方法：将字符串如 `"主要诊断或次要诊断+主要手术"` 解析为结构化匹配指令
- 解析结果为一个二维数组：`[ ["主要诊断","次要诊断"], ["主要手术"] ]`，其中第一层为 AND 关系，第二层为 OR 关系
- 匹配时先执行第二层 OR 匹配，再执行第一层 AND 组合

### 决策3：数据库表设计

**选择**: 创建独立的 `HB_DRGSpecialGroup` 表，采用扁平字段结构（一个字段存所有编码，用逗号分隔）。

**字段设计**:
| 字段 | 类型 | 说明 |
|------|------|------|
| DRGCode | VARCHAR(10) | DRG编码(必填，前3位为ADRG编码) |
| DRGName | VARCHAR(200) | DRG名称(必填) |
| PrincipalDiagnosis | VARCHAR(500) | 主要诊断编码(逗号分隔多个) |
| PrincipalDiagnosisName | VARCHAR(2000) | 主要诊断名称 |
| SecondaryDiagnosis | VARCHAR(500) | 次要诊断编码(逗号分隔多个) |
| SecondaryDiagnosisName | VARCHAR(2000) | 次要诊断名称 |
| MajorProcedure | VARCHAR(500) | 主要手术编码(逗号分隔多个) |
| MajorProcedureName | VARCHAR(2000) | 主要手术名称 |
| SecondaryProcedure | VARCHAR(500) | 次要手术编码(逗号分隔多个) |
| SecondaryProcedureName | VARCHAR(2000) | 次要手术名称 |
| GroupFactors | VARCHAR(200) | 入组因素说明 |
| Remark | VARCHAR(500) | 备注 |
| Admvs | VARCHAR(10) | 行政区划代码(必填，如340100) |
| Province_Dr | VARCHAR(50) | 省(外键→CB_Province) |
| City_Dr | VARCHAR(50) | 市(外键→CB_City) |
| Year | VARCHAR(4) | 分组方案年份 |
| StartDate | DATE | 生效日期 |
| StopDate | DATE | 失效日期 |
| CreateDate | DATE | 创建日期 |
| CreateTime | TIME | 创建时间 |

**理由**:
- 扁平字段结构与图片表格一致，方便数据导入和业务理解
- 不单独存储ADRG编码：DRG编码前3位即为ADRG编码（如 DRGCode="CB46" → ADRG="CB4"），存储冗余信息无必要，查询时通过 `LEFT(DRGCode, 3)` 等效过滤
- 新增 Admvs 字段：存储行政区划代码，作为地区匹配的主要维度，兼容市本级（6位）、省直（4位+99）、异地等多种场景
- 逗号分隔多编码是现有系统的一致做法（如 `CB_DRGCoreGroupsList` 的 PrincipalDiagnosis 字段）
- 继承现有省市外键体系（`Province_Dr` / `City_Dr`），与 `HB_DRGSegmentationRules` 保持一致
- 增加 Year 字段支持按年份管理分组方案

### 决策4：前端页面架构

**选择**: 参考 `DRGSegmentationRules` 页面的实现模式——表格+弹窗CRUD，省市联动下拉筛选。

**页面结构**:
- 顶部查询区：DRG代码、行政区划代码（Admvs）、省、市、年份筛选条件
- 表格列：序号、DRG编码、DRG名称、主要诊断编码/名称、次要诊断编码/名称、主要手术编码/名称、次要手术编码/名称、行政区划代码、入组因素、备注
- 新增/编辑弹窗：所有字段的表单输入，省市联动下拉（自动填充Admvs）
- 删除：二次确认后物理删除

### 决策5：分组器集成方式

**选择**: 新增独立方法 `GroupSpecialMatch`，在 `Device` 方法中作为新增步骤调用。改动前先将当前 `Device` 方法完整代码复制为 `DeviceOLD` 方法。

**伪代码**:
```
// 0. 改动前：复制 DeviceOLD（已在实施时完成）

// 5. 第四步B：特异化分组匹配（新增步骤，仅当hospinfo非空时执行）
if (hospinfo.%Size() > 0) {
    set joRtn = ..GroupSpecialMatch(jsonObj, MDC, jaADRG)
    if (joRtn.errorCode = "0") {
        // 命中特异化分组，直接使用特异化DRG
        set DRG = joRtn.result.drgCode
        set DRGDesc = joRtn.result.drgDesc
        // 跳过 CC/MCC 确认和标准 DRG 细分分组
        goto Step7  // 直接进入算法配置查询
    }
}
// hospinfo为空或未命中，继续原流程（Step 5 Complication → Step 6 GroupDRG）
```

**理由**: 
- 独立方法便于测试和后续扩展
- 通过返回值判断是否命中，清晰明了
- 命中时跳过 CC/MCC 和标准 DRG 分组，避免不必要的计算

## Risks / Trade-offs

- [风险] **特异化分组规则与标准分组规则冲突** → 缓解：特异化分组优先级高于标准分组；配置表中明确标注入组因素，运维人员可追溯
- [风险] **ICD编码版本不一致** → 缓解：使用双向包含匹配（如入参 "H25.900" 可匹配配置 "H25.9"），降低版本差异影响；后续可扩展 ICD 版本映射
- [风险] **跨年度方案切换** → 缓解：表设计中包含 Year 字段和 StartDate/StopDate，分组器根据传入年份匹配对应方案
- [已解决] **入组因素字段已升级为结构化解析**：GroupFactors 字段通过 `+`（AND）和 `或`（OR）语法驱动动态匹配逻辑，不再局限于纯AND组合

## Migration Plan

1. **数据库变更**: 部署 `User.HBDRGSpecialGroup` 持久化类（自动建表）
2. **后端部署**: 部署 `src.DRG.BasicData.DRGSpecialGroup.cls` 业务类，更新 `InterFace.cls` 入口类
3. **分组器更新**: 先将现有 `Device` 方法复制为 `DeviceOLD` 方法备案；再部署更新后的 `GroupDevice.cls`（增加 `GroupSpecialMatch` 方法和 `Device` 流程调整）
4. **前端部署**: 部署 `SpecialDRGGrouping.tsx` 页面，更新路由配置
5. **数据初始化**: 通过前端维护页面或SQL脚本导入合肥市2026年特异化分组数据

**回滚策略**: 
- 若 `HB_DRGSpecialGroup` 表无数据（默认状态）或未传入医疗机构信息（hospinfo为空），分组器行为与改造前完全一致
- 若需紧急回滚，将 `DeviceOLD` 方法代码覆盖回 `Device` 方法即可（不涉及标准流程修改）

## Open Questions（已确认）

1. **入组因素字段是否需要解析为结构化匹配逻辑？** 
   → **需要**。已更新决策2：GroupFactors 字段使用 `+`（AND）/ `或`（OR）结构化语法驱动动态匹配逻辑。详见 [决策2](#决策2groupfactors-结构化入组因素驱动匹配逻辑)。

2. **特异化分组匹配命中时，并发症信息如何处理？**
   → **直接返回，不考虑并发症信息处理**。特异化分组命中后跳过 CC/MCC 判断，DRGDesc 仅包含入组因素标识（格式："DRG名称（特异化分组：入组因素描述）"），不携带并发症说明。

3. **是否需要支持版本号管理？**
   → **不需要**。当前仅使用 Year 字段区分年份即可满足需求，无需额外的版本号字段。若一年内有多次方案更新，通过 StartDate/StopDate 字段的生效/失效日期控制。
