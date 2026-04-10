# Modal Style Guide

## ADDED Requirements

### Requirement: Modal size specification

The system SHALL provide standardized modal sizes for different use cases.

#### Scenario: Small modal for confirmation
- **WHEN** a component requests a small modal (sm)
- **THEN** the modal width SHALL be 400px and height SHALL be auto

#### Scenario: Medium modal for simple forms
- **WHEN** a component requests a medium modal (md)
- **THEN** the modal width SHALL be 600px and height SHALL be auto

#### Scenario: Large modal for complex forms
- **WHEN** a component requests a large modal (lg)
- **THEN** the modal width SHALL be 900px and height SHALL be 70vh

#### Scenario: Extra-large modal for data tables
- **WHEN** a component requests an extra-large modal (xl)
- **THEN** the modal width SHALL be 1200px and height SHALL be 80vh

### Requirement: Modal footer button layout

The system SHALL enforce consistent button layout in modal footers.

#### Scenario: Standard footer layout
- **WHEN** a modal has action buttons
- **THEN** buttons SHALL be positioned at the bottom-right of the modal
- **AND** the primary action button (确定) SHALL appear on the right
- **AND** the secondary action button (取消) SHALL appear on the left of the primary button

### Requirement: Modal title style

The system SHALL enforce consistent modal title styling.

#### Scenario: Title rendering
- **WHEN** a modal is displayed
- **THEN** the title SHALL use 18px font size
- **AND** the title SHALL be bold
- **AND** the title text SHALL be left-aligned

### Requirement: Modal animation

The system SHALL provide consistent modal animations.

#### Scenario: Open animation
- **WHEN** a modal is opened
- **THEN** the modal SHALL fade in with a 200ms transition

#### Scenario: Close animation
- **WHEN** a modal is closed
- **THEN** the modal SHALL fade out with a 200ms transition

### Requirement: Modal mask

The system SHALL enforce consistent modal mask behavior.

#### Scenario: Mask configuration
- **WHEN** a modal is displayed
- **THEN** the mask SHALL be semi-transparent black (#00000066)
- **AND** clicking the mask SHALL close the modal by default
