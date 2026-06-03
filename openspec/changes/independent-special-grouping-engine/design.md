## Context

当前 DRG 特异化分组匹配逻辑（约 392 行）深度嵌入在 `src.DRG.GroupDevice.cls` 中：

| 方法 | 行号 | 职责 |
|------|------|------|
| `SplitCodes()` | 90-111 | 编码字符串拆分 |
| `IsCodeMatch()` | 161-187 | ICD 双向前缀匹配 |
| `ParseGroupFactors()` | 3013-3050 | GroupFactors 结构化解析 |
| `GroupSpecialMatch()` | 3064-3368 | 主入口，SQL 查询 + 逐条匹配 |

**约束**：IRIS ObjectScript 2019+，数据源 `HB_DRGSpecialGroup` 不可变，新引擎不允许引入对 GroupDevice 的循环依赖。

### 实际数据（20 条，通过 MCP 查询 IRIS 服务器确认，Admvs=340100，Year=2026）

| DRGCode | 行数 | GroupFactors | 主诊断 | 主手术 | 次手术 |
| --- | --- | --- | --- | --- | --- |
| CB66 | 1 | 主要诊断+主要手术 | h40.501 | 12.6704 | — |
| CB26 | 4 | 主要诊断+主要手术+次要手术 | 4 个不同诊断 | 14.7401 或 13.4100x001 | 互为对方手术 |
| CB46 | 12 | 主要手术 | — | 12 个不同手术（每行1个） | — |
| CB56 | 3 | 主要诊断+主要手术 | 3 个不同诊断（每行1个） | 13.4101 | — |
| CB54 | 1 | 主要诊断+主要手术+次要手术 | H25.900 | 13.4100x001 | 13.9003 |
| CB58 | 1 | 主要手术+次要手术 | — | 13.7000 | 13.4100x001 |
| CJ16 | 1 | 主要手术 | — | 09.8100x004 | — |

## Goals / Non-Goals

**Goals:**
1. 创建独立类 `src.DRG.SpecialGroupEngine.cls`，零对 GroupDevice 的依赖
2. 公开 API：`Match(patientInfo, regionInfo, groupYear)` → DRG 结果
3. 实现 SplitCodes / IsCodeMatch / ParseGroupFactors 三个工具方法
4. 直接替换 GroupDevice 中旧的特异化分组实现
5. 兼容多值编码字段（逗号分隔，`+` 不作为分隔符）

**Non-Goals:**
- 不修改 HB_DRGSpecialGroup 表结构
- 不解析 Remark（仅透传）
- 不涉及 ADRG 或细分规则
- 不新增接口注册

## Decisions

### 决策 1：直接替换而非委托

**选择**: Device() 内联提取 patientInfo 和 regionInfo 后直接调用 `##class(src.DRG.SpecialGroupEngine).Match()`，删除 GroupDevice 中的 GroupSpecialMatch/ParseGroupFactors/IsCodeMatch/SplitCodes 四个方法。

**理由**: 减少调用链路（Device → GroupSpecialMatch → Engine 变为 Device → Engine），消除冗余适配层。

### 决策 2：SplitCodes 分隔符——`+` 不是分隔符

**选择**: `$TRANSLATE(codeStr, "，;/ ", ",,,,,")`，不包含 `+`。

**理由**: ICD 星剑号复合编码如 `e88.906+h28.1*` 含 `+`，不可拆分。

### 决策 3：Remark 仅透传

**选择**: SQL 查询包含 Remark 字段，命中后放入结果，但不解析。

**理由**: CB26 的"另一个作为次要手术"已编码在 SecondaryProcedure 字段中，GroupFactors 已覆盖全部匹配条件。

### 决策 4：GroupFactors 为空时自动构建 AND

**选择**: 若 GroupFactors 为空，按当前行所有非空编码字段构建纯 AND 关系。

**理由**: 简化数据录入，无 GroupFactors 时默认所有有值字段必须同时匹配。

### 决策 5：首次命中即返回

**选择**: 按 DRGCode 排序遍历，命中首条规则立即返回。

## Risks / Trade-offs

- **[风险] 代码重复** → 缓解：方法简洁（~120 行），注释标明来源
- **[风险] Device() 内联代码增加** → 缓解：仅 ~25 行参数提取 + SQL 查询，可读性好
- **[风险] 性能** → 缓解：<50 条，联合索引，首次命中退出

## Migration Plan

1. 备份 GroupDevice.cls 完整文件
2. 创建 SpecialGroupEngine.cls
3. 实现 Match 方法
4. 替换 Device() 中的特异化分组调用块，删除 4 个旧方法
5. 20 条规则逐一验证 + 回归测试
6. 部署上线

**回滚策略**: 回滚 GroupDevice.cls 到备份版本即可，SpecialGroupEngine.cls 不动不影响系统。
