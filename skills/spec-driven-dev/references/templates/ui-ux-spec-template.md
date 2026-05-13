# UI/UX 规范模板

> 阶段 4 模板：用户界面与体验标准

---

## 文档信息

| 字段 | 值 |
|------|-----|
| 项目名称 | `{项目名称}` |
| 版本 | `1.0.0` |
| 创建日期 | `{日期}` |

---

## 1. 设计系统概述

### 1.1 设计原则

| 原则 | 描述 | 应用方式 |
|------|------|----------|
| 清晰性 | 清晰的视觉层级 | 使用一致的间距和排版 |
| 高效性 | 最小化用户操作 | 智能默认值、快捷键 |
| 一致性 | 可预测的模式 | 可复用组件 |
| 无障碍 | 包容性设计 | WCAG 2.1 AA 合规 |

### 1.2 品牌个性

| 属性 | 描述 |
|------|------|
| 调性 | 专业 / 友好 / 活泼 |
| 语气 | 直接 / 对话式 / 技术性 |
| 风格 | 极简 / 丰富 / 插画 |

---

## 2. 色彩系统

### 2.1 主色调

| 令牌 | 亮色模式 | 暗色模式 | 用途 |
|------|----------|----------|------|
| `--color-primary` | `#3B82F6` | `#60A5FA` | 主要操作、链接 |
| `--color-primary-hover` | `#2563EB` | `#93C5FD` | 悬停状态 |
| `--color-primary-active` | `#1D4ED8` | `#BFDBFE` | 激活/按下 |

### 2.2 语义色

| 令牌 | 亮色 | 暗色 | 用途 |
|------|------|------|------|
| `--color-success` | `#10B981` | `#34D399` | 成功状态 |
| `--color-warning` | `#F59E0B` | `#FBBF24` | 警告状态 |
| `--color-error` | `#EF4444` | `#F87171` | 错误状态 |
| `--color-info` | `#3B82F6` | `#60A5FA` | 信息提示 |

### 2.3 中性色

| 令牌 | 亮色 | 暗色 | 用途 |
|------|------|------|------|
| `--color-background` | `#FFFFFF` | `#111827` | 页面背景 |
| `--color-surface` | `#F9FAFB` | `#1F2937` | 卡片背景 |
| `--color-text-primary` | `#111827` | `#F9FAFB` | 主要文本 |
| `--color-text-secondary` | `#6B7280` | `#9CA3AF` | 次要文本 |
| `--color-border` | `#E5E7EB` | `#374151` | 边框、分割线 |

### 2.4 颜色使用规范

```css
/* 正确用法 */
.button-primary {
  background-color: var(--color-primary);
  color: var(--color-text-on-primary);
}

/* 避免硬编码颜色 */
.button-bad {
  background-color: #3B82F6; /* 不要这样做 */
}
```

---

## 3. 排版系统

### 3.1 字体族

| 令牌 | 字体 | 回退字体 | 用途 |
|------|------|----------|------|
| `--font-heading` | Inter | system-ui, sans-serif | 标题 |
| `--font-body` | Inter | system-ui, sans-serif | 正文 |
| `--font-mono` | JetBrains Mono | monospace | 代码 |

### 3.2 字号层级

| 令牌 | 字号 | 行高 | 字重 | 用途 |
|------|------|------|------|------|
| `--text-xs` | 12px | 16px | 400 | 说明文字、标签 |
| `--text-sm` | 14px | 20px | 400 | 小号正文、元信息 |
| `--text-base` | 16px | 24px | 400 | 正文 |
| `--text-lg` | 18px | 28px | 400 | 引导段落 |
| `--text-xl` | 20px | 28px | 500 | 小标题 |
| `--text-2xl` | 24px | 32px | 600 | H3 |
| `--text-3xl` | 30px | 36px | 700 | H2 |
| `--text-4xl` | 36px | 40px | 800 | H1 |

### 3.3 排版示例

```html
<h1 class="text-4xl font-extrabold">页面标题</h1>
<h2 class="text-3xl font-bold">章节标题</h2>
<h3 class="text-2xl font-semibold">小节标题</h3>
<p class="text-base">正文段落内容。</p>
<span class="text-sm text-secondary">2 小时前更新</span>
```

---

## 4. 间距系统

### 4.1 间距层级

| 令牌 | 值 | 像素 | 用途 |
|------|-----|------|------|
| `--space-0` | 0 | 0px | 无间距 |
| `--space-1` | 0.25rem | 4px | 紧凑间距 |
| `--space-2` | 0.5rem | 8px | 小间距 |
| `--space-3` | 0.75rem | 12px | 中等间距 |
| `--space-4` | 1rem | 16px | 标准内边距 |
| `--space-6` | 1.5rem | 24px | 区块内边距 |
| `--space-8` | 2rem | 32px | 大区块 |
| `--space-12` | 3rem | 48px | 页面区块 |
| `--space-16` | 4rem | 64px | 主要区块 |

### 4.2 栅格系统

| 断点 | 列数 | 间距 | 边距 |
|------|------|------|------|
| 移动端 (<640px) | 4 | 16px | 16px |
| 平板 (640-1024px) | 8 | 24px | 24px |
| 桌面 (>1024px) | 12 | 24px | 32px |

---

## 5. 组件库

### 5.1 按钮

#### 按钮变体

| 变体 | 用途 | 样式 |
|------|------|------|
| 主要 | 主要操作 | 主色填充 |
| 次要 | 备选操作 | 描边 |
| 幽灵 | 第三操作 | 无边框/背景 |
| 危险 | 危险操作 | 错误色填充 |

#### 按钮尺寸

| 尺寸 | 高度 | 内边距 | 字号 |
|------|------|--------|------|
| 小 | 32px | 8px 12px | 14px |
| 中 | 40px | 10px 16px | 14px |
| 大 | 48px | 12px 24px | 16px |

#### 按钮状态

| 状态 | 视觉效果 |
|------|----------|
| 默认 | 标准外观 |
| 悬停 | 变暗 10%，指针光标 |
| 激活 | 变暗 20% |
| 禁用 | 透明度 50%，无交互 |
| 加载中 | 旋转图标，禁用 |

```html
<button class="btn btn-primary btn-medium">
  主要按钮
</button>
<button class="btn btn-secondary btn-medium">
  次要按钮
</button>
<button class="btn btn-danger btn-medium" disabled>
  禁用按钮
</button>
```

### 5.2 表单控件

#### 输入框

| 状态 | 边框颜色 | 背景 |
|------|----------|------|
| 默认 | `--color-border` | `--color-background` |
| 聚焦 | `--color-primary` | `--color-background` |
| 错误 | `--color-error` | `#FEF2F2` |
| 禁用 | `--color-border` | `--color-surface` |

```html
<div class="form-group">
  <label class="form-label">邮箱地址</label>
  <input type="email" class="form-input" placeholder="you@example.com" />
  <span class="form-helper">我们不会分享您的邮箱。</span>
</div>

<div class="form-group has-error">
  <label class="form-label">密码</label>
  <input type="password" class="form-input" />
  <span class="form-error">密码至少需要 8 个字符。</span>
</div>
```

### 5.3 卡片

```html
<div class="card">
  <div class="card-header">
    <h3 class="card-title">卡片标题</h3>
    <p class="card-description">可选的描述文字。</p>
  </div>
  <div class="card-content">
    <!-- 卡片内容 -->
  </div>
  <div class="card-footer">
    <button class="btn btn-primary">操作</button>
  </div>
</div>
```

### 5.4 导航

| 组件 | 用途 |
|------|------|
| 顶部导航 | 主应用导航 |
| 侧边导航 | 二级/上下文导航 |
| 面包屑 | 位置感知 |
| 标签页 | 内容组织 |

---

## 6. 响应式设计

### 6.1 断点

| 名称 | 最小宽度 | 目标设备 |
|------|----------|----------|
| `sm` | 640px | 大屏手机、横屏 |
| `md` | 768px | 平板 |
| `lg` | 1024px | 小型笔记本 |
| `xl` | 1280px | 桌面 |
| `2xl` | 1536px | 大屏幕 |

### 6.2 响应式模式

| 模式 | 用途 | 示例 |
|------|------|------|
| 重排 | 移动端堆叠 | 栅格 → 弹性列 |
| 显示/隐藏 | 条件显示 | 导航菜单 → 汉堡菜单 |
| 缩放 | 尺寸调整 | 字号、间距 |

```css
/* 移动优先响应式 */
.container {
  padding: var(--space-4);
}

@media (min-width: 768px) {
  .container {
    padding: var(--space-6);
  }
}

@media (min-width: 1024px) {
  .container {
    padding: var(--space-8);
    max-width: 1200px;
  }
}
```

---

## 7. 无障碍

### 7.1 WCAG 2.1 AA 要求

| 要求 | 实现方式 |
|------|----------|
| 颜色对比度 | 文本 4.5:1，大文本 3:1 |
| 焦点指示器 | 所有交互元素可见焦点环 |
| 键盘导航 | 所有功能可通过键盘访问 |
| 屏幕阅读器支持 | ARIA 标签、语义化 HTML |
| 动画 | 尊重 `prefers-reduced-motion` |

### 7.2 焦点管理

```css
/* 焦点环 */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

/* 跳过链接 */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  padding: var(--space-2) var(--space-4);
  background: var(--color-primary);
  color: white;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
```

### 7.3 ARIA 模式

```html
<!-- 带加载状态的按钮 -->
<button aria-busy="true" aria-live="polite">
  <span class="sr-only">加载中...</span>
  <span aria-hidden="true" class="spinner"></span>
</button>

<!-- 带错误的表单 -->
<div role="alert" class="form-error">
  请修正下面的错误。
</div>
```

---

## 8. 交互模式

### 8.1 加载状态

| 状态 | 指示器 | 用途 |
|------|--------|------|
| 骨架屏 | 占位形状 | 初始页面加载 |
| 旋转器 | 旋转图标 | 操作进行中 |
| 进度条 | 填充条 | 文件上传、多步骤 |

### 8.2 反馈消息

| 类型 | 持续时间 | 位置 |
|------|----------|------|
| 成功提示 | 3 秒 | 右上角 |
| 错误提示 | 5 秒（或手动关闭） | 右上角 |
| 信息提示 | 4 秒 | 右上角 |

### 8.3 动画

| 动画 | 时长 | 缓动函数 |
|------|------|----------|
| 快速 | 150ms | ease-out |
| 正常 | 250ms | ease-in-out |
| 慢速 | 400ms | ease-in-out |

```css
/* 减少动画 */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 9. 页面布局

### 9.1 页面模板

#### 仪表盘布局

```
┌─────────────────────────────────────────────┐
│ 顶部栏（Logo、导航、用户菜单）                │
├──────────┬──────────────────────────────────┤
│          │                                  │
│ 侧边栏   │     主内容区                      │
│          │                                  │
│          │  ┌─────────┐ ┌─────────┐        │
│          │  │ 卡片 1  │ │ 卡片 2  │        │
│          │  └─────────┘ └─────────┘        │
│          │                                  │
├──────────┴──────────────────────────────────┤
│ 底部栏                                      │
└─────────────────────────────────────────────┘
```

#### 表单布局

```
┌─────────────────────────────────────────────┐
│ 页面头部                                    │
│ 标题 + 描述                                 │
├─────────────────────────────────────────────┤
│                                             │
│  表单区块 1                                 │
│  ┌─────────────────────────────────────────┐│
│  │ 字段 1    │ 字段 2                      ││
│  │ 字段 3                                 ││
│  └─────────────────────────────────────────┘│
│                                             │
│  表单区块 2                                 │
│  ┌─────────────────────────────────────────┐│
│  │ ...                                     ││
│  └─────────────────────────────────────────┘│
│                                             │
│  [取消]                        [保存]       │
└─────────────────────────────────────────────┘
```

---

## 10. 图标系统

### 10.1 图标库

| 库 | 用途 |
|------|------|
| Heroicons | 主要图标集 |
| Lucide | 扩展图标 |

### 10.2 图标尺寸

| 尺寸 | 像素 | 用途 |
|------|------|------|
| 小 | 16x16 | 行内、徽章 |
| 中 | 20x20 | 按钮、导航 |
| 大 | 24x24 | 功能图标 |

### 10.3 图标用法

```html
<!-- 带标签 -->
<button class="btn btn-primary">
  <svg class="icon icon-sm"><!-- 图标 SVG --></svg>
  <span>保存</span>
</button>

<!-- 仅图标（带无障碍标签） -->
<button class="btn btn-ghost" aria-label="设置">
  <svg class="icon icon-md"><!-- 图标 SVG --></svg>
</button>
```

---

## 11. 错误处理界面

### 11.1 错误状态

| 状态 | 视觉效果 | 消息 |
|------|----------|------|
| 表单错误 | 红色边框 + 图标 | 具体错误信息 |
| 页面错误 | 插图 + 文字 | "出错了" |
| 空状态 | 插图 + 文字 | "暂无数据" |
| 离线状态 | 横幅 | "您已离线" |

### 11.2 空状态

```html
<div class="empty-state">
  <img src="empty-illustration.svg" alt="" class="empty-state-image" />
  <h3 class="empty-state-title">暂无数据</h3>
  <p class="empty-state-description">
    点击下方按钮创建第一条数据。
  </p>
  <button class="btn btn-primary">创建数据</button>
</div>
```

---

## 校验清单

- [ ] 颜色令牌覆盖所有 UI 需求
- [ ] 字号层级一致
- [ ] 间距遵循定义的系统
- [ ] 所有组件有文档化的状态
- [ ] 响应式断点已测试
- [ ] 无障碍要求已满足
- [ ] 动画尊重用户偏好
- [ ] 错误状态已设计
