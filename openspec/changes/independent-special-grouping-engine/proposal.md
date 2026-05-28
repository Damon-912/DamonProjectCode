## Why

当前 DRG 特异化分组匹配算法（`GroupSpecialMatch`）深度耦合在 `src.DRG.GroupDevice.cls` 分组器内部，作为 `Device` 方法的一个步骤执行。这导致该算法无法独立使用——任何需要根据患者诊断/手术信息查询特异化 DRG 编码的场景（如事前预分组评估、批量规则校验、后台重算等），都必须初始化完整的分组器流程，增加了不必要的计算开销和耦合风险。将匹配算法解耦为独立模块，可提升复用性和可测试性。

## What Changes

- **新增**独立的 `src.DRG.SpecialGroupEngine.cls` 类，提供零依赖的 DRG 特异化分组匹配能力
- **新增**公开入口方法 `Match(patientData, regionInfo)` —— 输入患者诊断/手术数据和地区信息，输出匹配到的 DRG 编码
- **提取**核心算法（ParseGroupFactors、IsCodeMatch、SplitCodes）到独立模块中，与 GroupDevice 的其余逻辑分离
- **保留** GroupDevice 中的 `GroupSpecialMatch` 方法，但将其内部实现委托给新引擎（渐进式迁移）
- 新引擎不接受 GroupDevice 内部对象（如 jaADRG、MDC），仅接受纯数据输入

## Capabilities

### New Capabilities

- `special-grouping-engine`: 独立 DRG 特异化分组匹配引擎，根据患者诊断组、手术组及地区信息匹配 HB_DRGSpecialGroup 规则表，返回命中的 DRG 编码及描述

### Modified Capabilities

_（无现有 spec 需求变更）_

## Impact

- 受影响代码：`src/src/DRG/GroupDevice.cls`（GroupSpecialMatch、ParseGroupFactors、IsCodeMatch、SplitCodes）
- 新增文件：`src/src/DRG/SpecialGroupEngine.cls`（独立引擎类）
- 接口层面：无变化，分组器 Device 方法行为不变
- 数据库：无变化，仍使用 `HB_DRGSpecialGroup` 表
- 前端：无影响
