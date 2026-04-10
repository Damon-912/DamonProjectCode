## ADDED Requirements

### Requirement: DRG目录信息查询
系统 SHALL 提供DRG目录信息的分页查询功能，支持按DRG代码(模糊匹配)、DRG描述(模糊匹配)、省(精确匹配)、市(精确匹配)进行筛选查询，查询结果按DRG代码排序。

#### Scenario: 按条件查询DRG目录
- **WHEN** 用户在查询条件中输入DRG代码、描述或选择省市后点击查询
- **THEN** 系统返回符合条件的DRG目录信息分页列表，包含id、code、descripts、admvs、provinceID、provinceDesc、cityID、cityDesc字段

#### Scenario: 无条件查询
- **WHEN** 用户不输入任何查询条件直接查询
- **THEN** 系统返回所有DRG目录信息的分页列表

### Requirement: DRG目录信息新增
系统 SHALL 支持新增DRG目录信息，必填字段包括DRG代码、DRG描述、省、市。新增时系统自动获取行政区划代码(Admvs)、更新日期、更新时间和操作人员。

#### Scenario: 新增DRG目录成功
- **WHEN** 用户填写完整的DRG代码、描述、省、市信息后提交
- **THEN** 系统保存记录到HB_DRGCataLog表并返回成功

#### Scenario: 新增重复DRG目录
- **WHEN** 用户在同一省市下新增已存在的DRG代码
- **THEN** 系统返回错误提示"该DRG目录已存在（同一省市下代码不能重复）"

#### Scenario: 必填字段为空
- **WHEN** 用户未填写DRG代码或描述或省市信息就提交
- **THEN** 系统返回相应的字段必填错误提示

### Requirement: DRG目录信息编辑
系统 SHALL 支持编辑已有DRG目录信息，编辑时自动加载当前记录的省、市、代码、描述数据，市下拉列表根据所选省联动加载。

#### Scenario: 编辑DRG目录成功
- **WHEN** 用户修改DRG目录信息后提交
- **THEN** 系统更新HB_DRGCataLog表中对应记录并返回成功

#### Scenario: 编辑时省市联动
- **WHEN** 用户在编辑弹窗中切换省份选择
- **THEN** 系统清空当前市选择并异步加载新省对应的市列表

### Requirement: DRG目录信息删除
系统 SHALL 支持删除DRG目录信息，删除前需用户确认。删除采用物理删除方式。

#### Scenario: 删除DRG目录成功
- **WHEN** 用户确认删除某条DRG目录记录
- **THEN** 系统从HB_DRGCataLog表中物理删除该记录并返回成功

#### Scenario: 删除ID为空
- **WHEN** 删除请求中未提供记录ID
- **THEN** 系统返回错误"删除ID不能为空"

### Requirement: 前端菜单注册
系统 SHALL 在"基础数据管理"菜单分组下注册"DRGs目录信息表"菜单项，菜单key为 `basic-data-drg-catalog`，点击后展示DRGCataLog页面组件。

#### Scenario: 菜单展示
- **WHEN** 用户展开"基础数据管理"菜单分组
- **THEN** 可见"DRGs目录信息表"菜单项

#### Scenario: 菜单点击导航
- **WHEN** 用户点击"DRGs目录信息表"菜单项
- **THEN** 系统渲染DRGCataLog页面组件，展示查询条件区和数据表格

### Requirement: 后端接口服务
系统 SHALL 通过 `src.DRG.BasicData.InterFace` 入口类提供三个接口方法，委托到 `src.DRG.BasicData.DRGCataLog` 业务类执行。

#### Scenario: 接口02010041-查询DRG目录
- **WHEN** 前端调用接口编号02010041
- **THEN** 系统执行InterFace.GetDRGCataLogList方法，委托到DRGCataLog.GetDRGCataLogList，返回分页查询结果

#### Scenario: 接口02010042-保存DRG目录
- **WHEN** 前端调用接口编号02010042
- **THEN** 系统执行InterFace.SaveDRGCataLog方法，委托到DRGCataLog.SaveDRGCataLog，根据id是否为空判断新增或更新

#### Scenario: 接口02010043-删除DRG目录
- **WHEN** 前端调用接口编号02010043
- **THEN** 系统执行InterFace.DeleteDRGCataLog方法，委托到DRGCataLog.DeleteDRGCataLog，物理删除指定ID的记录

### Requirement: 数据库表结构
系统 SHALL 使用 `User.HBDRGCataLog` 持久化类（SQL表名 `HB_DRGCataLog`）存储DRG目录信息，包含以下字段：Code(DRGs代码,必填,大写排序)、Descripts(DRGs描述,必填,大写排序)、ProvinceDr(省,外键关联CB_Province,必填)、CityDr(市,外键关联CBCity,必填)、Admvs(行政区划代码,必填)、UpdateDate(更新日期,系统自动)、UpdateTime(更新时间,系统自动)、UpdateUserDr(更新人员,外键关联HB_User,系统自动)。建立Code索引和(Code,ProvinceDr,CityDr)联合索引。

#### Scenario: 数据完整性
- **WHEN** 保存DRG目录记录
- **THEN** Code和Descripts字段采用大写排序(COLLATION=UPPER)，ProvinceDr和CityDr分别关联行政区划表，系统自动填充更新日期、时间和操作人员
