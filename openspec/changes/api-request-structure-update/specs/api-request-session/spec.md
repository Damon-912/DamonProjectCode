## ADDED Requirements

### Requirement: SessionInfo interface definition
The system SHALL define a TypeScript interface `SessionInfo` to standardize session information passed in API requests.

#### Scenario: SessionInfo interface structure
- **WHEN** the frontend makes an API call
- **THEN** the session object MUST contain the following fields:
  - `userID`: string - User unique identifier
  - `userCode`: string - User login code
  - `userName`: string - User display name
  - `locID`: string - Current location/department ID
  - `locDesc`: string - Current location/department description
  - `groupID`: string - User group ID
  - `groupDesc`: string - User group description
  - `hospID`: string - Hospital ID
  - `hospCode`: string - Hospital code
  - `hospDesc`: string - Hospital description
  - `langID`: number - Language ID (default: 1)
  - `langDesc`: string - Language description
  - `changeFlag`: string - Change flag indicator
  - `changeDesc`: string - Change description
  - `defaultMenuType`: string - Default menu type
  - `mainInterface`: string - Main interface identifier
  - `path`: string - Current path
  - `sessionID`: string - Session unique identifier

### Requirement: Session data retrieval
The system SHALL provide a `getDefaultSession` function to retrieve session information from localStorage or return default empty values.

#### Scenario: Retrieve session from localStorage
- **WHEN** `getDefaultSession` is called and localStorage contains valid session data
- **THEN** the function SHALL return the parsed SessionInfo object from localStorage

#### Scenario: Return default session when localStorage is empty
- **WHEN** `getDefaultSession` is called and localStorage has no session data
- **THEN** the function SHALL return a SessionInfo object with all fields set to empty strings (langID defaults to 1)

#### Scenario: Handle localStorage parse errors
- **WHEN** `getDefaultSession` is called and localStorage contains invalid JSON
- **THEN** the function SHALL log a warning and return the default empty SessionInfo object

### Requirement: Session in request body
The system SHALL include session information as a required field in all API request bodies.

#### Scenario: Request body structure with session
- **WHEN** any API request is made via the `invoke` function
- **THEN** the request body MUST contain a `session` field as an array containing one SessionInfo object
- **AND** the structure SHALL be: `{ code: string, params: any[], session: [SessionInfo], pagination?: [Pagination] }`

## MODIFIED Requirements

### Requirement: Invoke function signature
The system SHALL update the `invoke` function signature to accept session and pagination as separate optional parameters.

#### Scenario: Updated function signature
- **WHEN** calling the `invoke` function
- **THEN** the parameter order SHALL be: `(code: string, params?: any[], session?: SessionInfo, pagination?: any)`
- **AND** the pagination parameter SHALL only be provided for query/list operations

#### Scenario: Backward compatibility for non-paginated calls
- **WHEN** calling `invoke` without pagination (e.g., save/delete operations)
- **THEN** the function SHALL work correctly with just `code` and `params` parameters
- **AND** session SHALL be automatically populated from localStorage

#### Scenario: Paginated query calls
- **WHEN** calling `invoke` for paginated queries
- **THEN** the call SHALL pass `undefined` as the session parameter to use default
- **AND** pass the pagination object as the fourth parameter
- **AND** the request body SHALL include `pagination: [paginationObject]`
