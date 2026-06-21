## Context

DRG医保控费预警系统需要实时或定期获取HIS（医院信息系统）中的患者就诊数据，包括住院信息、诊断信息、手术信息、费用信息等，用于DRG/DIP分组、费用预警、医保控费等核心业务。

当前系统前端页面（`DataSync.tsx`、`MedicalRecords.tsx`）使用模拟数据，缺乏真实的HIS数据对接能力。HIS系统已提供REST API接口（如接口示例文件所示），采用统一的请求/响应格式，需要通过标准化的方式对接。

系统技术栈：
- 后端：InterSystems IRIS/Cache ObjectScript 2019+
- 数据库：InterSystems IRIS 内置数据库（对象存储为主）
- 前端：React + Ant Design
- HIS接口协议：HTTP + JSON，请求需携带 `code`（接口编码）、`params`（业务参数）、`session`（会话信息）

## Goals / Non-Goals

**Goals:**

- 建立标准化的HIS API客户端，封装所有接口调用细节（认证、签名、重试）
- 实现可靠的数据同步引擎，支持全量同步、增量同步、定时调度
- 建立HIS接口数据与IRIS数据库表结构的映射规则，确保数据准确入库
- 提供同步任务管理能力（配置、执行、监控、失败重试、日志记录）
- 前端页面对接真实API，替换模拟数据，展示真实同步状态和病案信息
- 确保同步过程的可观测性（日志、告警、统计）

**Non-Goals:**

- 不涉及HIS系统本身的改造或接口开发（由HIS方提供）
- 不涉及双向数据同步（只从HIS同步到DRG系统，不支持写回HIS）
- 不涉及实时WebSocket推送（采用定时轮询+增量同步方式）
- 不涉及多HIS系统并行对接（当前只对接一个HIS实例）
- 不涉及数据清洗或质量管理（只做字段映射和基本的非空校验）

## Decisions

### 决策1：同步方式选择——定时增量同步 + 手动全量同步

**选择**：采用「定时增量同步（每30分钟）+ 手动全量同步」的组合方式

**备选方案**：
- A：实时Webhook推送（HIS主动推送数据变更）
- B：纯定时全量同步（每天凌晨全量拉取）
- C：定时增量同步 + 手动全量同步（当前选择）

**理由**：
- HIS系统不支持Webhook主动推送，只能被动调用接口查询（排除A）
- 纯全量同步数据冗余大、性能差，且无法及时获取当日新入院患者数据（排除B）
- 增量同步通过时间窗口（`stDate`/`endDate`）拉取指定范围内的数据，效率高；全量同步用于初始化和历史数据补录（选择C）

**增量比对策略**：
- 使用 `admDateTime`（入院时间）作为增量时间窗口的依据
- 每次同步记录最后同步时间，下次同步以`最后同步时间`作为`stDate`
- 支持配置增量时间窗口大小（默认1天，可调整为3天或7天以应对HIS数据延迟更新场景）

---

### 决策2：HIS API客户端封装方式——独立REST客户端类

**选择**：在IRIS中创建独立的 `DRG.HIS.APIClient` 类，封装所有HIS接口调用

**备选方案**：
- A：在每个业务类中直接调用HTTP客户端（分散管理）
- B：创建独立的API客户端类统一封装（当前选择）
- C：使用外部中间件（如Node.js代理服务）转发请求

**理由**：
- 分散管理会导致认证、签名、错误处理代码重复（排除A）
- 独立封装便于统一处理session管理、超时重试、错误码映射
- IRIS原生支持HTTP客户端（`%Net.HttpRequest`），无需外部中间件（排除C）
- 符合单一职责原则，便于后续扩展其他HIS接口

**API客户端核心方法**：
- `CallInterface(code, params) -> %DynamicObject`：通用接口调用方法
- `GetInpatientData(stDate, endDate) -> %DynamicArray`：获取住院患者就诊数据（接口编码：05900014）
- `BuildSession() -> %DynamicObject`：构建session对象（从配置表读取locID、hospID等）
- `HandleError(response) -> %Status`：统一错误处理

---

### 决策3：数据存储设计——直接映射 + 去重更新

**选择**：HIS接口数据直接映射到IRIS表，使用 `admID`（HIS就诊ID）作为唯一键，存在则更新，不存在则插入

**备选方案**：
- A：先存入临时 staging 表，经校验后再转入正式表
- B：直接写入正式表，写入时做UPSERT（当前选择）
- C：只存储DRG分组所需必要字段，忽略其他字段

**理由**：
- staging表增加复杂度，当前数据来源可信（HIS系统内部接口），无需额外校验层（排除A）
- UPSERT方式简单高效，利用`admID`唯一键保证幂等性
- 保留HIS接口返回的全部字段，便于后续业务扩展（排除C）

**核心数据表设计**：

1. `DRG_HIS_PatientAdm`（患者就诊主表）
   - 主键：`AdmID`（HIS就诊ID）、`PatID`（HIS患者ID）
   - 主要字段：`PatName`、`PatSexCode`、`PatNo`、`PatMedicalNo`、`AdmDocDesc`、`AdmDateTime`、`AdmInDays`、`AdmDiag`、`InLocDesc`、`InWardDesc`
   - 索引：`AdmDateTime`（增量查询）、`PatMedicalNo`（病案号查询）

2. `DRG_HIS_DRGParams`（DRG分组参数表）
   - 主键：`AdmID`（关联患者就诊主表）
   - 主要字段：`PsnNo`（医保个人编号）、`InsuranceAreaCode`（医保统筹区代码）、`InsuType`（医保类型）、`MainDiagnosisCode`、`MainOperationCode`、`Sex`、`Age`、`TotalCost`等
   - 说明：对应HIS接口返回数据中的 `drgParams.result` 对象

3. `DRG_HIS_OprnInfo`（手术信息表）
   - 主键：`AdmID` + `OprnSn`（手术序号）
   - 主要字段：`MainFlag`（主手术标志）、`OprnCode`、`OprnName`、`OprnDate`
   - 说明：对应 `drgParams.result.oprnInfo` 数组

4. `DRG_HIS_SyncLog`（同步日志表）
   - 主键：`LogID`（自增）
   - 主要字段：`SyncType`（full/incremental/manual）、`StartTime`、`EndTime`、`Status`（success/failed/partial）、`TotalCount`、`SuccessCount`、`FailedCount`、`ErrorMessage`、`CreatedTime`

---

### 决策4：前端数据同步页面改造——真实API对接

**选择**：改造现有 `DataSync.tsx` 页面，调用后端同步任务API，替换模拟数据

**备选方案**：
- A：完全前后端分离，前端通过REST API调用同步服务
- B：前端只做展示，同步任务完全由后端定时任务执行（当前部分采用）
- C：混合模式——定时任务自动执行 + 前端可手动触发和查看状态（推荐）

**理由**：
- 纯前端触发（A）不适合定时同步场景
- 纯后端执行（B）缺乏灵活性，无法手动触发同步
- 混合模式兼顾自动化和灵活性：定时任务负责日常增量同步，前端提供手动触发、状态查看、失败重试能力

**前端改造要点**：
- `DataSync.tsx`：调用 `GET /api/his-sync/tasks` 获取同步任务列表，调用 `POST /api/his-sync/tasks/{taskId}/start` 手动触发同步
- `MedicalRecords.tsx`：调用 `GET /api/his-sync/patients?startDate=&endDate=` 查询已同步的患者数据
- 新增API函数文件 `frontend/src/api/hisSync.js`，封装所有HIS同步相关API调用

---

### 决策5：错误处理与重试机制——分层错误处理

**选择**：采用「接口层重试 + 业务层失败记录 + 告警通知」的分层错误处理策略

**重试规则**：
- 网络超时：自动重试3次，间隔5秒
- HIS返回 `errorCode != 0`：不重试，记录错误日志，人工介入
- 数据库写入失败：回滚当前批次，记录失败数据，不重试（避免脏数据）

**告警机制**：
- 同步失败超过5条记录：前端页面红色标记 + 日志记录
- 连续3次同步任务失败：需人工介入检查HIS接口可用性

## Risks / Trade-offs

### Risk 1：HIS接口不稳定或返回数据格式变更
**风险**：HIS系统升级可能导致接口返回格式变化，影响数据同步

**缓解措施**：
- API客户端增加响应结构校验，发现格式异常立即记录并告警
- 保留HIS接口原始返回数据（存入 `DRG_HIS_RawData` 备份表），便于问题排查和数据修复
- 与HIS系统维护团队建立接口变更通知机制

---

### Risk 2：增量同步时间窗口遗漏数据
**风险**：若HIS系统中某条记录的 `admDateTime` 被修正为更早日期，而该日期已在上次同步时间窗口之前，会导致数据遗漏

**缓解措施**：
- 支持配置「回溯天数」（默认3天），每次增量同步时，将 `stDate` 向前回溯N天
- 提供手动全量同步功能，可定期（如每月）执行一次全量同步以修正数据

---

### Risk 3：大量数据同步时IRIS数据库性能
**风险**：日同步数据量增大（如多院区部署）时，频繁写入可能影响数据库性能

**缓解措施**：
- 采用批量写入（每批次100条），减少数据库交互次数
- `DRG_HIS_PatientAdm` 表建立合适索引，避免全表扫描
- 同步任务安排在系统低峰期（如每30分钟，避开门诊高峰）

---

### Risk 4：session信息配置错误导致接口调用失败
**风险**：HIS接口需要正确的 `session` 信息（locID、hospID、fixmedinsCode等），配置错误会导致认证失败

**缓解措施**：
- session信息存储在IRIS全局变量 `^DRG.HIS.Config("Session")` 中，提供管理界面进行配置
- API客户端调用前校验session信息完整性，缺失则拒绝执行并告警
- 在接口对接说明文档中详细说明session各字段的获取方式

## Open Questions

1. **HIS接口的分页机制是什么？**
   - 当前接口示例未展示分页参数，需确认当返回数据超过一定数量时，HIS是否支持分页查询，以及分页参数格式

2. **HIS接口的认证方式细节？**
   - 当前示例中的 `sessionID` 是如何获取的？是否需要定期刷新？刷新机制是什么？

3. **生产环境HIS接口地址和测试环境地址？**
   - 需要HIS方提供测试环境接口地址、测试数据，以及正式环境访问权限

4. **数据同步频率最终确认？**
   - 建议每30分钟增量同步一次，但需与业务方确认可接受的数据延迟（实时性要求）

5. **历史数据初始化范围？**
   - 全量同步时，需要确定初始化时间范围（如：同步最近1年数据，还是全部历史数据）
