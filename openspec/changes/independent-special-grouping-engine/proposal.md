## Why

当前 DRG 特异化分组匹配逻辑（`GroupSpecialMatch` + `ParseGroupFactors` + `IsCodeMatch` + `SplitCodes` 约 392 行）深度耦合在 `src.DRG.GroupDevice.cls` 内部。这导致该算法无法独立使用——任何需要根据患者诊断/手术信息匹配特异化 DRG 编码的场景（如事前预分组评估、批量规则校验），都必须初始化完整的分组器流程。将匹配算法解耦为独立引擎并直接替换旧实现，可提升复用性、可测试性，同时减少 GroupDevice 的代码量。

## What Changes

- **新增**独立的 `src.DRG.SpecialGroupEngine.cls` 纯静态工具类，零对 GroupDevice 的依赖
- **新增**公开入口方法 `Match(patientInfo, regionInfo, groupYear)` —— 接受患者诊断/手术数据和地区信息，查询 HB_DRGSpecialGroup 表并返回命中的 DRG 编码
- **移除** GroupDevice 中的 `GroupSpecialMatch`、`ParseGroupFactors`、`IsCodeMatch`、`SplitCodes` 四个旧方法（共 ~392 行）
- **修改** GroupDevice.Device() 方法：内联提取 patientInfo 和 regionInfo 后直接调用新引擎
- 引擎不解析 Remark（仅为透传），GroupFactors 驱动全部匹配逻辑

## Capabilities

### New Capabilities

- `special-grouping-engine`: 独立 DRG 特异化分组匹配引擎，根据患者诊断组、手术组及地区信息匹配 HB_DRGSpecialGroup 规则表（当前 20 条/合肥 2026），支持 GroupFactors AND/OR 结构化解析、ICD 双向前缀匹配、多编码逗号分隔、空字段自适应 AND 构建，返回命中的 DRG 编码及描述

### Modified Capabilities

_（无现有 spec 需求变更）_

## Impact

- 受影响代码：`src/src/DRG/GroupDevice.cls`（删除第 90-111、161-187、3013-3050、3064-3368 行，替换第 1782-1809 行）
- 新增文件：`src/src/DRG/SpecialGroupEngine.cls`
- 接口层面：无变化，分组器 Device 方法行为不变
- 数据库：无变化，仍使用 `HB_DRGSpecialGroup` 表
- 前端：无影响
