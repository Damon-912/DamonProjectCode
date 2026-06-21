## ADDED Requirements

### Requirement: HIS API客户端能发起标准接口调用

系统SHALL提供统一的HIS API客户端类（`DRG.HIS.APIClient`），封装所有HIS接口调用协议。客户端SHALL支持：
- 接收接口编码（`code`）和业务参数（`params`）作为入参
- 自动构建完整的HIS请求体（包含`code`、`params`、`session`）
- 发送HTTP POST请求到配置的HIS接口地址
- 解析响应体，返回标准格式（`errorCode`、`errorMessage`、`result`）

#### Scenario: 成功调用HIS接口并获取结果

- **WHEN** 调用方传入有效的接口编码`"05900014"`和参数`{stDate: "2026-06-11", endDate: "2026-06-12"}`
- **THEN** 客户端自动构建包含`session`信息的完整请求体，发送POST请求，并返回解析后的`result`数组（包含患者就诊数据）

---

#### Scenario: HIS接口返回业务错误码

- **WHEN** HIS接口返回的`errorCode`不为0（如`errorCode: 1001, errorMessage: "参数错误"`）
- **THEN** 客户端SHALL将错误码和错误信息封装为`%Status`对象返回给调用方，不进行重试

---

#### Scenario: 网络连接超时

- **WHEN** 发送HTTP请求时发生网络超时或连接失败
- **THEN** 客户端SHALL自动重试3次，每次重试间隔5秒；若3次均失败，则返回包含错误描述的`%Status`对象

---

### Requirement: HIS API客户端管理session信息

系统SHALL从配置全局变量`^DRG.HIS.Config("Session")`中读取session信息，并在每次接口调用时自动附加到请求体中。session信息SHALL包含以下必填字段：
- `locID`：院区ID
- `hospID`：医院ID
- `fixmedinsCode`：医保定点机构编码
- `sessionID`：会话ID

#### Scenario: session信息完整，接口调用成功

- **WHEN** 配置全局变量中包含完整的session信息
- **THEN** 客户端SHALL将session信息原样附加到请求体的`session`字段中，并成功发起接口调用

---

#### Scenario: session信息缺失必填字段

- **WHEN** 配置全局变量中缺少`fixmedinsCode`或`sessionID`等必填字段
- **THEN** 客户端SHALL拒绝执行接口调用，并返回明确的错误提示（如`"缺少必填session字段：fixmedinsCode"`）

---

### Requirement: HIS API客户端支持获取住院患者就诊数据

系统SHALL提供专门的方法`GetInpatientData(stDate, endDate)`用于调用接口编码`05900014`（住院患者就诊数据查询接口），并返回标准化的患者就诊数据列表。

#### Scenario: 按日期范围查询住院患者数据

- **WHEN** 调用`GetInpatientData("2026-06-11", "2026-06-12")`
- **THEN** 客户端SHALL以`code: "05900014"`和`params: [{stDate: "2026-06-11", endDate: "2026-06-12"}]`发起请求，并将返回的`result`数组转换为标准化的患者就诊数据对象列表

---

#### Scenario: HIS接口返回空结果

- **WHEN** 指定日期范围内无住院患者数据（返回`result: []`）
- **THEN** 客户端SHALL返回空数组，不视为错误，不影响同步任务状态
