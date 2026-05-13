# 字段类型映射表

> **单一信息源**：本文档是 typeCode 的唯一权威来源，其他文档仅引用本文档

---

## 一、表单控件 typeCode 完整映射

### 1. 基础输入类型

| 原型图元素 | typeCode | 示例配置 | 说明 |
|------------|----------|----------|------|
| 文本输入框 | `Input` | `{ typeCode: 'Input' }` | 单行文本输入 |
| 多行文本框 | `TextArea` | `{ typeCode: 'TextArea', rows: 4 }` | 多行文本，可设置rows |
| 数字输入框 | `InputNumber` | `{ typeCode: 'InputNumber', min: 0, max: 100 }` | 数值输入 |

### 2. 选择类型

| 原型图元素 | typeCode | 示例配置 | 说明 |
|------------|----------|----------|------|
| 下拉单选 | `Select` | `{ typeCode: 'Select', selectField: 'statusList' }` | 单选下拉框 |
| 下拉多选 | `MultipleSelect` | `{ typeCode: 'MultipleSelect', selectField: 'tags' }` | 多选下拉框 |
| 单选按钮组 | `RadioGroup` | `{ typeCode: 'RadioGroup', selectField: 'genderList' }` | 单选按钮组 |
| 复选框组 | `CheckGroup` | `{ typeCode: 'CheckGroup', selectField: 'hobbies' }` | 多选复选框组 |
| 单个复选框 | `Checkbox` | `{ typeCode: 'Checkbox', default: 'N' }` | 单个勾选框 |
| 开关 | `Switch` | `{ typeCode: 'Switch' }` | 布尔开关 |

### 3. 日期时间类型

| 原型图元素 | typeCode | 示例配置 | 说明 |
|------------|----------|----------|------|
| 日期选择 | `DatePicker` | `{ typeCode: 'DatePicker' }` | 选择日期 |
| 日期范围 | `RangePicker` | `{ typeCode: 'RangePicker' }` | 选择日期范围 |
| 日期时间 | `DateTimePicker` | `{ typeCode: 'DateTimePicker' }` | 选择日期时间 |
| 时间选择 | `TimePicker` | `{ typeCode: 'TimePicker' }` | 选择时间 |
| 月份选择 | `MonthPicker` | `{ typeCode: 'MonthPicker' }` | 选择月份 |

### 4. 高级选择类型

| 原型图元素 | typeCode | 示例配置 | 说明 |
|------------|----------|----------|------|
| 级联选择 | `Cascader` | `{ typeCode: 'Cascader', selectField: 'regionTree' }` | 级联选择器 |
| 树形选择 | `TreeSelect` | `{ typeCode: 'TreeSelect', selectField: 'deptTree' }` | 树形下拉选择 |
| 树形多选 | `TreeSelectMultiple` | `{ typeCode: 'TreeSelectMultiple' }` | 树形多选 |

### 5. 特殊类型

| 原型图元素 | typeCode | 示例配置 | 说明 |
|------------|----------|----------|------|
| 自动完成 | `AutoComplete` | `{ typeCode: 'AutoComplete', selectField: 'suggestions' }` | 自动补全输入 |
| 滑块 | `Slider` | `{ typeCode: 'Slider', min: 0, max: 100 }` | 滑块选择 |
| 评分 | `Rate` | `{ typeCode: 'Rate', max: 5 }` | 星级评分 |
| 图片上传 | `UploadImg` | `{ typeCode: 'UploadImg' }` | 图片上传 |
| 文件上传 | `UploadFile` | `{ typeCode: 'UploadFile' }` | 文件上传 |
| 颜色选择 | `ColorPicker` | `{ typeCode: 'ColorPicker' }` | 颜色选择器 |
| **标题（分组）** | `CardTitle` | `{ typeCode: 'CardTitle', title: '基本信息' }` | **表单分组标题，在同一表单中使用，无需拆分多个 DynamicRenderingForm** |
| **分割线** | `Divider` | `{ typeCode: 'Divider', title: '专项字段' }` | 分割线，用于视觉分隔表单区域 |
| 按钮 | `Button` | `{ typeCode: 'Button', type: 'primary', onClick: 'handleQuery' }` | 按钮 |

### 6. 业务专用类型

| 原型图元素 | typeCode | 示例配置 | 说明 |
|------------|----------|----------|------|
| 搜索输入框 | `InputSearch` | `{ typeCode: 'InputSearch' }` | 搜索输入框 |
| 人员搜索 | `PatSearch` | `{ typeCode: 'PatSearch' }` | 患者/人员搜索 |
| 回车展示列表 | `InputTable` | `{ typeCode: 'InputTable' }` | 双击选择 |

---

## 二、表单字段配置属性

### 1. 通用属性

| 属性名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `dataIndex` | string | 是 | 字段名（对应接口参数） |
| `title` | string | 是 | 显示标签 |
| `typeCode` | string | 是 | 控件类型（见上表） |
| `col` | number | 否 | 栅格占比（默认8，共24份） |
| `required` | string | 否 | 是否必填：`'Y'`/`'N'` |
| `disabled` | string | 否 | 是否禁用：`'Y'`/`'N'` |
| `hidden` | string | 否 | 是否隐藏：`'Y'`/`'N'` |
| `doubt` | string | 否 | 提示文字 |

### 2. 布局属性

| 属性名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `labelCol` | number | 8 | 标签占比（共24份） |
| `wrapperCol` | number | 16 | 输入域占比（共24份） |

**布局规则：**
- **横向布局**：不设置labelCol/wrapperCol，使用默认
- **纵向布局**：设置 `labelCol: 24, wrapperCol: 24`

### 3. 下拉框专用属性

| 属性名 | 类型 | 说明 |
|--------|------|------|
| `selectField` | string | **关联selectData中的字段名** |

**⚠️ 重要**：
- 下拉框必须使用 `selectField` 属性
- 禁止使用 `linkService`、`selectKey` 等无效属性

---

## 三、下拉数据格式规范

### 1. 正确格式

```javascript
selectData = {
    statusList: [
        { id: '1', descripts: '启用', descriptsSPCode: '启用' },
        { id: '0', descripts: '停用', descriptsSPCode: '停用' }
    ]
};
```

### 2. 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 数据值（传给后台） |
| `descripts` | string | 是 | 显示文本 |
| `descriptsSPCode` | string | 否 | 描述+首拼（用于检索） |

### 3. 错误格式示例

```javascript
// ❌ 错误：使用value/label格式
[{ value: '1', label: '启用' }]

// ❌ 错误：使用id/name格式
[{ id: '1', name: '启用' }]

// ❌ 错误：使用id/title格式
[{ id: '1', title: '启用' }]
```

---

## 四、表单布局规范

### 1. 查询表单布局（横向）

```javascript
queryFormData = [
    { dataIndex: 'code', title: '代码', typeCode: 'Input', col: 8 },
    { dataIndex: 'name', title: '名称', typeCode: 'Input', col: 8 },
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
```

**查询按钮间距规范：**
按钮前一个字段的 `labelCol + wrapperCol` 设为 **23**，保留1份空隙。

```javascript
[
    { dataIndex: 'a', title: '字段A', typeCode: 'Input', col: 8 },
    { 
        dataIndex: 'b', 
        title: '字段B', 
        typeCode: 'Input', 
        col: 8,
        labelCol: 6,
        wrapperCol: 17,  // 6+17=23，预留1份空隙
    },
    { dataIndex: 'queryBtn', title: '查询', typeCode: 'Button', col: 8, labelCol: 0, wrapperCol: 24 },
]
```

### 2. 弹窗表单布局（常用两列）

```javascript
modalFormData = [
    { dataIndex: 'code', title: '代码', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'name', title: '名称', typeCode: 'Input', required: 'Y', col: 12 },
    { dataIndex: 'status', title: '状态', typeCode: 'Select', col: 12, selectField: 'statusList' },
    { dataIndex: 'type', title: '类型', typeCode: 'Select', col: 12, selectField: 'typeList' },
];
```

### 3. 详情表单布局（纵向）

```javascript
detailFormData = [
    { 
        dataIndex: 'name', 
        title: '名称', 
        typeCode: 'Input', 
        col: 24,
        labelCol: 24,      // 标签占满一行
        wrapperCol: 24,    // 输入域占满一行（换行展示）
        disabled: 'Y'
    }
];
```

---

## 五、表单分组规范

### 使用 CardTitle 分组

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

### 错误做法

```javascript
// ❌ 错误：拆分成多个 DynamicRenderingForm
render() {
    return (
        <div>
            <DynamicRenderingForm formData={this.basicInfoFormData} />
            <DynamicRenderingForm formData={this.contactInfoFormData} />
        </div>
    );
}
```

---

## 六、列表列类型映射

### 1. 数据渲染处理

| 数据类型 | render函数示例 | 说明 |
|----------|----------------|------|
| 普通文本 | - | 直接显示，无需render |
| 状态转换 | `(text) => text === '1' ? '启用' : '停用'` | 状态码转文字 |
| 日期 | `(text) => text ? moment(text).format('YYYY-MM-DD') : ''` | 日期格式化 |
| 日期时间 | `(text) => text ? moment(text).format('YYYY-MM-DD HH:mm') : ''` | 日期时间格式化 |
| 金额 | `(text) => text ? '¥' + parseFloat(text).toFixed(2) : ''` | 金额格式化 |
| 百分比 | `(text) => text ? text + '%' : ''` | 百分比显示 |

### 2. 列常用属性

```javascript
{
    title: '列标题',           // 列显示标题
    dataIndex: 'fieldName',    // 数据字段名
    key: 'fieldName',          // 唯一标识
    width: 150,                // 列宽度
    ellipsis: true,            // 超出省略
    align: 'center',           // 对齐方式：left/center/right
    fixed: 'left',             // 固定列：left/right
    sorter: true,              // 启用排序
    render: (text, record) => text  // 自定义渲染
}
```

---

## 七、常见问题

### Q1: 单个 Checkbox 和 CheckGroup 有什么区别？

**单个 Checkbox（`typeCode: 'Checkbox'`）：**
- 不需要 `selectField` 属性
- 不需要 `detailItem` 选项列表
- 通过 `title` 属性设置显示文本
- 通过 `default` 属性设置默认值（'Y' 或 'N'）
- 选中时值为 'Y'，未选中时值为 'N'

**CheckGroup（`typeCode: 'CheckGroup'`）：**
- 需要 `selectField` 或 `detailItem` 提供选项列表
- 值为数组 `['id1', 'id2']`

### Q2: 如何实现表单分组？

使用 `CardTitle` 类型：

```javascript
modalFormData = [
    { typeCode: 'CardTitle', title: '基本信息' },
    { dataIndex: 'name', title: '名称', typeCode: 'Input', col: 12 },
    
    { typeCode: 'CardTitle', title: '其他信息' },
    { dataIndex: 'remark', title: '备注', typeCode: 'TextArea', col: 24 },
];
```

**优势：**
1. 代码简洁：一个组件实例完成所有表单渲染
2. 数据统一：所有字段在同一个表单实例中
3. 样式一致：自动应用统一样式
4. 维护方便：只需维护一个 formData 配置数组

### Q3: 下拉框无数据怎么办？

**排查步骤：**

1. 检查 `selectField` 配置是否正确
2. 检查下拉数据是否正确获取
3. 检查下拉数据格式是否符合规范

```javascript
// ✅ 正确示例
{
    dataIndex: 'status',
    title: '状态',
    typeCode: 'Select',
    selectField: 'statusList',  // 必须与 selectData 中的 key 对应
}

// selectData 格式
selectData = {
    statusList: [
        { id: '1', descripts: '启用', descriptsSPCode: '启用' },
        { id: '0', descripts: '停用', descriptsSPCode: '停用' }
    ]
};
```

---

## 八、参考文档

- [公共组件使用指南](common-components-guide.md) - DynamicRenderingForm 详细使用方法
- [最佳实践规范](best-practices.md) - 开发规范合集
- [代码检查清单](code-checklist.md) - 统一检查标准
