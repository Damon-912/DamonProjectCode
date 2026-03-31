# Proposal: DRG基础数据维护

## 变更名称
`basic-data-maintenance`

## 背景与动机

DRG基础数据维护是"基础数据管理"模块的核心功能之一。系统已有两张数据表和对应的后端持久化类：

- **HB_DRGBasicData** (`User.HBDRGBasicData`) - DRG基础数据主表（字典分类）
- **HB_DRGBasicDataSub** (`User.HBDRGBasicDataSub`) - DRG基础数据明细表（字典子项）

当前缺少以下能力：
1. 后端接口服务（CRUD操作）
2. 前端维护页面

需要实现完整的增删改查接口和前端页面，支撑DRG基础数据的日常维护工作。

## 变更目标

### 后端接口服务（6个）

| 接口Code | 接口名称 | 方法名 | 说明 |
|----------|----------|--------|------|
| 02010010 | 保存DRG基础数据 | SaveBasicData | 新增/修改主表 |
| 02010011 | 查询DRG基础数据 | QueryBasicData | 分页查询主表 |
| 02010012 | 删除DRG基础数据 | DeleteBasicData | 删除主表(级联删除明细) |
| 02010013 | 保存DRG基础数据明细 | SaveBasicDataSub | 新增/修改明细 |
| 02010014 | 查询DRG基础数据明细 | QueryBasicDataSub | 按主表ID查询明细 |
| 02010015 | 删除DRG基础数据明细 | DeleteBasicDataSub | 删除明细 |

### 前端页面

- 路由key: `basic-data-maintenance`
- 路径: `/basic-data/maintenance`
- 组件: `pages/BasicData/BasicDataMaintenance.tsx`

## 数据表结构

### HB_DRGBasicData（主表）

| 字段 | 数据库列名 | 类型 | 必填 | 说明 |
|------|-----------|------|------|------|
| ID | ID | Long | 自动 | 主键 |
| insuCode | InsuCode | String(50) | 是 | 代码 |
| insuDesc | InsuDesc | String(30) | 是 | 描述 |
| provinceDr | Province_Dr | FK(CBProvince) | 是 | 省 |
| cityDr | City_Dr | FK(CBCity) | 是 | 市 |
| areaDr | Area_Dr | FK(CBArea) | 否 | 区 |
| startDate | StartDate | Date | 是 | 生效日期 |
| stopDate | StopDate | Date | 否 | 失效日期 |
| createDate | CreateDate | Date | 自动 | 创建日期 |
| createTime | CreateTime | Time | 自动 | 创建时间 |
| createUserDr | CreateUser_Dr | FK(HBUser) | 否 | 创建人 |
| identification | Identification | String | 否 | 标识码-分类 |
| remark | Remark | String | 否 | 备注 |

### HB_DRGBasicDataSub（明细表）

| 字段 | 数据库列名 | 类型 | 必填 | 说明 |
|------|-----------|------|------|------|
| ID | ID | Long | 自动 | 主键 |
| hbDictionariesDr | HBDictionaries_Dr | FK(HBDRGBasicData) | 是 | 所属主表 |
| code | Code | String | 是 | 代码 |
| descripts | Descripts | String | 是 | 描述 |
| identification | Identification | String | 否 | 标识码-分类 |
| startDate | StartDate | Date | 是 | 生效日期 |
| stopDate | StopDate | Date | 否 | 失效日期 |
| createDate | CreateDate | Date | 自动 | 创建日期 |
| createTime | CreateTime | Time | 自动 | 创建时间 |
| createUserDr | CreateUser_Dr | FK(HBUser) | 否 | 创建人 |
| remark | Remark | String | 否 | 备注 |

## 影响范围

### 新增文件
- `src/src/BasicData/BasicData.cls` - 后端接口服务类
- `frontend/src/pages/BasicData/BasicDataMaintenance.tsx` - 前端页面组件
- `frontend/src/api/basicData.ts` - 前端API封装

### 修改文件
- `前端菜单&数据接口需求.md` - 更新接口清单
- `系统设计/07-基础数据管理模块设计.md` - 补充设计细节（如已创建）
