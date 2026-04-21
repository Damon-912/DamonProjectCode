## ADDED Requirements

### Requirement: Create new DIP core algorithm configuration
The system SHALL allow users to create new DIP core algorithm configurations through a form with validation.

#### Scenario: Open create modal
- **WHEN** user clicks the "新增配置" button
- **THEN** system opens a modal dialog with an empty form
- **AND** province dropdown is loaded with available provinces

#### Scenario: Submit valid new configuration
- **WHEN** user fills in all required fields (principal diagnosis code, principal diagnosis name, province, city, medical institution level, score value)
- **AND** user clicks the save button
- **THEN** system validates the form
- **AND** system saves the configuration to database
- **AND** system displays success message
- **AND** modal closes and list refreshes

#### Scenario: Validation error for missing required fields
- **WHEN** user submits form without filling required fields
- **THEN** system displays validation error messages for each missing field
- **AND** form is not submitted

#### Scenario: Province-city cascade selection
- **WHEN** user selects a province
- **THEN** city dropdown is cleared and populated with cities for that province
- **AND** mdtrtArea field is auto-populated with the city's administrative code

### Requirement: Update existing DIP core algorithm configuration
The system SHALL allow users to modify existing DIP core algorithm configurations.

#### Scenario: Open edit modal
- **WHEN** user clicks the "编辑" button on a configuration row
- **THEN** system opens the modal with form pre-filled with current values
- **AND** province and city dropdowns are loaded with current selections

#### Scenario: Submit valid update
- **WHEN** user modifies one or more fields
- **AND** user clicks the save button
- **THEN** system validates the form
- **AND** system updates the configuration in database
- **AND** system displays success message
- **AND** modal closes and list refreshes

#### Scenario: Cancel edit operation
- **WHEN** user clicks the cancel button or closes the modal
- **THEN** modal closes without saving changes
- **AND** list remains unchanged

### Requirement: Handle data conversion
The system SHALL properly handle data type conversions between frontend and backend.

#### Scenario: Numeric coefficient conversion
- **WHEN** user enters decimal values for adjustment coefficients
- **THEN** system stores them as strings in the database
- **AND** frontend displays them with proper decimal formatting

#### Scenario: Medical institution level mapping
- **WHEN** user selects "一级" from dropdown
- **THEN** system stores value "1" in database
- **AND** when displaying, "1" is mapped back to "一级"
