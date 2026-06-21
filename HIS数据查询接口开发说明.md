# HIS数据查询接口开发说明

## 概述
本次开发为HIS数据模块添加了后端查询接口服务和前端页面功能，包括：
1. 已同步患者信息查询（接口02010075）
2. 患者详情查询（接口02010076）
3. 同步日志查询（接口02010077）

## 后端修改

### 1. HisDataService.cls
文件位置：`src/src/DRG/HISData/HisDataService.cls`

新增方法：
- **QuerySyncedPatients** (接口02010075)
  - 功能：查询已同步患者列表
  - 筛选条件：患者姓名、病案号、就诊日期范围
  - 返回：分页的患者列表（包含主诊断、主手术信息）

- **QueryPatientDetail** (接口02010076)
  - 功能：查询患者详情
  - 包含：就诊信息、诊断列表、手术列表
  - 参数：admID（就诊ID）

- **QuerySyncLogs** (接口02010077)
  - 功能：查询同步日志列表
  - 筛选条件：同步类型、状态、日期范围
  - 返回：分页的同步日志列表

### 2. Interface.cls
文件位置：`src/src/DRG/HISData/Interface.cls`

新增接口方法：
- `GetSyncedPatients` (02010075) - 调用QuerySyncedPatients
- `GetPatientDetail` (02010076) - 调用QueryPatientDetail
- `GetSyncLogs` (02010077) - 调用QuerySyncLogs

## 前端修改

### 1. hisData.ts（API接口定义）
文件位置：`frontend/src/api/hisData.ts`

新增接口定义：
- `queryPatientDetail` - 查询患者详情（02010076）
- `querySyncLogs` - 查询同步日志（02010077）
- 相关TypeScript接口：`PatientDetail`, `SyncLogItem`, `QuerySyncLogsParams`

### 2. SyncedPatients.tsx（已同步患者查询页面）
文件位置：`frontend/src/pages/HIS/SyncedPatients.tsx`

修改内容：
- 导入`queryPatientDetail` API
- 更新"详情"按钮功能，调用新的详情接口
- 详情弹窗使用Tabs展示：
  - 就诊信息（就诊号、病案号、患者姓名、性别、科室等）
  - 诊断信息（诊断列表，包含诊断编码、名称、主诊断标志）
  - 手术信息（手术列表，包含手术编码、名称、主手术标志）

### 3. SyncLog.tsx（同步日志查询页面 - 新增）
文件位置：`frontend/src/pages/HIS/SyncLog.tsx`

功能：
- 筛选条件：同步类型（增量/全量/手动）、状态（成功/失败/部分成功）、日期范围
- 表格显示：任务名称、同步类型、状态、开始时间、结束时间、总数、成功数、失败数、错误信息
- 支持分页

### 4. App.tsx（路由和菜单配置）
文件位置：`frontend/src/App.tsx`

修改内容：
- 导入SyncLog组件
- 添加路由case：`'data-sync-log'` → `<SyncLog />`
- 添加菜单配置：`'data-sync-log': '同步日志查询'`
- 在"HIS数据"菜单下添加子菜单：
  - 已同步患者查询
  - 同步日志查询

## 数据库表结构

涉及的表：
1. **BS_HIS_PatAdm** - 就诊信息表
2. **BS_HIS_DiseInfo** - 诊断信息表
3. **BS_HIS_OprnInfo** - 手术信息表
4. **BS_HIS_SyncLog** - 同步日志表
5. **BS_HISDRGParams** - DRG参数表（用于获取总费用）

## 编译说明

### 后端编译
在IRIS终端中执行：
```objectscript
Do $System.OBJ.Compile("src.DRG.HISData.HisDataService,src.DRG.HISData.Interface","ck")
```

或使用提供的编译脚本：`scripts/compile_his_data.cls.sql`

## 测试建议

### 1. 测试已同步患者查询（02010075）
- 不传筛选条件，查询所有已同步患者
- 按患者姓名筛选
- 按病案号筛选
- 按就诊日期范围筛选
- 测试分页功能

### 2. 测试患者详情查询（02010076）
- 查询存在的患者详情
- 验证就诊信息是否正确
- 验证诊断列表是否正确（包括主诊断标志）
- 验证手术列表是否正确（包括主手术标志）
- 测试不存在的admID，应返回错误

### 3. 测试同步日志查询（02010077）
- 不传筛选条件，查询所有同步日志
- 按同步类型筛选
- 按状态筛选
- 按日期范围筛选
- 测试分页功能

### 4. 前端页面测试
- 访问"已同步患者查询"页面，验证查询和详情功能
- 访问"同步日志查询"页面，验证查询和筛选功能
- 验证日期组件显示中文
- 验证分页组件工作正常

## 注意事项

1. **日期格式**：前端传递的日期格式为`YYYY-MM-DD`，后端需正确解析
2. **分页**：后端使用`LIMIT`和`OFFSET`实现分页（IRIS 2019+支持）
3. **模糊查询**：患者姓名和病案号使用`LIKE`进行模糊查询
4. **菜单权限**：根据实际需要配置菜单权限

## 后续优化建议

1. 添加导出功能（导出患者列表、同步日志）
2. 添加同步日志详情查看功能
3. 添加手动触发同步功能
4. 优化查询性能（添加必要索引）
