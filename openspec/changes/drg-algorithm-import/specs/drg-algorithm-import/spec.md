## ADDED Requirements

### Requirement: DRG算法配置导入模板下载
系统 SHALL 提供DRG算法数据导入的Excel模板下载功能。

#### Scenario: 用户点击模板下载按钮
- **WHEN** 用户在DRG算法配置页面点击"下载模板"按钮
- **THEN** 系统 SHALL 下载包含DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard六个字段的标准Excel模板文件

### Requirement: DRG算法数据批量导入
系统 SHALL 支持通过Excel文件批量导入DRG算法数据到HB_DRGCoreAlgorithmData表。

#### Scenario: 用户完成导入前置选择并上传文件
- **WHEN** 用户选择省、市、医疗机构
- **AND** 用户上传有效的Excel文件
- **THEN** 系统 SHALL 解析Excel文件并显示数据预览

#### Scenario: 用户未选择必填项尝试导入
- **WHEN** 用户未选择省或市或医疗机构
- **AND** 用户点击导入按钮
- **THEN** 系统 SHALL 提示"请选择省、市、医疗机构"
- **AND** 导入操作 SHALL 被阻止

#### Scenario: 导入数据校验通过
- **WHEN** 用户上传的Excel文件中所有数据校验通过
- **THEN** 系统 SHALL 显示校验成功提示
- **AND** 用户 SHALL 能够确认保存数据

#### Scenario: 导入数据校验失败
- **WHEN** 用户上传的Excel文件存在校验不通过的数据
- **THEN** 系统 SHALL 显示校验失败的数据列表及失败原因
- **AND** 保存按钮 SHALL 被禁用

### Requirement: 导入数据行政区划关联
导入的DRG算法数据 SHALL 与选择的行政区划和医疗机构信息关联。

#### Scenario: 保存导入数据时关联行政区划
- **WHEN** 用户确认保存导入数据
- **THEN** 系统 SHALL 将选择的市的Code作为MdtrtArea存入数据库
- **AND** 系统 SHALL 将医疗机构的OrganizationCode作为FixmedinsCode存入数据库
- **AND** 系统 SHALL 将医疗机构的Descripts作为FixmedinsName存入数据库
- **AND** 系统 SHALL 将医疗机构的HospGrade_Dr作为MedinsLv存入数据库

### Requirement: 后端导入接口服务
后端 SHALL 提供三个接口服务支持DRG算法数据导入功能。

#### Scenario: 调用查询接口
- **WHEN** 前端调用DRG算法导入查询接口
- **THEN** 系统 SHALL 返回符合查询条件的DRG算法数据列表

#### Scenario: 调用验证接口
- **WHEN** 前端调用DRG算法导入验证接口并传入导入数据
- **THEN** 系统 SHALL 校验数据的必填字段、数据格式、重复性
- **AND** 系统 SHALL 返回校验结果和错误信息

#### Scenario: 调用保存接口
- **WHEN** 前端调用DRG算法导入保存接口并传入已验证的数据
- **THEN** 系统 SHALL 使用operatetable方式将数据保存到HB_DRGCoreAlgorithmData表
- **AND** 系统 SHALL 返回保存结果

### Requirement: 导入数据字段校验
系统 SHALL 对导入的DRG算法数据进行字段级别的校验。

#### Scenario: 必填字段校验
- **WHEN** 导入数据中DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard任一字段为空
- **THEN** 该校验 SHALL 失败
- **AND** 系统 SHALL 提示"必填字段不能为空"

#### Scenario: 数值字段格式校验
- **WHEN** 导入数据中Points、PipValue、DGDOV、PayStandard字段为非数值格式
- **THEN** 该校验 SHALL 失败
- **AND** 系统 SHALL 提示"数值格式错误"
