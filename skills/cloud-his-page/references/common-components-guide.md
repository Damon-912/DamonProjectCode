# 公共组件使用指南

> CloudHIS-PR项目公共组件使用说明

---

## 概述

### 使用原则

> **公共组件中有的优先使用，没有的才需要自己开发**

### 组件优先级

| 场景 | 优先使用 | 禁止行为 |
|------|----------|----------|
| 表单渲染 | DynamicRenderingForm | 禁止直接使用Ant Design的Form自行封装 |
| 列表展示 | PubilcTablePagination | 禁止直接使用Ant Design的Table自行封装 |
| 弹窗表单 | PublicModalFormHooks | 禁止直接使用Ant Design的Modal+Form自行封装 |
| 标准CRUD | SingleTableOperation | 禁止自行实现标准增删改查界面 |
| iframe弹窗 | IframeModal | 禁止直接使用Ant Design的Modal+iframe自行封装 |
| 数据排序 | PublicDataOrderAdjustment | 禁止自行实现拖拽排序功能 |

---

## 必用公共组件

| 组件 | 路径 | 用途 | 使用场景 |
|------|------|------|----------|
| **DynamicRenderingForm** | `src/pages/common/DynamicRenderingForm.jsx` | 动态渲染表单 | 查询条件表单、弹窗表单 |
| **PubilcTablePagination** | `src/pages/common/PubilcTablePagination.jsx` | 表格+分页 | 列表展示 |
| **PublicModalFormHooks** | `src/pages/common/PublicModalFormHooks.jsx` | 弹窗表单处理 | 新增/修改弹窗 |
| **SingleTableOperation** | `src/pages/dynamicComponent/SingleTableOperation.jsx` | 标准CRUD包装 | 标准增删改查界面 |
| **IframeModal** | `src/pages/common/IframeModal.jsx` | iframe弹窗 | 外链页面弹窗展示 |
| **PublicDataOrderAdjustment** | `src/pages/common/PublicDataOrderAdjustment.jsx` | 数据顺序调整 | 拖拽排序功能 |

### 导入路径规范（重要）

**正确的导入方式：**
```jsx
// ✅ 正确：使用相对路径
import DynamicRenderingForm from '../common/DynamicRenderingForm';
import PubilcTablePagination from '../common/PubilcTablePagination';
import PublicModalFormHooks from '../common/PublicModalFormHooks';
import SingleTableOperation from '../dynamicComponent/SingleTableOperation';
```

**错误的导入方式：**
```jsx
// ❌ 错误：项目未配置 @/ alias
import DynamicRenderingForm from '@/pages/common/DynamicRenderingForm';

// ❌ 错误：路径不存在
import DynamicRenderingForm from '@/containers/components/DynamicRenderingForm';

// ❌ 错误：alias 配置不匹配
import DynamicRenderingForm from 'pages/common/DynamicRenderingForm';
```

**说明：**
- 公共组件位于 `src/pages/common/` 目录下
- 动态组件位于 `src/pages/dynamicComponent/` 目录下
- 在 `src/pages/xxx/` 下的组件中引用时，必须使用 `../` 相对路径
- 项目 webpack 配置中未配置 `@/` 别名，禁止使用

---

## DynamicRenderingForm

### 组件用途

动态渲染表单组件，根据配置数据自动渲染各种表单元素。

### 组件路径

```
src/pages/common/DynamicRenderingForm.jsx
```

### Props属性

| 属性名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| formData | array | 是 | 表单字段配置数据 |
| onRef | function | 否 | 组件ref，用于获取表单实例 |
| selectData | object | 否 | 下拉框数据源 |
| rowData | object | 否 | 编辑回显数据 |
| className | string | 否 | 样式类名，查询表单用 `dynamic-component-form` |

### formData配置格式

```javascript
[
  {
    dataIndex: 'fieldName',      // 字段名
    title: '字段标题',            // 显示标题
    typeCode: 'Input',           // 输入类型
    required: 'Y',               // 是否必填 Y/N
    disabled: 'N',               // 是否禁用 Y/N
    col: 8,                      // 占列数（一行24份）
    selectField: 'statusList',   // 下拉数据源key（Select类型）
    doubt: '提示信息'            // 提示文字
  }
]
```

### 使用示例

#### 查询表单

```jsx
import { Row, Col } from 'antd';
import DynamicRenderingForm from '../common/DynamicRenderingForm';

// 在class组件中
class Example extends Component {
  // 写死的查询表单配置
  queryFormData = [
    {
      dataIndex: 'userCode',
      title: '用户代码',
      typeCode: 'Input',
      required: 'N',
      col: 8
    },
    {
      dataIndex: 'status',
      title: '状态',
      typeCode: 'Select',
      required: 'N',
      col: 8,
      selectField: 'statusList'
    }
  ];

  render() {
    return (
      <Row style={{ padding: '14px 24px 0 12px' }}>
        <Col span={20}>
          <DynamicRenderingForm
            className="dynamic-component-form"
            rowData={{}}
            selectData={this.state.selectData}
            formData={this.queryFormData}
            onRef={ref => this.formRef = ref}
          />
        </Col>
      </Row>
    );
  }
}
```

#### 获取表单值

```javascript
// 获取表单值
fetchList = async () => {
  let values = await this.formRef.handleSave();
  if (values.error) {
    message.error('请完善必填信息');
    return;
  }
  // values为表单字段值对象
  console.log(values);  // { userCode: 'xxx', status: '1' }
};
```

### 表单布局技巧

#### 横向布局（默认）

查询表单通常使用横向布局，label和input在同一行：

```jsx
// formData配置 - 不设置labelCol/wrapperCol
queryFormData = [
  { dataIndex: 'code', title: '代码', typeCode: 'Input', col: 8 }
];

// 使用dynamic-component-form类名
<DynamicRenderingForm
  className="dynamic-component-form"
  formData={this.queryFormData}
/>
```

#### 纵向布局（label和wrapper换行）

右侧详情面板等场景需要label和input分两行展示：

```jsx
// formData配置 - labelCol和wrapperCol都设置为24
detailFormData = [
  { 
    dataIndex: 'fieldName', 
    title: '字段名称', 
    typeCode: 'Input', 
    col: 24,
    labelCol: 24,      // label占满一行
    wrapperCol: 24     // wrapper占满一行（换行展示）
  }
];

// 不使用dynamic-component-form类名
<DynamicRenderingForm
  formData={this.detailFormData}
  rowData={rowData}
/>
```

#### 布局对比

| 布局方式 | className | labelCol | wrapperCol | 效果 |
|----------|-----------|----------|------------|------|
| 横向 | `dynamic-component-form` | 不设置 | 不设置 | label和input同行 |
| 纵向 | 不设置 | 24 | 24 | label和input各占一行 |

### 表单分组功能

#### 核心说明

```
⚠️ DynamicRenderingForm 组件已内置 CardTitle 类型，支持在同一个 formData 数组中实现表单分组！

❌ 错误做法：将表单拆分成多个 DynamicRenderingForm 组件
✅ 正确做法：在同一个 formData 数组中使用 CardTitle 进行分组
```

#### CardTitle 用法

```javascript
// ✅ 正确：使用 CardTitle 在同一个表单中分组
modalFormData = [
  // 基本信息分组
  { typeCode: 'CardTitle', title: '基本信息' },
  { dataIndex: 'userName', title: '用户名称', typeCode: 'Input', col: 12, required: 'Y' },
  { dataIndex: 'userCode', title: '用户代码', typeCode: 'Input', col: 12, required: 'Y' },

  // 联系信息分组
  { typeCode: 'CardTitle', title: '联系信息' },
  { dataIndex: 'phone', title: '手机号', typeCode: 'Input', col: 12, required: 'Y' },
  { dataIndex: 'email', title: '邮箱', typeCode: 'Input', col: 12 },
];
```

| 属性名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `typeCode` | string | 是 | 固定值 `'CardTitle'` |
| `title` | string | 是 | 分组标题文字 |

#### Divider 分割线

```javascript
modalFormData = [
  { dataIndex: 'field1', title: '字段1', typeCode: 'Input', col: 12 },
  { typeCode: 'Divider', col: 24 },  // 分割线
  { dataIndex: 'field2', title: '字段2', typeCode: 'Input', col: 12 },
];
```

#### 优势

1. **代码简洁**：一个组件实例完成所有表单渲染
2. **数据统一**：所有字段在同一个表单实例中，方便统一验证和提交
3. **样式一致**：自动应用 `.card-title-left-icon` 样式，视觉效果统一
4. **维护方便**：只需维护一个 formData 配置数组

---

## PubilcTablePagination

### 组件用途

封装了表格和分页功能的公共列表组件。

### 组件路径

```
src/pages/common/PubilcTablePagination.jsx
```

### Props属性

| 属性名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| param | object | 是 | 配置参数对象 |
| compilePage | function | 是 | 分页变化回调 (page, pageSize) => {} |
| onClickRowPublic | function | 否 | 行点击事件 |
| setRowClassNamePublic | function | 否 | 行样式类名 |
| getColumns | function | 否 | 刷新表头方法 |
| rowSelection | object | 否 | 行选择配置 |

### param参数详解

```javascript
{
  page: 1,                      // 当前页码
  size: 'small',                // 表格尺寸 small/default/large
  pageSize: 10,                 // 每页条数
  total: 0,                     // 总记录数
  loading: false,               // 加载状态
  extendFlag: 'Y',              // 扩展数据标识（维护分页设置）
  componentName: 'Example',     // 组件名称
  data: [],                     // 表格数据数组
  x: 1500,                      // 表格宽度
  y: 400,                       // 表格最小高度
  height: '400px',              // 表格最大高度
  columns: []                   // 表头配置数组
}
```

### 使用示例

#### 基础列表

```jsx
import PubilcTablePagination from '../common/PubilcTablePagination';
import store from 'tools/store';

class Example extends Component {
  state = {
    dataList: [],
    columns: [],
    loading: false,
    page: 1,
    pageSize: 10,
    total: 0,
    queryHeight: 125
  };

  // 写死的表头
  columns = [
    { title: '用户代码', dataIndex: 'userCode', width: 120 },
    { title: '用户名称', dataIndex: 'userName', width: 150 }
  ];

  handlePageChange = (page, pageSize) => {
    this.setState({ page, pageSize }, () => {
      this.fetchList();
    });
  };

  render() {
    const { dataList, loading, page, pageSize, total, queryHeight } = this.state;
    const totalWidth = this.columns.reduce((sum, col) => sum + (col.width || 100), 0);

    return (
      <div style={{ padding: '24px' }} className="table-body-height">
        <PubilcTablePagination
          param={{
            page,
            size: 'small',
            pageSize,
            total,
            loading,
            extendFlag: 'Y',
            componentName: 'Example',
            data: dataList,
            x: totalWidth,
            y: store.getState().tableHeight.y + 93 - queryHeight,
            height: store.getState().tableHeight.y + 143 - queryHeight + 'px',
            columns: this.columns
          }}
          compilePage={this.handlePageChange}
        />
      </div>
    );
  }
}
```

#### 带行点击选中

```jsx
class Example extends Component {
  state = {
    rowID: ''
  };

  // 行点击事件
  onClickRowPublic = (record) => {
    return {
      onClick: () => {
        const id = record?.id || record?.key || '';
        this.setState({ rowID: this.state.rowID === id ? '' : id });
      }
    };
  };

  // 行样式
  setRowClassNamePublic = (record) => {
    return (record?.id || record?.key || '') === this.state.rowID ? 'clickRowStyle' : '';
  };

  render() {
    return (
      <PubilcTablePagination
        param={{ /* ... */ }}
        compilePage={this.handlePageChange}
        onClickRowPublic={this.onClickRowPublic}
        setRowClassNamePublic={this.setRowClassNamePublic}
      />
    );
  }
}
```

---

## PublicModalFormHooks

### 组件用途

封装了弹窗和表单处理的公共组件，用于新增/编辑操作。

### 组件路径

```
src/pages/common/PublicModalFormHooks.jsx
```

### Props属性

| 属性名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| onRef | function | 否 | 组件ref |
| formData | array | 是 | 表单配置数据 |
| rowData | object | 否 | 当前编辑的记录数据 |
| recordFormInput | function | 否 | 记录表单输入值变化的回调 |
| handleSave | function | 是 | 保存确认回调 |

### 使用示例

```jsx
import PublicModalFormHooks from '../common/PublicModalFormHooks';

class Example extends Component {
  state = {
    modalRecord: {},
    modalFormData: [
      {
        dataIndex: 'userCode',
        title: '用户代码',
        typeCode: 'Input',
        required: 'Y',
        col: 12
      },
      {
        dataIndex: 'userName',
        title: '用户名称',
        typeCode: 'Input',
        required: 'Y',
        col: 12
      }
    ]
  };

  // 新增
  handleAdd = () => {
    const { modalRecord } = this.state;
    // 清空之前的编辑记录
    if (modalRecord && modalRecord.id) {
      this.setState({ modalRecord: {} });
    }
    this.modalFormRef && this.modalFormRef.modifyVisible(true);
  };

  // 编辑
  handleEdit = (record) => {
    this.setState({ modalRecord: record }, () => {
      this.modalFormRef && this.modalFormRef.modifyVisible(true);
    });
  };

  // 保存
  handleSave = async (values) => {
    try {
      let res = await React.$asyncPost(this, '010XXXXX', {
        params: [{ ...values }]
      });
      message.success(res?.errorMessage || '操作成功');
      this.fetchList();
      // 关闭弹窗并刷新表单
      this.modalFormRef && this.modalFormRef.modifyVisible(false, 'Y');
    } catch (error) {
      console.log(error);
    }
  };

  render() {
    const { modalFormData, modalRecord } = this.state;

    return (
      <div>
        {/* 列表部分 */}
        
        {/* 弹窗 */}
        <PublicModalFormHooks
          onRef={ref => this.modalFormRef = ref}
          formData={modalFormData}
          rowData={modalRecord}
          handleSave={this.handleSave}
        />
      </div>
    );
  }
}
```

### 实例方法

通过`modalFormRef`可以调用：

```javascript
// 打开弹窗
this.modalFormRef.modifyVisible(true);

// 关闭弹窗
this.modalFormRef.modifyVisible(false);

// 关闭弹窗并刷新表单（重置）
this.modalFormRef.modifyVisible(false, 'Y');
```

---

## SingleTableOperation

### 组件用途

标准CRUD包装组件，自动处理查询、新增、编辑、删除、分页等功能。

### 组件路径

```
src/pages/dynamicComponent/SingleTableOperation.jsx
```

### Props属性

| 属性名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| skip01040073 | boolean | 是 | 跳过01040073接口，使用静态配置 |
| categoryData | object | 是 | 接口编码和功能开关配置 |
| hardcodedColumns | array | 是 | 静态表头配置 |
| hardcodedQueryFormData | array | 否 | 静态查询表单配置 |
| hardcodedModalFormData | array | 否 | 静态弹窗表单配置 |
| hardcodedSelectData | object | 否 | 静态下拉数据 |
| componentName | string | 是 | 组件名称（用于表格高度计算） |

### 使用示例

```jsx
import SingleTableOperation from '../dynamicComponent/SingleTableOperation';

class XxxManagement extends Component {
    columns = [/* ... */];
    queryFormData = [/* ... */];
    modalFormData = [/* ... */];
    
    categoryData = {
        queryCode: '0104XXXX',
        addCode: '0104XXXX',
        deleteCode: '0104XXXX',
        idIndex: 'xxxID',
        hideQueryBtnFlag: 'Y',        // 已手动配置查询按钮
        cancelAddOperationFlag: 'Y',  // 已手动配置操作列
    };

    render() {
        return (
            <SingleTableOperation
                skip01040073={true}
                categoryData={this.categoryData}
                hardcodedColumns={this.columns}
                hardcodedQueryFormData={this.queryFormData}
                hardcodedModalFormData={this.modalFormData}
                hardcodedSelectData={this.state.selectData}
                componentName="XxxManagement"
            />
        );
    }
}
```

### 自动处理机制（必读）

```
⚠️ 使用 SingleTableOperation 前，必须了解以下自动处理逻辑：

1. 查询按钮自动添加机制：
   - SingleTableOperation 会根据 categoryData.hideQueryBtnFlag 自动添加查询按钮
   - 如果 hideQueryBtnFlag !== 'Y'，组件会自动在查询表单后添加查询按钮
   - ❌ 错误：同时在 queryFormData 中配置查询按钮 + 不设置 hideQueryBtnFlag: 'Y'
   - ✅ 正确：要么在 queryFormData 中配置查询按钮并设置 hideQueryBtnFlag: 'Y'，要么让组件自动添加

2. 操作列自动添加机制：
   - SingleTableOperation 会根据 categoryData.cancelAddOperationFlag 自动添加操作列
   - 如果 cancelAddOperationFlag !== 'Y'，组件会自动在表格末尾添加操作列
   - ❌ 错误：同时在 hardcodedColumns 中定义操作列 + 不设置 cancelAddOperationFlag: 'Y'
   - ✅ 正确：要么手动定义操作列并设置 cancelAddOperationFlag: 'Y'，要么让组件自动添加
```

### categoryData 配置

```javascript
categoryData = {
    // 接口配置（必填）
    queryCode: '0104XXXX',      // 查询接口编号
    addCode: '0104XXXX',        // 新增接口编号
    editCode: '0104XXXX',       // 编辑接口编号（可选，默认使用addCode）
    deleteCode: '0104XXXX',     // 删除接口编号
    idIndex: 'xxxID',           // 主键字段名
    
    // 功能开关（可选）
    isRowClick: 'Y',            // 是否启用行点击选中
    hideQueryBtnFlag: 'Y',      // 隐藏自动查询按钮（已手动配置时设置）
    cancelAddOperationFlag: 'Y', // 取消自动操作列（已手动配置时设置）
    exportBtnFlag: 'Y',         // 启用导出按钮
    importBtnFlag: 'Y',         // 启用导入按钮
    batchDeleteFlag: 'Y',       // 启用批量删除
    defaultPageSize: 20,        // 默认分页大小
};
```

---

### 高度计算规范

Drawer 内容区域高度计算公式：

```javascript
// Drawer 内容区高度 = calc(~"100vh - 56px");
// 56px: Drawer头部高度
```

### 完整示例

```jsx
<Drawer
    className="my-drawer"
    title="详情"
    visible={visible}
    width={720}
    destroyOnClose
    onClose={this.handleClose}
>
    {/* 内容区需要设置高度 */}
    <div style={{ height: 'calc(100vh - 105px)', overflow: 'auto' }}>
        <DynamicRenderingForm
            className="dynamic-component-form"
            formData={this.detailFormData}
            rowData={this.state.currentRecord}
        />
    </div>
</Drawer>
```

### 关键配置速查

| 配置项 | 值 | 说明 |
|--------|-----|------|
| 内容区高度 | `calc(100vh - 105px)` | 减去系统菜单和 Drawer 头部 |
| Drawer 头部高度 | 56px | Ant Design 默认值 |

---

## Modal 组件使用规范

### 表单渲染规范

Drawer 和 Modal 中的表单渲染必须使用 `DynamicRenderingForm` 组件：

```jsx
// ❌ 错误：直接使用 Ant Design 的 Form
<Modal title="新增" visible={visible}>
    <Form>
        <Form.Item label="名称">
            <Input />
        </Form.Item>
    </Form>
</Modal>

// ✅ 正确：使用 DynamicRenderingForm
<Modal title="新增" visible={visible}>
    <DynamicRenderingForm
        className="dynamic-component-form"
        formData={this.modalFormData}
        selectData={this.state.selectData}
        rowData={this.state.modalRecord}
    />
</Modal>
```

### 表单分组

```jsx
// 使用 CardTitle 进行分组
modalFormData = [
    { typeCode: 'CardTitle', title: '基本信息' },
    { dataIndex: 'name', title: '名称', typeCode: 'Input', required: 'Y', col: 12 },
    
    { typeCode: 'CardTitle', title: '其他信息' },
    { dataIndex: 'remark', title: '备注', typeCode: 'TextArea', col: 24 },
];
```

---

## 其他公共组件

### IframeModal

用于在弹窗中展示外部页面。

```jsx
import IframeModal from '../common/IframeModal';

<IframeModal
  visible={isVisible}
  title="外部页面"
  url="https://example.com/page"
  onCancel={this.handleCancel}
  width={1000}
  height={600}
/>
```

### PublicDataOrderAdjustment

数据顺序调整组件，支持拖拽排序。

```jsx
import PublicDataOrderAdjustment from '../common/PublicDataOrderAdjustment';

<PublicDataOrderAdjustment
  visible={isVisible}
  dataSource={dataList}
  onSave={this.handleSaveOrder}
  onCancel={this.handleCancel}
/>
```

### PublicModalQueryTable

弹窗内查询表格组件。

```jsx
import PublicModalQueryTable from '../common/PublicModalQueryTable';

<PublicModalQueryTable
  visible={isVisible}
  columns={columns}
  queryFormData={queryFormData}
  onSelect={this.handleSelect}
  onCancel={this.handleCancel}
/>
```

---

## 常见问题

### Q1: 表单值获取不到？

确保正确绑定了ref：
```jsx
<DynamicRenderingForm
  onRef={ref => this.formRef = ref}
/>
```

### Q2: 弹窗无法打开/关闭？

通过ref调用实例方法：
```javascript
this.modalFormRef.modifyVisible(true);   // 打开
this.modalFormRef.modifyVisible(false);  // 关闭
```

### Q3: 下拉框没有选项？

确保selectData格式正确：
```javascript
selectData = {
  statusList: [
    { id: '0', descripts: '停用' },
    { id: '1', descripts: '启用' }
  ]
};
```

### Q5: SingleTableOperation 出现重复查询按钮或操作列？

检查 categoryData 配置：
- 手动配置查询按钮时设置 `hideQueryBtnFlag: 'Y'`
- 手动配置操作列时设置 `cancelAddOperationFlag: 'Y'`

---

## 参考文档

- [字段类型映射表](field-type-mapping.md) - typeCode 完整列表
- [最佳实践规范](best-practices.md) - 开发规范合集
- [代码检查清单](code-checklist.md) - 统一检查标准
