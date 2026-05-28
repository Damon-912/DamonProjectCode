## ADDED Requirements

### Requirement: 查询字典类型列表
系统 SHALL 提供查询所有字典类型列表的接口，查询条件为 `ParentDr IS NULL`，不分页返回全部。

#### Scenario: 加载字典类型
- **WHEN** 用户访问字典管理页面
- **THEN** 系统返回所有 `ParentDr` 为空的字典类型列表，包含 ID、编码、名称、状态、排序号

### Requirement: 维护字典类型
系统 SHALL 提供字典类型的保存接口，支持新增和修改、启用/停用（Status Y/N）。字典类型的新增/编辑可通过其他管理入口完成。

#### Scenario: 保存字典类型
- **WHEN** 调用 SaveDRGDictType 保存类型信息
- **THEN** 系统新增或更新 CB_DRGDictTable 中 ParentDr=NULL 的记录
