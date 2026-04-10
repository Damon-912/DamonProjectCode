## ADDED Requirements

### Requirement: Session信息存储
系统SHALL在登录成功后，将完整的session信息存储到localStorage，供后续API调用使用。

#### Scenario: 登录成功存储session
- **WHEN** Logon接口调用成功返回session信息
- **THEN** 系统将以下信息存入localStorage：
  - userID（用户ID）
  - userCode（用户编码）
  - userName（用户姓名）
  - groupID（角色组ID）
  - groupDesc（角色组名称）
  - hospID（医院ID）
  - hospDesc（医院名称）
  - hospCode（医院编码）
  - sessionID（会话ID）
- **AND** 设置登录状态为已登录

#### Scenario: 页面刷新后恢复session
- **WHEN** 用户刷新页面
- **THEN** 系统从localStorage读取session信息
- **AND** 恢复登录状态
- **AND** 用户无需重新登录

### Requirement: 登录状态检查
系统SHALL在页面加载时检查登录状态，未登录用户自动跳转到登录页面。

#### Scenario: 未登录访问系统
- **WHEN** 未登录用户访问系统内页面
- **THEN** 自动重定向到登录页面
- **AND** 登录成功后跳转回原目标页面

#### Scenario: Session过期
- **WHEN** API调用返回session过期错误
- **THEN** 清除localStorage中的session
- **AND** 提示用户"登录已过期，请重新登录"
- **AND** 跳转到登录页面

### Requirement: 登出功能
系统SHALL提供登出功能，清除登录状态并返回登录页面。

#### Scenario: 用户点击登出
- **WHEN** 用户点击右上角登出按钮
- **THEN** 清除localStorage中的session信息
- **AND** 调用 Logout 接口（code: 01010003）
- **AND** 跳转到登录页面
- **AND** 显示"已成功登出"提示
