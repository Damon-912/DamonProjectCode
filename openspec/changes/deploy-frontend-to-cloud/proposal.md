## Why

当前 DRG 医保控费预警系统的前端程序仅在本地开发环境运行，无法在外网访问。为了让用户能够通过互联网访问系统，需要将前端应用部署到腾讯云服务器，并实现外网可访问的生产环境部署。

## What Changes

- 构建前端生产版本（使用 Vite build）
- 配置 Caddy Web 服务器以提供静态文件服务
- 将构建产物部署到腾讯云轻量应用服务器（111.229.137.113）
- 配置服务器防火墙和安全组规则，开放 HTTP/HTTPS 端口（80/443）
- 配置 Caddy 反向代理以解决开发环境的 API 跨域问题
- 可选：配置域名解析和 SSL 证书

## Capabilities

### New Capabilities

- `frontend-deployment`: 前端生产环境部署流程，包括构建、传输、配置 Web 服务器等步骤
- `nginx-web-server`: Nginx Web 服务器配置（Windows 版本），包括静态文件服务、反向代理等
- `cloud-server-config`: 腾讯云 Windows Server 2019 服务器环境配置，包括 Windows 防火墙规则、Nginx 服务自启动等

### Modified Capabilities

（无现有能力需要修改）

## Impact

- **前端代码**: Vite 构建配置（vite.config.ts）可能需要调整 base URL 或 API 代理配置
- **Caddyfile**: 需要创建或更新 Caddy 配置文件
- **服务器配置**: 腾讯云服务器需要安装 Caddy、配置防火墙规则
- **API 服务**: 后端 API 服务需要能够被前端访问（可能需要配置 CORS 或反向代理）
- **依赖**: 服务器需要安装 Node.js（用于构建）和 Caddy（用于生产服务）
