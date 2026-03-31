## 1. Core Request Module Updates

- [x] 1.1 Add `SessionInfo` TypeScript interface to `request.ts`
- [x] 1.2 Implement `getDefaultSession` function to read from localStorage
- [x] 1.3 Update `invoke` function signature to `(code, params?, session?, pagination?)`
- [x] 1.4 Update request body construction to include `session` array

## 2. API Module Updates

- [x] 2.1 Update `basicData.ts` - Add `undefined` as session parameter for 9 query operations
  - [x] 2.1.1 `queryIcdMapping` (02010025)
  - [x] 2.1.2 `queryMedInsuIcdInfo` (02010022)
  - [x] 2.1.3 `queryIcdInfo` (02010037)
  - [x] 2.1.4 `queryAdrgRules` (02010017)
  - [x] 2.1.5 `queryCoreAlgorithm` (02010033)
  - [x] 2.1.6 `queryDipDiseases` (02010020)
  - [x] 2.1.7 `queryBasicData` (02010011)
  - [x] 2.1.8 `queryBasicDataSub` (02010014)
  - [x] 2.1.9 `queryHospitalList` (03020113)
- [x] 2.2 Update `system.ts` - Add `undefined` as session parameter for 1 query operation
  - [x] 2.2.1 `queryInterfaceServices` (01010017)

## 3. Verification and Testing

- [ ] 3.1 Test non-paginated API calls (save/delete operations)
- [ ] 3.2 Test paginated API calls (query operations)
- [ ] 3.3 Verify session data is correctly included in request body
- [ ] 3.4 Verify localStorage session retrieval works correctly
- [ ] 3.5 Test error handling when localStorage has invalid session data

## 4. Documentation

- [x] 4.1 Create OpenSpec proposal document
- [x] 4.2 Create OpenSpec design document
- [x] 4.3 Create OpenSpec spec documents for new capabilities
- [ ] 4.4 Update API usage documentation for developers
- [ ] 4.5 Document session field meanings and usage

## 5. Backend Coordination (Not in scope for frontend)

- [ ] 5.1 Update IRIS backend to parse `session` field from request body
- [ ] 5.2 Implement session validation logic in backend
- [ ] 5.3 Ensure backward compatibility for requests without session
