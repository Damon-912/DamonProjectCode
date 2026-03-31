# Tasks: DRG基础数据维护

## 实现任务清单

### Task 1: 后端接口服务类

**文件**: `src/src/BasicData/BasicData.cls`

- [ ] 1.1 创建 `src.BasicData.BasicData` 类
- [ ] 1.2 实现 `SaveBasicData` 方法 (02010010)
  - 参数获取: id, insuCode, insuDesc, provinceDr, cityDr, areaDr, startDate, stopDate, identification, remark
  - 逻辑: id为空则 `New`，非空则 `%OpenId` 获取后修改
  - 写入字段映射
- [ ] 1.3 实现 `QueryBasicData` 方法 (02010011)
  - 支持 insuCode/insuDesc 模糊查询
  - 支持 provinceDr/cityDr 精确筛选
  - 支持 isActive 有效状态筛选(根据startDate/stopDate判断)
  - 分页查询，返回 total + rows
- [ ] 1.4 实现 `DeleteBasicData` 方法 (02010012)
  - 参数: id
  - 先删除 HB_DRGBasicDataSub 中 hbDictionariesDr = id 的明细记录
  - 再删除主表记录
- [ ] 1.5 实现 `SaveBasicDataSub` 方法 (02010013)
  - 参数获取: id, hbDictionariesDr, code, descripts, identification, startDate, stopDate, remark
  - 逻辑: id为空则 `New`，非空则 `%OpenId` 获取后修改
- [ ] 1.6 实现 `QueryBasicDataSub` 方法 (02010014)
  - 参数: hbDictionariesDr(必填), code, identification, isActive
  - 按 hbDictionariesDr 筛选明细
  - 分页查询
- [ ] 1.7 实现 `DeleteBasicDataSub` 方法 (02010015)
  - 参数: id
  - 删除明细记录

---

### Task 2: 前端API封装

**文件**: `frontend/src/api/basicData.ts`

- [x] 2.1 创建 basicData.ts 文件
- [x] 2.2 封装6个接口方法: saveBasicData, queryBasicData, deleteBasicData, saveBasicDataSub, queryBasicDataSub, deleteBasicDataSub
- [x] 2.3 导出 TypeScript 类型定义

---

### Task 3: 前端页面组件

**文件**: `frontend/src/pages/BasicData/BasicDataMaintenance.tsx`

- [x] 3.1 创建页面组件骨架
- [x] 3.2 主表搜索区域 (代码/描述/标识码/省份/城市)
- [x] 3.3 主表数据表格 (Ant Design Table)
  - 列: 代码, 描述, 省, 市, 区, 生效日期, 失效日期, 标识码, 操作(编辑/删除)
- [x] 3.4 新增/编辑主表对话框 (Ant Design Modal + Form)
  - 表单字段: insuCode, insuDesc, provinceDr(下拉), cityDr(下拉), areaDr(下拉), startDate(日期), stopDate(日期), identification, remark
- [x] 3.5 明细区域 (点击主表行加载)
  - 标题显示选中主表名称
- [x] 3.6 明细数据表格
  - 列: 代码, 描述, 标识码, 生效日期, 失效日期, 备注, 操作(编辑/删除)
- [x] 3.7 新增/编辑明细对话框
  - 表单字段: code, descripts, identification, startDate, stopDate, remark
- [x] 3.8 删除二次确认 (Modal.confirm)

---

### Task 4: 菜单集成与路由注册

**文件**: `frontend/src/App.tsx`

- [x] 4.1 确认 `basic-data-maintenance` 菜单项已存在
- [x] 4.2 添加页面组件导入和路由渲染逻辑

---

## 实现顺序

1. **Task 1** (后端) → 2. **Task 2** (API封装) → 3. **Task 3** (页面) → 4. **Task 4** (集成)

## 验证标准

- 后端6个接口均能正确响应
- 前端页面可正常加载、搜索、新增、编辑、删除主表和明细
- 主表删除时级联删除明细
- 所有字段使用小驼峰命名
