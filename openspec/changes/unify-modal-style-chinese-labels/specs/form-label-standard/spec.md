# Form Label Standard

## ADDED Requirements

### Requirement: Chinese label requirement

The system SHALL use Chinese text for all form labels.

#### Scenario: Label language
- **WHEN** a Form.Item component is rendered
- **THEN** the label prop SHALL contain only Chinese characters
- **AND** English words like "code", "name", "desc", "type" SHALL NOT be used

### Requirement: Required field indicator

The system SHALL use consistent required field indicators.

#### Scenario: Required field label
- **WHEN** a field is required
- **THEN** the label SHALL start with a red asterisk (*) followed by a space
- **AND** the format SHALL be "* 字段名称"

#### Scenario: Optional field label
- **WHEN** a field is optional
- **THEN** the label SHALL NOT contain any asterisk
- **AND** the format SHALL be "字段名称"

### Requirement: Unit specification in labels

The system SHALL use consistent unit specification format.

#### Scenario: Numeric fields with units
- **WHEN** a field represents a numeric value with a unit
- **THEN** the unit SHALL be placed inside Chinese parentheses at the end of the label
- **AND** the format SHALL be "字段名称(单位)"
- **AND** the unit SHALL be in Chinese (e.g., "岁", "元", "%")

#### Scenario: Common units
- **WHEN** the field represents age
- **THEN** the label SHALL be "年龄(岁)"
- **WHEN** the field represents amount
- **THEN** the label SHALL be "金额(元)"
- **WHEN** the field represents percentage
- **THEN** the label SHALL be "比例(%)"

### Requirement: Button text standardization

The system SHALL use standardized Chinese button text.

#### Scenario: Primary action button
- **WHEN** a button performs a confirm/submit action
- **THEN** the button text SHALL be "确定"

#### Scenario: Cancel button
- **WHEN** a button performs a cancel/abort action
- **THEN** the button text SHALL be "取消"

#### Scenario: Delete button
- **WHEN** a button performs a delete action
- **THEN** the button text SHALL be "删除"

#### Scenario: Add button
- **WHEN** a button performs an add/create action
- **THEN** the button text SHALL be "新增"

#### Scenario: Edit button
- **WHEN** a button performs an edit action
- **THEN** the button text SHALL be "编辑"

#### Scenario: Save button
- **WHEN** a button performs a save action
- **THEN** the button text SHALL be "保存"

### Requirement: Select option labels

The system SHALL use Chinese text for all select option labels.

#### Scenario: Status options
- **WHEN** a select field has status options
- **THEN** "启用" SHALL be used for active status
- **AND** "停用" SHALL be used for inactive status

#### Scenario: Type options
- **WHEN** a select field has type options
- **THEN** the type names SHALL be in Chinese (e.g., "模块", "页面", "按钮")
