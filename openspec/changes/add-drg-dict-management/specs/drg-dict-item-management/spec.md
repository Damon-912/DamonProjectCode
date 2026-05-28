## ADDED Requirements

### Requirement: 按字典类型查询字典项列表
系统 SHALL 根据选中类型的 ID 查询 `ParentDr = 指定ID` 的字典项分页列表，支持按编码和名称模糊搜索，按 SortNo 升序排列。

#### Scenario: 选中类型后加载字典项
- **WHEN** 用户点击左侧某个字典类型
- **THEN** 系统查询 `WHERE ParentDr = {选中类型ID}` 并返回排序号升序的分页字典项列表

#### Scenario: 按编码搜索
- **WHEN** 用户输入编码关键字搜索
- **THEN** 系统返回 `WHERE ParentDr = {类型ID} AND Code LIKE '%keyword%'` 的结果

#### Scenario: 按名称搜索
- **WHEN** 用户输入名称关键字搜索
- **THEN** 系统返回 `WHERE ParentDr = {类型ID} AND Name LIKE '%keyword%'` 的结果

### Requirement: 新增字典项
系统 SHALL 允许在指定类型下新增字典项，ParentDr 自动设为当前类型 ID，编码在同类下唯一，SortNo 自动递增。

#### Scenario: 成功新增字典项
- **WHEN** 用户在右侧点击"新增字典项"按钮并填写信息提交
- **THEN** 系统插入新记录，ParentDr=当前类型ID，SortNo 自动递增，Status 默认 Y

#### Scenario: 编码在同一类型下重复
- **WHEN** 同类型下编码已存在
- **THEN** 系统返回错误"该类型下编码已存在"

### Requirement: 修改字典项
系统 SHALL 允许修改字典项的显示名称、排序号、说明和启用/停用状态，编码不可修改。

#### Scenario: 编辑字典项保存
- **WHEN** 用户编辑字典项后保存
- **THEN** 系统更新该记录的对应字段

### Requirement: 启用/停用字典项（Switch 开关）
系统 SHALL 支持通过状态列的 Switch 开关快速启用或停用字典项。

#### Scenario: 点击开关停用
- **WHEN** 用户点击某行启用状态的 Switch 开关
- **THEN** 开关变为灰色（N），该行 Status 更新为 N

#### Scenario: 点击开关启用
- **WHEN** 用户点击某行停用状态的 Switch 开关
- **THEN** 开关变为蓝色（Y），该行 Status 更新为 Y
