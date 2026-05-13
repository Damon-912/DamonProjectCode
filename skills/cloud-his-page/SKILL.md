---
name: cloud-his-page
description: |
  CloudHIS-PR(HIS)项目React界面开发规范。适用场景：
  1. 根据原型图生成新界面代码
  2. 修改现有界面代码时遵循规范
  3. 调整布局、样式时的规范检查
  4. 代码审查时的规范依据
  
  触发时机：开发、修改、审查任何CloudHIS界面代码时都应参考此规范。
  技术栈：React 16.6.3 + Ant Design 3.x（类组件，禁止Hooks）
---

# CloudHIS 静态界面代码规范

> 版本: v4.0（精简版）
> 项目: CloudHIS-PR  
> 技术栈: React 16.6.3 + Ant Design 3.x（类组件，禁止Hooks）

---

## 快速决策流程

```
                        ┌─────────────────────────────┐
                        │      收到原型图/开发需求      │
                        └──────────────┬──────────────┘
                                       │
                                       ▼
                        ┌─────────────────────────────┐
                        │   是否为标准单列表操作界面？    │
                        │ (查询条件+tab页签+列表+操作列)  │
                        └──────────────┬──────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │ 是                                  │ 否
                    ▼                                     ▼
        ┌─────────────────────┐           ┌─────────────────────────┐
        │ 【必须】包装组件模式  │           │  是否为主从表/审核流程？  │
        │ SingleTableOperation│           └─────────────┬───────────┘
        └─────────────────────┘                         │
                                          ┌─────────────┴─────────────┐
                                          │ 是                        │ 否
                                          ▼                           ▼
                              ┌───────────────────────┐  ┌────────────────────────┐
                              │ 【必须】对应动态组件    │  │  是否为复杂交互界面？   │
                              │ ParentChildTableOper  │  └─────────────┬──────────┘
                              │ OrderReviewComponent  │                │
                              │ LeftConditionRightList│   ┌────────────┴────────────┐
                              └───────────────────────┘   │ 是                      │ 否
                                                          ▼                          ▼
                                              ┌───────────────────────┐  ┌────────────────┐
                                              │ 自定义组件开发         │  │ 根据具体功能    │
                                              │ (需说明不使用动态组件  │  │ 选择合适方案    │
                                              │  的理由)              │  │                │
                                              └───────────────────────┘  └────────────────┘
```

---

## 红线规则（禁止事项）

> 违反以下规则将导致代码无法运行或产生严重问题

| 红线规则 | 错误方式 | 正确方式 |
|---------|---------|---------|
| **禁止使用Hooks** | `useState`, `useEffect`, `useRef` | 类组件 + `this.state` |
| **禁止函数组件** | `const Xxx = () => {...}` | `class Xxx extends Component` |
| **禁止直接使用Form** | `<Form><Form.Item>...` | `<DynamicRenderingForm>` |
| **禁止错误typeCode** | `typeCode: 'Btn'` | `typeCode: 'Button'` |
| **禁止错误下拉格式** | `{value, label}` | `{id, descripts, descriptsSPCode}` |
| **禁止使用$http** | `import { $http }` | `React.$asyncPost(this, code, data)` |
| **禁止空catch块** | `catch (e) {}` | `catch (e) { console.log(e); }` |
| **禁止重复定义常量** | 自定义分页配置 | 从 `statusConstants` 导入 |

---

## 按需加载指引

| 开发场景 | 必读规范 |
|---------|---------|
| **新建标准页面** | [最佳实践规范](references/best-practices.md) · [公共资源清单](references/public-resources.md) |
| **修改表单功能** | [字段类型映射表](references/field-type-mapping.md) · [公共资源清单](references/public-resources.md) |
| **调整布局样式** | [公共资源清单](references/public-resources.md) |
| **处理组件通信** | [最佳实践规范](references/best-practices.md) |
| **解决特定组件问题** | [公共组件使用指南](references/common-components-guide.md) |
| **代码审查** | [检查清单](references/code-checklist.md) |
| **问题排查** | [最佳实践规范](references/best-practices.md) |

---

## 核心文档索引

### 规范文档（references/）

- [最佳实践规范](references/best-practices.md) - 命名、布局、通信等开发规范
- [公共组件使用指南](references/common-components-guide.md) - 组件详细使用方法
- [字段类型映射表](references/field-type-mapping.md) - 完整的typeCode列表
- [公共资源清单](references/public-resources.md) - 公共样式、常量、接口规范
- [配置示例集合](references/code-examples.md) - columns、formData配置示例
- [代码检查清单](references/code-checklist.md) - 统一检查标准

### 代码模板（assets/）

- `WrapperComponentTemplate.jsx` - 标准CRUD包装组件
- `CustomComponentTemplate.jsx` - 自定义组件（复杂交互）
- `SimpleListTemplate.jsx` - 简单列表（无增删改）
- `CardListTemplate.jsx` - Card包裹列表组件
- `LeftRightLayoutTemplate.jsx` - 左右分栏布局

---

## 技术栈约束

### React 16.6.3 版本限制

**组件类型：**
```
✅ 必须使用类组件: class Xxx extends Component { ... }
❌ 禁止使用函数组件: const Xxx = () => { ... }
```

**状态管理：**
```
✅ 必须使用: this.state = { ... } 在 constructor 中初始化
✅ 必须使用: this.setState({ ... }) 更新状态
❌ 禁止使用: useState, useReducer 等 Hooks
```

**生命周期：**
```
✅ 使用: componentDidMount, componentDidUpdate, componentWillUnmount
❌ 禁止使用: useEffect, useLayoutEffect 等 Hooks
```

---

> 💡 **维护原则**：详细规范放在 `references/` 目录，模板代码放在 `assets/` 目录，保持本文件简洁，通过引用建立文档间关联。
