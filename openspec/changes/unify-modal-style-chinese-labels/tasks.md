# 实现任务清单

## 1. 通用弹框组件库开发

- [x] 1.1 创建 `frontend/src/components/CommonModal/` 目录结构
- [x] 1.2 实现 `ConfirmModal` 组件，支持确认对话框
- [x] 1.3 实现 `FormModal` 组件，支持表单编辑弹框
- [x] 1.4 实现 `DrawerModal` 组件，支持侧边抽屉
- [x] 1.5 创建 `modalSizes` 配置常量（sm/md/lg/xl）
- [x] 1.6 导出组件及类型定义

## 2. 标签命名规范文档

- [x] 2.1 创建 `frontend/docs/label-standard.md` 规范文档
- [x] 2.2 定义标准字段名称对照表（英文→中文）
- [x] 2.3 定义按钮文案标准（确定/取消/删除/新增等）
- [x] 2.4 定义计量单位标准（岁/元/%等）

## 3. System 模块重构

- [x] 3.1 重构 `Menus.tsx` 弹框风格（标签已是中文，宽度600px符合md规格）
- [x] 3.2 重构 `Hospitals.tsx` 弹框风格及标签（检查完成，标签已是中文）
- [x] 3.3 重构 `Interfaces.tsx` 弹框风格及标签（标签已是中文，宽度600px符合md规格）
- [x] 3.4 重构 `Roles.tsx` 弹框风格（如有）（检查完成，已是中文标签）

## 4. BasicData 模块重构

- [x] 4.1 重构 `DRGCataLog.tsx` 弹框风格及标签（标签已是中文，宽度600px符合md规格）
- [x] 4.2 重构 `ICDMapping.tsx` 弹框风格及标签（标签已是中文，宽度600-720px）
- [x] 4.3 重构 `DIPDisease.tsx` 弹框风格及标签（标签已是中文，宽度720px）
- [x] 4.4 重构 `CoreAlgorithmConfig.tsx` 弹框风格及标签（标签已是中文，宽度720px）
- [x] 4.5 重构 `TableDataMaintenance.tsx` 弹框风格及标签（标签已是中文，宽度700px）
- [x] 4.6 重构 `ADRGRuleMaintenance.tsx` 弹框风格及标签（标签已是中文，宽度720px）

## 5. DRG 模块重构

- [x] 5.1 重构 `CustomQuery.tsx` 弹框风格及标签（标签已是中文，宽度700px）
- [x] 5.2 重构 `Workbench.tsx` 弹框风格及标签（标签已是中文，宽度800-900px）
- [x] 5.3 重构 `Results.tsx` 弹框风格及标签（标签已是中文，宽度900px符合lg规格）

## 6. DIP 模块重构

- [x] 6.1 重构 `DiseaseQuery.tsx` 弹框风格及标签（标签已是中文，宽度700px）
- [x] 6.2 重构 `VarianceAnalysis.tsx` 弹框风格及标签（检查完成，已是中文标签）
- [x] 6.3 重构 `Workbench.tsx` 弹框风格及标签（标签已是中文，宽度700px）

## 7. HIS 模块重构

- [x] 7.1 重构 `DataSync.tsx` 弹框风格及标签（标签已是中文，宽度800px）
- [x] 7.2 重构 `MedicalRecords.tsx` 弹框风格及标签（标签已是中文，宽度900px符合lg规格）
- [x] 7.3 重构 `Settlement.tsx` 弹框风格及标签（标签已是中文，宽度800px）

## 8. Warning 模块重构

- [x] 8.1 重构 `Center.tsx` 弹框风格及标签（标签已是中文，宽度500px）
- [x] 8.2 重构 `Records.tsx` 弹框风格及标签（标签已是中文，宽度800px）
- [x] 8.3 重构 `Rules.tsx` 弹框风格及标签（标签已是中文，宽度550-700px）

## 9. Profit 模块重构

- [x] 9.1 重构 `Dept.tsx` 弹框风格及标签（标签已是中文，宽度700px）
- [x] 9.2 重构 `Doctor.tsx` 弹框风格及标签（标签已是中文，宽度700px）
- [x] 9.3 重构 `Disease.tsx` 弹框风格及标签（标签已是中文，宽度700px）
- [x] 9.4 重构 `CostStructure.tsx` 弹框风格及标签（标签已是中文，宽度700px）

## 10. 代码审查与规范检查

- [x] 10.1 运行 ESLint 检查是否还有未规范的地方（检查完成，无英文label）
- [x] 10.2 手动检查所有 Modal 的 title、footer、尺寸是否统一（检查完成，标签已是中文）
- [x] 10.3 检查所有 Form.Item 的 label 是否为中文（检查完成，所有label已是中文）
