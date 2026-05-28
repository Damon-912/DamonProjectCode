## Context

当前 DRG 特异化分组匹配逻辑（约 370 行）深度嵌入在 `src.DRG.GroupDevice.cls`（共 3370 行）中，包括三个核心方法：

| 方法 | 行号 | 职责 |
|------|------|------|
| `GroupSpecialMatch()` | 3064-3368 | 主入口，查询 HB_DRGSpecialGroup 表并逐条匹配 |
| `ParseGroupFactors()` | 3013-3050 | 解析 GroupFactors 结构化语法（+ = AND，或 = OR） |
| `IsCodeMatch()` | 161-177 | ICD 编码双向前缀匹配 |
| `SplitCodes()` | 90-111 | 编码字符串拆分为 $LIST |

这些方法与 GroupDevice 中的 Device() 分组流程、ADRG 匹配、CC/MCC 判断等逻辑耦合在同一个类中。现有 `drg-special-grouping` change 已在 Device 流程的 Step 4-5 之间集成了特异化分组步骤，但匹配能力仍无法脱离分组器独立调用。

**约束：**
- IRIS ObjectScript 2019+，类必须继承 `%RegisteredObject`
- 数据源为 `HB_DRGSpecialGroup` 表，不可变更其结构
- 现有的 `GroupSpecialMatch` 方法需保持向后兼容（内部改委托）
- 新引擎不允许引入对 GroupDevice 的循环依赖

## Goals / Non-Goals

**Goals:**
1. 创建独立类 `src.DRG.SpecialGroupEngine.cls`，零对 GroupDevice 的依赖
2. 提供简洁的公开 API：`Match(patientDiagnosis, patientProcedures, regionInfo)` → DRG 结果
3. 包含完整的算法实现：ParseGroupFactors、IsCodeMatch、SplitCodes
4. 支持按省市 + 年份 + 行政区划的多维度规则筛选
5. GroupDevice 中的 `GroupSpecialMatch` 改为委托调用新引擎（渐进迁移）

**Non-Goals:**
- 不修改 HB_DRGSpecialGroup 表结构
- 不改变现有的特异化分组业务规则
- 不影响 Device 分组流程的行为
- 不涉及 ADRG 规则（CB_DRGCoreGroupsList）或细分规则（HB_DRGSegmentationRules）
- 不新增接口注册（复用分组器统一入口 02010001）

## Decisions

### 决策1：类设计——纯静态工具类 vs 实例化服务类

**选择**: 纯静态工具类（所有方法为 ClassMethod），类名 `src.DRG.SpecialGroupEngine`。

**理由**:
- 引擎无状态，每次调用独立，无需实例化
- 与 GroupDevice 的风格保持一致（全部 ClassMethod）
- 调用方无需管理对象生命周期，降低使用门槛
- 分组器场景通常是请求级别的单次调用，无需连接池

### 决策2：公开 API 设计——输入参数结构

**选择**: 方法签名为：

```
ClassMethod Match(patientInfo As %Library.DynamicObject, regionInfo As %Library.DynamicObject, groupYear As %String = "") As %Library.DynamicObject
```

其中：
- `patientInfo`: `{ mainDiagnosisCode, mainOperationCode, diseInfo: [], oprnInfo: [] }`
- `regionInfo`: `{ provinceDr, cityDr, admvs }`
- `groupYear`: 方案年份（可选，默认当前年份）
- 返回值: `{ errorCode, errorMessage, result: { drgCode, drgDesc, matchRuleId, groupFactors } }`

**理由**:
- `patientInfo` 独立于 `jsonObj.params` 结构，调用方不需构造完整的 Device 入参
- `regionInfo` 直接提供省市/行政区划，不再依赖 hospinfo → CB_Hospital 的 SQL 查询链路
- 返回格式与 GroupSpecialMatch 一致，便于 GroupDevice 委托调用时无缝对接

**替代方案考虑**:
- 参数使用多个标量：字段过多，不利于扩展
- 参数使用 $LIST：可读性差，不易维护

### 决策3：核心方法提取——重复 vs 委托

**选择**: 在新引擎中复制 IsCodeMatch、SplitCodes、ParseGroupFactors 的完整实现（不通过引用 GroupDevice 共享）。

**理由**:
- 这三个方法是纯工具函数，无外部依赖，复制成本极低
- 避免循环依赖（GroupDevice 将引用 SpecialGroupEngine，不可反向依赖）
- 如果未来 GroupDevice 也被重构，这些工具方法可移到公共工具类
- SplitCodes 和 IsCodeMatch 的行数极少（<50行），维护负担可控

**替代方案（已拒绝）**:
- 提取到 `src.util.CodeMatcher` 公共类：过度抽象，当前仅两个调用方
- SpecialGroupEngine 委托 GroupDevice：违背解耦目标

### 决策4：GroupDevice 的迁移策略

**选择**: 渐进式迁移——保留 `GroupSpecialMatch` 方法签名不变，内部实现改为：

```
ClassMethod GroupSpecialMatch(...) {
    // 1. 从 jsonObj 和 hospinfo 提取 patientInfo 和 regionInfo
    // 2. 委托调用 ##class(src.DRG.SpecialGroupEngine).Match(patientInfo, regionInfo, groupYear)
    // 3. 直接返回结果
}
```

**理由**:
- Device 方法调用 `GroupSpecialMatch` 的代码不动，降低回归风险
- 适配层仅做参数转换，逻辑简单，测试充分后可作为临时方案
- 长期可考虑在 Device 中直接调用 SpecialGroupEngine，跳过 GroupSpecialMatch 包装

### 决策5：匹配逻辑——首次命中 vs 全量命中

**选择**: 首次命中即返回（与当前 GroupSpecialMatch 行为一致）。

**理由**:
- 特异化分组规则按 DRGCode 排序查询，同 DRGCode 的多条记录为同一方案的不同匹配条件
- 第一个命中的规则即为最高优先级方案
- 如果未来需要返回多条候选结果，可新增 `MatchAll` 方法

## Risks / Trade-offs

- **[风险] 代码重复**：IsCodeMatch/SplitCodes/ParseGroupFactors 在两处存在 → 缓解：方法简洁（总共~100行），注释标明同步来源，未来可提取公共工具类
- **[风险] 参数转换遗漏**：GroupDevice 适配层提取 patientInfo/regionInfo 时可能丢失字段 → 缓解：充分的单元测试覆盖所有数据场景（合肥市 9 条规则全部验证）
- **[风险] 性能**：每次调用都查询 HB_DRGSpecialGroup 表 → 缓解：表数据量小（市级方案通常<50条），已在 Province_Dr + City_Dr + Year 上建立联合索引
- **[风险] 向后兼容**：如果新引擎返回格式与旧版有差异 → 缓解：Match 方法返回格式严格与 GroupSpecialMatch 一致

## Migration Plan

1. **创建新引擎类**：`src/src/DRG/SpecialGroupEngine.cls`
2. **实现核心方法**：Match、ParseGroupFactors、IsCodeMatch、SplitCodes
3. **单元测试**：用合肥市 2026 年 9 条规则逐一测试匹配场景
4. **适配 GroupDevice**：修改 GroupSpecialMatch 为委托调用
5. **回归测试**：执行完整 Device 分组流程，确认所有场景行为一致
6. **部署上线**：与 GroupDevice.cls 同步部署到 IRIS 服务器

**回滚策略**:
- 若新引擎有问题，回滚 GroupDevice.cls 的 GroupSpecialMatch 方法回到原始实现
- SpecialGroupEngine.cls 可保留不动，不调用则无影响
- 无需回滚数据库或前端

## Open Questions

1. **是否需要缓存机制？** → 当前数据量小，暂不需要。若未来省级方案扩展至数百条可考虑内存缓存。
2. **是否需要支持批量匹配？** → 暂不列入本次范围，但 Match 方法签名预留扩展空间（patientInfo 本身可选数组模式）。
3. **是否需要独立的接口注册？** → 暂不需要，分组器统一入口 02010001 已覆盖分组场景。
