## Why

已有DRG/DIP后端分组服务和数据库表结构完成开发，但缺少前端用户界面。为实现完整的医保控费预警系统，需要基于现有后端接口（如02010027查询病案、02010035保存分组记录等）开发前端菜单和业务功能模块，提供分组工作台、预警监控、盈亏分析等功能。

## What Changes

**前端功能模块：**

- **DRG/DIP分组工作台前端**：病案查询、分组结果显示、批量分组操作界面
- **分组规则管理前端**：MDC/ADRG/DRG规则配置界面、版本管理
- **费用预警中心前端**：预警规则配置、实时预警展示、预警处理流程
- **盈亏分析报表前端**：科室/医生/病种盈亏统计、趋势分析图表
- **病案质控前端**：病案完整性校验、诊断合理性检查界面
- **数据对接监控前端**：HIS数据同步状态、接口调用日志
- **系统管理前端**：用户权限、菜单管理、接口服务配置

**后端接口扩展（按CB_MapInterface规范）：**

- 新增预警相关接口（Code: 020101xx系列）：预警规则CRUD、预警记录查询
- 新增盈亏分析接口（Code: 020102xx系列）：盈亏统计、趋势分析
- 新增质控接口（Code: 020103xx系列）：质控检查、问题记录
- 新增系统管理接口（Code: 020104xx系列）：用户管理、菜单管理

**数据表扩展（按BS_表结构规范）：**

- 预警规则表（BS_DRGWarningRule）、预警记录表（BS_DRGWarningRecord）
- 盈亏分析表（BS_DRGProfitAnalysis）、科室汇总表（BS_DRGDeptSummary）
- 质控记录表（BS_DRGQCIssue）、系统菜单表（BS_DRGSystemMenu）

## Capabilities

### New Capabilities

- `frontend-drg-workbench`：DRG分组工作台前端，包含病案查询、分组结果展示
- `frontend-dip-workbench`：DIP分组工作台前端，病种分值计算结果展示
- `frontend-rule-config`：分组规则管理前端，MDC/ADRG/DRG规则配置
- `frontend-warning-center`：费用预警中心前端，预警监控和处理
- `frontend-profit-analysis`：盈亏分析报表前端，多维度统计分析
- `frontend-medical-qc`：病案质控前端，质量检查和问题修正
- `frontend-data-sync`：数据对接监控前端，同步任务和日志查看
- `frontend-system-mgmt`：系统管理前端，用户、菜单、权限配置
- `backend-warning-service`：预警服务后端，预警规则引擎和计算
- `backend-profit-service`：盈亏分析后端，统计分析和报表生成
- `backend-qc-service`：病案质控后端，质控检查和问题管理
- `backend-sys-service`：系统管理后端，用户菜单权限接口

### Modified Capabilities

- （无现有能力修改，均为新增扩展）

## Impact

**前端影响：**
- 新增React路由页面：DRG工作台、DIP工作台、规则配置、预警中心等
- 新增Ant Design组件：病案查询表单、分组结果表格、预警卡片、统计图表
- 新增Axios API调用：对接已有后端接口（02010027、02010035等）

**后端影响：**
- 新增IRIS数据库表：BS_DRGWarningRule、BS_DRGWarningRecord、BS_DRGProfitAnalysis等
- 新增ObjectScript业务类：预警服务、盈亏分析、质控检查
- 新增REST API接口：按CB_MapInterface规范注册新接口（Code: 020101xx-020104xx）

**集成影响：**
- 前端调用已有HIS接口（如09030028获取病案）通过后端转发
- 新增接口需按CB_MapInterface表规范配置Code、类名、方法名映射

**数据影响：**
- 预警和盈亏分析数据需与已有分组结果数据关联
- 需初始化系统菜单和权限数据
