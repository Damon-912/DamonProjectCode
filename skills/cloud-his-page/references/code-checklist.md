# 代码检查清单

> 统一的开发检查标准，整合所有分散的检查项，成为唯一的核对依据

---

## 开发前检查

### 界面类型识别

- [ ] 确认界面类型（单表/父子表/审核流程/复杂交互）
- [ ] 选择合适的开发模式（包装组件/动态组件/自定义组件）
- [ ] 确认是否可以使用动态组件

### 公共资源检查

- [ ] 查看公共组件目录，了解可用组件
- [ ] 查看公共样式文件，确认所需样式是否已存在
- [ ] 检查 `statusConstants.js` 是否已有需要的常量

---

## 核心规范检查

### React 类组件规范（红线）

- [ ] **使用类组件**：`class Xxx extends Component`
- [ ] **禁止函数组件**：未使用 `const Xxx = () => {}`
- [ ] **禁止 Hooks**：未使用 `useState`、`useEffect`、`useRef` 等
- [ ] **状态初始化**：在 `constructor` 中使用 `this.state = {}`
- [ ] **状态更新**：使用 `this.setState({})` 而非直接修改 state

### 表单渲染规范

- [ ] **使用 DynamicRenderingForm**：所有表单场景使用该组件
- [ ] **禁止直接使用 Form**：未使用 `<Form><Form.Item>`
- [ ] **表单分组**：使用 `typeCode: 'CardTitle'` 而非拆分多个表单
- [ ] **分割线**：使用 `typeCode: 'Divider'` 而非直接使用 Divider 组件

### typeCode 规范

- [ ] **拼写正确**：`Button` 而非 `Btn`，`Input` 而非 `Text`
- [ ] **大小写匹配**：`Select` 而非 `select`
- [ ] **查阅映射表**：参考 [字段类型映射表](field-type-mapping.md)

### 下拉框数据规范

- [ ] **使用 selectField 属性**：关联 selectData 中的数据
- [ ] **禁止无效属性**：未使用 `linkService`、`selectKey` 等
- [ ] **数据格式正确**：`{id, descripts, descriptsSPCode}` 格式
- [ ] **避免错误格式**：未使用 `{value, label}` 或 `{id, title/name}`

### 接口调用规范

- [ ] **使用 React.$asyncPost**：`await React.$asyncPost(this, code, data)`
- [ ] **禁止使用 $http**：未从 `containers/config/https` 导入
- [ ] **使用 try-catch**：所有接口调用包裹在 try-catch 中
- [ ] **安全取值**：使用 `res && 'result' in res ? res.result : res`
- [ ] **错误处理**：catch 块中有 `console.log(error)`

---

## 动态组件检查

### SingleTableOperation 检查

- [ ] 设置 `skip01040073={true}`
- [ ] 手动配置查询按钮时设置 `hideQueryBtnFlag: 'Y'`
- [ ] 手动配置操作列时设置 `cancelAddOperationFlag: 'Y'`
- [ ] 传入 `componentName` 属性
- [ ] 已阅读组件代码了解自动处理功能

### PubilcTablePagination 检查

- [ ] `param` 对象包含必要属性（page, size, pageSize, total, loading, data, columns）
- [ ] 设置 `extendFlag: 'Y'`
- [ ] 表格高度使用 `store.getState().tableHeight.y` 计算
- [ ] 行点击事件使用 `onClickRowPublic` 和 `setRowClassNamePublic`

---

## 布局与样式检查

### 布局规范检查

- [ ] 查询表单使用 `className="dynamic-component-form"`
- [ ] 分隔线高度/宽度为 8px
- [ ] 左右布局使用 `common-card-right-split-line`
- [ ] Card 设置 `size="small"` 和 `bordered={false}`
- [ ] Card 标题使用 `className="card-title-left-img"`

### 公共样式检查

- [ ] 未重复定义公共样式（`.span`、`.add-btn`、`.clickRowStyle`）
- [ ] 未重写 Ant Design 默认样式
- [ ] 使用公共样式类替代自定义样式
- [ ] 样式文件行数合理（建议不超过 60 行）

### Drawer/Modal 检查

- [ ] 内容区高度使用 `calc(100vh - 105px)`
- [ ] 表单使用 `DynamicRenderingForm` 渲染
- [ ] 使用 Less 转义语法：`calc(~"100vh - 105px")`

---

## Columns 配置检查

### 必填属性

- [ ] **所有列添加 `align: 'center'`**
- [ ] **所有列添加 `ellipsis: true`**（除非需要完整显示）
- [ ] 操作列设置 `fixed: 'right'`

### 属性完整性

- [ ] `title` - 列标题
- [ ] `dataIndex` - 数据字段名
- [ ] `key` - 唯一标识（通常与 dataIndex 相同）
- [ ] `width` - 列宽度
- [ ] `align` - 对齐方式
- [ ] `ellipsis` - 超出省略
- [ ] `render` - 自定义渲染函数（如需要）

### 渲染函数规范

- [ ] 状态转换：`(text) => text === '1' ? '启用' : '停用'`
- [ ] 日期格式化：`(text) => text ? moment(text).format('YYYY-MM-DD') : ''`
- [ ] 金额格式化：`(text) => text ? '¥' + parseFloat(text).toFixed(2) : ''`
- [ ] 操作列使用公共样式类 `.span` 和 `.common-record-delete-span`

---

## 命名与导入规范检查

### 组件命名

- [ ] 组件名使用大驼峰（如 `UserManagement`）
- [ ] 界面名称与组件名对应（xxx维护 → XxxMaintenance）
- [ ] 主组件文件名与组件名一致

### 文件结构

- [ ] 主组件文件放在 `src/pages/模块名/` 下
- [ ] 样式文件放在 `style/` 子目录
- [ ] 样式文件名与组件名一致（XxxManagement.less）
- [ ] 禁止使用 `index.jsx` 作为主组件文件名

### 导入路径

- [ ] **使用绝对路径别名**：`'pages/common/xxx'`
- [ ] **禁止相对路径**：未使用 `'../common/xxx'`
- [ ] 公共组件导入：
  ```jsx
  import SingleTableOperation from 'pages/dynamicComponent/SingleTableOperation';
  import DynamicRenderingForm from 'pages/common/DynamicRenderingForm';
  import PubilcTablePagination from 'pages/common/PubilcTablePagination';
  ```

---

## 公共常量检查

### 禁止重复定义

- [ ] 未重复定义 `PAGE_NUM` 等分页常量
- [ ] 未重复定义日期格式常量（直接使用字符串）
- [ ] 从 `statusConstants.js` 导入公共常量

### 常用常量

```javascript
// 分页常量
import { PAGE_NUM, PAGE_NUM_STATUS } from 'tools/statusConstants';

// 日期格式（直接使用字符串）
'YYYY-MM-DD'
'YYYY-MM-DD HH:mm:ss'
'HH:mm'
```

---

## 公共样式类检查

### 操作类样式

- [ ] 编辑/查看链接：使用 `.span`
- [ ] 删除操作：使用 `.common-record-delete-span`
- [ ] 新增按钮：使用 `.add-btn` 和 `.add-btn-noHover`

### 表格类样式

- [ ] 行点击高亮：使用 `.clickRowStyle`
- [ ] 滚动条样式：使用 `.scroll-bar-style`

### 表单类样式

- [ ] 动态组件表单：使用 `.dynamic-component-form`
- [ ] 卡片标题：使用 `.card-title-left-img`

### 分割线样式

- [ ] 上下分割：使用 `.common-query-split-line`
- [ ] 左右分割：使用 `.common-card-right-split-line`

---

## 组件通信检查

### 父子组件通信

- [ ] 子组件在 `componentDidMount` 中注册 ref
- [ ] 子组件实现了 `modifyVisible(visible, params)` 方法
- [ ] 初始化接口在 `modifyVisible` 中调用，而非 `componentDidMount`
- [ ] 父组件通过 `this.childRef?.modifyVisible(true)` 打开弹窗
- [ ] 参数传递使用对象形式 `{ visible, ...params }`
- [ ] 关闭弹窗时正确重置状态

### 惰性加载模式

- [ ] 弹窗打开时加载数据，而非 `componentDidMount`
- [ ] 通过 `params` 控制是否自动查询

---

## 开发后检查

### 代码规范

- [ ] 无未使用的 import
- [ ] 无 console.log 等调试代码
- [ ] 注释清晰、有意义
- [ ] 接口编号已替换为实际值（非 010XXXXX）

### 样式文件

- [ ] 样式文件未重复定义公共样式
- [ ] 样式文件未重写 Ant Design 默认样式
- [ ] 样式文件行数合理（建议不超过 60 行）

### 布局完整性

- [ ] 包含必要的分割线
- [ ] 代码结构符合包装组件模式
- [ ] 表格列内容居中对齐

---

## 快速检查流程

```
1. 确认界面类型 → 选择合适的模板
2. 检查 React 类组件 → 禁止 Hooks
3. 检查表单渲染 → DynamicRenderingForm
4. 检查下拉数据格式 → {id, descripts}
5. 检查样式规范 → 避免重复定义
6. 检查 Drawer/Modal → 必配 drawerStyle（如适用）
7. 检查 Columns → align: 'center'
8. 检查导入路径 → 绝对路径别名
```

---

## 参考文档

- [最佳实践规范](best-practices.md) - 详细开发规范
- [公共组件使用指南](common-components-guide.md) - 组件使用方法
- [字段类型映射表](field-type-mapping.md) - typeCode 完整列表
- [公共资源清单](public-resources.md) - 公共样式和常量
- [布局与样式规范](modules/layout-and-styles.md) - 详细布局规范
- [表单与字段规范](modules/form-and-fields.md) - 详细表单规范
- [组件通信规范](modules/component-communication.md) - 详细通信规范
