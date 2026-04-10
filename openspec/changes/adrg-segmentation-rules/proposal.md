## Why

DRG分组算法中，ADRG细分规则是决定病例从ADRG组进一步细分到DRG组的关键配置。当前系统缺少独立的ADRG细分规则管理功能，无法灵活配置各地方不同省市下的联合标志(UnionFlag)和细分标志(SegmentationFlag)规则，影响DRG分组算法的精确性和地方适配能力。

## What Changes

- 新增数据库表 `HB_DRGSegmentationRules`（IRIS类: `User.HBDRGSegmentationRules`），存储ADRG细分规则，字段包含：ADRG代码、ADRG描述、省(ProvinceDr)、市(CityDr)、行政区划代码(Admvs)、联合标志(UnionFlag)、细分标志(SegmentationFlag)、更新人/更新日期/更新时间
- 新增后端接口服务类 `src.DRG.BasicData.DRGRSegmentationRules`，提供查询、保存/更新、删除三个方法
- 新增后端接口入口方法（InterFace类中注册），接口编号分配：02010044(查询)、02010045(保存)、02010046(删除)
- 新增前端API接口定义（`basicData.ts`中新增类型和接口函数）
- 新增前端页面组件 `DRGSegmentationRules.tsx`，包含省市联动查询、增改删操作
- 新增前端菜单项（key: `basic-data-segmentation-rules`，位于"基础数据管理"分组下）

## Capabilities

### New Capabilities
- `adrg-segmentation-rules-crud`: ADRG细分规则表的增删改查功能，包含数据库表结构、后端接口服务、前端页面和菜单配置的完整实现

### Modified Capabilities

## Impact

- **数据库**: 新增 `User.HBDRGSegmentationRules` 持久化类（SQL表: HB_DRGSegmentationRules）
- **后端**: 新增 `src/src/DRG/BasicData/DRGRSegmentationRules.cls` 业务类，修改 `src/src/DRG/BasicData/InterFace.cls` 增加接口入口
- **前端**: 新增 `frontend/src/pages/BasicData/DRGSegmentationRules.tsx`，修改 `frontend/src/api/basicData.ts` 和 `frontend/src/App.tsx`
- **接口编号**: 02010044(查询)、02010045(保存)、02010046(删除)
