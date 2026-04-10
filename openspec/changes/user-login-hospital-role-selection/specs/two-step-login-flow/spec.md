## ADDED Requirements

### Requirement: 用户名密码验证
系统SHALL提供用户名密码验证功能，对接后端接口 code 01010001，验证用户身份并获取用户基本信息。

#### Scenario: 输入正确的用户名密码
- **WHEN** 用户在登录页面输入正确的用户名和密码
- **THEN** 系统调用 IsValidUser 接口验证成功，返回用户ID、用户名、姓名等基本信息
- **AND** 系统跳转到医院角色选择页面

#### Scenario: 输入错误的用户名密码
- **WHEN** 用户输入错误的用户名或密码
- **THEN** 系统调用 IsValidUser 接口返回错误
- **AND** 页面显示错误提示"用户名或密码错误"

#### Scenario: 用户被锁定
- **WHEN** 用户多次输入错误密码导致账号被锁定
- **THEN** 系统返回账号锁定错误
- **AND** 页面提示"账号已锁定，请联系管理员"

### Requirement: 完成登录
系统SHALL在用户选择医院角色后，调用后端接口 code 01010002 完成登录，建立session。

#### Scenario: 选择医院角色后登录
- **WHEN** 用户在医院角色选择页面选择了一个医院+角色组合
- **THEN** 系统调用 Logon 接口，传入 userID、groupID、hospID 等参数
- **AND** 登录成功后保存session信息到localStorage
- **AND** 跳转到系统主页面

#### Scenario: 登录接口返回错误
- **WHEN** 调用 Logon 接口时返回错误
- **THEN** 页面显示错误提示
- **AND** 用户仍停留在选择页面，可重新选择

### Requirement: 单权限自动跳过
系统SHALL在用户只有一个可用的医院+角色组合时，自动选择并跳过选择页面，直接完成登录。

#### Scenario: 用户只有一个权限
- **WHEN** 用户验证通过后，调用 GetLogonGroupByUserId 接口只返回一个权限组合
- **THEN** 系统自动选择该权限
- **AND** 直接调用 Logon 接口完成登录
- **AND** 用户无感知地进入主页面
