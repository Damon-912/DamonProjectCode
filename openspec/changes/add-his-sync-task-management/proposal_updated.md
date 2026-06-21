# 方案：增加HIS数据同步任务管理功能（更新版）

## 修改说明
将所有 `hospID` 改为 `hospCode`，用于关联和记录同步HIS所属的医院信息，
通过 `hospCode` 与 `CB_Hospital` 表中的 `Code` 字段关联。

## 概述

为HIS数据模块增加**同步任务管理**前端菜单，支持：
1. **手动同步** - 立即执行增量/全量同步
2. **自动同步配置** - 配置定时任务（每天0点、每小时等）
3. **同步监控** - 查看同步状态、日志、执行历史

## 数据库设计

### 1. BS_HIS_SyncConfig 表（新增）

| 字段名 | 类型 | 说明 |
|--------|------|------|
| ID | %String | 主键 |
| HospCode | %String | 医院代码（关联CB_Hospital.Code） |
| SyncType | %String | 同步类型：incremental/full |
| Frequency | %String | 频率：manual/hourly/daily/weekly |
| ScheduledTime | %String | 定时时间（daily: "00:00", weekly: "1,00:00"） |
| LookbackDays | %Integer | 增量同步回溯天数 |
| Enabled | %Boolean | 是否启用 |
| LastSyncTime | %TimeStamp | 最后同步时间 |
| Status | %String | 状态：idle/running/error |
| ErrorMessage | %String | 错误信息 |
| CreateUserDr | %String | 创建用户 |
| CreateDate | %Date | 创建日期 |
| UpdateUserDr | %String | 更新用户 |
| UpdateDate | %Date | 更新日期 |

**索引**：
- `HospCodeIndex` On HospCode As Exact
- `EnabledIndex` On Enabled As Exact

### 2. BS_HIS_PatAdm 表（修改）

已添加字段：
- `FixmedinsCode` - 医疗机构代码
- `FixmedinsName` - 医疗机构名称

### 3. 关联说明

所有同步配置、日志、患者数据均通过 `HospCode` 关联所属医院：
- `BS_HIS_SyncConfig.HospCode` → `CB_Hospital.Code`
- `BS_HIS_PatAdm.FixmedinsCode` → `CB_Hospital.Code`

## 后端新增接口服务

### Interface.cls 新增接口方法

| 接口码 | 方法名 | 说明 |
|--------|--------|------|
| 02010078 | `ExecuteSyncTask` | 手动执行同步任务（增量/全量） |
| 02010079 | `GetSyncConfig` | 查询同步配置 |
| 02010080 | `SaveSyncConfig` | 保存同步配置（频率、类型等） |
| 02010081 | `GetSyncStatus` | 查询同步状态（最后同步时间、是否正在同步） |

### 新增服务类 (SyncTaskService.cls)

```objectscript
Class src.DRG.HISData.SyncTaskService Extends (%RegisteredObject, %XML.Adaptor)
{
    /// 执行同步任务（接口02010078）
    ClassMethod ExecuteSyncTask(jsonObj) As %Library.DynamicObject
    {
        // 从jsonObj.params获取：syncType, hospCode, lookbackDays, startDate, endDate
        // 调用 SyncEngine.IncrementalSync 或 FullSync
    }
    
    /// 查询同步配置（接口02010079）
    ClassMethod GetSyncConfig(jsonObj) As %Library.DynamicObject
    {
        // 从jsonObj.params获取：hospCode
        // 查询 BS_HIS_SyncConfig 表
    }
    
    /// 保存同步配置（接口02010080）
    ClassMethod SaveSyncConfig(jsonObj) As %Library.DynamicObject
    {
        // 从jsonObj.params获取配置信息
        // 保存到 BS_HIS_SyncConfig 表
    }
    
    /// 查询同步状态（接口02010081）
    ClassMethod GetSyncStatus(jsonObj) As %Library.DynamicObject
    {
        // 从jsonObj.params获取：hospCode
        // 查询最后同步时间、状态等
    }
}
```

## 前端新增/修改页面

### 1. 修改 DataSync.tsx - 数据同步监控页面

**扩展功能**：
1. 同步类型选择：增量同步 / 全量同步
2. 增量同步：自动计算回溯日期（使用 hospCode 获取配置）
3. 全量同步：选择日期范围
4. 显示当前同步状态（正在同步/空闲/错误）
5. 显示最后同步时间
6. 同步进度显示
7. **医院选择**：下拉选择医院（从CB_Hospital表查询）

### 2. 新增 SyncTaskConfig.tsx - 同步任务配置页面

**功能**：
1. 医院选择：选择要配置的医院（hospCode）
2. 同步类型配置：
   - 增量同步：配置回溯天数（默认3天）
   - 全量同步：配置日期范围（或手动指定）
3. 同步频率配置：
   - 手动执行
   - 每小时
   - 每天0点
   - 每周（指定星期几）
   - 自定义Cron表达式
4. 启用/禁用同步任务
5. 保存配置

### 3. 修改 SyncLog.tsx - 同步日志查询（已存在，无需修改）

### 4. 修改 SyncedPatients.tsx - 已同步患者查询（已存在，添加医院筛选）

## 菜单配置

在 `App.tsx` 的"HIS数据"菜单下添加：

```
HIS数据
├── 数据同步监控 (已有，扩展功能)
├── 同步任务配置 (新增)
├── 已同步患者查询 (已有，添加医院筛选)
└── 同步日志查询 (已有)
```

## 实现步骤

### 步骤1：创建同步配置表
- [ ] 创建 `User.BSHISSyncConfig` 类
- [ ] 添加必要字段和索引（HospCode字段）
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
- [ ] 修改 `DataSync.tsx` 扩展同步功能（添加医院选择）
- [ ] 新增 `SyncTaskConfig.tsx` 同步任务配置页面
- [ ] 更新API定义 `hisData.ts`
- [ ] 修改 `SyncedPatients.tsx` 添加医院筛选

### 步骤5：配置菜单和路由
- [ ] 修改 `App.tsx` 添加菜单项
- [ ] 添加路由配置

### 步骤6：编译和测试
- [ ] 编译后端类
- [ ] 测试手动同步功能
- [ ] 测试同步配置保存
- [ ] 测试同步状态查询

## 接口设计（更新后）

### 02010078 执行同步任务

**请求**：
```json
{
    "code": "02010078",
    "params": [{
        "hospCode": "H34010400768",
        "syncType": "incremental",
        "lookbackDays": 3,
        "startDate": "",
        "endDate": ""
    }],
    "session": [{"userID": "158", "hospCode": "H34010400768"}]
}
```

### 02010079 查询同步配置

**请求**：
```json
{
    "code": "02010079",
    "params": [{"hospCode": "H34010400768"}],
    "session": [{"hospCode": "H34010400768"}]
}
```

**响应**：
```json
{
    "errorCode": "0",
    "errorMessage": "",
    "result": {
        "id": "1",
        "hospCode": "H34010400768",
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
        "hospCode": "H34010400768",
        "syncType": "incremental",
        "frequency": "daily",
        "scheduledTime": "00:00",
        "lookbackDays": 3,
        "enabled": true
    }],
    "session": [{"userID": "158", "hospCode": "H34010400768"}]
}
```

### 02010081 查询同步状态

**请求**：
```json
{
    "code": "02010081",
    "params": [{"hospCode": "H34010400768"}],
    "session": [{"hospCode": "H34010400768"}]
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
        "nextSyncTime": "2026-06-17 00:00:00",
        "hospCode": "H34010400768",
        "hospName": "合肥普瑞眼科医院"
    }
}
```

## 关键修改点总结

1. **所有 hospID → hospCode**
   - 数据库表字段：HospID → HospCode
   - 接口参数：hospID → hospCode
   - 前端参数：hospID → hospCode
   
2. **关联 CB_Hospital 表**
   - 使用 `HospCode` 关联 `CB_Hospital.Code`
   - 查询医院信息时同时获取医院名称
   
3. **前端医院选择**
   - 添加医院下拉选择框
   - 从 CB_Hospital 表查询可用医院列表
   - 选择医院后，hospCode 自动填充

## 文件清单

### 新增文件
1. `src/src/User/BSHISSyncConfig.cls` - 同步配置表类
2. `src/src/DRG/HISData/SyncTaskService.cls` - 同步任务服务类
3. `frontend/src/pages/HIS/SyncTaskConfig.tsx` - 同步任务配置页面

### 修改文件
1. `src/src/DRG/HISData/Interface.cls` - 添加4个新接口方法
2. `src/src/User/BSHISPatAdm.cls` - 已添加FixmedinsCode/Name字段
3. `frontend/src/pages/HIS/DataSync.tsx` - 扩展同步功能（添加医院选择）
4. `frontend/src/pages/HIS/SyncedPatients.tsx` - 添加医院筛选
5. `frontend/src/App.tsx` - 添加菜单和路由
6. `frontend/src/api/hisData.ts` - 添加新接口API定义

## 编译说明

### 后端编译
```objectscript
// 编译表类（添加新字段和表）
Do $System.OBJ.Compile("User.BSHISPatAdm,User.BSHISSyncConfig","ck")

// 编译服务类和接口类
Do $System.OBJ.Compile("src.DRG.HISData.HisDataService,src.DRG.HISData.SyncTaskService,src.DRG.HISData.Interface","ck")
```

### 前端启动
```bash
cd frontend
npm start
```

## 测试计划

1. **测试医院关联**：
   - 调用接口02010067，检查 BS_HIS_PatAdm 表是否保存了 FixmedinsCode 和 FixmedinsName
   
2. **测试同步配置**：
   - 保存同步配置（接口02010080）
   - 查询同步配置（接口02010079）
   
3. **测试同步执行**：
   - 手动执行增量同步（接口02010078）
   - 检查同步日志和患者数据是否正确保存
   
4. **测试同步状态查询**：
   - 查询同步状态（接口02010081）
   - 验证最后同步时间、状态等信息

## 注意事项

1. **医院代码一致性**：
   - 确保 session 中的 hospCode 与 CB_Hospital.Code 一致
   - 同步配置、日志、患者数据均使用 hospCode 关联
   
2. **多医院支持**：
   - 系统应支持为不同医院配置不同同步策略
   - 查询时需按 hospCode 过滤数据
   
3. **权限控制**：
   - 同步配置需要管理员权限
   - 普通用户只能查看自己医院的同步数据
