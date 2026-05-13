# 公共资源清单

> 本文档列出项目中已存在的公共常量、工具函数、样式类等，开发时禁止重复定义。

---

## 一、公共常量

### 1. 分页配置

**文件位置：** `src/tools/statusConstants.js`

```javascript
// 小数据分页（10/20/30/50）
export const PAGE_NUM = {
    FIRST: '10',
    SECOND: '20',
    THIRD: '30',
    FOURTH: '50'
};

// 分页选项数组
export const PAGE_NUM_STATUS = [
    { code: PAGE_NUM.FIRST, name: '10条/页' },
    { code: PAGE_NUM.SECOND, name: '20条/页' },
    { code: PAGE_NUM.THIRD, name: '30条/页' },
    { code: PAGE_NUM.FOURTH, name: '50条/页' },
];

// 大数据分页（50/100/200/300）
export const PAGE_NUM_MORE = {
    FIRST: '50',
    SECOND: '100',
    THIRD: '200',
    FOURTH: '300'
};

// 大数据分页选项数组
export const PAGE_NUM_MORE_STATUS = [
    { code: PAGE_NUM_MORE.FIRST, name: '50条/页' },
    { code: PAGE_NUM_MORE.SECOND, name: '100条/页' },
    { code: PAGE_NUM_MORE.THIRD, name: '200条/页' },
    { code: PAGE_NUM_MORE.FOURTH, name: '300条/页' },
];
```

**使用方式：**
```javascript
import { PAGE_NUM, PAGE_NUM_STATUS, PAGE_NUM_MORE } from 'tools/statusConstants';

// 使用分页选项
const pagination = {
    current: 1,
    pageSize: PAGE_NUM.SECOND,  // 20
    total: 100,
    pageSizeOptions: PAGE_NUM_STATUS.map(item => item.code),
    showSizeChanger: true,
    showQuickJumper: true,
    showTotal: (total) => `共 ${total} 条`,
};
```

**⚠️ 禁止重复定义：**
```javascript
// ❌ 错误：在模块中重复定义分页常量
const PAGE_SIZE = { DEFAULT: 20, LARGE: 50 };
const PAGINATION_CONFIG = { defaultPageSize: 20 };

// ✅ 正确：使用公共常量
import { PAGE_NUM } from 'tools/statusConstants';
```

---

### 2. 日期格式

**推荐：** 直接使用字符串常量，无需从工具文件导入。

| 用途 | 格式字符串 | 示例 |
|------|-----------|------|
| 日期 | `'YYYY-MM-DD'` | `'2024-01-15'` |
| 时间 | `'HH:mm:ss'` | `'14:30:00'` |
| 日期时间 | `'YYYY-MM-DD HH:mm:ss'` | `'2024-01-15 14:30:00'` |
| 小时分钟 | `'HH:mm'` | `'14:30'` |
| 月份 | `'YYYY-MM'` | `'2024-01'` |

**使用方式：**
```javascript
import moment from 'moment';

// ✅ 直接使用字符串
const dateStr = moment().format('YYYY-MM-DD');
const dateTimeStr = moment().format('YYYY-MM-DD HH:mm:ss');
```

**⚠️ 禁止重复定义：**
```javascript
// ❌ 错误：在模块中定义日期格式常量
const DATE_FORMAT = {
    date: 'YYYY-MM-DD',
    dateTime: 'YYYY-MM-DD HH:mm:ss',
};

// ✅ 正确：直接使用字符串
moment().format('YYYY-MM-DD');
```

---

## 二、公共样式类

### 1. 操作类样式

| 样式类名 | 文件位置 | 用途 | 示例 |
|----------|---------|------|------|
| `.span` | `src/assets/css/App.css` (314-322行) | 操作列链接（蓝色） | 编辑、查看链接 |
| `.common-record-delete-span` | `src/assets/css/App.css` (324-327行) | 删除操作（红色） | 删除链接 |
| `.add-btn` | `src/assets/css/common.css` (295-299行) | 新增按钮 | 新增按钮 |

**使用方式：**
```jsx
// 操作列
{
    title: '操作',
    dataIndex: 'operation',
    align: 'center',
    render: (text, record) => (
        <span>
            <span className="span" onClick={() => this.handleEdit(record)}>编辑</span>
            <Divider type="vertical" />
            <span className="common-record-delete-span" onClick={() => this.handleDelete(record)}>删除</span>
        </span>
    )
}

// 新增按钮
<Button type="primary" className="add-btn" onClick={this.handleAdd}>新增</Button>
```

---

### 2. 表格类样式

| 样式类名 | 文件位置 | 用途 |
|----------|---------|------|
| `.clickRowStyle` | `src/assets/css/index.css` (27-34行) | 表格行点击高亮 |
| `.scroll-bar-style` | `src/assets/css/common.css` (243-265行) | 滚动条样式 |

**使用方式：**
```jsx
// 表格行点击高亮
<Table
    rowClassName={(record, index) => 
        record.id === this.state.rowID ? 'clickRowStyle' : ''
    }
    onRow={(record) => ({
        onClick: () => this.setState({ rowID: record.id })
    })}
/>

// 滚动区域
<div className="scroll-bar-style" style={{ height: '300px', overflow: 'auto' }}>
    {/* 内容 */}
</div>
```

---

### 3. 表单类样式

| 样式类名 | 文件位置 | 用途 |
|----------|---------|------|
| `.dynamic-component-form` | `src/assets/less/index.less` (141-155行) | 动态组件表单 |
| `.card-title-left-img` | `src/assets/css/common.css` (147-158行) | 卡片标题左侧图标 |

**使用方式：**
```jsx
// 动态组件表单（自动布局）
<DynamicRenderingForm
    className="dynamic-component-form"
    formData={this.queryFormData}
    selectData={this.state.selectData}
/>

// 卡片标题
<Card title={<span><Icon type="setting" /> 配置管理</span>} className="card-title-left-img">
    {/* 内容 */}
</Card>
```

---

## 三、公共工具函数

### 1. 数据处理工具

**文件位置：** `src/tools/common/dataProcessing.js`

| 函数名 | 用途 |
|--------|------|
| `deepClone` | 深拷贝对象 |
| `formatMoney` | 格式化金额 |
| `throttle` | 节流函数 |
| `debounce` | 防抖函数 |

### 2. HTTP 请求工具

**文件位置：** `src/tools/common/https.js`

| 函数名 | 用途 |
|--------|------|
| `fetchRequest` | 通用请求封装 |
| `postRequest` | POST 请求 |
| `getRequest` | GET 请求 |

---

## 四、接口调用工具

### 1. React.$asyncPost - 异步请求

**用途：** 统一的异步 HTTP 请求方法（项目强制使用）

**语法：**
```javascript
let res = await React.$asyncPost(this, code, data);
```

**参数说明：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `this` | Object | 组件实例（必须传递） |
| `code` | String | 接口代码（如 '20010008'） |
| `data` | Object | 请求参数对象 |

**参数格式：**
```javascript
// 标准格式
let data = {
    params: [{
        // 参数字段
    }]
};

// 带分页
let data = {
    params: [{ ...queryParams }],
    pagination: [{
        pageSize: 10,
        currentPage: 1
    }]
};
```

**使用示例：**
```javascript
getSelectData = async () => {
    try {
        let data = {
            params: [{ hospID: '' }]
        };
        let res = await React.$asyncPost(this, '20010008', data);
        this.setState({ 
            selectData: res && 'result' in res ? res.result : res 
        });
    } catch (error) {
        console.log(error);
        this.setState({ selectData: {} });
    }
}
```

**响应数据处理：**
```javascript
// 方式1: 标准格式
let result = res && 'result' in res ? res.result : res;

// 方式2: 安全访问
let field = res?.result?.field || [];

// 方式3: 表格数据处理
let tableData = React.$processingTableRequestData(res);
```

### 2. React.$processingTableRequestData - 表格数据处理

**用途：** 处理表格接口返回的数据

**语法：**
```javascript
let tableData = React.$processingTableRequestData(res);
```

**使用示例：**
```javascript
getTableData = async () => {
    try {
        let data = {
            params: [{ ...queryParams }],
            pagination: [{ pageSize: 10, currentPage: 1 }]
        };
        let res = await React.$asyncPost(this, '20010011', data);
        let tableData = React.$processingTableRequestData(res);
        this.setState({ tableData });
    } catch (error) {
        console.log(error);
        this.setState({ tableData: [] });
    }
}
```

### 3. React.$downloadPost - 文件下载

**用途：** 文件下载请求

**语法：**
```javascript
await React.$downloadPost(this, code, data);
```

**使用示例：**
```javascript
handleExport = async () => {
    try {
        let data = {
            params: [{ ...queryParams }]
        };
        await React.$downloadPost(this, '20010006', data);
        message.success('导出成功');
    } catch (error) {
        console.log(error);
        message.error('导出失败');
    }
}
```

### 4. 详细规范文档

**查看完整接口调用规范：** [接口调用规范](./api-calling-standards.md)

---

## 五、检查清单

生成代码前必须确认：

- [ ] **下拉框数据格式**：使用 `{id, descripts, descriptsSPCode}` 格式
- [ ] **公共常量**：未重复定义 PAGE_NUM 等分页常量
- [ ] **日期格式**：直接使用字符串，无需定义常量
- [ ] **公共样式**：使用 `.span`、`.clickRowStyle`、`.add-btn` 等公共样式类
- [ ] **工具函数**：检查 `tools/` 目录是否已有需要的工具函数

---

## 六、快速查询

```bash
# 搜索公共常量
grep -r "PAGE_NUM" src/tools/
grep -r "export const" src/tools/statusConstants.js

# 搜索公共样式
grep -r "\.span" src/assets/css/
grep -r "\.clickRowStyle" src/assets/css/

# 搜索公共组件
ls src/pages/common/
ls src/pages/dynamicComponent/
```
