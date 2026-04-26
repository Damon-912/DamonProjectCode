## Context

当前系统已实现DRG分组器（`src.DRG.GroupDevice.Device`）的完整流程，包括MDC先期分组、ADRG分组、并发症确认、DRG分组及费用预警。DIP（按病种分值付费）作为另一种医保支付方式，其核心算法配置表 `HB_DIPCoreAlgorithmData` 已建表并维护数据，前端DIP算法配置页面已开发完成，但后端的DIP分值查询接口 `GetDIPGroupScore` 方法体为空，需要实现核心查询逻辑。

**当前状态**：
- 数据表 `HB_DIPCoreAlgorithmData` 已定义，包含 PrincipalDiagnosis、MajorProcedure、ScoreValue、AdjustCoefficient 等字段
- 已建立组合索引 `Index On (PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv)`
- 接口路由 `src.DRG.Interface.GetDIPGroupScore` 已注册（编码02010003），转发至 `src.DRG.GroupDevice.GetDIPGroupScore`
- 同类查询方法如 `GetDRGCoreAlgorithm`、`QueryDIPCoreAlgorithm` 使用 `%SQL.Statement` 动态SQL + LIKE模糊匹配模式

## Goals / Non-Goals

**Goals:**
- 实现 `GetDIPGroupScore` 方法，通过主诊断和主手术模糊匹配查询DIP算法配置数据
- 主诊断为必传参数，主手术为选填参数（可为空）
- 行政区划代码（`mdtrtArea`）和医疗机构代码/名称（`fixmedinsCode`/`fixmedinsName`）不能同时为空，必须至少提供一个以确定数据范围
- 支持医疗机构代码/名称关联筛选：通过 `CB_Hospital` 表获取省市ID，再匹配DIP算法配置表的省市字段
- 返回匹配记录的完整算法配置字段（分值、调节系数、省市、机构等级等）
- 利用已有组合索引保证模糊匹配查询效率
- 遵循同类方法（如 `Device`、`GetDRGCoreAlgorithm`）的编码规范和异常处理模式

**Non-Goals:**
- 不涉及DIP分组器逻辑实现（DIP分组与DRG分组是不同算法体系）
- 不修改 `HB_DIPCoreAlgorithmData` 表结构或索引
- 不修改前端页面（前端已有DIPCoreAlgorithmConfig页面）
- 不修改接口路由注册（已注册02010003）

## Decisions

### 1. 查询方式：使用 %SQL.Statement 动态SQL构建条件查询

**选择**: 使用 `%SQL.Statement` 动态SQL + 参数化 LIKE 条件  
**备选**: 使用嵌入式 `&sql()` 宏  
**理由**: 
- 动态SQL支持灵活的条件拼接，主手术参数非必传需动态构建WHERE子句
- 参数化查询使用 `?` 占位符配合 `%Execute(params...)` 传参，避免SQL注入
- 同类方法 `QueryDIPCoreAlgorithm`、`GetDRGCoreAlgorithm` 均采用此模式
- `%SQL.Statement.%New(1)` 设置 `%SelectMode=1`（ODBC模式），日期自动格式化

### 2. 模糊匹配策略：前置LIKE利用索引前缀

**选择**: 使用 `PrincipalDiagnosis LIKE 'xxx%'` 前置模糊匹配  
**备选**: `PrincipalDiagnosis LIKE '%xxx%'` 全模糊匹配  
**理由**:
- 前置模糊（`LIKE 'xxx%'`）可以利用B-tree索引的前缀匹配特性，查询效率远高于全模糊
- ICD编码具有层级结构（如 `K25.0`、`K25.1` 都属于 `K25`），前置匹配更符合DIP病种分组的业务语义：用户输入主诊断代码前缀即可匹配该大类下所有DIP配置
- 组合索引 `Index On (PrincipalDiagnosis, MajorProcedure, ...)` 的第一列支持前置LIKE走索引
- 但考虑到前端使用场景是精确输入诊断代码后查询，实际更多是 `LIKE 'xxx%'` 精确到具体编码的匹配

### 3. 返回结构：复用 SetJarraySuccessResult 返回数组

**选择**: 使用 `..SetJarraySuccessResult(rows, totalCount)` 返回结果数组  
**理由**: 
- 模糊匹配可能返回多条记录，数组格式与同类方法（`GroupADRG`、`GroupComplication`、`GroupDRG`）保持一致
- 前端可基于数组结果展示多条匹配记录供用户选择

### 4. 异常处理：遵循标准try/catch模式

**选择**: 使用同类方法的标准异常处理模式，调用 `src.Interface.Message.InsErrRecord` 记录错误日志  
**理由**: 与 `Device`、`CheckRules`、`GroupPreMDC` 等方法保持一致

### 5. 医疗机构关联查询：先查CB_Hospital获取省市ID再拼条件

**选择**: 当前端传入 `fixmedinsCode` 时，先通过 `&sql()` 或嵌入式查询从 `CB_Hospital` 表获取 `ProvID_Dr` 和 `CityID_Dr`，再作为WHERE条件加入DIP算法配置查询SQL  
**备选**: 在DIP查询SQL中使用子查询或JOIN直接关联 `CB_Hospital`  
**理由**:
- `CB_Hospital` 查询简单（单条记录），使用 `&sql(SELECT ProvID_Dr, CityID_Dr INTO :provID, :cityID FROM CB_Hospital WHERE OrganizationCode=:fixmedinsCode)` 一步获取，无需复杂JOIN
- 同类方法 `Device` 中第六步循环医疗机构信息时也是先查 `CB_Hospital` 获取省市ID（代码行1121），再用于后续查询，模式一致
- 当 `fixmedinsCode` 为空但 `fixmedinsName` 非空时，使用 `Descripts LIKE '%fixmedinsName%'` 模糊匹配查询，此时可能返回多条记录需遍历
- 获取到省市ID后，作为 `Province_Dr = ?` 和 `City_Dr = ?` 参数化条件追加到DIP算法配置查询SQL中

## Risks / Trade-offs

- **[模糊匹配性能]** → 使用前置LIKE (`LIKE 'xxx%'`) 替代全模糊 (`LIKE '%xxx%'`)，利用组合索引第一列的索引前缀匹配能力，避免全表扫描
- **[多结果集过大]** → 模糊匹配可能返回大量记录，暂不加LIMIT限制，但前端分页展示可控制；后续如有性能问题可增加TOP限制
- **[SQL注入风险]** → 使用 `%SQL.Statement` 参数化查询（`?` 占位符 + `%Execute`传参），不直接拼接用户输入到SQL字符串
- **[CB_Hospital查询返回多条]** → 当通过医疗机构名称模糊查询可能返回多条记录时，取第一条结果的省市ID作为筛选条件；医疗机构代码查询为主，名称查询为备选
