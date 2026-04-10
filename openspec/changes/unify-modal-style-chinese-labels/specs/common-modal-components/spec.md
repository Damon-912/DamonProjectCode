# Common Modal Components

## ADDED Requirements

### Requirement: ConfirmModal component

The system SHALL provide a ConfirmModal component for confirmation dialogs.

#### Scenario: Basic confirmation dialog
- **WHEN** a ConfirmModal is rendered with open=true
- **THEN** it SHALL display a title
- **AND** it SHALL display the content message
- **AND** it SHALL display "确定" and "取消" buttons

#### Scenario: Custom button text
- **WHEN** a ConfirmModal is rendered with custom okText
- **THEN** the primary button SHALL display the specified text

#### Scenario: Close on mask click
- **WHEN** a user clicks on the modal mask
- **THEN** the modal SHALL be closed
- **AND** the onCancel callback SHALL be invoked

#### Scenario: Close on cancel button
- **WHEN** a user clicks the "取消" button
- **THEN** the modal SHALL be closed
- **AND** the onCancel callback SHALL be invoked

#### Scenario: Execute on ok button
- **WHEN** a user clicks the "确定" button
- **THEN** the onOk callback SHALL be invoked

### Requirement: FormModal component

The system SHALL provide a FormModal component for form editing dialogs.

#### Scenario: Form modal with size
- **WHEN** a FormModal is rendered with size="lg"
- **THEN** the modal SHALL have width of 900px and height of 70vh

#### Scenario: Form validation on submit
- **WHEN** a user clicks the submit button with invalid form data
- **THEN** the form SHALL display validation errors
- **AND** the onOk callback SHALL NOT be invoked

#### Scenario: Successful form submission
- **WHEN** a user clicks the submit button with valid form data
- **THEN** the onOk callback SHALL be invoked with form values
- **AND** the modal SHALL be closed

#### Scenario: Cancel form editing
- **WHEN** a user clicks the "取消" button
- **THEN** the modal SHALL be closed
- **AND** the form SHALL be reset to initial values
- **AND** the onCancel callback SHALL be invoked

#### Scenario: Loading state during submission
- **WHEN** a FormModal is in loading state
- **THEN** all buttons SHALL be disabled
- **AND** a loading indicator SHALL be displayed

### Requirement: DrawerModal component

The system SHALL provide a DrawerModal component for side-panel dialogs.

#### Scenario: Right-side drawer
- **WHEN** a DrawerModal is rendered
- **THEN** the drawer SHALL appear from the right side
- **AND** the width SHALL be 600px by default

#### Scenario: Drawer with form
- **WHEN** a DrawerModal contains a form
- **THEN** the form footer SHALL have "确定" and "取消" buttons

#### Scenario: Close drawer
- **WHEN** a user clicks the close icon or clicks outside
- **THEN** the drawer SHALL be closed
- **AND** the onClose callback SHALL be invoked

### Requirement: Component API consistency

The system SHALL enforce consistent API patterns across all modal components.

#### Scenario: Open/close state management
- **WHEN** any modal component is used
- **THEN** it SHALL accept an `open` prop to control visibility
- **AND** it SHALL accept an `onCancel` or `onClose` callback for close events

#### Scenario: Standard footer buttons
- **WHEN** any modal component displays footer buttons
- **THEN** the buttons SHALL follow the button text standardization spec
