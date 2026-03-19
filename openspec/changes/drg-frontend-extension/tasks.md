## 1. 数据库表创建

- [x] 1.1 创建BS_DRGWarningRule预警规则表
- [x] 1.2 创建BS_DRGWarningRecord预警记录表
- [x] 1.3 创建BS_DRGProfitAnalysis盈亏分析表
- [x] 1.4 创建BS_DRGDeptSummary科室汇总表
- [x] 1.5 创建BS_DRGQCIssue质控问题表
- [x] 1.6 创建BS_DRGSystemUser系统用户表
- [x] 1.7 创建BS_DRGSystemRole系统角色表
- [x] 1.8 创建BS_DRGUserRole用户角色关联表
- [x] 1.9 创建BS_DRGSystemMenu系统菜单表
- [x] 1.10 创建BS_DRGRoleMenu角色菜单关联表
- [x] 1.11 在CB_MapInterface注册新增接口记录

## 2. 后端接口服务开发

- [x] 2.1 开发src.DRG.Warning类 - 预警服务
  - [x] QueryWarningRules (Code: 02010101)
  - [x] SaveWarningRule (Code: 02010102)
  - [x] QueryWarningRecords (Code: 02010103)
  - [x] ProcessWarning (Code: 02010104)
- [x] 2.2 开发src.DRG.Profit类 - 盈亏分析服务
  - [x] QueryDeptProfit (Code: 02010201)
  - [x] QueryDoctorProfit (Code: 02010202)
  - [x] QueryDiseaseProfit (Code: 02010203)
- [x] 2.3 开发src.DRG.QC类 - 病案质控服务
  - [x] PerformQCCheck (Code: 02010301)
  - [x] QueryQCIssues (Code: 02010302)
- [x] 2.4 开发src.DRG.System类 - 系统管理服务
  - [x] QuerySystemUsers (Code: 02010401)
  - [x] SaveSystemUser (Code: 02010402)
  - [x] QuerySystemMenus (Code: 02010403)
  - [x] QueryInterfaceServices (Code: 02010404)
  - [x] SaveInterfaceService (Code: 02010405)
  - [x] GetUserMenus (Code: 02010408)

## 3. 前端基础框架搭建

- [ ] 3.1 初始化React 18 + Vite项目
- [ ] 3.2 安装Ant Design 5 + React Router 6
- [ ] 3.3 配置Axios请求封装（request.ts）
- [ ] 3.4 配置路由（router/index.tsx）
- [ ] 3.5 创建主布局组件（Layout/index.tsx）
- [ ] 3.6 配置状态管理（Zustand/Redux）

## 4. 前端API对接

- [ ] 4.1 对接已有病案查询接口（02010027）
- [ ] 4.2 对接已有分组记录接口（02010036）
- [ ] 4.3 对接已有分组执行接口（02010001）
- [ ] 4.4 创建预警相关API（warning.ts）
- [ ] 4.5 创建盈亏分析API（profit.ts）
- [ ] 4.6 创建质控相关API（qc.ts）
- [ ] 4.7 创建系统管理API（system.ts）

## 5. 前端页面开发

### 5.1 DRG业务模块
- [ ] 5.1.1 DRG分组工作台页面（DRG/Workbench）
- [ ] 5.1.2 分组结果查询页面（DRG/Results）
- [ ] 5.1.3 病案详情弹窗组件

### 5.2 DIP业务模块
- [ ] 5.2.1 DIP分组工作台页面（DIP/Workbench）
- [ ] 5.2.2 病种分值查询页面（DIP/DiseaseQuery）

### 5.3 费用预警模块
- [ ] 5.3.1 预警监控中心页面（Warning/Center）
- [ ] 5.3.2 预警规则配置页面（Warning/Rules）
- [ ] 5.3.3 预警处理记录页面（Warning/Records）

### 5.4 盈亏分析模块
- [ ] 5.4.1 科室盈亏报表页面（Profit/Dept）
- [ ] 5.4.2 医生盈亏分析页面（Profit/Doctor）
- [ ] 5.4.3 病种盈亏统计页面（Profit/Disease）

### 5.5 系统管理模块
- [ ] 5.5.1 用户管理页面（System/Users）
- [ ] 5.5.2 角色权限页面（System/Roles）
- [ ] 5.5.3 菜单配置页面（System/Menus）
- [ ] 5.5.4 接口服务配置页面（System/Interface）

## 6. 前端公共组件开发

- [ ] 6.1 创建SearchForm搜索表单组件
- [ ] 6.2 创建DataTable数据表格组件
- [ ] 6.3 创建StatisticCard统计卡片组件
- [ ] 6.4 创建ECharts图表封装组件
- [ ] 6.5 创建日期范围选择器组件
- [ ] 6.6 创建科室选择器组件

## 7. 菜单权限配置

- [ ] 7.1 初始化系统菜单数据
- [ ] 7.2 配置角色菜单权限
- [ ] 7.3 实现前端动态菜单渲染
- [ ] 7.4 实现页面权限控制

## 8. 系统集成测试

- [ ] 8.1 前端联调测试（与已有后端接口）
- [ ] 8.2 新增接口单元测试
- [ ] 8.3 端到端流程测试
- [ ] 8.4 权限控制测试

## 9. 部署上线

- [ ] 9.1 后端新表部署
- [ ] 9.2 后端新接口部署
- [ ] 9.3 前端构建部署
- [ ] 9.4 生产环境验证
