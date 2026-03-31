# 配置示例集合

> 纯配置数据示例，与 assets 模板配合使用

---

## 使用说明

本文档只展示**配置数据**，完整组件代码请参考：
- 标准CRUD → `assets/WrapperComponentTemplate.jsx`
- 自定义组件 → `assets/CustomComponentTemplate.jsx`
- 简单列表 → `assets/SimpleListTemplate.jsx`

---

## 一、包装组件配置示例

### 示例1: 标准CRUD界面

**配套模板**: `WrapperComponentTemplate.jsx`

```javascript
// columns - 列表表头配置
columns = [
    { title: '字段代码', dataIndex: 'fieldCode', align: 'center', width: 150, ellipsis: true },
    { title: '字段名称', dataIndex: 'fieldName', align: 'center', width: 200, ellipsis: true },
    { title: '字段类型', dataIndex: 'fieldType', align: 'center', width: 120, ellipsis: true },
    { title: '创建时间', dataIndex: 'createTime', align: 'center', width: 180, ellipsis: true }
];

// queryFormData - 查询表单配置
queryFormData = [
    { dataIndex: 'fieldCode', title: '字段代码', typeCode: 'Input', col: 8 },
    { dataIndex: 'fieldName', title: '字段名称', typeCode: 'Input', col: 8 },
    { 
        dataIndex: 'queryBtn', 
        title: '查询', 
        typeCode: 'Button', 
        type: 'primary', 
        col: 8, 
        labelCol: 0, 
        wrapperCol: 24 
    }
];

// modalFormData - 弹窗表单配置
modalFormData = [
    { dataIndex: 'fieldCode', title: '字段代码', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'fieldName', title: '字段名称', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'fieldType', title: '字段类型', typeCode: 'Select', selectField: 'fieldTypeList', required: 'Y', col: 12 }
];

// categoryData - 接口配置
categoryData = {
    queryCode: '01040001',
    addCode: '01040002',
    deleteCode: '01040003',
    idIndex: 'fieldID',
    hideQueryBtnFlag: 'Y',        // 已手动配置查询按钮
    cancelAddOperationFlag: 'Y',  // 已在 columns 中配置操作列
};

// selectData - 下拉数据
selectData = {
    fieldTypeList: [
        { id: '1', descripts: '文本', descriptsSPCode: '文本' },
        { id: '2', descripts: '数字', descriptsSPCode: '数字' },
        { id: '3', descripts: '日期', descriptsSPCode: '日期' }
    ]
};
```

---

### 示例2: 带状态转换的CRUD

**配套模板**: `WrapperComponentTemplate.jsx`

```javascript
// columns - 带 render 函数
columns = [
    { title: '用户代码', dataIndex: 'userCode', align: 'center', width: 120, ellipsis: true },
    { title: '用户名称', dataIndex: 'userName', align: 'center', width: 150, ellipsis: true },
    { title: '手机号', dataIndex: 'phone', align: 'center', width: 130, ellipsis: true },
    { 
        title: '状态', 
        dataIndex: 'status', 
        align: 'center', 
        width: 80, 
        render: (text) => text === '1' ? '启用' : '停用' 
    },
    { 
        title: '创建时间', 
        dataIndex: 'createTime', 
        align: 'center', 
        width: 160,
        render: (text) => text ? moment(text).format('YYYY-MM-DD HH:mm') : ''
    }
];

// queryFormData - 带下拉框
queryFormData = [
    { dataIndex: 'userCode', title: '用户代码', typeCode: 'Input', col: 6 },
    { dataIndex: 'userName', title: '用户名称', typeCode: 'Input', col: 6 },
    { 
        dataIndex: 'status', 
        title: '状态', 
        typeCode: 'Select', 
        selectField: 'statusList', 
        col: 6, 
        labelCol: 6, 
        wrapperCol: 17 
    },
    { 
        dataIndex: 'queryBtn', 
        title: '查询', 
        typeCode: 'Button', 
        type: 'primary', 
        col: 6, 
        labelCol: 0, 
        wrapperCol: 24 
    }
];

// modalFormData - 带分组
modalFormData = [
    // 基本信息分组
    { typeCode: 'CardTitle', title: '基本信息' },
    { dataIndex: 'userCode', title: '用户代码', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'userName', title: '用户名称', typeCode: 'Input', required: 'Y', col: 12 },
    
    // 联系信息分组
    { typeCode: 'CardTitle', title: '联系信息' },
    { dataIndex: 'phone', title: '手机号', typeCode: 'Input', col: 12 },
    { dataIndex: 'email', title: '邮箱', typeCode: 'Input', col: 12 },
    { dataIndex: 'status', title: '状态', typeCode: 'Select', required: 'Y', col: 12, selectField: 'statusList' }
];

// categoryData
categoryData = {
    queryCode: '01040101',
    addCode: '01040102',
    deleteCode: '01040103',
    idIndex: 'userID',
    hideQueryBtnFlag: 'Y',
    cancelAddOperationFlag: 'Y'
};

// selectData
selectData = {
    statusList: [
        { id: '1', descripts: '启用', descriptsSPCode: '启用' },
        { id: '0', descripts: '停用', descriptsSPCode: '停用' }
    ]
};
```

---

## 二、自定义组件配置示例

### 示例3: 用户管理（标准增删改查）

**配套模板**: `CustomComponentTemplate.jsx`

```javascript
// columns - 带操作列
columns = [
    { title: '用户代码', dataIndex: 'userCode', key: 'userCode', width: 120, align: 'center', ellipsis: true },
    { title: '用户名称', dataIndex: 'userName', key: 'userName', width: 150, align: 'center', ellipsis: true },
    { title: '手机号', dataIndex: 'phone', key: 'phone', width: 120, align: 'center', ellipsis: true },
    { 
        title: '状态', 
        dataIndex: 'status', 
        key: 'status', 
        width: 80, 
        align: 'center', 
        render: (text) => text === '1' ? '启用' : '停用' 
    },
    { 
        title: '创建时间', 
        dataIndex: 'createTime', 
        key: 'createTime', 
        width: 160, 
        align: 'center' 
    },
    {
        title: '操作', 
        dataIndex: 'operation', 
        key: 'operation', 
        width: 150, 
        align: 'center', 
        fixed: 'right', // 根据实际场景添加，如果表格列很多时出现x轴滚动条则使用
        render: (text, record) => (
            <>
                <span className="span" onClick={() => this.handleEdit(record)}>
                    <Icon type="edit" /> 编辑
                </span>
                <Divider type="vertical" />
                <Popconfirm title="确定删除？" onConfirm={() => this.handleDelete(record)}>
                    <span className="span common-record-delete-span">
                        <Icon type="delete" /> 删除
                    </span>
                </Popconfirm>
            </>
        )
    }
];

// queryFormData
queryFormData = [
    { dataIndex: 'userCode', title: '用户代码', typeCode: 'Input', col: 8, labelCol: 8, wrapperCol: 16 },
    { dataIndex: 'userName', title: '用户名称', typeCode: 'Input', col: 8, labelCol: 8, wrapperCol: 16 },
    { 
        dataIndex: 'status', 
        title: '状态', 
        typeCode: 'Select', 
        col: 7, 
        selectField: 'statusList', 
        labelCol: 6, 
        wrapperCol: 17 
    },
    { 
        dataIndex: 'queryBtn', 
        title: '查询', 
        typeCode: 'Button', 
        type: 'primary', 
        col: 1, 
        labelCol: 0, 
        wrapperCol: 24 
    }
];

// modalFormData
modalFormData = [
    { dataIndex: 'userCode', title: '用户代码', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'userName', title: '用户名称', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'phone', title: '手机号', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'email', title: '邮箱', typeCode: 'Input', col: 12 },
    { dataIndex: 'status', title: '状态', typeCode: 'Select', required: 'Y', col: 12, selectField: 'statusList' }
];

// state 初始值
this.state = {
    spinLoading: false,
    selectData: {},
    dataList: [],
    loading: false,
    queryHeight: 64,
    page: 1,
    pageSize: 10,
    total: 0,
    modalRecord: {},
    rowID: ''
};
```

---

### 示例4: 订单查询（纯查询列表）

**配套模板**: `SimpleListTemplate.jsx`

```javascript
// columns
columns = [
    { title: '订单号', dataIndex: 'orderNo', key: 'orderNo', width: 150, align: 'center', ellipsis: true },
    { title: '客户名称', dataIndex: 'customerName', key: 'customerName', width: 150, align: 'center', ellipsis: true },
    { 
        title: '订单金额', 
        dataIndex: 'orderAmount', 
        key: 'orderAmount', 
        width: 120, 
        align: 'right', 
        render: (text) => text ? '¥' + parseFloat(text).toFixed(2) : '' 
    },
    { title: '订单状态', dataIndex: 'orderStatus', key: 'orderStatus', width: 100, align: 'center' },
    { 
        title: '下单时间', 
        dataIndex: 'orderTime', 
        key: 'orderTime', 
        width: 160, 
        align: 'center',
        render: (text) => text ? moment(text).format('YYYY-MM-DD HH:mm') : ''
    }
];

// queryFormData - 包含日期范围选择
queryFormData = [
    { dataIndex: 'orderNo', title: '订单号', typeCode: 'Input', col: 6 },
    { dataIndex: 'customerName', title: '客户名称', typeCode: 'Input', col: 6 },
    { dataIndex: 'dateRange', title: '下单日期', typeCode: 'RangePicker', col: 8 },
    { dataIndex: 'orderStatus', title: '订单状态', typeCode: 'Select', col: 6, selectField: 'orderStatusList' }
];

// selectData
selectData = {
    orderStatusList: [
        { id: '0', descripts: '待付款', descriptsSPCode: '待付款' },
        { id: '1', descripts: '已付款', descriptsSPCode: '已付款' },
        { id: '2', descripts: '已发货', descriptsSPCode: '已发货' },
        { id: '3', descripts: '已完成', descriptsSPCode: '已完成' }
    ]
};

// state 初始值
this.state = {
    spinLoading: false,
    selectData: {},
    dataList: [],
    loading: false,
    queryHeight: 64,
    page: 1,
    pageSize: 10,
    total: 0
};
```

---

## 三、特殊场景配置

### 示例5: 左右布局配置

**配套模板**: `LeftRightLayoutTemplate.jsx`

```javascript
// columns - 左侧列表
columns = [
    { title: '参数代码', dataIndex: 'paramCode', align: 'center', width: 120 },
    { title: '参数名称', dataIndex: 'paramName', align: 'center', width: 150 },
    { title: '参数值', dataIndex: 'paramValue', align: 'center', width: 100 }
];

// detailFormData - 右侧详情表单（纵向布局）
detailFormData = [
    { 
        dataIndex: 'paramCode', 
        title: '参数代码', 
        typeCode: 'Input', 
        col: 24, 
        labelCol: 24, 
        wrapperCol: 24, 
        disabled: 'Y' 
    },
    { 
        dataIndex: 'paramName', 
        title: '参数名称', 
        typeCode: 'Input', 
        col: 24, 
        labelCol: 24, 
        wrapperCol: 24, 
        disabled: 'Y' 
    },
    { 
        dataIndex: 'paramValue', 
        title: '参数值', 
        typeCode: 'Input', 
        col: 24, 
        labelCol: 24, 
        wrapperCol: 24, 
        disabled: 'Y' 
    },
    { 
        dataIndex: 'remark', 
        title: '备注', 
        typeCode: 'TextArea', 
        rows: 4, 
        col: 24, 
        labelCol: 24, 
        wrapperCol: 24, 
        disabled: 'Y' 
    }
];

// state 初始值
this.state = {
    dataList: [],
    loading: false,
    queryHeight: 64,
    selectedRow: null,  // 当前选中行
    rowID: ''
};
```

---

## 四、表格参数速查

### PubilcTablePagination param

```javascript
const tableParams = {
    page: 1,                      // 当前页码
    size: 'small',                // 表格尺寸
    pageSize: 10,                 // 每页条数
    total: 0,                     // 总记录数
    loading: false,               // 加载状态
    extendFlag: 'Y',              // 扩展数据标识
    componentName: 'Example',     // 组件名称
    data: [],                     // 表格数据数组
    x: 1500,                      // 表格宽度（所有列width之和）
    y: 400,                       // 表格内容区高度
    height: '400px',              // 表格总高度
    columns: []                   // 表头配置数组
};

// 高度计算公式
y: store.getState().tableHeight.y + 93 - queryHeight,
height: store.getState().tableHeight.y + 143 - queryHeight + 'px',
```

---

## 五、模板与配置对应关系

| 场景 | 配置示例 | 模板文件 |
|------|----------|----------|
| 标准CRUD | 示例1 | `WrapperComponentTemplate.jsx` |
| 带状态转换CRUD | 示例2 | `WrapperComponentTemplate.jsx` |
| 自定义组件CRUD | 示例3 | `CustomComponentTemplate.jsx` |
| 纯查询列表 | 示例4 | `SimpleListTemplate.jsx` |
| 左右布局 | 示例5 | `LeftRightLayoutTemplate.jsx` |

---

## 参考文档

- [字段类型映射表](field-type-mapping.md) - 完整的 typeCode 列表
- [公共组件使用指南](common-components-guide.md) - 组件API文档
- [最佳实践规范](best-practices.md) - 开发原则和规范
