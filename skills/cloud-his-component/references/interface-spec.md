# 接口规范说明

## 01049999 - 数据入库接口（写入）

### 接口说明

用于将组件的表头数据、表单数据一次性写入数据库。这是执行数据入库的核心接口。

### 请求参数

```javascript
{
  params: [{
    componentArr: [{
      // 组件基本信息
      code: 'ComponentName',      // 组件代码（必填，对应componentName）
      descripts: '组件描述',       // 组件描述（必填）
      enDesc: 'Component Desc',   // 英文描述（可选）
      path: '/src/pages/xxx/',    // 组件路径（可选）

      // 表头数据
      columns: [{
        descripts: '列标题',       // 描述（对应title）
        code: 'dataIndex',        // 代码（对应dataIndex）
        width: 150,               // 列宽（数值，去除px后缀）
        align: 'C',               // 对齐方式：L(左)/C(中)/R(右)
        seqNo: 1,                 // 序号（对应key）
        type: 'C',                // 类型（固定为'C'表示列表）
        display: 'Y',             // 是否显示（默认'Y'）
        print: 'Y',               // 是否打印（默认'Y'）
        export: 'Y'               // 是否导出（默认'Y'）
        // 其他扩展字段可添加在基础字段之后
      }],

      // 表单数据（查询表单+弹窗表单）
      formData: [{
        descripts: '字段标题',     // 描述（对应title）
        code: 'dataIndex',        // 代码（对应dataIndex）
        fieldTypeID: 5,           // 字段类型ID（通过映射表转换）
        col: 12,                  // 栅格占位
        labelCol: 8,              // label占比
        wrapperCol: 16,           // wrapper占比
        required: 'Y',            // 是否必填（'Y'/'N'）
        disabled: 'N',            // 是否禁用（'Y'/'N'）
        placeholder: '请输入',    // 提示信息
        display: 'Y'              // 是否显示（默认'Y'）
        // 其他扩展字段可添加在基础字段之后
      }]
    }]
  }]
}
```

### 字段白名单限制

**columns 只接收以下字段**，其他字段会被过滤：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| code | string | 数据索引 |
| descripts | string | 描述 |
| enDesc | string | 英文描述 |
| type | string | 类型（固定'C'） |
| width | number | 列宽 |
| seqNo | number | 序号 |
| display | string | 是否显示 |
| print | string | 是否打印 |
| export | string | 是否导出 |
| visible | string | 是否可见 |
| linkMethod | string | 关联方法 |
| linkService | string | 关联服务 |
| align | string | 对齐方式（L/C/R） |
| fixed | string | 固定列 |

**formData 只接收以下字段**，其他字段会被过滤：

| 字段名 | 类型 | 说明 | 必填 | 默认值 |
|--------|------|------|------|--------|
| code | string | 数据索引 | 是 | - |
| descripts | string | 描述 | 是 | - |
| seqNo | number | 序号 | 否 | - |
| enDesc | string | 英文描述 | 否 | - |
| fieldTypeID | number | 字段类型ID | 是 | - |
| callback | string | 回调方法 | 否 | - |
| placeholder | string | 提示信息 | 否 | - |
| doubt | string | 输入域描述 | 否 | - |
| className | string | CSS类名 | 否 | - |
| methodName | string | 方法名 | 否 | - |
| linkValueID | string | 关联值ID | 否 | - |
| linkCode | string | 关联代码 | 否 | - |
| col | number | 栅格占比 | 是 | - |
| jumpID | string | 跳转ID | 否 | - |
| labelCol | number | label占比 | 是 | - |
| wrapperCol | number | 输入域占比 | 是 | - |
| default | string | 默认值 | 否 | - |
| required | string | 是否必填 | 是 | N |
| disabled | string | 是否禁用 | 是 | N |
| display | string | 是否显示 | 是 | Y |
| textSelect | string | 文本选择 | 否 | - |

**⚠️ formData 必填字段规则：**
- `display`: **必填**，不传会报错，默认值 `Y`
- `required`: **必填**，不传会报错，默认值 `N`
- `disabled`: **必填**，不传会报错，默认值 `N`
- 生成数据时必须包含这三个字段

### 对齐方式转换

| 前端值 | 接口值 |
|--------|--------|
| left | L |
| center | C |
| right | R |

### 调用示例

```javascript
const data = {
  params: [{
    componentArr: [{
      code: 'Level1EventReminder',
      descripts: 'Ⅰ级事件提醒',
      columns: [
        { descripts: '状态', code: 'isRead', width: 60, align: 'center', seqNo: 1, type: 'C', display: 'Y', print: 'Y', export: 'Y' },
        { descripts: '事件编号', code: 'eventId', width: 130, align: 'center', seqNo: 2, type: 'C', display: 'Y', print: 'Y', export: 'Y' },
        { descripts: '事件类型', code: 'eventType', width: 120, align: 'center', seqNo: 3, type: 'C', display: 'Y', print: 'Y', export: 'Y' },
        { descripts: '上报日期', code: 'reportTime', width: 150, align: 'center', seqNo: 4, type: 'C', display: 'Y', print: 'Y', export: 'Y' },
        { descripts: '当前状态', code: 'status', width: 120, align: 'center', seqNo: 5, type: 'C', display: 'Y', print: 'Y', export: 'Y' },
        { descripts: '操作', code: 'operation', width: 180, align: 'left', seqNo: 6, type: 'C', display: 'Y', print: 'N', export: 'N' }
      ],
      formData: [
        { descripts: '上报日期', code: 'dateRange', fieldTypeID: 16, col: 5, labelCol: 5, wrapperCol: 18, display: 'Y' },
        { descripts: '查询', code: 'queryBtn', fieldTypeID: 17, col: 2, offset: 1, display: 'Y' }
      ]
    }]
  }]
};

const res = await React.$asyncPost(this, '01049999', data);
```

### 返回值

```javascript
{
  errorCode: 0,           // 0表示成功
  errorMessage: '操作成功'
}
```

---

## 01040073 - 获取配置接口（读取）

### 接口说明

用于获取组件的表头数据、表单数据。改造后的组件通过此接口动态获取配置。

### 请求参数

```javascript
{
  params: [{
    type: 'C',
    compontName: 'ComponentName',    // 组件名称
    reactCode: ['ComponentName']     // React代码标识
  }]
}
```

### 调用示例

```javascript
const data = {
  params: [{
    type: 'C',
    compontName: 'Level1EventReminder',
    reactCode: ['Level1EventReminder']
  }]
};

const res = await React.$asyncPost(this, '01040073', data);
```

### 返回值

```javascript
{
  errorCode: 0,
  result: {
    C: [                          // 表头数据
      { descripts: '状态', code: 'isRead', width: 60, align: 'center', ... },
      { descripts: '事件编号', code: 'eventId', width: 130, ... },
      ...
    ],
    formData: [                   // 表单数据
      { descripts: '上报日期', code: 'dateRange', fieldTypeID: 16, ... },
      { descripts: '查询', code: 'queryBtn', fieldTypeID: 17, ... }
    ],
    extendAttr: {                 // 扩展属性（可选）
      pageSize: 10,
      size: 'small'
    }
  },
  totalWidth: 760                 // 表格总宽度
}
```

### 标准使用模式

```javascript
// 在SingleTableOperation等动态组件中
getTableColumns = async () => {
  const { categoryData } = this.state;
  
  let data = {
    params: [{
      type: 'C',
      compontName: categoryData.componentName,
      reactCode: [categoryData.componentName],
    }]
  };
  
  let res = await React.$asyncPost(this, '01040073', data);
  let nColumns = res?.result?.C || [];
  let nFormData = res?.result?.formData || [];
  
  // 处理操作列render绑定
  for (let i = 0; i < nColumns.length; i++) {
    if (nColumns[i]?.dataIndex === 'operation') {
      nColumns[i].render = (text, record) => {
        return (
          <span>
            <span className="span" onClick={(e) => this.handleModify(record, e)}>编辑</span>
            <Divider type="vertical" />
            <Popconfirm title="确定删除?" onConfirm={(e) => this.handleDelete(record, e)}>
              <span className="span">删除</span>
            </Popconfirm>
          </span>
        );
      };
    }
  }
  
  // 处理表单按钮事件绑定
  for (let i = 0; i < nFormData.length; i++) {
    if (nFormData[i]?.dataIndex === 'queryBtn') {
      nFormData[i].type = 'primary';
      nFormData[i].onClick = this.handleQuery;
    }
    if (nFormData[i]?.dataIndex === 'addBtn') {
      nFormData[i].icon = 'plus';
      nFormData[i].onClick = this.handleAdd;
    }
  }
  
  this.setState({
    columns: nColumns,
    queryFormData: nFormData,
    totalWidth: res.totalWidth
  });
};
```

---

## 字段类型映射

typeCode 到 fieldTypeID 的映射关系：

| typeCode | fieldTypeID | 说明 |
|----------|-------------|------|
| Input | 5 | 输入框 |
| InputNumber | 12 | 数字框 |
| Select | 3 | 下拉框 |
| DatePicker | 13 | 日期选择 |
| RangePicker | 16 | 日期范围 |
| Button | 17 | 按钮 |
| TextArea | 20 | 文本域 |
| ... | ... | 完整映射见 field-mapping.md |

---

## 错误处理

| errorCode | 说明 | 处理方式 |
|-----------|------|----------|
| 0 | 成功 | 继续执行 |
| 非0 | 失败 | 显示errorMessage，记录日志 |

---

## 完整工作流程

```
┌────────────────┐
│ 1. 解析组件     │  提取硬编码 columns/formData
└───────┬────────┘
        ▼
┌────────────────┐
│ 2. 数据转换     │  转换为接口格式
└───────┬────────┘
        ▼
┌────────────────┐
│ 3. 确认数据     │  列出转换数据等用户确认
└───────┬────────┘
        ▼
┌────────────────┐
│ 4. 调用01049999 │  写入数据库
└───────┬────────┘
        ▼
┌────────────────┐
│ 5. 代码改造     │  移除硬编码，改为动态获取
└───────┬────────┘
        ▼
┌────────────────┐
│ 6. 调用01040073 │  运行时动态获取配置
└────────────────┘
```
