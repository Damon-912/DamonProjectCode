## ADDED Requirements

### Requirement: Query DIP core algorithm configuration list
The system SHALL provide a paginated query interface for DIP core algorithm configurations with support for multiple filter conditions.

#### Scenario: Query with pagination
- **WHEN** user opens the DIP core algorithm configuration page
- **THEN** system displays a paginated list of configurations (default 15 items per page)
- **AND** list includes fields: principal diagnosis code/name, major procedure code/name, province, city, medical institution level, score value

#### Scenario: Filter by principal diagnosis
- **WHEN** user enters a principal diagnosis code or name in the search field
- **THEN** system filters results to show only configurations matching the diagnosis (fuzzy match supported)

#### Scenario: Filter by province and city
- **WHEN** user selects a province from the dropdown
- **THEN** city dropdown is populated with cities belonging to that province
- **AND** system filters results by selected province and city

#### Scenario: Filter by medical institution level
- **WHEN** user selects a medical institution level (1: 一级, 2: 二级, 3: 三级)
- **THEN** system filters results to show only configurations for that level

#### Scenario: Empty result handling
- **WHEN** query returns no matching records
- **THEN** system displays an empty table with appropriate message
- **AND** pagination controls are hidden

### Requirement: Display configuration details
The system SHALL display detailed information for each DIP core algorithm configuration in the list view.

#### Scenario: View all fields in list
- **WHEN** configuration list is displayed
- **THEN** each row shows: principal diagnosis code, principal diagnosis name, major procedure code, major procedure name, province description, city description, medical institution level, score value, adjustment coefficients

#### Scenario: Handle missing optional fields
- **WHEN** a configuration has empty optional fields (e.g., secondary procedure, adjustment coefficients)
- **THEN** those fields display as empty or "-" in the list
