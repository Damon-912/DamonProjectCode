## Context

当前DRG核心算法配置表（`HB_DRGCoreAlgorithmData`）已包含基准点数(Points)、预估点值(PipValue)、病组差异系数(DGDOV)、支付标准(PayStandard)等核心数值字段。医保控费预警系统需要额外的倍率和权重参数来进行费用异常判定：高倍率判定费用偏高病例、低倍率判定费用偏低病例、权重用于病组间费用比较。

本次变更是在已有表结构和业务逻辑基础上，新增三个可选数值字段，保持与现有架构完全兼容。

## Goals / Non-Goals

**Goals:**
- 在 `HB_DRGCoreAlgorithmData` 表新增 `HighMultiplier`、`LowMultiplier`、`Weight` 三个可选数值字段
- 后端 CRUD 接口全部支持新字段的读写
- 前端配置页面支持新字段的展示、新增、编辑
- 导入导出功能（模板下载、预览、确认导入）支持新字段
- 保持与现有数据的完全向后兼容

**Non-Goals:**
- 不修改 DIP 核心算法配置（`HB_DIPCoreAlgorithmData`）——仅修改 DRG 部分
- 不在本次变更中实现基于新字段的预警判定逻辑——仅完成数据存储层
- 不修改数据库索引结构——新字段不需要额外索引
- 不修改接口协议格式（继续使用 02010032/02010033/02010034 接口）

## Decisions

### Decision 1: 字段命名与数据类型

- **HighMultiplier**（高倍率）：`%String` 类型，SqlColumnNumber = 23，非必填
- **LowMultiplier**（低倍率）：`%String` 类型，SqlColumnNumber = 24，非必填
- **Weight**（权重）：`%String` 类型，SqlColumnNumber = 25，非必填

**理由**：与现有字段 Points、PipValue、DGDOV 等保持一致，全部使用 `%String` 存储数值（支持任意精度小数）。字段名前端使用小驼峰 `highMultiplier`/`lowMultiplier`/`weight`，后端使用与表属性一致的大写开头命名。

### Decision 2: 新字段为可选（非 Required）

**理由**：新字段为医保控费预警场景使用，并非所有DRG配置都需要。设为可选不会破坏现有数据的完整性约束，已有的新增/编辑操作无需强制填写这些字段。空值在预警判定时视为不启用倍率判断。

### Decision 3: 表单布局位置

新增字段放置在"算法参数"Card 内，布局在"预估支付标准"字段之后，与现有算法参数字段分组一致。

### Decision 4: 导入CSV模板扩展

在现有 CSV 模板末尾追加三列 `HighMultiplier,LowMultiplier,Weight`，示例值填 `NULL`（与其他可选字段一致）。

### Decision 5: SqlColumnNumber 分配

当前表最大 SqlColumnNumber 为 22（Year 字段），新字段依次分配 23、24、25。Storage Default Data 块需同步增加对应的 Value 节点。

## Risks / Trade-offs

- **[低风险] 表结构变更**：IRIS 的对象存储支持动态属性扩展，新增字段不影响已有数据行。Storage 块更新后需要编译类和重建索引（如有需要）。→ **缓解**：新字段不参与索引，无需重建索引；编译类后即可生效。
- **[低风险] 前后端字段不同步**：如果后端接口未更新但前端已传新字段，会因动态对象方式的 JSON 序列化而自然忽略未定义的属性。→ **缓解**：分步骤部署，先部署后端再部署前端。
- **[无风险] 数据兼容性**：所有现有记录的三个新字段为空，不会影响现有查询和业务逻辑。
