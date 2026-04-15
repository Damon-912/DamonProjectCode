# 角色菜单权限管理 - 技术设计

## 代码目录结构

```
src/
├── Menu/
│   ├── Interface.cls      # Menu REST接口路由定义
│   ├── Service.cls        # Menu接口业务实现
│   └── Service.int        # 预编译头文件
└── User/
    ├── CBMenu.cls         # 菜单字典表
    ├── CBMenu.int         # 预编译头文件
    ├── CBRoleMenu.cls     # 角色菜单权限表
    └── CBRoleMenu.int     # 预编译头文件
```

## 数据库设计

### 表1: User.CBMenu (菜单字典表)

| 字段 | 类型 | 说明 |
|------|------|------|
| Code | VARCHAR(50) | 菜单唯一编码(主键) |
| Descripts | VARCHAR(100) | 菜单显示名称 |
| ENDescripts | VARCHAR(100) | 英文名称 |
| StartDate | DATE | 开始日期 |
| StopDate | DATE | 结束日期 |
| ParentCode | VARCHAR(50) | 父菜单编码，顶级为空 |
| MenuLevel | INTEGER | 菜单层级(1=一级,2=二级) |
| SortNo | INTEGER | 排序号 |
| Icon | VARCHAR(100) | 图标名称 |
| RoutePath | VARCHAR(200) | 路由路径 |
| IsVisible | VARCHAR(1) | 是否可见(Y/N) |
| IsActive | VARCHAR(1) | 是否启用(Y/N) |
| CreateDate | DATE | 创建日期 |
| CreateUserDr | User.HBUser | 创建用户外键 |
| Deleted | INTEGER | 删除标记(0=正常,1=已删除) |
| DeleteTime | TIMESTAMP | 删除时间 |

### 表2: User.CBRoleMenu (角色菜单权限表)

| 字段 | 类型 | 说明 |
|------|------|------|
| MenuCode | VARCHAR(50) | 菜单编码(外键) |
| RoleCode | VARCHAR(50) | 角色编码(外键) |
| CreateDate | DATE | 创建日期 |
| CreateUserDr | User.HBUser | 创建用户外键 |
| Deleted | INTEGER | 删除标记(0=正常,1=已删除) |

### 表3: DRG.Role (角色表，扩展现有)

| 字段 | 类型 | 说明 |
|------|------|------|
| ID | INTEGER | 主键，自增 |
| RoleCode | VARCHAR(50) | 角色编码 |
| RoleName | VARCHAR(100) | 角色名称 |
| IsActive | VARCHAR(1) | 是否启用 |
| CreateDate | TIMESTAMP | 创建时间 |

## 后端API设计

### Interface接口路由 (src.Menu.Interface)

```objectscript
Class src.Menu.Interface Extends src.util.REST.Base
{

/// Menu接口路由前缀
Parameter PREURL = "/menu";

/// 获取所有菜单(树形结构)
ClassMethod GetMenuTree() As %Status
{
    Set %response.ContentType = "application/json"
    Set rtn = ##class(src.Menu.Service).GetMenuTree(.data)
    Write ##class(src.util.JSON).Write(.data)
    Quit $$$OK
}

/// 保存菜单
ClassMethod SaveMenu() As %Status
{
    Set %response.ContentType = "application/json"
    Set json = ##class(src.util.JSON).Read(%request.Content)
    Set rtn = ##class(src.Menu.Service).SaveMenu(.json,.result)
    Write ##class(src.util.JSON).Write(.result)
    Quit $$$OK
}

/// 删除菜单
ClassMethod DeleteMenu() As %Status
{
    Set menuCode = %request.Get("code","")
    Set rtn = ##class(src.Menu.Service).DeleteMenu(menuCode,.result)
    Write ##class(src.util.JSON).Write(.result)
    Quit $$$OK
}

/// 初始化默认菜单
ClassMethod InitDefaultMenus() As %Status
{
    Set %response.ContentType = "application/json"
    Set rtn = ##class(src.Menu.Service).InitDefaultMenus(.result)
    Write ##class(src.util.JSON).Write(.result)
    Quit $$$OK
}

/// 获取角色菜单权限
ClassMethod GetRoleMenus(roleCode) As %Status
{
    Set %response.ContentType = "application/json"
    Set rtn = ##class(src.Menu.Service).GetRoleMenus(roleCode,.data)
    Write ##class(src.util.JSON).Write(.data)
    Quit $$$OK
}

/// 保存角色菜单权限
ClassMethod SaveRoleMenus() As %Status
{
    Set %response.ContentType = "application/json"
    Set json = ##class(src.util.JSON).Read(%request.Content)
    Set rtn = ##class(src.Menu.Service).SaveRoleMenus(.json,.result)
    Write ##class(src.util.JSON).Write(.result)
    Quit $$$OK
}

/// 获取用户菜单(登录后调用)
ClassMethod GetUserMenus() As %Status
{
    Set %response.ContentType = "application/json"
    Set userCode = %request.Get("userCode","")
    Set rtn = ##class(src.Menu.Service).GetUserMenus(userCode,.data)
    Write ##class(src.util.JSON).Write(.data)
    Quit $$$OK
}
}
```

### 菜单管理

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/menu/list` | GET | 获取所有菜单(树形结构) |
| `/api/menu/save` | POST | 保存/更新菜单 |
| `/api/menu/delete/{id}` | DELETE | 删除菜单 |
| `/api/menu/init` | POST | 初始化默认菜单(从App.tsx导入) |

### 角色菜单权限

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/rolemenu/{roleCode}` | GET | 获取角色的菜单权限 |
| `/api/rolemenu/save` | POST | 保存角色菜单权限 |
| `/api/user/{userId}/menus` | GET | 获取用户可用的菜单(登录后调用) |

## 前端设计

### 登录流程改造

1. 用户登录成功后，后端返回用户的菜单列表
2. 前端根据返回的菜单动态渲染导航栏
3. 不再使用 `App.tsx` 中的硬编码 `menuItems`

### 新增页面

1. **菜单管理页面** (`/pages/System/Menus.tsx`)
   - 树形展示菜单结构
   - 支持新增/编辑/删除菜单
   - 支持拖拽排序

2. **角色菜单配置页面** (扩展现有 `Roles.tsx`)
   - 左侧角色列表
   - 右侧菜单树(复选框选择)

## 技术实现

### 后端 (ObjectScript)

1. 创建 `User.CBMenu` 类定义菜单表（遵从CB表规范）
2. 创建 `User.CBRoleMenu` 类定义角色菜单权限表
3. 创建 `src.Menu.Interface` REST接口路由类
4. 创建 `src.Menu.Service` 接口业务实现类
5. 实现 `InitDefaultMenus()` 方法从 App.tsx 导入初始菜单

### src.Menu.Interface 类说明

```objectscript
/// Menu REST接口路由定义类
Class src.Menu.Interface Extends src.util.REST.Base
{
    /// 接口路由前缀
    Parameter PREURL = "/menu";
    
    /// 路由映射
    /// GET /menu/tree - GetMenuTree
    /// POST /menu/save - SaveMenu
    /// DELETE /menu/delete?code=xxx - DeleteMenu
    /// POST /menu/init - InitDefaultMenus
    /// GET /menu/role/{roleCode} - GetRoleMenus
    /// POST /menu/role/save - SaveRoleMenus
    /// GET /menu/user?userCode=xxx - GetUserMenus
}
```

### src.Menu.Service 类说明

```objectscript
/// Menu接口业务实现类
Class src.Menu.Service Extends src.util.REST.Base
{
    /// 获取菜单树形结构
    ClassMethod GetMenuTree(Output data)
    
    /// 保存菜单(新增/修改)
    ClassMethod SaveMenu(ByRef json, Output result)
    
    /// 删除菜单(逻辑删除)
    ClassMethod DeleteMenu(menuCode, Output result)
    
    /// 初始化默认菜单
    ClassMethod InitDefaultMenus(Output result)
    
    /// 获取角色菜单权限
    ClassMethod GetRoleMenus(roleCode, Output data)
    
    /// 保存角色菜单权限
    ClassMethod SaveRoleMenus(ByRef json, Output result)
    
    /// 获取用户菜单(根据角色)
    ClassMethod GetUserMenus(userCode, Output data)
}
```

### User.CBMenu 表规范

遵循CB表规范，包含必填字段：
- Code (主键，菜单编码)
- Descripts (菜单名称)
- StartDate, StopDate (有效期)
- CreateDate (创建日期)
- CreateUserDr (创建用户外键)
- Deleted, DeleteTime (删除标记)

### 前端 (React/TypeScript)

1. 修改登录流程获取菜单数据
2. 创建 `MenuContext` 全局上下文存储菜单
3. 创建 `useMenus` Hook 获取用户菜单
4. 优化 `Menus.tsx` 页面功能
