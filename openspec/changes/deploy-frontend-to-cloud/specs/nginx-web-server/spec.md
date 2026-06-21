## ADDED Requirements

### Requirement: Install Nginx on Windows Server
系统 SHALL 提供在 Windows Server 2019 上安装 Nginx 的步骤。

#### Scenario: Download and extract Nginx
- **WHEN** 从 https://nginx.org/en/download.html 下载 Windows 版本
- **THEN** 将压缩包解压到 `C:\nginx` 目录
- **AND** 目录结构包含 `nginx.exe`、`conf\`、`logs\`、`html\` 等

#### Scenario: Verify Nginx installation
- **WHEN** 运行 `C:\nginx\nginx.exe -v`
- **THEN** 显示 Nginx 版本信息，确认安装成功

### Requirement: Configure Nginx as static file server
Nginx SHALL 能够配置为静态文件服务器，提供前端构建产物（HTML, CSS, JS, 图片等）。

#### Scenario: Basic static file serving
- **WHEN** `nginx.conf` 配置 `root C:/www/drg-frontend;` 和 `index index.html;`
- **THEN** 访问 `http://111.229.137.113/` 返回 `index.html` 文件
- **AND** 所有静态资源（CSS, JS, 图片）都能正确访问

#### Scenario: SPA fallback handling
- **WHEN** 前端是单页应用（SPA），用户直接访问 `/some-route`
- **THEN** Nginx 配置 `try_files $uri $uri/ /index.html;` 将请求 fallback 到 `index.html`
- **AND** 前端路由能够正确工作

### Requirement: Configure reverse proxy for API
Nginx SHALL 支持配置反向代理，将特定路径的请求转发到后端 API 服务器。

#### Scenario: Proxy API requests
- **WHEN** `nginx.conf` 配置 `location /api/ { proxy_pass http://localhost:52773/; }`
- **THEN** 所有发往 `/api/*` 的请求都被代理到后端 IRIS 服务器（端口 52773）
- **AND** 响应头正确传递，无 CORS 问题

#### Scenario: WebSocket proxy
- **WHEN** 后端 API 需要支持 WebSocket 连接
- **THEN** Nginx 配置 `proxy_http_version 1.1;` 和 `proxy_set_header Upgrade $http_upgrade;`
- **AND** WebSocket 连接成功建立

### Requirement: Nginx configuration validation
系统 SHALL 提供 Nginx 配置文件语法检查机制，在部署前验证配置的正确性。

#### Scenario: Valid nginx.conf
- **WHEN** 运行 `C:\nginx\nginx.exe -t`
- **THEN** 如果配置语法正确，命令返回成功信息
- **AND** 显示 "syntax is ok" 和 "test is successful"

#### Scenario: Invalid nginx.conf
- **WHEN** `nginx.conf` 存在语法错误
- **THEN** `nginx -t` 命令返回错误信息
- **AND** 错误信息明确指出错误的行号和原因

### Requirement: Nginx process management
系统 SHALL 支持 Nginx 进程的启动、停止、重启和重新加载配置。

#### Scenario: Start Nginx
- **WHEN** 运行 `C:\nginx\start nginx.exe`
- **THEN** Nginx 进程启动并监听配置的端口（80）
- **AND** 可以通过 `tasklist /fi "imagename eq nginx.exe"` 查看运行的进程

#### Scenario: Reload configuration
- **WHEN** 修改 `nginx.conf` 后运行 `C:\nginx\nginx.exe -s reload`
- **THEN** Nginx 重新加载配置文件，无需停止服务
- **AND** 新的配置生效

#### Scenario: Stop Nginx
- **WHEN** 运行 `C:\nginx\nginx.exe -s stop`
- **THEN** Nginx 进程立即停止
- **AND** 可以通过 `tasklist /fi "imagename eq nginx.exe"` 确认进程已终止

### Requirement: Configure Nginx as Windows service (optional)
系统 SHALL 支持将 Nginx 配置为 Windows 服务，实现开机自启动（可选，使用 nssm 工具）。

#### Scenario: Register Nginx as Windows service using nssm
- **WHEN** 下载 nssm 工具并运行 `nssm install nginx C:\nginx\nginx.exe`
- **THEN** Nginx 注册为 Windows 服务
- **AND** 可以通过 `sc start nginx` 或"服务"管理器启动 Nginx

#### Scenario: Enable auto-start
- **WHEN** 运行 `sc config nginx start= auto`
- **THEN** Nginx 服务设置为开机自启动
- **AND** 可以通过 `sc qc nginx` 验证启动类型
