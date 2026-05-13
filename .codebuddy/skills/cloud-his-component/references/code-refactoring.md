# 代码改造规则

## 概述

组件数据入库后，需要修改原组件代码，使其从01040073接口动态获取配置，而非使用硬编码。

## 改造前判断

### 识别硬编码模式

组件具有以下特征时需要改造：

```jsx
// 特征1: skip01040073=true
<SingleTableOperation
  skip01040073={true}
  ...
/>

// 特征2: hardcodedColumns/hardcodedQueryFormData等props
<SingleTableOperation
  hardcodedColumns={columns}
  hardcodedQueryFormData={this.getQueryFormData()}
  hardcodedTotalWidth={totalWidth}
  ...
/>

// 特征3: 存在getColumns/getQueryFormData方法
getColumns = () => { return [...] }
getQueryFormData = () => { return [...] }
```

---

## 改造规则

### 1. 删除硬编码方法

**删除以下方法：**

| 方法名 | 说明 | 是否删除 |
|--------|------|----------|
| `getColumns()` | 返回硬编码表头数组 | 是 |
| `getQueryFormData()` | 返回硬编码查询表单 | 是 |
| `getFormData()` | 返回硬编码弹窗表单 | **单独组件处理** |
| `modalFormData` | 弹窗表单配置 | **单独组件处理** |

**示例：**

```diff
- /**
-  * 表格列配置
-  */
- getColumns = () => {
-   return [
-     { title: '状态', dataIndex: 'isRead', ... },
-     { title: '事件编号', dataIndex: 'eventId', ... },
-     ...
-   ];
- }

- /**
-  * 查询表单配置
-  */
- getQueryFormData = () => {
-   return [
-     { dataIndex: 'dateRange', title: '上报日期', typeCode: 'RangePicker', ... },
-     { dataIndex: 'queryBtn', title: '查询', typeCode: 'Button', ... },
-   ];
- }
```

### 1.1 modalFormData 单独组件处理

如果原组件包含 `modalFormData`，需要：

1. **新建组件**：`原组件名Modal`（如 `FormMaintenanceModal`）
2. 将 `modalFormData` 入库到新组件的 `formData` 中
3. **原组件中删除 `modalFormData` 变量**
4. 使用 `DynamicRenderingForm` 从新组件获取弹窗配置

```diff
// FormMaintenance.jsx 中
- /**
-  * 新建表单弹窗配置
-  */
- modalFormData = [
-   { dataIndex: 'templateName', title: '表单名称', typeCode: 'Input', ... },
-   ...
- ];

// 改为使用 DynamicRenderingForm 动态获取
```

**新组件的代码改造：**
- 新组件只需要保留基本的组件结构
- 通过 `getTableColumns` 获取配置
- 不需要其他业务逻辑

### 2. 删除相关变量

**删除render中用于硬编码的变量：**

```diff
  render() {
-   const columns = this.getColumns();
-   const totalWidth = columns.reduce((sum, col) => sum + (col.width || 120), 0);
-   const filteredData = this.getFilteredData();
    ...
  }
```

### 3. 修改SingleTableOperation组件props

**移除硬编码相关props：**

```diff
  <SingleTableOperation
    ref={this.tableRef}
-   skip01040073={true}
-   hardcodedColumns={columns}
-   hardcodedQueryFormData={this.getQueryFormData()}
-   hardcodedTotalWidth={totalWidth}
-   hardcodedDataSource={filteredData}
    categoryData={{
      componentName: 'Level1EventReminder',
      hidePaginationFlag: 'N',
      cancelAddOperationFlag: 'Y',
      hideQueryBtnFlag: 'Y',
    }}
-   selectData={{
-     tabList: this.getTabList(),
-   }}
    tabPosition="table"
    onTabChange={this.handleTabChange}
  />
```

### 4. 操作列render函数处理

**原则：入库基础信息，代码通过 operationObj prop 传入**

操作列（`dataIndex='operation'` 或 `key='action'`）需要特殊处理：

1. **入库内容：** title, key/seqNo, width, align, fixed（基础信息，用于被 operationObj 替换）
2. **代码保留：** 将操作列 render 逻辑迁移到 `getOperationObj()` 方法，通过 `operationObj` prop 传入

**改造后通过 operationObj prop 传入操作列：**

```jsx
// 组件内定义操作列 — 只返回 render，其他属性由 STO 内部维护
getOperationObj = () => ({
  render: (_, record) => (
    <span>
      <span className="span" onClick={(e) => this.handleViewDetail(record, e)}>
        查看详情
      </span>
      <Divider type="vertical" />
      <span className="span" onClick={(e) => this.handleModify(record, e)}>
        编辑
      </span>
    </span>
  ),
});

// render 中传入
<SingleTableOperation
  categoryData={{
    componentName: 'ComponentName',
    ...
  }}
  operationObj={this.getOperationObj()}
/>
```

**SingleTableOperation 内部处理逻辑：**
- `props.operationObj` 存在时，查找 columns 中 `dataIndex='operation'` 或 `key='action'` 的列
- 找到 → 用 `{ ...finalColumns[opIndex], ...props.operationObj }` 合并（数据库入库的操作列属性作为基础，props 覆盖）
- 未找到 → 追加到 columns 末尾
- **只需传 `render` 函数**：`width`、`title`、`align`、`key`、`fixed` 等由数据库入库的值提供，无需在 `getOperationObj()` 中重复定义

---

## 改造后代码结构

### 标准模板A：纯列表模式

```jsx
class ComponentName extends Component {
  constructor(props) {
    super(props);
    this.state = {
      // 保留业务state（不再需要 columns, queryFormData, totalWidth）
      currentTab: 'UNREAD',
      ...
    };
    this.tableRef = React.createRef();
  }

  componentDidMount() {
    // 业务初始化逻辑
  }

  // ==================== 业务方法保留 ====================

  handleQuery = () => { ... };
  handleTabChange = (tabId) => { ... };

  // ==================== 操作列配置（可选） ====================

  // 只需返回 { render: fn }，width/title/align 等由 STO 内部维护
  getOperationObj = () => ({
    render: (_, record) => (
      <span>
        <span className="span" onClick={(e) => this.handleViewDetail(record, e)}>查看详情</span>
      </span>
    ),
  });

  render() {
    return (
      <div className="component-name dynamic-component">
        <SingleTableOperation
          ref={this.tableRef}
          categoryData={{
            componentName: 'ComponentName',
            hidePaginationFlag: 'N',
            cancelAddOperationFlag: 'Y',
            hideQueryBtnFlag: 'Y',
            queryCode: '...',
            // 有下拉需求时使用 selectCode，不要在父组件 fetch 后通过 selectData prop 传入
            // selectCode: '30070023',
          }}
          operationObj={this.getOperationObj()}
        />
      </div>
    );
  }
}
```

### 标准模板B：弹窗融入模式

当组件包含新增/编辑弹窗（PublicModalFormHooks）时，弹窗由 SingleTableOperation 内部管理：

```jsx
import React, { Component } from 'react';
import { Divider } from 'antd';
import SingleTableOperation from 'pages/dynamicComponent/SingleTableOperation';

class ComponentName extends Component {
  constructor(props) {
    super(props);
    this.state = {
      // 仅保留子组件（Drawer/Modal）需要的 state
      selectData: {},
    };
    this.tableRef = React.createRef();
    this.drawerRef = React.createRef();
  }

  // 不需要 componentDidMount 调用 fetchInitData
  // 初始化数据通过 categoryData.selectCode 由 STO 统一获取

  // ==================== 操作列配置 ====================

  getOperationObj = () => ({
    render: (_, record) => {
      const buttons = [];

      // 自定义按钮
      buttons.push(
        <span key="custom" className="span" onClick={() => this.handleCustomAction(record)}>
          自定义
        </span>
      );

      // 修改按钮 — 委托给 STO 的 handleModify
      buttons.push(
        <span key="modify" className="span" onClick={() => this.tableRef.current.handleModify(record)}>
          修改
        </span>
      );

      return (
        <span className="action-buttons">
          {buttons.map((btn, index) => (
            <React.Fragment key={index}>
              {index > 0 && <Divider type="vertical" />}
              {btn}
            </React.Fragment>
          ))}
        </span>
      );
    },
  });

  // ==================== 子组件数据获取 ====================

  // 子组件（如 Drawer）需要 selectData 时，从 STO 内部读取
  handleOpenDrawer = (record) => {
    const selectData = this.tableRef.current?.state?.selectData || {};
    this.setState({ selectData }, () => {
      this.drawerRef.current.modifyVisible(true, { ... });
    });
  }

  render() {
    const { selectData } = this.state;
    return (
      <div className="component-name dynamic-component">
        <SingleTableOperation
          ref={this.tableRef}
          categoryData={{
            componentName: 'ComponentName',
            hidePaginationFlag: 'N',
            hideQueryBtnFlag: 'Y',
            queryCode: '...',                // 查询接口
            selectCode: '30070023',          // 初始化数据接口（下拉框等）
            addCode: '30070012',             // 新建/编辑保存接口
            addFollowQueryFlag: 'Y',         // 配合 addCode，使用 formData 中的新增按钮
            formModalWidth: '520px',          // 弹窗宽度
            modalTitle: '新建',               // 弹窗标题
            idIndex: 'id',                   // 主键字段名
            interfaceIDIndex: 'templateID',  // 接口ID字段名（编辑时传给后台）
          }}
          operationObj={this.getOperationObj()}
          // 不要传 selectData prop — 避免覆盖 STO 通过 selectCode 获取的数据
        />

        {/* 子组件 */}
        <SomeDrawer
          ref={this.drawerRef}
          selectData={selectData}
        />
      </div>
    );
  }
}
```

#### 弹窗融入模式关键配置项

| categoryData 字段 | 说明 | 示例 |
|-------------------|------|------|
| `selectCode` | 初始化数据接口，STO 在构建列之前先获取 selectData | `'30070023'` |
| `addCode` | 保存接口号，STO 内部 `handleSave` 使用此接口 | `'30070012'` |
| `addFollowQueryFlag` | `'Y'` 启用 formData 中的新增按钮 | `'Y'` |
| `formModalWidth` | 弹窗宽度 | `'520px'` |
| `modalTitle` | 弹窗标题 | `'新建表单'` |
| `idIndex` | 主键字段名，用于判断新增/编辑 | `'id'` |
| `interfaceIDIndex` | 接口ID字段名，编辑时传给后台 | `'templateID'` |

#### 弹窗融入模式注意事项

1. **不要传 `selectData` prop** — STO 通过 `getDerivedStateFromProps` 接收 prop 后会覆盖内部通过 `selectCode` 获取的数据，导致下拉为空
2. **子组件需要 selectData 时** — 使用 `this.tableRef.current?.state?.selectData` 读取，用 `setState` callback 确保子组件拿到最新值
3. **修改按钮委托** — 操作列中的"修改"按钮通过 `this.tableRef.current.handleModify(record)` 委托给 STO，STO 内部设置 rowData 并打开弹窗
4. **自定义保存** — 如需自定义保存逻辑，传入 `handleModalSave` prop，STO 仍管理 loading/关闭弹窗/刷新列表

---

## 需要保留的内容

### 保留的方法

| 方法类型 | 说明 |
|----------|------|
| 业务事件处理 | handleQuery, handleAdd, handleModify, handleDelete等 |
| Tab切换逻辑 | handleTabChange |
| 数据处理逻辑 | getFilteredData等（如有特殊业务逻辑） |
| 操作列配置 | getOperationObj（如需自定义操作列，通过operationObj prop传入） |

### 保留的state

| state | 说明 |
|-------|------|
| 业务状态 | currentTab, currentRecord等 |
| 数据状态 | tableData（如有特殊处理） |

### 保留的props

| props | 说明 |
|-------|------|
| categoryData | 保留，移除hardcoded相关；弹窗融入模式增加 `selectCode`、`addCode`、`formModalWidth`、`modalTitle` |
| operationObj | 新增（自定义操作列配置，只需返回 `{ render: fn }`） |
| handleModalSave | 新增（可选，自定义保存逻辑，STO 仍管理 loading/关闭弹窗/刷新） |
| onTabChange | 保留 |
| 其他业务props | 保留 |

> **注意：不要保留 `selectData` prop** 传给 SingleTableOperation。初始化数据通过 `categoryData.selectCode` 让 STO 自行获取。

---

## 注意事项

1. **操作列必须入库** - 即使有复杂render函数，也要入库基础信息（title, width等）
2. **componentName必须一致** - 入库时的code与categoryData.componentName必须相同
3. **保留回调绑定** - 查询按钮onClick等事件绑定在入库后仍需在代码中处理
4. **验证接口返回** - 改造后应测试01040073接口能正确返回配置
5. **扩展字段必须补回** - 非白名单字段不入库，改造后需在代码中动态赋值（见下方扩展字段章节）
6. **不要通过 selectData prop 传入下拉数据** - 使用 `categoryData.selectCode` 让 STO 统一获取，避免时序问题
7. **getOperationObj 只需返回 render** - width/title/align/key/fixed 等属性由 STO 内部维护

---

## 扩展字段处理（重要）

### 什么是扩展字段

后台01040073接口的 formData 白名单字段仅包含：`code`、`descripts`、`seqNo`、`enDesc`、`fieldTypeID`、`callback`、`placeholder`、`doubt`、`className`、`methodName`、`linkValueID`、`linkCode`、`col`、`jumpID`、`labelCol`、`wrapperCol`、`default`、`required`、`disabled`、`display`、`textSelect`、`selectField`。

**不在白名单中的字段称为"扩展字段"**，这些字段不会从数据库返回，需要在改造后的代码中动态补回。

### 常见扩展字段及用途

| 扩展字段 | 适用类型 | 用途 | 示例值 |
|----------|----------|------|--------|
| `linkStaticParams` | Select/Input | 表单数据静态参数，传给后台接口的额外参数 | `{ dictType: 'CATEGORY' }` |
| `onClick` | Button | 按钮点击事件回调 | `this.handleQuery` |
| `onPressEnter` | Input/InputNumber/TextArea | 回车键事件回调 | `this.handleQuery` |
| `btnStyle` | Button | 按钮外层样式 | `{ marginBottom: '0' }` |
| `style` | Button/其他 | 行内样式 | `{ textAlign: 'center' }` |
| `type` | Button | 按钮类型（primary/danger等） | `'primary'` |
| `ghost` | Button | 幽灵按钮样式 | `true` |
| `icon` | Button | 按钮图标 | `'plus'` |
| `mode` | Select | 多选模式 | `'multiple'` |
| `callBackResult` | Select/Input | 回调结果类型标识 | `'Fn'`、`'InputNumber'` |
| `changeCallBack` | Select/InputNumber | 值变更时的回调 | `this.handleSelectChange` |
| `onSelect` | Select | 下拉选择回调 | `this.handleSelectChange` |
| `onRef` | 任意 | 表单项ref回调 | `(ref) => this.handleRef(ref)` |
| `onPressEnter` | Input | 回车跳转下一个 | `() => this.handleEnter(i)` |

### 改造规则

**入库时：** 扩展字段不入库，直接过滤掉。

**改造时：** 必须在获取 formData 后遍历补回扩展字段。

**改造后代码模式：**

```jsx
// 示例1：补回 linkStaticParams 和按钮事件
getTableColumns = async () => {
  let data = {
    params: [{ type: 'C', compontName: 'MyComponent', reactCode: ['MyComponent'] }]
  };
  let res = await React.$asyncPost(this, '01040073', data);
  let columns = res.result?.C || [];
  let formData = res.result?.formData || [];

  // 遍历补回扩展字段
  for (let i = 0; i < formData.length; i++) {
    // 回车触发查询
    if (['Input', 'InputNumber', 'TextArea'].includes(formData[i].typeCode)) {
      formData[i].onPressEnter = this.handleQuery;
    }
    // 查询按钮
    if (formData[i].dataIndex === 'queryBtn') {
      formData[i].type = 'primary';
      formData[i].btnStyle = { marginBottom: '0' };
      formData[i].onClick = this.handleQuery;
    }
    // 特定字段的静态参数
    if (formData[i].dataIndex === 'eventTypeID') {
      formData[i].linkStaticParams = { dictType: 'CATEGORY' };
    }
  }

  this.setState({ columns, queryFormData: formData, totalWidth: res.totalWidth || 0 });
}
```

```jsx
// 示例2：弹窗表单的扩展字段
getModalFormData = async () => {
  let data = {
    params: [{ type: 'C', compontName: 'MyComponentModal', reactCode: ['MyComponentModal'] }]
  };
  let res = await React.$asyncPost(this, '01040073', data);
  let formData = res.result?.formData || [];

  for (let i = 0; i < formData.length; i++) {
    // 多选模式
    if (formData[i].dataIndex === 'linkValueID') {
      formData[i].mode = 'multiple';
    }
    // 静态参数
    if (formData[i].dataIndex === 'categoryID') {
      formData[i].linkStaticParams = { dictType: 'CATEGORY' };
    }
  }

  this.setState({ modalFormData: formData });
}
```

### 解析阶段识别扩展字段

在 Step 1（解析组件代码）时，应识别原始硬编码 formData 中的扩展字段，以便在 Step 5（改造预览）中明确告知用户需要补回哪些扩展字段。

**识别方式：**
```javascript
// 白名单
const FORM_DATA_WHITELIST = ['code', 'descripts', 'seqNo', 'enDesc', 'fieldTypeID',
  'callback', 'placeholder', 'doubt', 'className', 'methodName', 'linkValueID',
  'linkCode', 'col', 'jumpID', 'labelCol', 'wrapperCol', 'default', 'required',
  'disabled', 'display', 'textSelect', 'selectField'];

// 检测扩展字段
const extraFields = Object.keys(formDataItem).filter(key => !FORM_DATA_WHITELIST.includes(key));
// extraFields 例如：['linkStaticParams', 'mode', 'onClick']
```

## 改造验证

改造完成后，验证以下内容：

1. 组件加载时自动调用01040073获取配置
2. 表头、查询表单正确显示
3. 操作列render正确绑定
4. 业务功能（查询、Tab切换等）正常工作
