## Why

DRG核心算法配置管理目前仅支持单条数据维护，缺乏批量导入能力。管理员需要频繁维护大量DRG算法数据（DRG代码、基准点数、预估点值、病组差异系数、支付标准等），逐条录入效率低下且容易出错。参考现有ICD编码导入功能（接口02010038/02010039/02010040），为DRG算法配置菜单增加批量导入能力，可大幅提升基础数据维护效率。

## What Changes

- **新增功能**：DRG算法配置页面增加"导入"按钮，支持Excel/CSV文件批量导入
- **导入模板**：提供标准模板下载，包含DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard六个核心字段
- **前置选择**：导入弹框要求用户必选省、市、医疗机构，自动关联行政区划代码和机构信息
- **三步流程**：采用与ICD编码导入一致的三步交互（上传文件→数据预览→导入结果）
- **后端接口**：新增三个接口服务（02010050预览/02010051确认导入/02010052下载模板），使用operatetable方式操作HB_DRGCoreAlgorithmData表
- **数据校验**：支持必填字段校验、数值格式校验、重复数据检测

## Capabilities

### New Capabilities
- `drg-core-algorithm-import`: DRG核心算法数据批量导入功能，包含前端导入界面、模板下载、数据校验、后端导入接口（Query/Validate/Save三层架构）

### Modified Capabilities
- 无现有能力需要修改

## Impact

- **前端**：DRG算法配置页面（frontend/src/pages/BasicData/DRGCoreAlgorithm.tsx）新增导入按钮和导入弹框组件
- **后端**：InterFace.cls新增02010050/02010051/02010052三个接口方法，CoreAlgorithm.cls新增对应的业务处理方法
- **数据库**：操作HB_DRGCoreAlgorithmData表，涉及字段：DRG、DRGDESC、Points、PipValue、DGDOV、PayStandard、MdtrtArea、FixmedinsCode、FixmedinsName、MedinsLv、Province_Dr、City_Dr
- **依赖**：依赖省市接口服务（getProvinceData/getCityData）、医疗机构接口服务获取关联数据
