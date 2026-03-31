# ADRG分组规则维护 - 任务清单

## Phase 1: API 层

- [x] **T1** 在 `frontend/src/api/basicData.ts` 中新增ADRG规则相关API函数和类型
  - `AdrgRuleItem` 接口类型
  - `SaveAdrgRuleParams` 接口类型
  - `queryAdrgRules` - 查询ADRG规则列表 (02010017)
  - `saveAdrgRule` - 保存ADRG规则 (02010016)
  - `deleteAdrgRule` - 删除ADRG规则 (02010018)

## Phase 2: 页面开发

- [ ] **T2** 创建 `frontend/src/pages/BasicData/ADRGRuleMaintenance.tsx`
  - 查询条件区域：ADRG名称（模糊）、状态（全部/有效/无效）
  - 数据表格：规则列表（分页），可展开行显示完整诊断和手术信息
  - 工具栏：新增规则
  - 新增/编辑弹窗：三区域布局（基本信息、诊断信息、手术/操作信息）
  - 删除确认弹窗
  - 接口调用：02010016（保存）、02010017（查询）、02010018（删除）

## Phase 3: 路由注册

- [x] **T3** 在 `frontend/src/App.tsx` 中注册路由和菜单
  - 菜单：基础数据管理 → ADRG分组规则维护（key: `basic-data-adrg-rules`）
  - 页面组件：`ADRGRuleMaintenance`
  - 引入组件并添加渲染逻辑

## 依赖关系

```
T1 ──> T2 ──> T3
```
