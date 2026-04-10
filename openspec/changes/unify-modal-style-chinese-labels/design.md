# 统一弹框风格与组件标签 - 技术设计

## Context

当前项目前端使用 React 18 + Ant Design 5 开发，存在以下问题：

1. **弹框风格不一致**：各页面自行定义 Modal 的 width、bodyStyle、footer 等属性
2. **标签命名混乱**：Form.Item 的 label 有英文、简写、不规范中文等问题
3. **代码重复**：相同功能的弹框代码在多个文件中重复编写

## Goals / Non-Goals

**Goals:**
- 建立统一的弹框尺寸规格（小/中/大/全屏）
- 统一按钮布局（底部居右，确定/取消顺序）
- 统一标签命名规范（全中文，简洁明确）
- 提供可复用的弹框组件

**Non-Goals:**
- 不修改 Ant Design 组件库源码
- 不改变现有业务逻辑
- 不涉及后端接口变更

## Decisions

### 1. 弹框尺寸规格

| 类型 | 用途 | width | height | 
|------|------|-------|--------|
| sm | 确认类、信息提示 | 400px | auto |
| md | 表单编辑（少字段） | 600px | auto |
| lg | 表单编辑（多字段） | 900px | 70vh |
| xl | 复杂表格、详情展示 | 1200px | 80vh |

### 2. 标签命名规范

- **必填标识**：使用红色星号 `*` 前缀
- **必填字段**：格式为 `* 字段名称`
- **可选字段**：直接使用字段名称
- **计量单位**：统一使用中文括号包裹，如 `年龄(岁)`、`金额(元)`
- **禁用英文**：全部使用中文，禁止使用 code、name、desc 等英文

### 3. 通用组件设计

创建以下组件：

```typescript
// 1. ConfirmModal - 确认弹框
interface ConfirmModalProps {
  open: boolean;
  title: string;
  content: string | ReactNode;
  okText?: string;  // 默认"确定"
  cancelText?: string;  // 默认"取消"
  onOk: () => void;
  onCancel: () => void;
}

// 2. FormModal - 表单弹框
interface FormModalProps {
  open: boolean;
  title: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  form: FormInstance;
  onOk: (values: any) => void;
  onCancel: () => void;
  okText?: string;
  cancelText?: string;
  loading?: boolean;
}

// 3. DrawerModal - 抽屉弹框
// 同 FormModal，使用 Drawer 实现
```

### 4. 按钮文案规范

| 场景 | 确定按钮 | 取消按钮 |
|------|----------|----------|
| 新增/编辑 | `确定` | `取消` |
| 删除确认 | `删除` | `取消` |
| 提交审核 | `提交` | `取消` |
| 批量操作 | `批量确认` | `取消` |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| 现有页面改动量大 | 分阶段实施，优先处理高频页面 |
| 组件API设计不合理 | 先在小范围试用再推广 |
| 样式调整影响布局 | 使用 CSS Modules 避免污染 |

## Migration Plan

1. **第一阶段**：创建通用组件库 (`frontend/src/components/CommonModal/`)
2. **第二阶段**：按模块逐步重构现有页面
3. **第三阶段**：添加 ESLint 规则强制规范

## Open Questions

- 是否需要支持自定义弹框的 header/footer 插槽？
- 移动端适配是否需要单独规范？
