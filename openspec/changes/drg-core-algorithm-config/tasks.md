# DRG核心算法配置维护 - 任务清单

## Phase 1: API 层

- [x] **T1** 在 `frontend/src/api/basicData.ts` 中新增DRG核心算法配置相关API函数和类型
  - `CoreAlgorithmItem` 接口类型
  - `SaveCoreAlgorithmParams` 接口类型
  - `queryCoreAlgorithm` - 查询DRG核心算法配置 (02010033)
  - `saveCoreAlgorithm` - 保存DRG核心算法配置 (02010032)
  - `deleteCoreAlgorithm` - 删除DRG核心算法配置 (02010034)

## Phase 2: 页面开发

- [x] **T2** 创建 `frontend/src/pages/BasicData/CoreAlgorithmConfig.tsx`
  - 查询条件区域：DRG编码（模糊）、医疗机构名称（模糊）、省市、状态
  - 数据表格：配置列表（分页），列包括DRG编码/描述、基准点数、预估点值、差异系数、支付标准、险种、医疗机构、状态
  - 工具栏：新增配置
  - 新增/编辑弹窗：三区域布局（DRG信息、算法参数、机构与地区+有效期）
  - 删除确认弹窗

## Phase 3: 导航栏与路由

- [ ] **T3** 在 `frontend/src/App.tsx` 中注册菜单和路由
  - 菜单：基础数据管理 → DRG核心算法配置维护（key: `basic-data-core-algorithm`）
  - 引入组件并添加渲染逻辑

## 依赖关系

```
T1 ──> T2 ──> T3
```
