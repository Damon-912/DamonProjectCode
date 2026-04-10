## 1. 全局ConfigProvider配置

- [x] 1.1 在main.tsx中添加ConfigProvider和zhCN import，用`<ConfigProvider locale={zhCN}>`包裹`<App />`
- [x] 1.2 移除BasicDataMaintenance.tsx中的局部`<ConfigProvider locale={zhCN}>`包裹、`import zhCN from 'antd/locale/zh_CN'`和`import { ConfigProvider }`导入

## 2. 删除重复Pagination Locale（25个页面）

- [x] 2.1 删除BasicData/ADRGRuleMaintenance.tsx中pagination的locale属性
- [x] 2.2 删除BasicData/BasicDataMaintenance.tsx中pagination的locale属性 (无locale配置，跳过)
- [x] 2.3 删除BasicData/CoreAlgorithmConfig.tsx中pagination的locale属性
- [x] 2.4 删除BasicData/DIPDisease.tsx中pagination的locale属性
- [x] 2.5 删除BasicData/DRGCataLog.tsx中pagination的locale属性
- [x] 2.6 删除BasicData/DRGSegmentationRules.tsx中pagination的locale属性
- [x] 2.7 删除BasicData/ICDMapping.tsx中pagination的locale属性
- [x] 2.8 删除BasicData/ICDQuery.tsx中pagination的locale属性
- [x] 2.9 删除BasicData/TableDataMaintenance.tsx中pagination的locale属性
- [x] 2.10 删除DIP/DiseaseQuery.tsx中pagination的locale属性
- [x] 2.11 删除DIP/VarianceAnalysis.tsx中pagination的locale属性
- [x] 2.12 删除DIP/Workbench.tsx中pagination的locale属性
- [x] 2.13 删除DRG/Results.tsx中pagination的locale属性 (无locale配置，跳过)
- [x] 2.14 删除DRG/Workbench.tsx中pagination的locale属性
- [x] 2.15 删除HIS/DataSync.tsx中pagination的locale属性
- [x] 2.16 删除HIS/MedicalRecords.tsx中pagination的locale属性
- [x] 2.17 删除HIS/Settlement.tsx中pagination的locale属性
- [x] 2.18 删除Profit/CostStructure.tsx中pagination的locale属性
- [x] 2.19 删除Profit/Dept.tsx中pagination的locale属性
- [x] 2.20 删除Profit/Disease.tsx中pagination的locale属性
- [x] 2.21 删除Profit/Doctor.tsx中pagination的locale属性
- [x] 2.22 删除System/Hospitals.tsx中pagination的locale属性
- [x] 2.23 删除System/Interfaces.tsx中pagination的locale属性
- [x] 2.24 删除System/Menus.tsx中pagination的locale属性
- [x] 2.25 删除Warning/Center.tsx中pagination的locale属性
- [x] 2.26 删除Warning/Records.tsx中pagination的locale属性
- [x] 2.27 删除Warning/Rules.tsx中pagination的locale属性

## 3. 纯英文标签替换为中文

- [x] 3.1 Interfaces.tsx：`title: 'Session'` → `title: '会话验证'`，`title: 'Token'` → `title: '令牌验证'`
- [x] 3.2 Results.tsx：`title: 'DRG'` → `title: 'DRG编码'`
- [x] 3.3 CustomQuery.tsx：`<Text>MDC</Text>` → `<Text>MDC编码</Text>`
