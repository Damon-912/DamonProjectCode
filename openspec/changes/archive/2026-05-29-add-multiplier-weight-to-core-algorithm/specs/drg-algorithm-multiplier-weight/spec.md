## ADDED Requirements

### Requirement: DRG核心算法配置支持高倍率字段

系统 SHALL 在 `HB_DRGCoreAlgorithmData` 表中支持存储"高倍率"（HighMultiplier）字段，用于标识费用偏高的倍率阈值。该字段为可选的数值类型，由用户在前端配置页面手动输入。

#### Scenario: 新增DRG配置时填写高倍率
- **WHEN** 用户在新增DRG核心算法配置表单中输入高倍率值（如 "2.5"）
- **THEN** 系统将该值保存到 `HighMultiplier` 字段
- **AND** 保存成功后该记录的高倍率字段值为 "2.5"

#### Scenario: 编辑DRG配置时修改高倍率
- **WHEN** 用户编辑已有DRG核心算法配置，将高倍率从 "2.5" 修改为 "3.0"
- **THEN** 系统将 `HighMultiplier` 字段更新为 "3.0"
- **AND** 其他字段不受影响

#### Scenario: 不填写高倍率时保存
- **WHEN** 用户在新增或编辑时未填写高倍率字段
- **THEN** 系统正常保存配置，`HighMultiplier` 字段为空
- **AND** 不弹出任何必填校验错误

#### Scenario: 查询配置时返回高倍率
- **WHEN** 用户查询DRG核心算法配置列表
- **THEN** 返回的每条记录中包含 `highMultiplier` 字段，值为存储的高倍率数据

### Requirement: DRG核心算法配置支持低倍率字段

系统 SHALL 在 `HB_DRGCoreAlgorithmData` 表中支持存储"低倍率"（LowMultiplier）字段，用于标识费用偏低的倍率阈值。该字段为可选的数值类型。

#### Scenario: 新增DRG配置时填写低倍率
- **WHEN** 用户在新增DRG核心算法配置表单中输入低倍率值（如 "0.5"）
- **THEN** 系统将该值保存到 `LowMultiplier` 字段

#### Scenario: 不填写低倍率时保存
- **WHEN** 用户在新增或编辑时未填写低倍率字段
- **THEN** 系统正常保存配置，`LowMultiplier` 字段为空

### Requirement: DRG核心算法配置支持权重字段

系统 SHALL 在 `HB_DRGCoreAlgorithmData` 表中支持存储"权重"（Weight）字段，用于病组间费用比较和分摊计算。该字段为可选的数值类型。

#### Scenario: 新增DRG配置时填写权重
- **WHEN** 用户在新增DRG核心算法配置表单中输入权重值（如 "1.2"）
- **THEN** 系统将该值保存到 `Weight` 字段

#### Scenario: 不填写权重时保存
- **WHEN** 用户在新增或编辑时未填写权重字段
- **THEN** 系统正常保存配置，`Weight` 字段为空

### Requirement: 导入模板支持新字段

系统 SHALL 在DRG核心算法配置的CSV导入模板中包含高倍率、低倍率、权重列。

#### Scenario: 下载导入模板包含新字段
- **WHEN** 用户点击下载导入模板按钮
- **THEN** 生成的CSV文件表头包含 `HighMultiplier,LowMultiplier,Weight` 列
- **AND** 示例数据中新字段值为 `NULL`（表示可选）

#### Scenario: 导入预览解析新字段
- **WHEN** 用户上传包含高倍率、低倍率、权重的CSV文件进行预览
- **THEN** 预览表格中显示对应的三列数据
- **AND** 新字段不是必填项，不会因缺失而校验失败

#### Scenario: 确认导入时写入新字段
- **WHEN** 用户确认导入包含新字段的DRG配置数据
- **THEN** 系统将 `HighMultiplier`、`LowMultiplier`、`Weight` 值写入对应字段

### Requirement: 前端列表展示新字段

系统 SHALL 在DRG核心算法配置列表表格中以独立列展示高倍率、低倍率、权重三个字段。

#### Scenario: 列表显示新字段列
- **WHEN** 用户打开DRG核心算法配置页面
- **THEN** 表格中在"预估支付标准"列之后显示"高倍率"、"低倍率"、"权重"三列
- **AND** 每列数值右对齐显示
