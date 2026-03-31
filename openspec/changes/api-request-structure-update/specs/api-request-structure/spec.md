## MODIFIED Requirements

### Requirement: Standard API request body structure
The system SHALL define a standard request body structure for all API calls to the IRIS backend.

#### Scenario: Complete request body structure
- **WHEN** making any API request via the `invoke` function
- **THEN** the request body MUST contain the following fixed fields:
  - `code`: string - The API interface code (e.g., "02010023")
  - `params`: array - Array of parameter objects (can be empty)
  - `session`: array - Array containing exactly one SessionInfo object
- **AND** the request body MAY contain the optional field:
  - `pagination`: array - Array containing exactly one pagination object (only for query operations)

#### Scenario: Request body JSON structure
- **WHEN** the request is sent to the backend
- **THEN** the JSON structure SHALL be:
```json
{
  "code": "02010023",
  "params": [{...}],
  "session": [{
    "userID": "",
    "userCode": "",
    "userName": "",
    "locID": "",
    "locDesc": "",
    "groupID": "",
    "groupDesc": "",
    "hospID": "",
    "hospCode": "",
    "hospDesc": "",
    "langID": 1,
    "langDesc": "",
    "changeFlag": "",
    "changeDesc": "",
    "defaultMenuType": "",
    "mainInterface": "",
    "path": "",
    "sessionID": ""
  }],
  "pagination": [{
    "pageSize": 20,
    "currentPage": 1,
    "sortColumn": "",
    "sortOrder": ""
  }]
}
```

### Requirement: Invoke function parameter order
The system SHALL update the `invoke` function to accept parameters in the order: code, params, session, pagination.

#### Scenario: Non-paginated API calls
- **WHEN** calling `invoke` for save/delete/update operations
- **THEN** the function signature SHALL be `invoke(code, params)`
- **AND** session SHALL be automatically retrieved from localStorage
- **AND** pagination SHALL NOT be included in the request body

#### Scenario: Paginated API calls
- **WHEN** calling `invoke` for query/list operations
- **THEN** the function signature SHALL be `invoke(code, params, undefined, pagination)`
- **AND** passing `undefined` as session SHALL use the default from localStorage
- **AND** pagination SHALL be included in the request body as `pagination: [paginationObject]`

#### Scenario: Custom session override
- **WHEN** calling `invoke` with a custom session object
- **THEN** the function SHALL use the provided session instead of localStorage
- **AND** the signature SHALL be `invoke(code, params, customSession)` or `invoke(code, params, customSession, pagination)`

### Requirement: API module updates
All API modules SHALL be updated to use the new `invoke` function signature.

#### Scenario: Query operations in API modules
- **WHEN** a query operation (e.g., `queryIcdMapping`) is called
- **THEN** the implementation SHALL call `invoke(code, [params], undefined, pagination)`
- **AND** the pagination parameter SHALL be passed as the fourth argument

#### Scenario: Non-query operations in API modules
- **WHEN** a save/delete operation (e.g., `saveIcdMapping`, `deleteIcdMapping`) is called
- **THEN** the implementation SHALL call `invoke(code, [params])`
- **AND** session SHALL be automatically handled by the `invoke` function

## ADDED Requirements

### Requirement: SessionInfo TypeScript interface
The system SHALL export a TypeScript interface `SessionInfo` for type-safe session handling.

#### Scenario: Interface definition
- **WHEN** importing `SessionInfo` from the request module
- **THEN** the interface SHALL define all required session fields with proper types
- **AND** the interface SHALL be usable for both reading and writing session data

### Requirement: Default session retrieval
The system SHALL provide a `getDefaultSession` function that retrieves session from localStorage.

#### Scenario: Function behavior
- **WHEN** `getDefaultSession` is called
- **THEN** it SHALL first attempt to read from localStorage key "session"
- **AND** if found, parse and return the SessionInfo object
- **AND** if not found or parse fails, return a default SessionInfo with empty values
