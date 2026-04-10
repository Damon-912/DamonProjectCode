## ADDED Requirements

### Requirement: 查看用户角色列表
系统SHALL支持在用户详情弹窗中查看该用户的权限角色列表，对接后端接口 code 01030111（GetUserDetail）。

#### Scenario: 打开用户详情弹窗
- **WHEN** 用户点击用户列表某行的"详情"按钮
- **THEN** 系统调用 GetUserDetail 接口，在弹窗中展示用户基本信息和权限角色列表（表格形式），角色列表显示：医院编码、医院名称、角色名称、是否默认、更新时间列

### Requirement: 分配用户权限角色
系统SHALL支持为用户分配新的医院+角色组合，对接后端接口 code 01030109（SaveUserLogonLoc）；后端使用session.userID作为更新人。

#### Scenario: 打开分配角色弹窗
- **WHEN** 用户在详情弹窗的角色列表区域点击"添加角色"按钮
- **THEN** 系统打开角色分配表单弹窗，包含医院选择(必填)、角色选择(必填)、是否默认角色(默认N)字段

#### Scenario: 提交角色分配
- **WHEN** 用户选择医院和角色后点击确定
- **THEN** 系统调用 SaveUserLogonLoc 接口（携带session信息），成功后刷新角色列表

### Requirement: 删除用户权限角色
系统SHALL支持删除用户的某个权限角色记录，对接后端接口 code 01030110（DeleteUserLogon）。

#### Scenario: 删除权限角色
- **WHEN** 用户点击角色列表某行的"删除"按钮并确认
- **THEN** 系统调用 DeleteUserLogon 接口，成功后刷新角色列表

### Requirement: 设置默认角色
系统SHALL支持将用户的某个角色设置为默认角色（通过更新权限角色实现，IsDefault="Y"），对接后端接口 code 01030109（UpdateUserLogonLoc）。

#### Scenario: 设置默认角色
- **WHEN** 用户点击角色列表某行的"设为默认"按钮
- **THEN** 系统调用 UpdateUserLogonLoc 接口（isDefault="Y"），成功后刷新角色列表，默认角色行显示"默认"标签
