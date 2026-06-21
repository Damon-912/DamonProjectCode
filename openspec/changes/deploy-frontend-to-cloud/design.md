## Context

DRG 医保控费预警系统当前仅在本地开发环境运行，前端使用 Vite 开发服务器（端口 5173）。系统需要部署到生产环境，以便医院用户能够通过互联网访问。

**现有环境：**
- 腾讯云轻量应用服务器：111.229.137.113（Windows Server 2019）
- 前端技术栈：React 19 + Vite 8 + TypeScript + Ant Design 6
- 构建命令：`npm run build`（输出到 dist/ 目录）

**目标环境：**
- 操作系统：Windows Server 2019
- Web 服务器：Nginx（高性能、配置成熟）
- 访问方式：IP 地址（http://111.229.137.113）
- 部署位置：C:\www\drg-frontend 或类似目录

## Goals / Non-Goals

**Goals:**
- 将前端应用构建为生产版本并部署到腾讯云 Windows Server 2019 服务器
- 配置 Nginx 提供静态文件服务和 API 反向代理
- 确保外网用户可以通过 IP 地址（http://111.229.137.113）访问系统
- 配置 Windows 防火墙规则，开放 HTTP 端口（80）
- 建立可重复的部署流程（构建 → 传输 → 部署）

**Non-Goals:**
- 不包括后端 IRIS 数据库的部署（已有独立部署）
- 不包括域名注册和 DNS 配置（使用 IP 地址访问）
- 不包括 HTTPS/SSL 证书配置（使用 HTTP）
- 不包括 CI/CD 自动化流水线（可后续添加）
- 不包括负载均衡和高可用配置

## Decisions

### 1. Web 服务器选择：Nginx over Caddy/Apache

**决策：** 使用 Nginx 作为生产 Web 服务器

**理由：**
- Nginx 成熟稳定，Windows 版本支持良好
- 高性能，低资源占用，适合生产环境
- 配置灵活，反向代理功能强大
- 社区资源丰富，排查问题容易

**替代方案：**
- Caddy：配置更简洁，但 Windows 下使用较少，社区资源相对少
- Apache：配置复杂，性能略低于 Nginx

### 2. 部署方式：手动部署 over CI/CD

**决策：** 首次部署采用手动流程，后续可添加自动化

**理由：**
- 项目初期，手动部署简单直接
- 便于调试和验证每个步骤
- 后续可根据需要添加 GitHub Actions 或类似工具

**替代方案：**
- CI/CD 自动化：适合频繁部署的场景，但初期成本较高

### 3. 构建产物传输：WinSCP/SFTP over SCP

**决策：** 使用 WinSCP 或 VS Code SFTP 扩展传输构建产物到 Windows 服务器

**理由：**
- Windows Server 原生支持 SFTP/SCP（通过 OpenSSH 或第三方工具）
- 图形界面操作简单直观（WinSCP）
- 可以保存会话配置，便于重复部署

**替代方案：**
- 共享文件夹：需要在服务器上配置文件共享，安全性较低
- Git 部署：需要在服务器上安装 Git 并拉取代码，占用服务器资源

### 4. API 代理策略：Nginx 反向代理 over CORS

**决策：** 使用 Nginx 反向代理解决跨域问题

**理由：**
- 前端和后端可能部署在不同端口
- 反向代理隐藏后端地址，提高安全性
- 可以在同一 IP 和端口下提供前端和 API 服务

**配置示例（nginx.conf）：**
```nginx
location /api/ {
    proxy_pass http://localhost:52773/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### 5. 访问方式：IP 地址 over 域名

**决策：** 使用 IP 地址访问（http://111.229.137.113），不配置域名和 HTTPS

**理由：**
- 简化部署流程，无需注册域名和配置 DNS
- 避免 SSL 证书配置（IP 地址无法使用 Let's Encrypt）
- 适合内部测试或初期部署阶段

**替代方案：**
- 配置域名和 HTTPS：需要注册域名、配置 DNS、申请 SSL 证书，适合生产环境长期使用

## Risks / Trade-offs

### Risk 1: Windows 防火墙配置错误
**风险：** Windows 防火墙或腾讯云安全组规则配置错误，导致外网无法访问

**缓解措施：**
- 部署前检查 Windows 防火墙状态（控制面板 → Windows Defender 防火墙）
- 确保腾讯云控制台的安全组规则已开放 80 端口
- 使用浏览器在服务器本地访问 `http://localhost`，然后在外部测试 `http://111.229.137.113`

### Risk 2: Nginx 反向代理配置错误
**风险：** Nginx 配置文件语法错误，导致前端无法调用后端 API

**缓解措施：**
- 使用 `nginx -t` 命令验证配置文件语法
- 查看 Nginx 错误日志（`logs\error.log`）排查问题
- 逐步测试：先配置静态文件服务，再添加反向代理

### Risk 3: 构建配置错误
**风险：** Vite 构建配置错误，导致生产版本无法正常运行

**缓解措施：**
- 本地先运行 `npm run build` 和 `npm run preview` 测试构建产物
- 检查 Vite 配置中的 `base` 设置（IP 访问应使用 `/`）
- 确保环境变量 `VITE_API_BASE_URL` 正确配置（如 `/api`）

### Risk 4: Nginx 在 Windows 下性能问题
**风险：** Nginx 在 Windows 下的性能不如 Linux，可能存在稳定性问题

**缓解措施：**
- 使用 Nginx 官方推荐的 Windows 版本
- 调整 Nginx 工作进程数（`worker_processes`）和连接数（`worker_connections`）
- 监控服务器资源使用情况，必要时考虑切换到 Linux 服务器

## Migration Plan

### 部署步骤

1. **准备服务器环境**
   - 远程桌面（RDP）登录到 Windows Server 2019
   - 下载 Nginx Windows 版本：https://nginx.org/en/download.html
   - 解压到 `C:\nginx` 目录
   - 创建部署目录：`C:\www\drg-frontend`

2. **配置 Nginx**
   - 编辑配置文件：`C:\nginx\conf\nginx.conf`
   - 配置静态文件服务（root 指向 `C:\www\drg-frontend`）
   - 配置反向代理（/api/ 路径代理到后端 IRIS）
   - 测试配置：`C:\nginx\nginx.exe -t`

3. **启动 Nginx**
   - 启动 Nginx：`C:\nginx\start nginx.exe`
   - 查看进程：任务管理器或 `tasklist /fi "imagename eq nginx.exe"`
   - 重新加载配置：`C:\nginx\nginx.exe -s reload`

4. **配置 Windows 防火墙**
   - 打开"Windows Defender 防火墙"
   - 高级设置 → 入站规则 → 新建规则
   - 选择"端口" → TCP → 特定本地端口：80 → 允许连接
   - 命名规则："Nginx HTTP"

5. **配置腾讯云安全组**
   - 登录腾讯云控制台
   - 找到实例 `lhins-djbbo9ac`
   - 安全组 → 添加入站规则：协议 TCP，端口 80，源地址 0.0.0.0/0

6. **构建前端应用**
   - 本地运行：`npm run build`
   - 验证构建产物：`dir dist/`

7. **传输构建产物**
   - 使用 WinSCP 连接到服务器
   - 将 `dist/` 目录下的所有文件上传到 `C:\www\drg-frontend\`

8. **验证部署**
   - 在服务器浏览器访问：`http://localhost`
   - 从外网访问：`http://111.229.137.113`
   - 检查浏览器控制台是否有错误
   - 测试 API 调用是否正常

### 回滚策略

如果出现问题：
1. 停止 Nginx：`C:\nginx\nginx.exe -s stop`
2. 恢复上一版本的构建产物（如果有备份）
3. 或重新部署修复后的版本
4. 重新启动 Nginx：`C:\nginx\start nginx.exe`

## Open Questions

1. **后端 API 地址：** 后端 IRIS 服务运行在哪个地址和端口？需要配置 Nginx 反向代理（如 `proxy_pass http://localhost:52773/`）。
2. **Nginx 作为 Windows 服务：** 是否需要将 Nginx 配置为 Windows 服务（开机自启）？可以使用 `nssm` 工具将 Nginx 注册为服务。
3. **服务器性能：** Windows Server 2019 的资源配置（CPU/内存）是否满足 Nginx 和前端应用的需求？
