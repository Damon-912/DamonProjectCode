## Why

DRG算法配置管理目前缺少批量导入功能，管理员需要逐条录入DRG基础数据（基准点数、预估点值、病组差异系数、支付标准等），效率低下且容易出错。参考ICD编码查询菜单的导入功能，为DRG算法配置菜单增加导入能力，支持通过Excel模板批量导入DRG核心算法数据，大幅提升数据维护效率。

## What Changes

- **新增功能**：DRG算法配置菜单增加导入按钮，支持Excel文件批量导入
- **导入模板**：提供标准模板，包含DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard六个字段
- **数据校验**：导入前校验必填字段和数据格式
- **关联选择**：导入弹框要求用户必选省、市、医疗机构，自动关联行政区划代码和机构信息
- **后端接口**：新增三个接口服务（查询列表、验证数据、保存数据），使用operatetable方式更新HB_DRGCoreAlgorithmData表

## Capabilities

### New Capabilities
- `drg-algorithm-import`: DRG算法数据批量导入功能，包含前端导入界面、模板下载、数据校验、后端导入接口

### Modified Capabilities
- 无现有能力需要修改

## Impact

- **前端**：DRG算法配置页面新增导入按钮和导入弹框组件
- **后端**：新增DRG算法导入相关接口服务类
- **数据库**：操作HB_DRGCoreAlgorithmData表，涉及行政区划和医疗机构关联字段
- **依赖**：依赖省市接口服务、医疗机构接口服务获取关联数据
