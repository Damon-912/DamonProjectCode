## 1. API层建设

- [x] 1.1 在 `api/system.ts` 中定义用户管理相关的TypeScript接口类型：UserItem（用户列表项）、UserDetailItem（用户详情）、UserAuditLogItem（申请记录项）、UserLogonLocItem（权限角色项）、SaveUserParams（新增/编辑参数）、UserApplyParams（申请参数）、AuditParams（审核参数）、SaveUserLogonLocParams（角色分配参数）
- [x] 1.2 在 `api/system.ts` 中实现 `queryUsers` 函数（code: 01030101），接受筛选参数和分页参数；**注意**：后端会根据session中的groupID自动进行医院数据权限过滤
- [x] 1.3 在 `api/system.ts` 中实现 `saveUser` 函数（code: 01030102），处理新增/编辑用户；**注意**：后端使用session.userID作为创建人和更新人
- [x] 1.4 在 `api/system.ts` 中实现 `queryApplyLogs` 函数（code: 01030107），查询申请记录列表
- [x] 1.5 在 `api/system.ts` 中实现 `getUserAuditLogDetail` 函数（code: 01030108），查询申请详情
- [x] 1.6 在 `api/system.ts` 中实现 `submitUserApply` 函数（code: 01030105），提交注册申请
- [x] 1.7 在 `api/system.ts` 中实现 `auditUserApply` 函数（code: 01030106），审核用户申请；**注意**：后端使用session.userID作为审核人
- [x] 1.8 在 `api/system.ts` 中实现 `saveUserLogonLoc` 函数（code: 01030109），保存/更新权限角色；**注意**：后端使用session.userID作为更新人
- [x] 1.9 在 `api/system.ts` 中实现 `deleteUserLogonLoc` 函数（code: 01030110），删除权限角色；**注意**：后端使用session.userID作为更新人
- [x] 1.10 在 `api/system.ts` 中实现 `getUserDetail` 函数（code: 01030111），查询用户详情含角色列表
- [x] 1.11 **Session校验处理**：确保所有API调用通过 `invoke` 函数自动传入session；在API响应拦截中统一处理session失效错误（errorCode为特定值时跳转登录页）

## 2. 用户管理页面实现

- [x] 2.1 重写 `pages/System/Users.tsx` 页面骨架：查询条件区域（医院下拉、用户编码输入、姓名输入、状态下拉）+ 工具栏（新增按钮）+ 表格区域 + 分页
- [x] 2.2 实现用户列表数据加载和分页逻辑，调用 `queryUsers` API
- [x] 2.3 实现筛选查询和重置功能
- [x] 2.4 实现新增用户弹窗（Form表单：姓名、手机号、性别、证件类型、证件号、出生日期、工作手机、邮箱、昵称、所属医院、启用日期、停用日期、状态），调用 `saveUser` API
- [x] 2.5 实现编辑用户弹窗（复用新增弹窗，回填数据并传递userDr），调用 `saveUser` API
- [x] 2.6 实现用户状态标签展示（Y=绿色启用、N=红色停用）

## 3. 用户权限角色管理实现

- [x] 3.1 在用户管理页面实现用户详情弹窗，调用 `getUserDetail` API，展示用户基本信息
- [x] 3.2 在详情弹窗中展示权限角色列表（表格：医院编码、医院名称、角色名称、是否默认、更新时间、操作列）
- [x] 3.3 实现添加角色弹窗（医院选择+角色选择+是否默认），调用 `saveUserLogonLoc` API
- [x] 3.4 实现删除角色功能（Popconfirm确认），调用 `deleteUserLogonLoc` API
- [x] 3.5 实现设置默认角色功能，调用 `saveUserLogonLoc` API（isDefault="Y"）

## 4. 用户申请审核页面实现

- [x] 4.1 创建 `pages/System/UserApply.tsx` 页面骨架：查询条件区域（审核状态下拉、医院下拉、申请日期范围）+ 工具栏（新增申请按钮）+ 表格区域 + 分页
- [x] 4.2 实现申请记录列表数据加载和分页逻辑，调用 `queryApplyLogs` API
- [x] 4.3 实现筛选查询和重置功能
- [x] 4.4 实现审核状态标签展示（R=橙色待审核、Y=绿色已通过、N=红色已驳回）
- [x] 4.5 实现申请详情查看弹窗，调用 `getUserAuditLogDetail` API
- [x] 4.6 实现审核操作弹窗（展示详情+通过/驳回按钮+审核备注输入），调用 `auditUserApply` API
- [x] 4.7 实现新增申请弹窗（表单：编码、姓名、性别、手机号、证件类型、证件号、所属医院、简介、审核组），调用 `submitUserApply` API

## 5. 菜单与路由集成

- [x] 5.1 在 `App.tsx` 的系统管理菜单中新增"用户申请审核"菜单项（key: system-user-apply，位于用户管理之后）
- [x] 5.2 在 `App.tsx` 的 menuTitleMap 中添加 `system-user-apply: '用户申请审核'` 映射
- [x] 5.3 在 `App.tsx` 中导入 UserApply 组件，并在 renderContent 的 switch 中添加 `case 'system-user-apply'` 分支
