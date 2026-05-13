# 最佳实践规范

> CloudHIS界面开发的核心规范集合，每条规范仅定义一次，通过引用建立关联

---

## 一、开发原则

### 1. 动态组件优先

```
【强制】标准单表增删改查界面必须使用包装组件模式，禁止手动实现分页、查询、增删改等通用逻辑
```

**使用场景：**
- 查询条件 + 列表 + 操作列 → SingleTableOperation
- 主从表结构 → ParentChildTableOperation
- 审核流程 → OrderReviewComponent
- 左侧查询右侧列表 → LeftConditionRightList

**详见：** [动态组件模板规范](dynamic-component-templates-guide.md)

### 2. 公共组件优先

```
【强制】所有表单渲染场景必须使用 DynamicRenderingForm 组件，禁止直接使用 Ant Design 的 Form 组件
```

**详见：** [公共组件使用指南](common-components-guide.md)

### 3. 使用前阅读组件代码

```
【重要】使用动态组件或公共组件前，必须先仔细阅读组件代码，了解其自动处理的功能，避免重复添加
```

---

## 二、命名规范

### 1. 组件命名

```
界面名称: xxx维护 → 组件名: XxxMaintenance
界面名称: xxx查询 → 组件名: XxxQuery
界面名称: xxx审核 → 组件名: XxxAudit
```

### 2. 文件命名

```
组件: XxxManagement.jsx
样式: style/XxxManagement.less (放在style文件夹下)
```

**重要：**
- 主组件文件名必须与组件名一致，使用大驼峰命名
- 禁止使用 `index.jsx` 作为主组件文件名
- 文件名首字母必须大写，遵循帕斯卡命名法（PascalCase）

### 3. 字段命名

```
xxx代码 → xxxCode (驼峰)
xxx名称 → xxxName (驼峰)
创建时间 → createTime (驼峰)
是否启用 → isEnabled/isActive (布尔)
```

---

## 三、界面布局规范

### 1. 标准单表界面布局

```jsx
<div className="xxx-management dynamic-component">
  {/* 1. 查询表单区域 */}
  <Row ref={this.queryRef} className="dynamic-component-form">
    <DynamicRenderingForm
      className="dynamic-component-form"
      formData={this.queryFormData}
      rowData={this.state.queryParams}
    />
  </Row>
  
  {/* 2. 分隔线 */}
  <div className="common-query-split-line" style={{ height: 8 }}></div>
  
  {/* 3. 列表区域 */}
  <div className="table-body-height">
    <PubilcTablePagination param={tableParams} />
  </div>
</div>
```

**布局要点：**
- 查询表单使用 `className="dynamic-component-form"`
- 分隔线使用 `className="common-query-split-line"`，高度固定为 8px
- 列表区域使用 `className="table-body-height"`
- 最外层容器使用 `className="xxx-management dynamic-component"`

### 2. 左右分栏布局

```jsx
<Row className="xxx-management">
  {/* 左侧列表区域 */}
  <Col span={14}>
    <div style={{ paddingRight: '8px', position: 'relative' }}>
      <Card size="small" bordered={false} title={<div>列表标题</div>}>
        {/* 列表内容 */}
      </Card>
      <div className="common-card-right-split-line" style={{ width: 8 }}></div>
    </div>
  </Col>
  
  {/* 右侧详情区域 */}
  <Col span={10}>
    <Card size="small" bordered={false} title={<div>详情标题</div>}>
      <div style={{ height: store.getState().tableHeight.y + 187 + 'px', overflow: 'auto' }}>
        {/* 详情内容 */}
      </div>
    </Card>
  </Col>
</Row>
```

**布局要点：**
- 左侧 span 通常为 14，右侧为 10
- 左侧 Card 外层 div 必须设置 `paddingRight: '8px'` 和 `position: 'relative'`
- 垂直分割线使用 `className="common-card-right-split-line"`，宽度固定为 8px
- 右侧详情区域设置独立滚动

### 3. 父子表布局

```jsx
<div className="parent-child-table dynamic-component">
  {/* 主表 Card */}
  <Card size="small" bordered={false} title={<div>主列表</div>}>
    {/* 主表内容 */}
  </Card>
  
  {/* 明细表 Card */}
  <Card size="small" bordered={false} title={<div>明细列表</div>} style={{ marginTop: '16px' }}>
    {/* 明细表内容 */}
  </Card>
</div>
```

---

## 四、Card 组件规范

```jsx
<Card
  size="small"           // 【强制】统一使用小尺寸
  bordered={false}       // 【强制】取消边框
  title={
    <div className="card-title-left-img">
      <img src={iconListVisits} alt="" />
      卡片标题
    </div>
  }
>
  {/* Card 内容 */}
</Card>
```

**Card 使用要点：**
- 必须设置 `size="small"`
- 必须设置 `bordered={false}`
- 标题使用 `className="card-title-left-img"` 统一样式
- 标题图标统一使用 `iconListVisits`

---

## 五、公共样式引用规范

### 1. 全局样式说明

```
【重要】全局公共样式已在入口文件 src/index.js 中统一引入，无需在组件 .less 文件中重复引用

公共样式文件引入位置：
- src/index.js 第 15 行：import './assets/css/index.css';
- src/index.js 第 16 行：import './assets/less/index.less';

【强制】禁止在组件 .less 文件中重复引入公共样式文件
```

### 2. 公共样式类速查

| 样式类名 | 公共文件位置 | 用途说明 |
|----------|-------------|----------|
| `.span` | `App.css` (314-322行) | 操作列链接样式（蓝色） |
| `.common-record-delete-span` | `App.css` (324-327行) | 删除操作样式（红色） |
| `.clickRowStyle` | `index.css` (27-34行) | 表格行点击高亮样式 |
| `.add-btn` | `common.css` (295-299行) | 新增按钮样式 |
| `.add-btn-noHover` | `common.css` | 新增按钮无悬浮效果 |
| `.dynamic-component-form` | `index.less` (141-155行) | 动态组件表单样式 |
| `.scroll-bar-style` | `common.css` (243-265行) | 滚动条样式 |
| `.card-title-left-img` | `common.css` (147-158行) | 卡片标题左侧图标样式 |
| `.common-query-split-line` | `common.css` | 查询区分隔线 |
| `.common-card-right-split-line` | `common.css` | 左右布局垂直分割线 |

**详见：** [公共资源清单](public-resources.md)

---

## 六、导入路径规范

### 1. 必须使用绝对路径别名

项目已配置的路径别名：
```javascript
resolve: {
    alias: {
        'tools': path.resolve(__dirname, '../src/tools'),
        'store': path.resolve(__dirname, '../src/store'),
        'pages': path.resolve(__dirname, '../src/pages'),
        'assets': path.resolve(__dirname, '../src/assets'),
        'routers': path.resolve(__dirname, '../src/routers'),
        'components': path.resolve(__dirname, '../src/components'),
        'containers': path.resolve(__dirname, '../src/containers'),
    },
    extensions: ['.js', '.jsx']
}
```

### 2. 公共组件导入示例

```jsx
// ❌ 错误：使用相对路径
import SingleTableOperation from '../dynamicComponent/SingleTableOperation';
import DynamicRenderingForm from '../common/DynamicRenderingForm';

// ✅ 正确：使用绝对路径别名
import SingleTableOperation from 'pages/dynamicComponent/SingleTableOperation';
import DynamicRenderingForm from 'pages/common/DynamicRenderingForm';
import PubilcTablePagination from 'pages/common/PubilcTablePagination';
```

---

## 七、表格 Columns 规范

### 1. align 属性规范

```
【强制】所有表格列必须添加 align: 'center' 属性，使数据居中显示，保持视觉一致性
```

```javascript
// ❌ 错误示例 - 缺少 align 属性
columns = [
    { title: '字段名称', dataIndex: 'fieldName', width: 120 },
    { title: '字段类型', dataIndex: 'fieldType', width: 100 },
];

// ✅ 正确示例 - 所有列都有 align: 'center'
columns = [
    { title: '字段名称', dataIndex: 'fieldName', width: 120, align: 'center', ellipsis: true },
    { title: '字段类型', dataIndex: 'fieldType', width: 100, align: 'center', ellipsis: true },
    { title: '操作', dataIndex: 'operation', width: 120, align: 'center', fixed: 'right' },
];
```

---

## 八、表单下拉框数据关联规范

### 1. 核心原则

```
【强制】DynamicRenderingForm 组件中，下拉框关联 selectData 数据必须使用 selectField 属性
【禁止】使用 linkService、selectKey 等无效属性
```

### 2. 下拉数据格式规范

```
【强制】selectData 中的下拉数据必须遵循以下格式：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `id` | string | 是 | 数据ID，传给后台的值 |
| `descripts` | string | 是 | 描述，下拉框显示的文字 |
| `descriptsSPCode` | string | 否 | 描述+首拼，用于下拉框检索 |
```

**详见：** [表单与字段规范](modules/form-and-fields.md)

---

## 九、Drawer 组件使用规范

### 2. 高度计算规范

```
Drawer 内容区高度 = calc(~"100vh - 105px")
// 56px: Drawer头部高度
```

---

## 十、Drawer/Modal 表单渲染规范

### 1. 核心原则

```
【强制】Drawer 和 Modal 中的表单渲染必须使用 DynamicRenderingForm 组件

禁止场景：
❌ 直接使用 <Form> + <Form.Item> 手动渲染表单字段
❌ 直接使用 <Divider> 组件作为分割线
❌ 将固定字段和动态字段拆分成多个表单组件

正确做法：
✅ 所有表单字段合并到同一个 formData 配置中
✅ 使用 typeCode: 'Divider' 代替直接使用 Divider 组件
✅ 使用 typeCode: 'CardTitle' 进行表单分组
✅ 只用一个 DynamicRenderingForm 渲染整个表单
```

### 2. 分割线使用

```javascript
// ❌ 错误：直接使用 Ant Design 的 Divider 组件
<Divider className="form-divider">
    <span className="divider-text">专项字段</span>
</Divider>

// ✅ 正确：在 formData 中使用 typeCode: 'Divider'
formData = [
    { dataIndex: 'field1', title: '字段1', typeCode: 'Input', col: 12 },
    { typeCode: 'Divider', title: '专项字段', col: 24 },  // 带标题的分割线
    { dataIndex: 'field2', title: '字段2', typeCode: 'Input', col: 12 },
];
```

---

## 十一、Less calc() 函数使用规范

### 1. 核心原则

```
【强制】在 Less 中使用 calc() 函数时，必须使用转义语法 ~"..."
```

```less
// ❌ 错误：直接使用 calc()，Less 会尝试计算表达式
.my-component {
    height: calc(100vh - 105px);  // 编译后可能出错
}

// ✅ 正确：使用转义语法 ~"..."
.my-component {
    height: calc(~"100vh - 105px");  // 编译后正确输出 calc(100vh - 105px)
}
```

---

## 十二、父子组件 ref 通信模式

### 1. 核心原则

```
【重要】弹窗类子组件应采用"惰性加载"模式：
1. 父组件通过 onRef 获取子组件实例引用
2. 子组件状态由子组件自行管理
3. 初始化接口在弹窗打开时调用，而非 componentDidMount
4. 父组件通过调用子组件方法（如 modifyVisible）触发弹窗显示
```

**详见：** [组件通信规范](modules/component-communication.md)

---

## 十三、常见问题与故障排除

### 1. 表单渲染问题

**问题: 查询按钮不显示**
- 原因：`typeCode` 应为 `'Button'` 而非 `'Btn'`，`title` 不能为空
- 解决：检查 typeCode 拼写和 title 属性

**问题: 下拉框无数据**
- 排查：检查 `selectField` 配置、下拉数据格式（应为 `{id, descripts}`）
- 解决：确保 selectData 正确传入且格式符合规范

**问题: 表单字段布局错乱**
- 原因：`col` 值设置不当，每行总和应为24的倍数
- 解决：调整 col、labelCol、wrapperCol 值

### 2. 接口调用问题

**问题: `$http is not defined`**
- 解决：使用 `React.$asyncPost(this, 'code', data)` 替代 `$http`

**问题: `Cannot read property 'xxx' of undefined`**
- 解决：使用 `res && 'result' in res ? res.result : res` 安全取值

### 3. 组件使用问题

**问题: 查询按钮/操作列重复显示**
- 原因：同时手动配置和自动添加
- 解决：设置 `hideQueryBtnFlag: 'Y'` 或 `cancelAddOperationFlag: 'Y'`

### 4. 常见错误速查

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `$http is not defined` | 错误的接口调用方式 | 使用 `React.$asyncPost` |
| `typeCode is not valid` | typeCode 值错误 | 检查拼写，参考字段类型映射表 |
| `selectData is undefined` | 未传入 selectData | 检查 props 传递 |
| 查询按钮重复 | 同时手动和自动添加 | 设置 `hideQueryBtnFlag: 'Y'` |
| 操作列重复 | 同时手动和自动添加 | 设置 `cancelAddOperationFlag: 'Y'` |

**更多问题详见：** [故障排除指南](modules/troubleshooting.md)

---

## 参考文档

- [公共组件使用指南](common-components-guide.md) - DynamicRenderingForm 等详细使用方法
- [字段类型映射表](field-type-mapping.md) - 完整的 typeCode 列表
- [公共资源清单](public-resources.md) - 公共样式和常量
- [代码检查清单](code-checklist.md) - 统一的检查标准
- [表单与字段规范](modules/form-and-fields.md) - typeCode 映射、表单配置
- [布局与样式规范](modules/layout-and-styles.md) - 布局规范、公共样式类
- [组件通信规范](modules/component-communication.md) - 父子组件通信、弹窗控制
