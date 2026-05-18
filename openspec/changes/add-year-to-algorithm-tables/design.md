## Context

当前 DRG/DIP 算法配置存储在两张独立的 IRIS 表中：
- **HB_DRGCoreAlgorithmData**: 存储 DRG 分组对应的基准点数、点值、差异系数、支付标准等算法参数
- **HB_DIPCoreAlgorithmData**: 存储 DIP 分组对应的基准分值、调节系数等算法参数

两张表当前均没有年份维度，所有年度的算法数据混合存储。由于各地 DRG/DIP 分组方案每年都会调整，需要按年度隔离管理。

后端分组查询（`GroupDevice.cls`）：
- DRG 分组: `Device()` 方法在分组完成后通过 SQL 查询 `HB_DRGCoreAlgorithmData` 获取算法参数（Points、PipValue、DGDOV、PayStandard）
- DIP 分组: `GetDIPGroupScore()` 方法（接口 02010003）通过 SQL 查询 `HB_DIPCoreAlgorithmData` 获取分值
- 病历保存: `SaveMedRecInfo()` 方法查询 DRG 指向时也使用 `HB_DRGCoreAlgorithmData`

前端 DRG/DIP 算法配置页面已实现完整的增删改查、导入导出功能，但缺少年份维度。

## Goals / Non-Goals

**Goals:**
- 在 `HB_DRGCoreAlgorithmData` 和 `HB_DIPCoreAlgorithmData` 表中增加 `Year` 字段（4位年份）
- 将 `Year` 纳入唯一索引，确保同一年份内业务键唯一
- 分组查询接口（Device、GetDIPGroupScore）按年份查询，支持当年无数据时回退到上一年
- 前端算法配置页面增加年份筛选、展示、新增/编辑必填、导入时必选

**Non-Goals:**
- 不修改分组规则本身（MDC、ADRG、DRG 分组逻辑不变）
- 不涉及其他表的年份改造
- 不提供跨年份数据对比/分析功能
- 不做自动年份切换的定时任务

## Decisions

### 1. Year 字段设计

**决策**: `Year` 使用 `%String(MAXLEN=4)` 类型，存储4位数字年份（如 "2026"），在独立索引中与现有业务键联合。

**原因**: 
- String 类型简单直观，查询方便（可直接比较）
- 与数据库中 StartDate/StopDate 等日期字段分离，单独管理年份维度
- 不需要日期解析开销

**备选方案**: 使用 StartDate 年份动态提取 — 但当前表已有 StartDate 表示"生效日期"，语义可能重叠，且已有数据可能不同年份同一 DRG 共用相同 StartDate，导致无法区分。Year 字段职责更单一明确。

### 2. 索引调整

**DRG 表现有索引**: `Index Index On (DRG, ProvinceDr, CityDr, FixmedinsCode)`
**调整后**: 增加 Year 到索引中 — `Index Index On (DRG, ProvinceDr, CityDr, FixmedinsCode, Year)` 或创建新的唯一索引。

**DIP 表现有索引**: `Index Index On (PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv)`
**调整后**: 增加 Year — `Index Index On (PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv, Year)`。

**注意**: IRIS 中 `Index Index` 不是唯一索引（没有 `Unique` 关键字），但实际业务逻辑视其为唯一键。增加 Year 后可确保同一年份内不重复。

### 3. 分组查询年份回退逻辑

**决策**: 两步查询策略：
1. 先查询当前年份（`$PIECE($ZDATE($HOROLOG, 3), "-", 1)`）的算法配置
2. 如果当前年份完全无数据（count=0），回退查询上一年份数据
3. 如果当前年份有数据但具体分组查询无结果，返回错误提示"未维护当年 DRG/DIP 分组数据"

**回退限制**: 仅回退到上一年，不无限回退。避免查找到过期配置。

**原因**:
- 新年伊始（如1月1日）可能当年数据尚未维护完毕，回退到上一年保证系统可用
- 当年已有部分数据说明当前维护中，不应再使用旧数据

**备选方案**: 多级回退（直到找到数据）— 但风险太高，可能误用到多年前的配置。单级回退更安全可控。

### 4. 前端年份字段处理

**决策**:
- 查询条件：Select 下拉选择年份（动态生成近5年 + "全部"选项，"全部"时不传Year参数）
- 表格列：显示"年份"列（宽度80，位于DRG编码/名称之后）
- 新增/编辑：年份必填，默认值为当前年份，使用 Select 下拉
- 导入：导入弹窗增加年份必选下拉（统一为导入的年份，不逐行指定）

**原因**: 导入时统一指定年份避免逐行解析年份的复杂性，符合批量导入场景。

### 5. 存量数据兼容

**决策**: 存量数据不自动填充 Year，而是在查询时判断 Year 为 NULL 或空的数据视为兼容模式（不参与年份过滤），后续更新维护时逐步补充。

**原因**: 无法自动推断存量数据的年份归属，人工介入更可靠。

## Risks / Trade-offs

- **[风险] 存量数据无 Year 值** → 查询逻辑兼容 Year 为空的记录（视为通用/不参与年份过滤），各管理员可逐步补填
- **[风险] 索引变更导致表锁** → 在低峰期执行 ALTER TABLE，或在测试环境验证后操作
- **[风险] 回退到上一年数据可能有业务差异** → 回退逻辑记录日志，前端显示提示"当前年份无数据，已使用 XXXX 年配置"
- **[风险] 前端导入模板需更新** → 导入模板不需要增加年份列（年份由导入弹窗统一选择），避免模板变更影响已有流程

## Migration Plan

1. 在 IRIS 中执行 DDL 添加 Year 字段
2. 更新 `GroupDevice.cls` 中相关查询逻辑
3. 更新后端算法配置接口（查询、保存、导入）支持 Year
4. 更新前端 DRG/DIP 算法配置页面
5. 在测试环境验证分组查询的正确性
6. 通知管理员逐步补填存量数据的年份信息

回滚方案：Year 字段为可选添加，如出问题可快速注释年份过滤逻辑，系统回退到原有行为。

## Open Questions

- 存量数据中是否有跨年份共用的通用配置？如何处理？
