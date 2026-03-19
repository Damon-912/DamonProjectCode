## ADDED Requirements

### Requirement: 接口服务配置管理
系统SHALL提供接口服务配置页面，支持查询和配置CB_MapInterface表中的接口映射。

#### Scenario: 查询接口服务列表
- **WHEN** 用户打开接口服务配置页面
- **THEN** 系统调用02010404接口查询所有接口服务
- **AND** 显示接口Code、描述、类名、方法名、服务类型

#### Scenario: 新增接口服务
- **WHEN** 用户填写接口Code、描述、类名、方法名等信息
- **AND** 点击保存按钮
- **THEN** 系统调用02010405接口保存接口服务配置
- **AND** 数据保存到CB_MapInterface表

### Requirement: 系统菜单管理
系统SHALL提供菜单配置页面，支持配置系统菜单和权限。

#### Scenario: 查询菜单列表
- **WHEN** 用户打开菜单配置页面
- **THEN** 系统调用02010403接口查询所有菜单
- **AND** 以树形结构展示菜单层级

#### Scenario: 获取用户菜单
- **WHEN** 用户登录系统
- **THEN** 系统调用02010408接口根据用户角色获取有权限的菜单
- **AND** 动态渲染左侧菜单栏
