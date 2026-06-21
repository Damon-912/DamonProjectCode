## 1. 数据库表结构创建（User包，BS_前缀）

- [ ] 1.1 创建`User.BSHISPatAdm`类（SqlTableName = `BS_HIS_PatAdm`，患者就诊主表）。字段：`AdmID`(%String,主键)、`PatID`(%String)、`PatName`(%String)、`PatSexCode`(%String)、`PatSexDesc`(%String)、`PatNo`(%String)、`PatMedicalNo`(%String,索引)、`AdmDocDesc`(%String)、`AdmNurDesc`(%String)、`AdmDateTime`(%TimeStamp,索引)、`AdmInDays`(%Integer)、`AdmDiag`(%String)、`InLocDesc`(%String)、`InWardDesc`(%String)、`CreateDate`(%Date)、`CreateTime`(%Time)、`UpdateDate`(%Date)、`UpdateTime`(%Time)、`Deleted`(%Integer,默认0)。继承`src.util.DynamicObject.Adapter`，遵循CB表必填字段规范。
- [ ] 1.2 创建`User.BSHISDRGParams`类（SqlTableName = `BS_HIS_DRGParams`，DRG分组参数表）。字段：`AdmDr`(%String,主键/外键→`User.BSHISPatAdm`)、`PsnNo`(%String)、`InsuranceAreaCode`(%String)、`MdtrtareaAreaCode`(%String)、`InsuType`(%String)、`DiagnosisCode`(%String)、`DiagnosisName`(%String)、`GroupStage`(%Integer)、`DiaTypeCode`(%String)、`UnionOprnFlag`(%Integer)、`MainDiagnosisCode`(%String)、`MainOperationCode`(%String)、`Sex`(%String)、`Age`(%Integer)、`AgeGroupDays`(%String)、`NewbornFlag`(%String)、`RespiratorTime`(%String)、`EcmoFlag`(%String)、`TransplantFlag`(%String)、`MarrowTransplantFlag`(%String)、`HivFlag`(%String)、`TraumaLevel`(%String)、`Department`(%String)、`DepartmentDesc`(%String)、`DischargeType`(%String)、`HospitalDays`(%Integer)、`TotalCost`(%Numeric)、`MedicalRecordID`(%String)、`HisAdmId`(%String)、`PatientName`(%String)、`DeptCode`(%String)、`DeptName`(%String)、`DoctorCode`(%String)、`DoctorName`(%String)、`TotalFee`(%Numeric)、`MedicalRecordDr`(%String)、`FixmedinsCode`(%String)、`FixmedinsName`(%String)、`DrgParamsStatusCode`(%String,默认"0")、`CreateDate`(%Date)、`CreateTime`(%Time)。
- [ ] 1.3 创建`User.BSHISOprnInfo`类（SqlTableName = `BS_HIS_OprnInfo`，手术信息表）。字段：`AdmDr`(%String,联合主键/外键→`User.BSHISPatAdm`)、`OprnSn`(%Integer,联合主键)、`MainFlag`(%String)、`OprnCode`(%String)、`OprnName`(%String)、`OprnDate`(%String)、`CreateDate`(%Date)、`CreateTime`(%Time)。
- [ ] 1.4 创建`User.BSHISSyncLog`类（SqlTableName = `BS_HIS_SyncLog`，同步日志表）。字段：`ID`(%Integer,主键自增)、`TaskName`(%String)、`SyncType`(%String)、`StartTime`(%TimeStamp)、`EndTime`(%TimeStamp)、`StatusCode`(%String)、`TotalCount`(%Integer)、`SuccessCount`(%Integer)、`FailedCount`(%Integer)、`ErrorMessage`(%String,MAXLEN=2000)、`CreateDate`(%Date)、`CreateTime`(%Time)。索引：`CreateDate`。

## 2. HIS服务配置管理（复用现有ModuleConfig机制）

- [ ] 2.1 在`HBModuleConfigType`和`HBModuleConfig`全局变量中配置HIS连接参数（HisIP=172.16.1.6、HisPort=、HisURL=bdhealth/、Authorization=Basic cHJoaXA6cHJoaXBAMjAyMA==），使用`src.Config.ModuleConfig.GetConfigByCode("HisIP",HospID)`等方式读取
- [ ] 2.2 创建`src.DRG.HISData.ConfigService`类，实现`SaveHisServiceConfig(jsonObj)`和`GetHisServiceConfig(jsonObj)`方法，通过`src.Config.ModuleConfig`读写HIS连接配置；方法遵循try-catch、后置条件无空格等规范
- [ ] 2.3 创建前端HIS服务配置菜单页面（`frontend/src/pages/HIS/HISServiceConfig.tsx`），支持配置HIS服务地址（IP/端口/URL）和Authorization，调用`src.DRG.HISData.ConfigService`保存；后续可扩展其他系统服务配置

## 3. HIS数据获取服务类（src.DRG.HISData包，复用现有调用模式）

- [ ] 3.1 创建`src.DRG.HISData.HisDataService`类，方法`GetInpatientData(pStartDate, pEndDate, pSessionObj)`：内部调用`##class(src.External.Service).HisService(pInputData)`（复用现有模式），传入`code=05900014`、`params=[{stDate, endDate}]`、`session`；返回解析后的`%DynamicArray`结果
- [ ] 3.2 在`src.DRG.HISData.HisDataService`中实现`BuildSession(pHospID)`方法：从`src.Config.ModuleConfig.GetConfigByCode`读取locID、hospID、fixmedinsCode、sessionID等，构建session对象；校验必填字段，缺失则返回错误%Status
- [ ] 3.3 在`src.DRG.HISData.HisDataService`中实现`CallInterface(pInputObj)`方法：构建完整请求体，通过`##class(src.External.Service).HisService()`发送请求；HTTP超时默认30秒；网络超时自动重试3次（间隔5秒）；错误处理遵循现有模式

## 4. HIS数据映射与存储类（src.DRG.HISData包）

- [ ] 4.1 创建`src.DRG.HISData.DataMapper`类，方法`MapAndSave(pResultArray)`：遍历HIS接口返回的result数组，对每条记录调用映射和存储逻辑
- [ ] 4.2 实现`MapPatAdm(pResultItem)`方法：将result顶层字段映射为`User.BSHISPatAdm`对象；`admDateTime`字符串转%TimeStamp；调用`##class(src.util.operatable).Insert/Update`持久化
- [ ] 4.3 实现`MapDRGParams(pAdmID, pDrgParams)`方法：将`drgParams.result`映射为`User.BSHISDRGParams`对象；若`drgParams.errorCode != "0"`则标记`DrgParamsStatusCode="error"`；调用公共Insert/Update方法持久化
- [ ] 4.4 实现`MapOprnInfo(pAdmID, pOprnInfoArray)`方法：将`oprnInfo`数组逐条映射为`User.BSHISOprnInfo`对象并持久化
- [ ] 4.5 实现`ValidateRequired(pResultItem)`方法：校验`admID`、`patID`、`patMedicalNo`非空；失败则返回错误%Status并记录日志

## 5. 数据同步引擎类（src.DRG.HISData包）

- [ ] 5.1 创建`src.DRG.HISData.SyncEngine`类，方法`IncrementalSync(pHospID, pLookbackDays)`：计算时间窗口（stDate = 最后同步时间 - lookbackDays，endDate = 当前时间）；调用`GetInpatientData()`；逐条MapAndSave；记录同步日志；更新最后同步时间
- [ ] 5.2 实现`FullSync(pHospID, pStartDate, pEndDate)`方法：按7天分段调用`GetInpatientData()`；每段独立try-catch；综合判断最终状态（全部成功→success，部分失败→partial）
- [ ] 5.3 实现`GetLastSyncTime(pHospID)`和`UpdateLastSyncTime(pHospID, pTime)`方法：通过全局变量`^BSHISSync("LastSyncTime", HospID)`读写最后同步时间
- [ ] 5.4 实现`SaveSyncLog(pLogObj)`方法：向`User.BSHISSyncLog`表写入同步日志；使用`##class(src.util.operatable).Insert`持久化
- [ ] 5.5 在`src.DRG.HISData.SyncEngine`中增加定时同步能力：读取全局变量`^BSHISSync("Schedule", HospID)`中的间隔分钟数；通过IRIS Task Manager或`%SYS.Task`类注册定时任务

## 6. REST API接口开发（对应前端调用）

- [ ] 6.1 创建REST接口：`GET /api/his-sync/config` 和 `POST /api/his-sync/config`，分别调用`src.DRG.HISData.ConfigService.GetHisServiceConfig`和`SaveHisServiceConfig`
- [ ] 6.2 创建REST接口：`POST /api/his-sync/incremental`，触发增量同步；`POST /api/his-sync/full`，触发全量同步（接收startDate/endDate参数）
- [ ] 6.3 创建REST接口：`GET /api/his-sync/logs`，查询`User.BSHISSyncLog`表，支持按SyncType/StatusCode/CreateDate筛选，返回分页结果
- [ ] 6.4 创建REST接口：`GET /api/his-sync/patients`，查询`User.BSHISPatAdm`联表`User.BSHISDRGParams`，支持按PatName/PatMedicalNo/AdmDateTime筛选，返回分页结果（供MedicalRecords.tsx使用）

## 7. 前端页面开发与改造

- [ ] 7.1 创建`frontend/src/api/hisSync.js`，封装6.1-6.4的所有API调用函数
- [ ] 7.2 新建`frontend/src/pages/HIS/HISServiceConfig.tsx`（HIS服务配置页面）：表单输入HIS服务IP、端口、URL、Authorization；调用`/api/his-sync/config`读写；菜单入口挂在系统配置下
- [ ] 7.3 改造`frontend/src/pages/HIS/DataSync.tsx`：替换模拟数据，调用`POST /api/his-sync/incremental`和`/full`触发同步；调用`/api/his-sync/logs`展示日志；同步任务状态实时刷新（running时每5秒刷新）
- [ ] 7.4 改造`frontend/src/pages/HIS/MedicalRecords.tsx`：调用`GET /api/his-sync/patients`获取已同步的患者病案数据；替换模拟数据

## 8. 测试与部署

- [ ] 8.1 使用接口示例文件（`接口示例/HIS住院患者就诊数据.txt`）中的真实数据，测试`src.DRG.HISData.HisDataService.GetInpatientData`的调用和解析逻辑
- [ ] 8.2 测试映射类：用示例数据验证字段映射准确性、类型转换正确性（admDateTime→%TimeStamp, totalCost→%Numeric）
- [ ] 8.3 在测试环境部署：配置HIS连接参数（HisIP=172.16.1.6, HisURL=bdhealth/, Authorization=Basic cHJoaXA6cHJoaXBAMjAyMA==）；执行一次增量同步验证端到端流程
- [ ] 8.4 编写同步任务监控说明文档：如何查看`User.BSHISSyncLog`、如何手动触发同步、如何配置定时任务
