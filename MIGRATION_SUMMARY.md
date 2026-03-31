# 前端页面迁移总结

## 迁移概述

将 `frontend` 项目中的前端菜单页面复制添加到 `frontend-云HIS` 项目中，按照云HIS的技术栈实现。

## 已完成工作

### 1. 目录结构创建

在 `frontend-云HIS/src/pages/` 下创建了以下目录：
- `drg/` - DRG业务页面
- `dip/` - DIP业务页面
- `warning/` - 费用预警页面
- `profit/` - 盈亏分析页面
- `system/` - 系统管理页面

### 2. 已迁移页面

#### DRG业务
- **DrgWorkbench.jsx** - DRG分组工作台
  - 病案列表查询
  - DRG分组功能
  - 分组结果展示
  - 病案详情查看

#### 费用预警
- **WarningCenter.jsx** - 预警监控中心
  - 预警统计卡片
  - 预警列表查询
  - 预警处理功能
  - 多级别预警展示

#### 盈亏分析
- **ProfitAnalysis.jsx** - 盈亏分析
  - 科室盈亏统计
  - 收入成本分析
  - 盈亏率计算
  - 数据可视化

### 3. 路由配置更新

在 `frontend-云HIS/src/routes/index.jsx` 中添加了新的路由：

```javascript
{
    label: 'DRG分组工作台',
    key: '/drg/workbench',
    path: '/drg/workbench',
    element: lazy(() => import('@pages/drg/DrgWorkbench.jsx')),
    icon: 'PartitionOutlined',
    ...
}
```

### 4. 技术栈适配

#### 从 TypeScript 迁移到 JavaScript
- 移除了类型定义 (interface, type)
- 修改了文件扩展名 (.tsx → .jsx)
- 保留了组件逻辑和功能

#### API调用适配
**frontend:**
```typescript
const res = await request({ url: '/api/xxx', method: 'POST', data });
```

**frontend-云HIS:**
```javascript
const res = await React.$asyncPost('接口代码', { params: [data] });
```

#### 状态管理适配
**frontend-云HIS 特有:**
```javascript
const userData = React.$getUserData();
const { contentHeight } = store.getState();
```

#### 样式规范统一
- 使用云HIS的样式规范
- 统一使用 `size="small"` 的紧凑布局
- 使用 `contentHeight` 自适应高度

## 待完成页面

### DRG业务
- [ ] DrgCustomQuery.jsx - DRG分组器
- [ ] DrgResults.jsx - 分组结果查询

### DIP业务
- [ ] DipWorkbench.jsx - DIP分组工作台
- [ ] DipDiseaseQuery.jsx - 病种分值查询

### 费用预警
- [ ] WarningRules.jsx - 预警规则配置
- [ ] WarningRecords.jsx - 预警处理记录

### 盈亏分析
- [ ] ProfitDoctor.jsx - 医生盈亏分析
- [ ] ProfitDisease.jsx - 病种盈亏统计

### 系统管理
- [ ] SystemUsers.jsx - 用户管理
- [ ] SystemRoles.jsx - 角色权限
- [ ] SystemMenus.jsx - 菜单配置
- [ ] SystemInterfaces.jsx - 接口服务配置
- [ ] SystemInterfaceLogs.jsx - 接口日志

## 文件清单

### 新增文件
```
frontend-云HIS/src/pages/
├── drg/
│   └── DrgWorkbench.jsx
├── dip/
│   └── (待创建)
├── warning/
│   └── WarningCenter.jsx
├── profit/
│   └── ProfitAnalysis.jsx
├── system/
│   └── (待创建)
├── MIGRATION_GUIDE.md
└── (其他页面待创建)
```

### 修改文件
```
frontend-云HIS/src/routes/index.jsx
```

## 接口映射

| 功能 | frontend 接口 | frontend-云HIS 接口 |
|------|--------------|-------------------|
| DRG分组 | POST /api/drg/group | 02010001 |
| 病案查询 | POST /api/medical/records | 4100 |
| 预警查询 | POST /api/warning/list | 4200 |
| 盈亏分析 | POST /api/profit/analysis | 4300 |

## 后续工作建议

1. **完成剩余页面迁移**
   - 按照已创建的示例页面模式
   - 参考 MIGRATION_GUIDE.md 文档

2. **接口对接**
   - 确认后端接口代码
   - 调整请求参数格式
   - 处理接口返回数据

3. **权限控制**
   - 添加页面级权限
   - 添加按钮级权限
   - 集成角色权限系统

4. **测试验证**
   - 功能测试
   - 性能测试
   - 兼容性测试

5. **优化改进**
   - 代码优化
   - 性能优化
   - 用户体验优化

## 注意事项

1. **接口适配**
   - 当前页面使用模拟数据
   - 需要根据实际情况调整接口调用

2. **样式调整**
   - 可能需要根据实际需求调整样式
   - 确保与云HIS整体风格一致

3. **功能完善**
   - 部分高级功能可能需要额外开发
   - 如动态表单、复杂查询等

## 参考文档

- `frontend-云HIS/src/pages/MIGRATION_GUIDE.md` - 详细迁移指南
- `frontend/src/pages/` - 源项目页面参考
- `frontend-云HIS/src/pages/basicData/BasicTableDataMaintenance.jsx` - 云HIS示例页面
