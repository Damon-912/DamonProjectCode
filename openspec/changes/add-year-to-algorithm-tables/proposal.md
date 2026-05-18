## Why

DRG/DIP分组方案每年都会发生变化，导致HB_DRGCoreAlgorithmData和HB_DIPCoreAlgorithmData两张算法配置表每年都需要新增数据。当前表结构缺少年份维度，无法按年度隔离管理算法配置数据，也无法在分组查询时自动选择当前年份的算法配置。这会导致各年度数据混杂、历史数据被覆盖、分组查询结果不准确等问题。

## What Changes

- **数据库层**：HB_DRGCoreAlgorithmData和HB_DIPCoreAlgorithmData两张表新增`Year`字段（年份，4位数字如2026），并将其纳入主键/唯一索引，确保同一年份内同一业务键唯一
- **后端分组查询逻辑**：DRG分组查询（02010001）和DIP分组查询（02010003）在查询算法配置表时，先从当前年份匹配数据；当前年份完全无数据时自动回退到上一年份数据；当前年份有数据但具体分组不存在时，提示"未维护当年分组数据"
- **前端DRG算法配置页面**：查询条件增加年份筛选，表格新增年份列，新增/编辑表单增加年份字段（必填），导入时增加年份必选
- **前端DIP算法配置页面**：同上，查询条件增加年份筛选，表格新增年份列，新增/编辑表单增加年份字段（必填），导入时增加年份必选

## Capabilities

### New Capabilities

- `algorithm-year-management`: 算法配置表的年份维度管理能力，包括表结构Year字段、年份回退查询逻辑、前后端年份字段处理

### Modified Capabilities

<!-- 无现有 specs 需要修改 -->

## Impact

- **数据库表**：HB_DRGCoreAlgorithmData、HB_DIPCoreAlgorithmData（新增Year字段，调整索引）
- **后端服务类**：src/DRG/GroupDevice.cls（Device方法中DRG算法查询、GetDIPGroupScore方法中DIP算法查询、SaveMedRecInfo方法中DRG指向查询）
- **前端页面**：DRGCoreAlgorithmConfig.tsx、DIPCoreAlgorithmConfig.tsx（查询、列表、新增/编辑、导入均需增加年份支持）
- **后端接口服务**：DRG/DIP算法配置的查询、保存、导入接口需支持Year参数
- **向下兼容**：存量数据需补填年份（可默认填当年），无Year数据的查询逻辑需保持兼容
