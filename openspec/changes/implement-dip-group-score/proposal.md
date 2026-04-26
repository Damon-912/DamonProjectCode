## Why

DIP分组分值查询接口 `GetDIPGroupScore` 已在后端类 `src.DRG.GroupDevice` 中声明（接口编码02010003），并在 `src.DRG.Interface` 中注册了路由转发，但方法体为空，缺少核心业务逻辑实现。前端在DIP算法配置页面需要通过主诊断和主手术模糊匹配查询DIP分值数据，该接口是DIP控费预警功能的关键入口，需要尽快实现。

此外，前端调用时还会传入行政区划代码、医疗机构代码/名称等筛选参数。其中行政区划代码可直接匹配 `HB_DIPCoreAlgorithmData.MdtrtArea`；而医疗机构代码/名称在DIP算法配置表中无直接对应字段，需要先通过 `CB_Hospital` 表的 `OrganizationCode`/`Descripts` 字段查询出对应的 `ProvID_Dr` 和 `CityID_Dr`，再用这两个值关联筛选 `HB_DIPCoreAlgorithmData` 表的 `Province_Dr` 和 `City_Dr` 字段。

## What Changes

- 实现 `src.DRG.GroupDevice` 类中 `GetDIPGroupScore` 方法的完整业务逻辑
- 接收前端传入的主诊断（`mainDiagnosisCode`，必填）和主手术（`mainOperationCode`，选填）参数
- 接收前端传入的行政区划代码（`mdtrtArea`，选填），直接匹配 `HB_DIPCoreAlgorithmData.MdtrtArea` 字段
- 接收前端传入的医疗机构代码（`fixmedinsCode`，选填），通过 `CB_Hospital.OrganizationCode` 查询 `ProvID_Dr` 和 `CityID_Dr`，再匹配 `HB_DIPCoreAlgorithmData` 的 `Province_Dr` 和 `City_Dr` 字段进行筛选
- 接收前端传入的医疗机构名称（`fixmedinsName`，选填），当 `fixmedinsCode` 为空时可通过 `CB_Hospital.Descripts` 模糊匹配查询省市信息
- **校验约束**：`mdtrtArea`、`fixmedinsCode`、`fixmedinsName` 三个参数不能同时为空，否则返回错误
- 通过 LIKE 前置模糊匹配 `HB_DIPCoreAlgorithmData` 表的 `PrincipalDiagnosis` 和 `MajorProcedure` 字段查询匹配记录
- 返回匹配行的完整算法配置数据（分值、调节系数、省市信息等）
- 主手术为空时仅按主诊断匹配，主手术非空时按主诊断+主手术联合匹配
- 利用已有索引 `Index On (PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv)` 优化查询效率
- 使用 `%SQL.Statement` 动态SQL构建条件查询，避免SQL注入

## Capabilities

### New Capabilities
- `dip-group-score-query`: DIP分组分值查询能力 - 通过主诊断和主手术模糊匹配DIP算法配置表，支持行政区划代码和医疗机构关联省市筛选，获取分值和调节系数等数据

### Modified Capabilities

## Impact

- **后端代码**: `src/src/DRG/GroupDevice.cls` - 实现 `GetDIPGroupScore` 方法体
- **后端代码**: `src/src/DRG/GroupDevice/1.int` - 对应int代码同步更新
- **接口路由**: `src/src/DRG/Interface.cls` 已注册02010003路由，无需修改
- **数据表**: `HB_DIPCoreAlgorithmData` (User.HBDIPCoreAlgorithmData) - 只读查询，无数据变更
- **数据表**: `CB_Hospital` (User.CBHospital) - 只读关联查询，获取ProvID_Dr和CityID_Dr
- **前端调用**: 前端已有DIPCoreAlgorithmConfig页面，通过接口编码02010003调用
