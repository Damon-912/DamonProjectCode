# ICD编码映射与ICD编码查询 - 任务清单

## Phase 1: API 层

- [x] **T1** 在 `frontend/src/api/basicData.ts` 中新增ICD编码映射相关API函数
  - `queryIcdMapping` - 查询ICD编码映射关系 (02010023)
  - `saveIcdMapping` - 保存ICD编码映射关系 (02010023)
  - `deleteIcdMapping` - 删除ICD编码映射关系 (02010023)
  - `queryMedInsuIcdInfo` - 查询医保ICD编码信息 (02010022)

- [x] **T2** 在 `frontend/src/api/basicData.ts` 中新增ICD编码查询API函数
  - `queryIcdInfo` - 查询各地方版本ICD编码信息 (02010037)

## Phase 2: ICD编码映射页面

- [x] **T3** 创建 `frontend/src/pages/BasicData/ICDMapping.tsx`
  - 查询条件区域：版本号、省市、地方ICD代码/描述、医保ICD代码/描述
  - 数据表格：映射关系列表（分页、勾选）
  - 工具栏：新增映射、批量删除
  - 新增/编辑弹窗：左右分栏（地方ICD / 医保ICD），支持从ICD库选择
  - 删除确认弹窗
  - 接口调用：02010023（查询/保存/删除）、02010022（医保ICD选择）

## Phase 3: ICD编码查询页面

- [x] **T4** 创建 `frontend/src/pages/BasicData/ICDQuery.tsx`
  - 查询条件区域：版本（ICD-9/ICD-10）、省市、ICD代码/描述、状态
  - 数据表格：ICD编码列表（分页）
  - 仅查询功能（后端增删改接口未生成）
  - 接口调用：02010037

## Phase 4: 路由注册

- [x] **T5** 在 `frontend/src/App.tsx` 中注册路由
  - `/basic-data/icd-mapping` → `ICDMapping`
  - `/basic-data/icd-query` → `ICDQuery`
  - 路由应在 add-basic-data-management change 中已预定义，此处确认并对接组件

## 依赖关系

```
T1 ──┬──> T3
T2 ──────> T4
T3, T4 ──> T5
```
