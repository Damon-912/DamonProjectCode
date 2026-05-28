## ADDED Requirements

### Requirement: 特异化分组方案查询
系统 SHALL 提供DRG特异化分组方案的分页查询功能，支持按DRG编码(模糊匹配)、行政区划代码Admvs(模糊匹配)、省(精确匹配)、市(精确匹配)、年份(精确匹配)进行筛选查询，查询结果按DRG编码排序。

#### Scenario: 按条件查询特异化分组方案
- **WHEN** 用户在查询条件中输入DRG编码、行政区划代码或选择省市/年份后点击查询
- **THEN** 系统返回符合条件的特异化分组方案分页列表，包含id、drgCode、drgName、principalDiagnosis、principalDiagnosisName、secondaryDiagnosis、secondaryDiagnosisName、majorProcedure、majorProcedureName、secondaryProcedure、secondaryProcedureName、groupFactors、remark、admvs、provinceID、provinceDesc、cityID、cityDesc、year字段

#### Scenario: 无条件查询
- **WHEN** 用户不输入任何查询条件直接查询
- **THEN** 系统返回所有特异化分组方案的分页列表

#### Scenario: 省市联动筛选
- **WHEN** 用户选择省份后
- **THEN** 市下拉列表异步加载该省份对应的市列表

### Requirement: 特异化分组方案新增
系统 SHALL 支持新增特异化分组方案，必填字段包括DRG编码、DRG名称、行政区划代码(Admvs)、省、市、年份。新增时系统自动填充创建日期、创建时间和操作人员。

#### Scenario: 新增特异化分组方案成功
- **WHEN** 用户填写完整的DRG编码、DRG名称、行政区划代码、省、市、年份后提交
- **THEN** 系统保存记录到HB_DRGSpecialGroup表并返回成功

#### Scenario: 新增重复特异化分组方案
- **WHEN** 用户在同一行政区划和同一年份下新增已存在的DRG编码+主要诊断编码+主要手术编码组合
- **THEN** 系统返回错误提示"该特异化分组方案已存在（同一行政区划同一年份下DRG+主要诊断+主要手术不能重复）"

#### Scenario: 必填字段为空
- **WHEN** 用户未填写ADRG编码或DRG编码或DRG名称或省市或年份信息就提交
- **THEN** 系统返回相应的字段必填错误提示

### Requirement: 特异化分组方案编辑
系统 SHALL 支持编辑已有特异化分组方案，编辑时自动加载当前记录的所有字段数据，市下拉列表根据所选省联动加载。

#### Scenario: 编辑特异化分组方案成功
- **WHEN** 用户修改特异化分组方案信息后提交
- **THEN** 系统更新HB_DRGSpecialGroup表中对应记录并返回成功

#### Scenario: 编辑时省市联动
- **WHEN** 用户在编辑弹窗中切换省份选择
- **THEN** 系统清空当前市选择并异步加载新省对应的市列表

### Requirement: 特异化分组方案删除
系统 SHALL 支持删除特异化分组方案，删除前需用户确认。删除采用物理删除方式。

#### Scenario: 删除特异化分组方案成功
- **WHEN** 用户确认删除某条特异化分组方案记录
- **THEN** 系统从HB_DRGSpecialGroup表中物理删除该记录并返回成功

#### Scenario: 删除ID为空
- **WHEN** 删除请求中未提供记录ID
- **THEN** 系统返回错误"删除ID不能为空"

### Requirement: 后端接口服务
系统 SHALL 通过 `src.DRG.BasicData.InterFace` 入口类提供三个接口方法，委托到 `src.DRG.BasicData.DRGSpecialGroup` 业务类执行。

#### Scenario: 接口02010064-查询特异化分组方案
- **WHEN** 前端调用接口编号02010064
- **THEN** 系统执行InterFace.GetDRGSpecialGroupList方法，委托到DRGSpecialGroup.GetDRGSpecialGroupList，返回分页查询结果

#### Scenario: 接口02010065-保存特异化分组方案
- **WHEN** 前端调用接口编号02010065
- **THEN** 系统执行InterFace.SaveDRGSpecialGroup方法，委托到DRGSpecialGroup.SaveDRGSpecialGroup，根据id是否为空判断新增或更新

#### Scenario: 接口02010066-删除特异化分组方案
- **WHEN** 前端调用接口编号02010066
- **THEN** 系统执行InterFace.DeleteDRGSpecialGroup方法，委托到DRGSpecialGroup.DeleteDRGSpecialGroup，物理删除指定ID的记录

### Requirement: 数据库表结构
系统 SHALL 使用 `User.HBDRGSpecialGroup` 持久化类（SQL表名 `HB_DRGSpecialGroup`）存储特异化分组方案，包含以下字段：DRGCode(DRG编码,必填,大写排序，前3位即为ADRG编码)、DRGName(DRG名称,必填)、PrincipalDiagnosis(主要诊断编码,支持逗号分隔多编码)、PrincipalDiagnosisName(主要诊断名称)、SecondaryDiagnosis(次要诊断编码,支持逗号分隔多编码)、SecondaryDiagnosisName(次要诊断名称)、MajorProcedure(主要手术编码,支持逗号分隔多编码)、MajorProcedureName(主要手术名称)、SecondaryProcedure(次要手术编码,支持逗号分隔多编码)、SecondaryProcedureName(次要手术名称)、GroupFactors(入组因素说明)、Remark(备注)、Admvs(行政区划代码,必填)、ProvinceDr(省,外键关联CB_Province,必填)、CityDr(市,外键关联CB_City,必填)、Year(分组方案年份,必填)、StartDate(生效日期)、StopDate(失效日期)、CreateDate(创建日期)、CreateTime(创建时间)、CreateUserDr(创建人员,外键关联HB_User)。建立DRGCode索引和(Admvs,ProvinceDr,CityDr,Year)联合索引。

#### Scenario: 数据完整性
- **WHEN** 保存特异化分组方案记录
- **THEN** DRGCode字段采用大写排序(COLLATION=UPPER)，DRG编码前3位即为对应的ADRG编码（无需单独存储），Admvs存储地区行政区划代码，ProvinceDr和CityDr分别关联行政区划表，系统自动填充创建日期、时间和操作人员

#### Scenario: 编码字段支持多值
- **WHEN** 主要诊断编码字段存储"H33.502,H35.303,H43.100,H25.100"格式
- **THEN** 分组器匹配时将其拆分为4个独立编码分别与患者诊断进行匹配，任一匹配成功即视为该维度匹配
