## 1. API层建设

- [x] 1.1 创建 `api/logon.ts` 文件，定义登录相关的TypeScript接口类型：ValidUserResult（用户验证结果）、LogonParams（登录参数）、LogonResult（登录结果）、UserLogonLocItem（登录权限项）
- [x] 1.2 实现 `isValidUser` 函数（code: 01010001），验证用户名密码
- [x] 1.3 实现 `logon` 函数（code: 01010002），完成登录
- [x] 1.4 实现 `getLogonGroupByUserId` 函数（code: 01010004），获取用户登录权限列表
- [x] 1.5 实现 `logout` 函数（code: 01010003），用户登出

## 2. 登录页面改造

- [x] 2.1 修改 `pages/Login/index.tsx`，对接 `isValidUser` API，验证成功后跳转选择页面
- [x] 2.2 添加登录加载状态处理
- [x] 2.3 添加错误提示：用户名密码错误、账号锁定等
- [x] 2.4 保存验证通过的用户信息到state，传递给选择页面

## 3. 医院角色选择页面

- [x] 3.1 创建 `pages/Login/SelectHospRole.tsx` 页面组件
- [x] 3.2 实现页面布局：顶部显示欢迎信息+当前用户名，中部卡片列表，底部操作按钮
- [x] 3.3 调用 `getLogonGroupByUserId` API 获取权限列表
- [x] 3.4 实现权限卡片组件，展示医院名称、角色名称、医院编码、是否默认标识
- [x] 3.5 实现搜索功能：按医院名称/角色名称实时过滤
- [x] 3.6 实现卡片选中效果（边框高亮）
- [x] 3.7 实现"进入系统"按钮，调用 `logon` API 完成登录
- [x] 3.8 实现单权限自动跳过逻辑（只有一个权限时直接登录）
- [x] 3.9 处理权限列表为空的场景，显示提示信息

## 4. 登录状态管理

- [x] 4.1 创建 `utils/auth.ts` 工具函数：setSession（保存session）、getSession（获取session）、clearSession（清除session）、isAuthenticated（检查登录状态）
- [x] 4.2 修改 `api/request.ts` 中的 `getDefaultSession` 函数，从localStorage读取session
- [x] 4.3 在 `App.tsx` 中添加登录状态检查，未登录用户重定向到登录页
- [x] 4.4 在 `App.tsx` 右上角添加用户信息和登出按钮
- [x] 4.5 实现登出功能，调用 `logout` API 并清除session

## 5. 路由和导航（调整为单页面应用状态管理）

- [x] 5.1 在 App.tsx 中实现登录状态管理（login/select/authenticated三种状态）
- [x] 5.2 根据登录状态渲染不同内容（登录页/选择页/主应用）
- [x] 5.3 登录成功后渲染主应用页面
