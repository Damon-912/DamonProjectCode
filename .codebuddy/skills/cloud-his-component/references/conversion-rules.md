# 数据转换规则

## Columns转换

### 字段映射

| 前端字段 | 接口字段 | 转换规则 |
|----------|----------|----------|
| title | descripts | 直接映射 |
| dataIndex | code | 直接映射 |
| width | width | 提取数值，去除px后缀 |
| align | align | **转换格式**：`left`→`L`, `center`→`C`, `right`→`R` |
| key | seqNo | 直接映射 |
| - | type | 默认值 'C' |
| - | display | 默认值 'Y' |
| - | print | 默认值 'Y' |
| - | export | 默认值 'Y' |

### 转换示例

**输入（前端格式）：**
```javascript
{
  title: '医院名称',
  dataIndex: 'hospName',
  width: '150px',
  align: 'center',
  key: 1
}
```

**输出（接口格式）：**
```javascript
{
  descripts: '医院名称',
  code: 'hospName',
  width: 150,
  align: 'C',  // center → C
  seqNo: 1,
  type: 'C',
  display: 'Y',
  print: 'Y',
  export: 'Y'
}
```

### 对齐方式转换表

| 前端值 | 接口值 |
|--------|--------|
| left | L |
| center | C |
| right | R |

### 字段白名单

**columns 只接收以下字段**，其他字段需要作为扩展字段处理：

| 字段名 | 说明 |
|--------|------|
| code | 数据索引（对应 dataIndex） |
| descripts | 描述（对应 title） |
| enDesc | 英文描述 |
| type | 类型（固定 'C'） |
| width | 列宽 |
| seqNo | 序号（对应 key） |
| display | 是否显示 |
| print | 是否打印 |
| export | 是否导出 |
| visible | 是否可见 |
| linkMethod | 关联方法 |
| linkService | 关联服务 |
| align | 对齐方式（L/C/R） |
| fixed | 固定列 |

### 过滤规则

以下列不进行转换：
1. 无 `dataIndex` 的列
2. `dataIndex` 为 'edit' 的列
3. 包含复杂 `render` 函数且无有效数据的列

**注意：** `dataIndex` 为 'operation' / 'action' 的列**应当入库**，入库基础信息（title, width, align 等），以便改造后通过 `operationObj` prop 替换。

#### operationObj 的 render 合并机制

SingleTableOperation 内部使用 `{ ...finalColumns[opIndex], ...props.operationObj }` 合并操作列：
- 数据库返回的属性（title, width, align, fixed 等）作为基础
- `props.operationObj` 的属性覆盖同名属性
- **因此 `getOperationObj()` 只需返回 `{ render: fn }`，无需重复定义 width/title 等**

---

## FormData转换

### 字段映射

| 前端字段 | 接口字段 | 转换规则 |
|----------|----------|----------|
| title | descripts | 直接映射 |
| dataIndex | code | 直接映射 |
| typeCode | fieldTypeID | 通过映射表转换 |
| selectField | className | **下拉数据**：映射到 className |
| col | col | 直接映射 |
| labelCol | labelCol | 直接映射 |
| wrapperCol | wrapperCol | 直接映射 |
| required | required | Y/N格式保持 |
| disabled | disabled | Y/N格式保持 |
| placeholder | placeholder | 直接映射 |
| defaultValue | default | 直接映射 |
| doubt | doubt | 直接映射（原样传递） |
| - | display | 默认值 'Y' |

### className 字段说明（下拉数据源）

对于 **Select 类型**（fieldTypeID=3）的字段，前端使用 `selectField` 指定下拉数据源，入库时需要映射到 `className` 字段：

| 前端格式 | 接口格式 |
|----------|----------|
| `selectField: 'eventTypes'` | `className: 'eventTypes'` |
| `selectField: 'formStatuses'` | `className: 'formStatuses'` |

**转换示例：**

```javascript
// 前端格式
{
  dataIndex: 'eventTypeID',
  title: '事件类型',
  typeCode: 'Select',
  selectField: 'eventTypes',
  col: 24,
  labelCol: 5,
  wrapperCol: 18,
}

// 接口格式
{
  code: 'eventTypeID',
  descripts: '事件类型',
  fieldTypeID: 3,
  className: 'eventTypes',
  col: 24,
  labelCol: 5,
  wrapperCol: 18,
  display: 'Y',
  required: 'N',
  disabled: 'N',
}
```

**⚠️ 注意：** `selectField` 不在接口白名单中，必须转换为 `className` 后入库。

### 字段白名单

**formData 只接收以下字段**，其他字段需要作为扩展字段处理：

| 字段名 | 说明 | 必填 | 默认值 |
|--------|------|------|--------|
| code | 数据索引（对应 dataIndex） | 是 | - |
| descripts | 描述（对应 title） | 是 | - |
| seqNo | 序号 | 否 | - |
| enDesc | 英文描述 | 否 | - |
| fieldTypeID | 字段类型ID | 是 | - |
| callback | 回调方法 | 否 | - |
| placeholder | 提示信息 | 否 | - |
| doubt | 输入域描述 | 否 | - |
| className | CSS类名 | 否 | - |
| methodName | 方法名 | 否 | - |
| linkValueID | 关联值ID | 否 | - |
| linkCode | 关联代码 | 否 | - |
| col | 栅格占比 | 是 | - |
| jumpID | 跳转ID | 否 | - |
| labelCol | label占比 | 是 | - |
| wrapperCol | 输入域占比 | 是 | - |
| default | 默认值 | 否 | - |
| required | 是否必填 | 是 | N |
| disabled | 是否禁用 | 是 | N |
| display | 是否显示 | 是 | Y |
| textSelect | 文本选择 | 否 | - |

**⚠️ 重要：formData 必填字段规则**
- `display`: **必填**，不传会报错，默认值 `Y`
- `required`: **必填**，不传会报错，默认值 `N`
- `disabled`: **必填**，不传会报错，默认值 `N`
- 生成数据时必须包含这三个字段

**⚠️ 扩展字段处理规则**
- 白名单**之外**的字段称为"扩展字段"（如 `linkStaticParams`、`onClick`、`onPressEnter`、`btnStyle`、`mode` 等）
- 扩展字段**不入库**，入库时直接过滤
- 改造后需在代码中通过遍历 formData 动态补回
- 详细处理规则见 [code-refactoring.md 扩展字段章节](code-refactoring.md#扩展字段处理重要)

### 转换示例

**输入（前端格式）：**
```javascript
{
  title: '医院代码',
  dataIndex: 'hospCode',
  typeCode: 'Input',
  required: 'Y',
  placeholder: '请输入医院代码',
  col: 12,
  labelCol: 8,
  wrapperCol: 16
}
```

**输出（接口格式）：**
```javascript
{
  descripts: '医院代码',
  code: 'hospCode',
  fieldTypeID: 5,  // Input → 5
  required: 'Y',
  placeholder: '请输入医院代码',
  col: 12,
  labelCol: 8,
  wrapperCol: 16,
  display: 'Y'
}
```

---

## 特殊字段处理

### 按钮类型字段

根据 `dataIndex` 自动识别为按钮类型：

| dataIndex | 处理方式 |
|-----------|----------|
| queryBtn | fieldTypeID = 17 (Button) |
| resetBtn | fieldTypeID = 17 (Button) |
| 其他 | 根据已有 typeCode 转换 |

### render函数处理

对于包含 `render` 函数的列，根据 `dataIndex` 判断是否需要特殊处理：

```javascript
// 示例：查询按钮
if (formData[i].dataIndex === 'queryBtn') {
  formData[i].type = 'primary';
  formData[i].btnStyle = { marginBottom: '0' };
  formData[i].onClick = this.handleQuery;
}
```

这类字段识别为按钮类型，`fieldTypeID = 17`。
