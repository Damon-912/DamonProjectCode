## ADDED Requirements

### Requirement: Build production bundle
系统 SHALL 能够通过运行 `npm run build` 命令生成生产环境构建产物，输出到 `dist/` 目录。

#### Scenario: Successful build
- **WHEN** 开发者运行 `npm run build` 命令
- **THEN** 系统生成优化后的静态文件（HTML, CSS, JS）到 `dist/` 目录
- **AND** 构建日志显示成功信息，无错误

#### Scenario: Build failure due to type error
- **WHEN** 代码中存在 TypeScript 类型错误
- **THEN** 构建过程失败并显示错误信息
- **AND** 错误信息明确指出错误的文件和行号

### Requirement: Configure Vite base path
系统 SHALL 允许通过 Vite 配置文件（`vite.config.ts`）中的 `base` 选项配置生产环境的基础路径。

#### Scenario: Deploy to root path
- **WHEN** `base` 设置为 `/`
- **THEN** 构建产物中的所有资源路径都基于根路径

#### Scenario: Deploy to subdirectory
- **WHEN** `base` 设置为 `/drg-app/`
- **THEN** 构建产物中的所有资源路径都基于 `/drg-app/` 路径

### Requirement: Transfer build artifacts to server
系统 SHALL 支持将构建产物（`dist/` 目录）传输到远程服务器，支持 SCP/SFTP 协议。

#### Scenario: Transfer via SCP
- **WHEN** 开发者执行 `scp -r dist/* user@server:/var/www/drg-frontend/`
- **THEN** 所有文件成功传输到远程服务器的目标目录
- **AND** 文件权限正确设置（可读 by web server）

#### Scenario: Transfer via WinSCP
- **WHEN** 开发者使用 WinSCP 图形界面传输文件
- **THEN** 可以选择 `dist/` 目录下的所有文件并上传到服务器
- **AND** 传输完成后可以在服务器上验证文件完整性

### Requirement: Environment-specific configuration
系统 SHALL 支持通过环境变量或配置文件区分开发环境和生产环境的配置（如 API 基础路径）。

#### Scenario: Configure API endpoint for production
- **WHEN** 生产环境需要连接不同的后端 API 地址
- **THEN** 可以通过 `.env.production` 文件或环境变量配置 `VITE_API_BASE_URL`
- **AND** 构建时将这些变量注入到前端代码中

#### Scenario: Runtime configuration injection
- **WHEN** 部署后需要修改 API 地址而不重新构建
- **THEN** 可以通过 `window.__CONFIG__` 或类似的全局变量在 `index.html` 中注入配置
- **AND** 应用启动时读取这些配置
