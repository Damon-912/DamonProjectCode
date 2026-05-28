## Why

各地医保局在CHS-DRG国家版分组方案基础上，会发布本地区的**特异化分组方案**（细分组方案内涵表），这些方案根据患者的具体诊断编码和手术编码组合，定义了不同于标准DRG分组规则的本地化入组逻辑。当前系统仅支持标准CHS-DRG分组流程，无法处理地方特异化分组规则，导致分组结果与地方医保局公示结果不一致，影响医院的DRG支付准确性。合肥市2026年已发布特异化分组方案，且其他地区同样存在此类需求，因此需要增加通用可扩展的特异化分组支持。

## What Changes

- **新增数据库表** `HB_DRGSpecialGroup`：存储各地区DRG特异化分组方案，包含DRG编码、主要诊断/次要诊断/主要手术/次要手术编码及名称、入组因素说明、行政区划代码（Admvs）、省市信息、年份等字段
- **新增后端IRIS类** `src.DRG.BasicData.DRGSpecialGroup`：提供特异化分组方案的查询、新增、编辑、删除接口服务，支持按行政区划和年份筛选
- **修改分组器** `src.DRG.GroupDevice`：改动前先将现有 `Device` 方法复制为 `DeviceOLD` 方法备案；在 `Device` 方法的分组流程中增加特异化分组匹配逻辑——**仅当调用分组服务时传入医疗机构信息（hospinfo非空）时才触发地方特异化分组匹配**，在ADRG分组完成后、DRG分组前之间插入特异化分组判断，命中规则时直接返回特异化DRG编码（覆盖标准分组结果）
- **新增前端页面** `SpecialDRGGrouping`：提供特异化分组方案的配置维护界面，支持表格展示、新增/编辑弹窗、删除确认，按省市联动筛选
- **修改前端路由/菜单**：在"基础数据管理"菜单下注册"特异化分组内涵表"菜单项

## Capabilities

### New Capabilities
- `drg-special-group-backend`: 后端特异化分组方案的CRUD接口服务（查询/新增/编辑/删除），支持按行政区划代码（Admvs）、省市和分组方案年份筛选，数据存储于 `HB_DRGSpecialGroup` 表。表中不存储ADRG编码，通过DRG编码前缀映射ADRG。
- `drg-special-group-frontend`: 前端特异化分组方案维护页面，支持表格分页展示、省市联动筛选、新增/编辑弹窗表单、删除确认
- `drg-special-group-matcher`: 分组器特异化匹配算法——在 `GroupDevice.Device` 方法中集成，**仅当入参包含医疗机构信息（hospinfo非空）时才触发**，根据患者就诊的主诊断、其他诊断、主手术、其他手术信息，按医疗机构省市/行政区划/年份匹配特异化分组规则，命中时覆盖标准DRG分组结果

### Modified Capabilities
- `drg-grouping-engine`: `GroupDevice.Device` 分组方法改动前先复制为 `DeviceOLD` 方法备案；增加"特异化分组匹配"环节，位于"ADRG分组"之后、"DRG分组"之前。**仅当入参包含医疗机构信息（hospinfo非空）时才触发**。匹配成功时直接使用特异化DRG编码，跳过标准DRG分组流程。无医疗机构信息或未命中时走原有标准分组流程。此为流程级别的需求变更——分组逻辑从单一CHS-DRG标准分组变为"有医疗机构信息时优先匹配地方特异化分组、未命中再走标准分组"的双层架构。

## Impact

- **分组器核心逻辑**: `src/src/DRG/GroupDevice.cls` 现有 `Device` 方法先复制为 `DeviceOLD` 方法备案；然后在 `Device` 方法中增加特异化分组匹配步骤，流程从8步变为9步（仅在hospinfo非空时执行新增步骤）
- **新增数据库表**: `User.HBDRGSpecialGroup` 持久化类（对应SQL表 `HB_DRGSpecialGroup`），不含ADRG编码字段，通过DRG编码前缀映射ADRG；新增 Admvs 字段存储行政区划代码
- **新增后端类**: `src/src/DRG/BasicData/DRGSpecialGroup.cls` 业务类
- **修改入口类**: `src/src/DRG/BasicData/InterFace.cls` 新增3个接口方法委托
- **新增前端页面**: `frontend/src/pages/BasicData/SpecialDRGGrouping.tsx`
- **修改前端路由**: `frontend/config/routes.ts` 新增菜单项
- **无破坏性变更**: 默认情况下无特异化分组规则时，系统行为与改造前完全一致（兼容存量逻辑）
