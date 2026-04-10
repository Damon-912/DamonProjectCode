## Why

DRGs目录信息表功能已完成开发并上线运行，包括前端页面、后端接口服务和数据库表结构。现在需要将这组变更进行归档，以便完整记录功能的设计与实现，作为后续维护和功能扩展的参考依据。

## What Changes

- 归档DRGs目录信息表的前端菜单配置（菜单key: `basic-data-drg-catalog`，菜单位于"基础数据管理"分组下）
- 归档前端页面组件 `DRGCataLog.tsx`（CRUD操作、省市联动查询、编辑弹窗）
- 归档前端API接口定义（`basicData.ts`中接口编号02010041/02010042/02010043）
- 归档后端接口服务类 `src.DRG.BasicData.DRGCataLog`（查询GetDRGCataLogList、保存SaveDRGCataLog、删除DeleteDRGCataLog）
- 归档后端接口入口 `src.DRG.BasicData.InterFace` 中02010041/02010042/02010043的委托方法
- 归档数据库表结构 `User.HBDRGCataLog`（SQL表名: HB_DRGCataLog，字段: Code/Descripts/ProvinceDr/CityDr/Admvs/UpdateDate/UpdateTime/UpdateUserDr）

## Capabilities

### New Capabilities
- `drg-catalog-crud`: DRGs目录信息表的增删改查功能，包含前端页面、API接口、后端服务和数据表结构的完整定义

### Modified Capabilities

## Impact

- **前端**: `frontend/src/pages/BasicData/DRGCataLog.tsx`（页面组件）、`frontend/src/api/basicData.ts`（API类型和接口定义）、`frontend/src/App.tsx`（菜单和路由注册）
- **后端**: `src/src/DRG/BasicData/DRGCataLog.cls`（业务逻辑类）、`src/src/DRG/BasicData/InterFace.cls`（接口入口类）
- **数据库**: `User.HBDRGCataLog`（持久化类/SQL表 HB_DRGCataLog）
- **接口编号**: 02010041（查询）、02010042（保存）、02010043（删除）
