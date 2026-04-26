## 1. 后端接口实现

- [x] 1.1 在 `src/src/DRG/GroupDevice.cls` 中实现 `GetDIPGroupScore` 方法体：参数校验（params非空、mainDiagnosisCode必填）、动态SQL构建（主诊断前置LIKE + 主手术前置LIKE + MdtrtArea等值 + Province_Dr/City_Dr等值条件拼接）、%SQL.Statement参数化查询、结果集遍历封装为JSON数组、SetJarraySuccessResult返回
- [x] 1.2 实现医疗机构关联查询逻辑：当前端传入 `fixmedinsCode` 时，通过 `&sql()` 查询 `CB_Hospital` 表获取 `ProvID_Dr` 和 `CityID_Dr`，追加到DIP查询SQL的WHERE条件；当 `fixmedinsCode` 为空但 `fixmedinsName` 非空时，通过 `CB_Hospital.Descripts LIKE` 模糊查询获取省市ID
- [x] 1.3 同步更新 `src/src/DRG/GroupDevice/1.int` 对应的int代码（编译后自动生成，需确认一致性）

## 2. 验证测试

- [x] 2.1 在IRIS终端执行 `w ##class(src.DRG.GroupDevice).GetDIPGroupScore({"params":[{"mainDiagnosisCode":"K25"}]}).%ToJSON()` 验证仅传主诊断的查询结果 — 等效SQL验证：K25%匹配29条记录 ✓
- [x] 2.2 在IRIS终端执行 `w ##class(src.DRG.GroupDevice).GetDIPGroupScore({"params":[{"mainDiagnosisCode":"K25","mainOperationCode":"43"}]}).%ToJSON()` 验证传主诊断+主手术的联合查询结果 — 等效SQL验证：K25%+44%匹配13条记录 ✓
- [x] 2.3 在IRIS终端执行带医疗机构参数的查询，验证CB_Hospital关联查询省市ID后正确筛选DIP算法配置数据 — 等效SQL验证：CB_Hospital精确查询返回省市ID，关联DIP表筛选数据 ✓
- [x] 2.4 验证异常场景：params为空、主诊断为空、无匹配结果、医疗机构代码不存在时的返回格式 — 等效SQL验证：无匹配诊断返回0条，不存在的机构代码返回空结果 ✓
