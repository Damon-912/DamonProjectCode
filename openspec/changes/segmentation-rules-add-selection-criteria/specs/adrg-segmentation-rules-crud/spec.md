## MODIFIED Requirements

### Requirement: ADRG细分规则查询
系统 SHALL 提供ADRG细分规则的分页查询功能，支持按ADRG代码(模糊匹配)、ADRG描述(模糊匹配)、省(精确匹配)、市(精确匹配)进行筛选查询，查询结果按ADRG代码排序。查询结果 SHALL 包含 selectionCriteria(入组规则) 字段。

#### Scenario: 按条件查询ADRG细分规则
- **WHEN** 用户在查询条件中输入ADRG代码、描述或选择省市后点击查询
- **THEN** 系统返回符合条件的ADRG细分规则分页列表，包含id、adrg、adrgDesc、admvs、unionFlag、segmentationFlag、selectionCriteria、provinceID、provinceDesc、cityID、cityDesc字段

#### Scenario: 无条件查询
- **WHEN** 用户不输入任何查询条件直接查询
- **THEN** 系统返回所有ADRG细分规则的分页列表

### Requirement: ADRG细分规则新增
系统 SHALL 支持新增ADRG细分规则，必填字段包括ADRG代码、ADRG描述、省、市、联合标志、细分标志，非必填字段包括入组规则(selectionCriteria)。新增时系统自动获取行政区划代码(Admvs)、更新日期、更新时间和操作人员。

#### Scenario: 新增ADRG细分规则成功
- **WHEN** 用户填写完整的ADRG代码、描述、省、市、联合标志、细分标志后提交（可选填入组规则）
- **THEN** 系统保存记录到HB_DRGSegmentationRules表并返回成功

#### Scenario: 新增重复ADRG细分规则
- **WHEN** 用户在同一省市下新增已存在的ADRG代码
- **THEN** 系统返回错误提示"该ADRG细分规则已存在（同一省市下ADRG代码不能重复）"

#### Scenario: 必填字段为空
- **WHEN** 用户未填写ADRG代码或描述或省市信息就提交
- **THEN** 系统返回相应的字段必填错误提示

### Requirement: ADRG细分规则编辑
系统 SHALL 支持编辑已有ADRG细分规则，编辑时自动加载当前记录的省、市、ADRG代码、描述、联合标志、细分标志、入组规则数据，市下拉列表根据所选省联动加载。

#### Scenario: 编辑ADRG细分规则成功
- **WHEN** 用户修改ADRG细分规则信息后提交
- **THEN** 系统更新HB_DRGSegmentationRules表中对应记录并返回成功

#### Scenario: 编辑时省市联动
- **WHEN** 用户在编辑弹窗中切换省份选择
- **THEN** 系统清空当前市选择并异步加载新省对应的市列表

### Requirement: 数据库表结构
系统 SHALL 使用 `User.HBDRGSegmentationRules` 持久化类（SQL表名 `HB_DRGSegmentationRules`）存储ADRG细分规则，包含以下字段：ADRG(ADRG代码,必填,大写排序)、ADRGDesc(ADRG描述,必填,大写排序)、ProvinceDr(省,外键关联CB_Province,必填)、CityDr(市,外键关联CB_City,必填)、Admvs(行政区划代码,必填)、UnionFlag(联合标志,必填)、SegmentationFlag(细分标志,必填)、SelectionCriteria(入组规则,非必填,字符串)、UpdateDate(更新日期,系统自动)、UpdateTime(更新时间,系统自动)、UpdateUserDr(更新人员,外键关联HB_User,系统自动)。建立ADRG索引和(ADRG,ProvinceDr,CityDr)联合索引。

#### Scenario: 数据完整性
- **WHEN** 保存ADRG细分规则记录
- **THEN** ADRG和ADRGDesc字段采用大写排序(COLLATION=UPPER)，ProvinceDr和CityDr分别关联行政区划表，系统自动填充更新日期、时间和操作人员，SelectionCriteria字段可为空

#### Scenario: 联合标志和细分标志值域
- **WHEN** 用户设置联合标志或细分标志
- **THEN** 字段值为0(否)或1(是)，前端通过下拉选择控制输入
