---
name: cloud-his-component
description: This skill should be used when converting hardcoded columns/formData from React components to database-driven dynamic configuration via 01049999 (write) and 01040073 (read) interfaces.
Triggers: 组件文件, 批量处理组件, 写死的表头表单数据入库, component data import.
---

# 组件数据导入

将 React 组件中写死的 Columns 和 FormData 转换为接口格式，通过 01049999 入库，并改造组件代码从 01040073 动态获取配置。

## 触发条件

- 用户 @ 一个组件文件，希望将写死的表头/表单数据入库
- 组件使用 `skip01040073={true}` 硬编码模式
- 需要将硬编码配置改为动态配置

## 改造模式

Step 1 解析代码后，判断改造模式并选择对应策略：

| 模式 | 判断条件 | 核心差异 |
|------|----------|----------|
| **纯列表** | 无弹窗，仅 `SingleTableOperation` | 删除硬编码，STO 自动获取列 |
| **弹窗融入** | 有 `PublicModalFormHooks` 或 `modalFormData` | 弹窗由 STO 内部管理，需 `selectCode`/`addCode` 等配置 |
| **直连表格** | 直接使用 `PubilcTablePagination`（非 STO） | 手动新增 `getColumnsData()` 调 01040073 |

三种模式的详细改造规则和代码模板：见 [references/code-refactoring.md](references/code-refactoring.md)

## 工作流程

```
@组件文件 → 解析代码 → 确认元数据 → 数据转换 → 入库 → 改造预览 → 执行改造
```

### Step 1: 解析组件代码

提取硬编码数据：`getColumns()`、`getQueryFormData()`、`modalFormData`（constructor 或类属性）。

识别硬编码特征：
- `skip01040073={true}`
- `hardcodedColumns={columns}` / `hardcodedQueryFormData={...}`
- 方法返回值模式：`getColumns = () => { return [...] }`

同步识别**扩展字段**（非白名单字段如 `onClick`、`linkStaticParams`、`onPressEnter` 等），记录下来用于 Step 5 改造预览。

### Step 2: 确认元数据

- **componentName**: 默认取文件名（去 `.jsx` 后缀），用户可修改
- **descripts**: 组件中文描述
- **enDesc**: 英文描述（可选）

确认改造模式（纯列表 / 弹窗融入 / 直连表格）。

### Step 3: 数据转换

将前端格式的 columns/formData 转换为 01049999 接口格式。

**关键转换规则（必须遵守）：**

1. **align**: `left`→`L`, `center`→`C`, `right`→`R`
2. **formData 必填字段**: `display`(Y), `required`(N), `disabled`(N) — 缺失会报错
3. **selectField → className**: Select 类型下拉数据源字段名映射
4. **扩展字段不入库**: 白名单外字段（`onClick`、`linkStaticParams`、`mode` 等）过滤掉，改造后在代码中补回
5. **操作列入库基础信息**: `operation`/`action` 列入库 title/width/align/seqNo，render 通过 `operationObj` prop 传入（仅限 STO 模式）
6. **modalFormData 单独入库**: 弹窗表单入库到 `XXXModal` 组件（命名规则：原组件名 + Modal）

详细转换规则和字段白名单：见 [references/conversion-rules.md](references/conversion-rules.md)
字段类型映射表（typeCode → fieldTypeID）：见 [references/field-mapping.md](references/field-mapping.md)

### Step 4: 调用 01049999 入库

1. 组装入库数据（columns + formData），写入临时文件 `scripts/push-data.json`
2. 执行入库脚本：`node .codebuddy/skills/component-data-import/assets/push-to-db.cjs scripts/push-data.json`
3. 成功后清理临时文件，继续 Step 5

入库数据格式和接口规范：见 [references/interface-spec.md](references/interface-spec.md)

### Step 5: 展示改造预览

以 diff 格式展示改造前后对比，根据改造模式选择对应模板：

**通用删除项：** 硬编码方法、`skip01040073` prop、`hardcoded*` props、多余的 state

**通用新增项（STO 模式）：** `getOperationObj()` → `{ render: fn }`，传入 `operationObj` prop

**弹窗融入额外项：** 删除 `fetchInitData`/`modalFormData`/`PublicModalFormHooks` JSX，增加 `selectCode`/`addCode`/`formModalWidth`/`modalTitle`

**直连表格额外项：** 新增 `getColumnsData()` 方法，`param` 加 `componentName`，传 `getColumns` 回调

### Step 6: 执行代码改造

确认后修改组件文件。改造完成后清理临时文件。

**验证要点：**
- 组件加载时调 01040073 获取配置
- 表头、查询表单正确显示
- 操作列 render 正确绑定
- 扩展字段已补回（`onClick`、`linkStaticParams` 等）
- 业务功能正常

## 直连表格模式要点（PubilcTablePagination）

当组件不使用 SingleTableOperation 而直接使用 PubilcTablePagination 时：

- `param` 中**必须**添加 `componentName`（与入库组件名一致）
- **必须**传入 `getColumns={this.getColumnsData}` 以支持列权限管理
- 新增 `getColumnsData()` 方法手动调 01040073，通过 `col.code` 匹配注入箭头函数 render
- `PublicModalFormHooks` 保持原样，`formData` 改为从接口动态获取

```jsx
<PublicTablePagination
  param={{
    columns: approvalColumns,
    data: approvalChain,
    componentName: 'ComponentName'   // 必须
  }}
  getColumns={this.getColumnsData}   // 必须
/>
```

## 过滤规则

- 无 `dataIndex` 且无 `key` 的列不入库
- `operation`/`action` 列入库基础信息，render 不入库
- `queryBtn`/`resetBtn` 识别为按钮类型（fieldTypeID=17）

## References

- [代码改造规则](references/code-refactoring.md) — 三种改造模式的详细规则、代码模板、扩展字段处理
- [数据转换规则](references/conversion-rules.md) — Columns/FormData 字段映射、白名单、转换示例
- [接口规范说明](references/interface-spec.md) — 01049999 入库 / 01040073 读取的参数与返回值
- [字段类型映射表](references/field-mapping.md) — typeCode 到 fieldTypeID 的完整映射
