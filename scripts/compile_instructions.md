# HIS数据查询接口 - 编译和测试说明

## 已修复的问题

### 1. Interface.cls 重写
- 参考 `src.DRG.BasicData.InterFace` 的模式
- 接口方法直接传递 `jsonObj` 到服务类
- 添加了3个新接口：02010075、02010076、02010077

### 2. HisDataService.cls 更新
- 服务方法接受 `jsonObj` 参数
- 从 `jsonObj.params` 提取查询参数
- 从 `jsonObj.pagination` 提取分页参数
- **修复了 `new (jsonObj)` 导致的参数被清空问题**

### 3. 前端开发
- `SyncedPatients.tsx` - 详情弹窗使用Tabs展示
- `SyncLog.tsx` - 新建同步日志查询页面
- `App.tsx` - 添加路由和菜单配置

## 编译步骤

### 在IRIS终端中执行：

```objectscript
// 方法1：编译单个类
Do $System.OBJ.Compile("src.DRG.HISData.HisDataService","ck")
Do $System.OBJ.Compile("src.DRG.HISData.InterFace","ck")

// 方法2：同时编译多个类
Do $System.OBJ.Compile("src.DRG.HISData.HisDataService,src.DRG.HISData.InterFace","ck")
```

## 测试接口

### 1. 测试查询已同步患者（02010075）

```json
{
    "code": "02010075",
    "params": [{}],
    "session": [{"userID": "158", "hospID": "13"}],
    "pagination": [{"pageSize": 20, "currentPage": 1}]
}
```

### 2. 测试查询患者详情（02010076）

```json
{
    "code": "02010076",
    "params": [{"admID": "测试就诊ID"}],
    "session": [{"userID": "158", "hospID": "13"}]
}
```

### 3. 测试查询同步日志（02010077）

```json
{
    "code": "02010077",
    "params": [{}],
    "session": [{"userID": "158", "hospID": "13"}],
    "pagination": [{"pageSize": 20, "currentPage": 1}]
}
```

## 前端测试

1. 启动前端开发服务器：`npm start` 或 `yarn start`
2. 访问"已同步患者查询"页面，测试查询和详情功能
3. 访问"同步日志查询"页面，测试查询和筛选功能

## 注意事项

1. **SQL表名**：确认SQL中使用的表名与类定义中的 `SqlTableName` 一致
   - `BS_HIS_PatAdm` - 对应 `User.BSHISPatAdm`
   - `BS_HIS_DiseInfo` - 对应 `User.BSHISDiseInfo`
   - `BS_HIS_OprnInfo` - 对应 `User.BSHISOprnInfo`
   - `BS_HIS_SyncLog` - 对应 `User.BSHISSyncLog`
   - `BS_HISDRGParams` - 对应 `User.BSHISDRGParams`

2. **分页语法**：IRIS支持 `LIMIT` 和 `OFFSET` 语法（IRIS 2019+）

3. **字段名拼写**：代码中可能有拼写错误（如 `Deleted` 误写为 `Deleted`），需要检查并修复

## 后续工作

1. 编译后端类
2. 测试接口功能
3. 根据测试结果修复问题
4. 完善前端页面功能
