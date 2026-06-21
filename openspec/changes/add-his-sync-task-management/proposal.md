# 方案：增加HIS数据同步任务管理功能

## 概述

为HIS数据模块增加**同步任务管理**前端菜单，支持：
1. **手动同步** - 立即执行增量/全量同步
2. **自动同步配置** - 配置定时任务（每天0点、每小时等）
3. **同步监控** - 查看同步状态、日志、执行历史

## 现有代码分析

### 后端已有能力
- `SyncEngine.cls` 已实现：
  - `IncrementalSync` - 增量同步（回溯N天）
  - `FullSync` - 全量同步（指定日期范围）
  - `GetLastSyncTime` / `UpdateLastSyncTime` - 同步时间管理
  - `SaveSyncLog` - 同步日志保存

- `Interface.cls` 已有接口：
  - `02010067` - 获取HIS住院患者数据
  - `02010075` - 查询已同步患者
  - `02010076` - 查询患者详情
  - `02010077` - 查询同步日志

### 前端已有页面
- `DataSync.tsx` - 数据同步监控（基础的手动同步）
- `SyncedPatients.tsx` - 已同步患者查询
- `SyncLog.tsx` - 同步日志查询

## 新增/修改内容

### 1. 后端新增接口服务

#### 新增接口类方法 (`Interface.cls`)

| 接口码 | 方法名 | 说明 |
|--------|--------|------|
| 02010078 | `ExecuteSyncTask` | 手动执行同步任务（增量/全量） |
| 02010079 | `GetSyncConfig` | 查询同步配置 |
| 02010080 | `SaveSyncConfig` | 保存同步配置（频率、类型等） |
| 02010081 | `GetSyncStatus` | 查询同步状态（最后同步时间、是否正在同步） |

#### 新增服务类 (`SyncTaskService.cls`)

```objectscript
Class src.DRG.HISData.SyncTaskService Extends (%RegisteredObject, %XML.Adaptor)
{
    /// 执行同步任务（接口02010078）
    /// pParams: {"syncType":"incremental|full", "startDate":"", "endDate":""}
    ClassMethod ExecuteSyncTask(jsonObj) As %Library.DynamicObject
    
    /// 查询同步配置（接口02010079）
    ClassMethod GetSyncConfig(jsonObj) As %Library.DynamicObject
    
    /// 保存同步配置（接口02010080）
    ClassMethod SaveSyncConfig(jsonObj) As %Library.DynamicObject
    
    /// 查询同步状态（接口02010081）
    ClassMethod GetSyncStatus(jsonObj) As %Library.DynamicObject
}
```

#### 同步配置表 (`BSHISSyncConfig`)

```objectscript
Class User.BSHISSyncConfig Extends (%Persistent)
{
    Property HospID As %String;          // 医院ID
    Property SyncType As %String;      // 同步类型：incremental/full
    Property Frequency As %String;     // 频率：manual/hourly/daily/weekly
    Property ScheduledTime As %String; // 定时时间（daily: "00:00", weekly: "1,00:00"）
    Property LookbackDays As %Integer; // 增量同步回溯天数
    Property Enabled As %Boolean;     // 是否启用
    Property LastSyncTime As %TimeStamp; // 最后同步时间
    Property Status As %String;      // 状态：idle/running/error
}
```

### 2. 前端新增/修改页面

#### 修改 `DataSync.tsx` - 数据同步监控页面

**现有功能**：手动选择日期范围，调用02010067同步数据

**扩展功能**：
1. 同步类型选择：增量同步 / 全量同步
2. 增量同步：自动计算回溯日期
3. 全量同步：选择日期范围
4. 显示当前同步状态（正在同步/空闲/错误）
5. 显示最后同步时间
6. 同步进度显示

#### 新增 `SyncTaskConfig.tsx` - 同步任务配置页面

**功能**：
1. 同步类型配置：
   - 增量同步：配置回溯天数（默认3天）
   - 全量同步：配置日期范围（或手动指定）
2. 同步频率配置：
   - 手动执行
   - 每小时
   - 每天0点
   - 每周（指定星期几）
   - 自定义Cron表达式
3. 启用/禁用同步任务
4. 保存配置

#### 修改 `SyncLog.tsx` - 同步日志查询（已存在，无需修改）

### 3. 菜单配置

在 `App.tsx` 的"HIS数据"菜单下添加：

```
HIS数据
├── 数据同步监控 (已有)
├── 同步任务配置 (新增)
├── 已同步患者查询 (已有)
└── 同步日志查询 (已有)
```

## 实现步骤

### 步骤1：创建同步配置表
- [ ] 创建 `User.BSHISSyncConfig` 类
- [ ] 添加必要字段和索引
- [ ] 编译表类

### 步骤2：开发后端服务类
- [ ] 创建 `src.DRG.HISData.SyncTaskService` 类
- [ ] 实现 `ExecuteSyncTask` 方法（调用SyncEngine）
- [ ] 实现 `GetSyncConfig` / `SaveSyncConfig` 方法
- [ ] 实现 `GetSyncStatus` 方法

### 步骤3：添加接口方法
- [ ] 修改 `src.DRG.HISData.Interface` 类
- [ ] 添加4个新接口方法（02010078-02010081）

### 步骤4：开发前端页面
- [ ] 修改 `DataSync.tsx` 扩展同步功能
- [ ] 新增 `SyncTaskConfig.tsx` 同步任务配置页面
- [ ] 更新API定义 `hisData.ts`

### 步骤5：配置菜单和路由
- [ ] 修改 `App.tsx` 添加菜单项
- [ ] 添加路由配置

### 步骤6：编译和测试
- [ ] 编译后端类
- [ ] 测试手动同步功能
- [ ] 测试同步配置保存
- [ ] 测试同步状态查询

## 文件清单

### 新增文件
1. `src/src/User/BSHISSyncConfig.cls` - 同步配置表类
2. `src/src/DRG/HISData/SyncTaskService.cls` - 同步任务服务类
3. `frontend/src/pages/HIS/SyncTaskConfig.tsx` - 同步任务配置页面
4. `frontend/src/api/hisData.ts` - 添加新接口API定义（修改）

### 修改文件
1. `src/src/DRG/HISData/Interface.cls` - 添加4个新接口方法
2. `frontend/src/pages/HIS/DataSync.tsx` - 扩展同步功能
3. `frontend/src/App.tsx` - 添加菜单和路由

## 接口设计

### 02010078 执行同步任务

**请求**：
```json
{
    "code": "02010078",
    "params": [{
        "syncType": "incremental",
        "lookbackDays": 3,
        "startDate": "",
        "endDate": ""
    }],
    "session": [{"hospID": "13"}]
}
```

**响应**：
```json
{
    "errorCode": "0",
    "errorMessage": "同步完成",
    "result": {
        "successCount": 10,
        "failedCount": 0,
        "totalCount": 10,
        "startTime": "2026-06-15 00:00:00",
        "endTime": "2026-06-16 11:58:00"
    }
}
```

### 02010079 查询同步配置

**请求**：
```json
{
    "code": "02010079",
    "params": [{"hospID": "13"}],
    "session": [{"hospID": "13"}]
}
```

**响应**：
```json
{
    "errorCode": "0",
    "errorMessage": "",
    "result": {
        "id": "1",
        "hospID": "13",
        "syncType": "incremental",
        "frequency": "daily",
        "scheduledTime": "00:00",
        "lookbackDays": 3,
        "enabled": true
    }
}
```

### 02010080 保存同步配置

**请求**：
```json
{
    "code": "02010080",
    "params": [{
        "id": "",
        "syncType": "incremental",
        "frequency": "daily",
        "scheduledTime": "00:00",
        "lookbackDays": 3,
        "enabled": true
    }],
    "session": [{"userID": "158", "hospID": "13"}]
}
```

### 02010081 查询同步状态

**请求**：
```json
{
    "code": "02010081",
    "params": [{"hospID": "13"}],
    "session": [{"hospID": "13"}]
}
```

**响应**：
```json
{
    "errorCode": "0",
    "errorMessage": "",
    "result": {
        "status": "idle",
        "lastSyncTime": "2026-06-15 00:00:00",
        "lastSyncStatus": "success",
        "nextSyncTime": "2026-06-17 00:00:00"
    }
}
```

## 前端页面设计

### DataSync.tsx（扩展后）

**布局**：
```
┌─────────────────────────────────────────────────────┐
│ 数据同步监控                                   │
├─────────────────────────────────────────────────────┤
│ [同步类型] 增量同步 ○  全量同步 ○          │
│ [增量选项] 回溯天数：[3] 天                      │
│ [全量选项] 开始日期：____  结束日期：____     │
│ [操作按钮] [立即同步] [刷新状态]               │
│ [状态显示] 最后同步：2026-06-15 00:00:00    │
│            当前状态：空闲                         │
│ [进度显示] █████████████░░ 80%                 │
│ [结果表格] 患者列表（调用02010067返回）      │
└─────────────────────────────────────────────────────┘
```

### SyncTaskConfig.tsx（新增）

**布局**：
```
┌─────────────────────────────────────────────────────┐
│ 同步任务配置                                   │
├─────────────────────────────────────────────────────┤
│ 同步类型配置：                                 │
│   □ 增量同步                                   │
│     回溯天数：[3] 天                          │
│   □ 全量同步                                   │
│     开始日期：____  结束日期：____            │
│                                                  │
│ 同步频率配置：                                 │
│   ○ 手动执行                                   │
│   ○ 每小时                                     │
│   ○ 每天  [00:00 ▼]                         │
│   ○ 每周  [周一 ▼] [00:00 ▼]              │
│   ○ 自定义Cron：[输入框]                     │
│                                                  │
│ □ 启用同步任务                                │
│                                                  │
│ [保存配置] [重置]                            │
│                                                  │
│ 当前配置：                                    │
│   类型：增量同步 | 频率：每天0点 | 状态：已启用│
└─────────────────────────────────────────────────────┘
```

## 数据库设计

### BS_HIS_SyncConfig 表

| 字段名 | 类型 | 说明 |
|--------|------|------|
| ID | %String | 主键 |
| HospID | %String | 医院ID |
| SyncType | %String | 同步类型：incremental/full |
| Frequency | %String | 频率：manual/hourly/daily/weekly/custom |
| ScheduledTime | %String | 定时时间 |
| LookbackDays | %Integer | 增量同步回溯天数 |
| StartDate | %Date | 全量同步开始日期 |
| EndDate | %Date | 全量同步结束日期 |
| Enabled | %Boolean | 是否启用 |
| LastSyncTime | %TimeStamp | 最后同步时间 |
| Status | %String | 状态：idle/running/error |
| ErrorMessage | %String | 错误信息 |
| CreateUserDr | %String | 创建用户 |
| CreateDate | %Date | 创建日期 |
| UpdateUserDr | %String | 更新用户 |
| UpdateDate | %Date | 更新日期 |

## 后续扩展

1. **定时任务执行器** - 使用IRIS Task Manager或Cron执行定时同步
2. **同步通知** - 同步失败时发送通知
3. **同步统计** - 统计同步成功率、数据量等
4. **多医院支持** - 支持为不同医院配置不同同步策略

## 风险与注意事项

1. **并发控制** - 防止同一医院同时执行多个同步任务
2. **性能影响** - 全量同步可能大量调用HIS接口，需考虑限流
3. **数据一致性** - 同步失败时的回滚策略
4. **权限控制** - 同步配置需要管理员权限
