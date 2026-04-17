## ADDED Requirements

### Requirement: DRG算法导入模板下载
系统 SHALL 提供DRG核心算法数据导入的CSV模板下载功能。

#### Scenario: 用户点击模板下载按钮
- **WHEN** 用户在DRG算法配置页面点击"下载模板"按钮
- **THEN** 系统 SHALL 下载包含DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard六个字段的CSV模板文件
- **AND** 模板第一行 SHALL 为表头，第二行起可为空或包含示例数据

### Requirement: DRG算法数据批量导入
系统 SHALL 支持通过CSV文件批量导入DRG核心算法数据到HB_DRGCoreAlgorithmData表。

#### Scenario: 用户完成导入前置选择并上传文件
- **WHEN** 用户选择省、市、医疗机构
- **AND** 用户上传有效的CSV文件
- **THEN** 系统 SHALL 解析CSV文件并显示数据预览
- **AND** 预览 SHALL 显示每行数据的状态（正常/重复/错误）

#### Scenario: 用户未选择必填项尝试导入
- **WHEN** 用户未选择省或市或医疗机构
- **AND** 用户点击下一步按钮
- **THEN** 系统 SHALL 提示"请选择省、市、医疗机构"
- **AND** 预览操作 SHALL 被阻止

#### Scenario: 用户未上传文件尝试预览
- **WHEN** 用户已选择省、市、医疗机构
- **AND** 用户未上传文件
- **AND** 用户点击下一步按钮
- **THEN** 系统 SHALL 提示"请先上传导入文件"
- **AND** 预览操作 SHALL 被阻止

#### Scenario: 导入数据校验通过
- **WHEN** 用户上传的CSV文件中所有数据校验通过
- **THEN** 系统 SHALL 显示校验成功提示
- **AND** 正常数据条数 SHALL 等于总数据条数
- **AND** 用户 SHALL 能够确认保存数据

#### Scenario: 导入数据存在重复
- **WHEN** 用户上传的CSV文件中存在与数据库重复的数据
- **THEN** 重复数据 SHALL 标记为"重复"状态
- **AND** 系统 SHALL 提示"该DRG代码已存在，导入将执行更新操作"
- **AND** 用户 SHALL 能够确认保存数据（重复数据将更新）

#### Scenario: 导入数据校验失败
- **WHEN** 用户上传的CSV文件存在校验不通过的数据
- **THEN** 系统 SHALL 显示校验失败的数据列表及失败原因
- **AND** 保存按钮 SHALL 被禁用
- **AND** 用户 SHALL 能够返回修改后重新上传

### Requirement: 导入数据行政区划和机构关联
导入的DRG算法数据 SHALL 与选择的行政区划和医疗机构信息关联。

#### Scenario: 保存导入数据时关联行政区划和机构
- **WHEN** 用户确认保存导入数据
- **THEN** 系统 SHALL 将选择的省的ID作为Province_Dr存入数据库
- **AND** 系统 SHALL 将选择的市的ID作为City_Dr存入数据库
- **AND** 系统 SHALL 将市接口返回的Code作为MdtrtArea存入数据库
- **AND** 系统 SHALL 将医疗机构接口返回的OrganizationCode作为FixmedinsCode存入数据库
- **AND** 系统 SHALL 将医疗机构接口返回的Descripts作为FixmedinsName存入数据库
- **AND** 系统 SHALL 将医疗机构接口返回的HospGrade_Dr作为MedinsLv存入数据库

### Requirement: 后端导入接口服务
后端 SHALL 提供三个接口服务支持DRG算法数据导入功能。

#### Scenario: 调用预览接口（02010050）
- **WHEN** 前端调用PreviewImportDRGCoreAlgorithm接口
- **AND** 传入provinceID、cityID、medicalInstitution、fileData（Base64）等参数
- **THEN** 系统 SHALL 解析CSV文件内容
- **AND** 系统 SHALL 校验每行数据的必填字段和数据格式
- **AND** 系统 SHALL 检查数据重复性（DRG+MdtrtArea+FixmedinsCode）
- **AND** 系统 SHALL 返回预览数据列表和统计信息（总条数、正常条数、重复条数、错误条数）

#### Scenario: 调用确认导入接口（02010051）
- **WHEN** 前端调用ConfirmImportDRGCoreAlgorithm接口
- **AND** 传入与预览接口相同的参数
- **THEN** 系统 SHALL 重新解析并校验CSV文件
- **AND** 系统 SHALL 使用operatetable方式将数据保存到HB_DRGCoreAlgorithmData表
- **AND** 重复数据 SHALL 执行更新操作
- **AND** 系统 SHALL 返回导入结果（总条数、成功条数、失败条数、新增条数、更新条数、失败明细）

#### Scenario: 调用模板下载接口（02010052）
- **WHEN** 前端调用DownloadDRGCoreAlgorithmTemplate接口
- **THEN** 系统 SHALL 返回CSV模板文件的Base64编码内容
- **AND** 系统 SHALL 返回文件名和Content-Type

### Requirement: 导入数据字段校验
系统 SHALL 对导入的DRG算法数据进行字段级别的校验。

#### Scenario: 必填字段校验
- **WHEN** 导入数据中DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard任一字段为空
- **THEN** 该校验 SHALL 失败
- **AND** 系统 SHALL 提示具体哪个必填字段为空

#### Scenario: 数值字段格式校验
- **WHEN** 导入数据中Points、PipValue、DGDOV、PayStandard字段为非数值格式
- **THEN** 该校验 SHALL 失败
- **AND** 系统 SHALL 提示"数值格式错误"

#### Scenario: DRG代码长度校验
- **WHEN** 导入数据中DRGCode超过系统定义的最大长度
- **THEN** 该校验 SHALL 失败
- **AND** 系统 SHALL 提示"DRG代码长度超限"

### Requirement: 导入文件格式限制
系统 SHALL 对上传的导入文件进行格式和大小限制。

#### Scenario: 上传非CSV文件
- **WHEN** 用户上传的文件扩展名不是.csv
- **THEN** 系统 SHALL 提示"仅支持CSV格式文件"
- **AND** 上传 SHALL 被阻止

#### Scenario: 上传超大文件
- **WHEN** 用户上传的文件大小超过10MB
- **THEN** 系统 SHALL 提示"文件大小不能超过10MB"
- **AND** 上传 SHALL 被阻止

#### Scenario: 上传空文件
- **WHEN** 用户上传的文件内容为空或只有表头
- **THEN** 系统 SHALL 提示"文件内容为空"
- **AND** 预览 SHALL 被阻止

### Requirement: 导入结果展示
系统 SHALL 在导入完成后展示详细的导入结果。

#### Scenario: 全部导入成功
- **WHEN** 所有数据导入成功
- **THEN** 系统 SHALL 显示"导入成功"提示
- **AND** 系统 SHALL 展示统计卡片（总记录数、成功导入数、新增记录数、更新记录数）

#### Scenario: 部分导入失败
- **WHEN** 部分数据导入失败
- **THEN** 系统 SHALL 显示"导入完成（部分失败）"提示
- **AND** 系统 SHALL 展示失败明细列表（行号、DRG代码、失败原因）
- **AND** 失败明细 SHALL 支持滚动查看

#### Scenario: 导入完成后刷新列表
- **WHEN** 导入完成后用户点击"完成"按钮
- **THEN** 导入弹框 SHALL 关闭
- **AND** DRG算法配置列表数据 SHALL 自动刷新
