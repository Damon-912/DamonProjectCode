## 1. 准备腾讯云 Windows Server 2019 环境

- [ ] 1.1 远程桌面（RDP）登录到腾讯云服务器（111.229.137.113）
- [ ] 1.2 下载 Nginx Windows 版本：访问 https://nginx.org/en/download.html，下载稳定版（如 nginx-1.26.x）
- [ ] 1.3 解压 Nginx 到 `C:\nginx` 目录
- [ ] 1.4 创建部署目录：`mkdir C:\www\drg-frontend`
- [ ] 1.5 验证 Nginx 安装：运行 `C:\nginx\nginx.exe -v`，应显示版本信息
- [ ] 1.6 测试 Nginx 启动：运行 `C:\nginx\start nginx.exe`，浏览器访问 `http://localhost`，看到 "Welcome to nginx!" 页面

## 2. 配置 Nginx Web 服务器

- [ ] 2.1 备份默认配置：复制 `C:\nginx\conf\nginx.conf` 为 `nginx.conf.backup`
- [ ] 2.2 编辑 `C:\nginx\conf\nginx.conf`，配置静态文件服务：
  ```nginx
  server {
      listen       80;
      server_name  localhost;

      root   C:/www/drg-frontend;
      index  index.html index.htm;

      location / {
          try_files $uri $uri/ /index.html;
      }
  }
  ```
- [ ] 2.3 配置反向代理：在 `server` 块中添加：
  ```nginx
  location /api/ {
      proxy_pass http://localhost:52773/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
  ```
- [ ] 2.4 验证 Nginx 配置：运行 `C:\nginx\nginx.exe -t`，应显示 "syntax is ok" 和 "test is successful"
- [ ] 2.5 （可选）配置 Nginx 日志：在 `http` 块中添加 `log_format` 和 `access_log` 指令

## 3. 配置 Windows 防火墙

- [ ] 3.1 打开"Windows Defender 防火墙"（控制面板 → 系统和安全）
- [ ] 3.2 点击"高级设置" → "入站规则" → "新建规则"
- [ ] 3.3 选择"端口" → 下一步
- [ ] 3.4 选择"TCP"，输入"特定本地端口"：`80` → 下一步
- [ ] 3.5 选择"允许连接" → 下一步
- [ ] 3.6 保持默认（域、专用、公用） → 下一步
- [ ] 3.7 命名规则：`Nginx HTTP`，描述：`Allow HTTP traffic for Nginx` → 完成
- [ ] 3.8 （可选）使用命令行配置：`netsh advfirewall firewall add rule name="Nginx HTTP" dir=in action=allow protocol=TCP localport=80`

## 4. 配置腾讯云安全组

- [ ] 4.1 登录腾讯云控制台：https://console.cloud.tencent.com/
- [ ] 4.2 进入"轻量应用服务器" → 找到实例 `lhins-djbbo9ac`
- [ ] 4.3 点击实例名称 → "防火墙" 标签页
- [ ] 4.4 点击"添加规则"
- [ ] 4.5 配置规则：
  - 应用类型：自定义
  - 协议：TCP
  - 端口：80
  - 策略：允许
  - 备注：HTTP for Nginx
- [ ] 4.6 点击"确定"，等待规则生效（通常几秒内）
- [ ] 4.7 验证：从外网访问 `http://111.229.137.113`，应能看到 Nginx 默认页面或前端应用

## 5. 构建前端生产版本

- [ ] 5.1 检查 `frontend/vite.config.ts` 配置，确认 `base` 选项设置为 `/`（生产环境根路径）
- [ ] 5.2 检查环境变量配置（`.env.production`），确认 `VITE_API_BASE_URL` 设置为 `/api`（使用 Nginx 反向代理）
- [ ] 5.3 本地运行 `npm run build` 构建生产版本
- [ ] 5.4 验证构建产物：检查 `dist/` 目录是否生成正确的文件（`index.html`, `assets/`, 等）
- [ ] 5.5 本地预览构建产物：`npm run preview`，确保无运行时错误
- [ ] 5.6 （可选）检查 `dist/index.html` 中的资源路径是否正确（应以 `/assets/` 开头）

## 6. 部署构建产物到 Windows 服务器

- [ ] 6.1 下载并安装 WinSCP：https://winscp.net/eng/download.php
- [ ] 6.2 打开 WinSCP，新建会话：
  - 协议：SFTP 或 SCP
  - 主机名：111.229.137.113
  - 用户名：administrator
  - 密码：q597167810..
- [ ] 6.3 连接成功后，左侧（本地）导航到 `frontend/dist/` 目录
- [ ] 6.4 右侧（远程）导航到 `C:\www\drg-frontend` 目录
- [ ] 6.5 选择本地 `dist/` 目录下的所有文件（除 `dist` 目录本身），上传到远程 `C:\www\drg-frontend\`
- [ ] 6.6 等待传输完成，验证远程文件已正确上传
- [ ] 6.7 （替代方案）使用 VS Code SFTP 扩展同步文件：
  - 安装 SFTP 扩展
  - 按 `Ctrl+Shift+P`，输入 "SFTP: Config"
  - 配置 `sftp.json`，设置 `remotePath: "/C/www/drg-frontend"`
  - 右键 `dist/` 目录 → "SFTP: Sync Remote -> Local"

## 7. 启动和配置 Nginx 服务

- [ ] 7.1 如果 Nginx 未启动，运行 `C:\nginx\start nginx.exe`
- [ ] 7.2 如果已启动，重新加载配置：`C:\nginx\nginx.exe -s reload`
- [ ] 7.3 验证 Nginx 进程：`tasklist /fi "imagename eq nginx.exe"`，应显示两个进程（master 和 worker）
- [ ] 7.4 （可选）将 Nginx 注册为 Windows 服务（使用 nssm）：
  - 下载 nssm：https://nssm.cc/download
  - 以管理员身份运行命令提示符
  - 执行 `nssm install nginx C:\nginx\nginx.exe`
  - 在弹出窗口中，Startup directory 填写 `C:\nginx`
  - 点击"Install service"
- [ ] 7.5 （可选）启动 Nginx 服务：`sc start nginx`
- [ ] 7.6 （可选）设置开机自启动：`sc config nginx start= auto`

## 8. 验证部署成功

- [ ] 8.1 在服务器本地测试：打开浏览器，访问 `http://localhost`
- [ ] 8.2 检查页面是否正确加载前端应用（看到登录页面或主页）
- [ ] 8.3 按 F12 打开开发者工具，检查"控制台"是否有错误
- [ ] 8.4 检查"网络"标签页，确保所有资源（CSS, JS, 图片）都成功加载（状态码 200）
- [ ] 8.5 从外网访问：在另一台电脑的浏览器中访问 `http://111.229.137.113`
- [ ] 8.6 验证外网访问正常，页面加载无错误
- [ ] 8.7 测试前端路由：直接访问 `http://111.229.137.113/#/some-route`，确保 SPA fallback 正常工作
- [ ] 8.8 测试 API 调用：在前端应用中执行登录或其他操作，确保 API 请求通过 Nginx 反向代理成功到达后端

## 9. 配置备份和回滚策略

- [ ] 9.1 创建部署脚本（PowerShell）：
  ```powershell
  # deploy.ps1
  $backupDir = "C:\www\backup\drg-frontend.backup." + (Get-Date -Format "yyyyMMdd")
  Copy-Item -Path "C:\www\drg-frontend" -Destination $backupDir -Recurse
  Write-Host "Backup created at $backupDir"
  ```
- [ ] 9.2 每次部署前运行备份脚本
- [ ] 9.3 测试回滚流程：
  - 停止 Nginx：`C:\nginx\nginx.exe -s stop`
  - 删除当前版本：`Remove-Item -Path "C:\www\drg-frontend\*" -Recurse -Force`
  - 恢复备份：`Copy-Item -Path "C:\www\backup\drg-frontend.backup.YYYYMMDD\*" -Destination "C:\www\drg-frontend" -Recurse`
  - 重启 Nginx：`C:\nginx\start nginx.exe`
- [ ] 9.4 编写部署文档（Markdown）：
  - 记录所有步骤
  - 记录配置文件位置（如 `C:\nginx\conf\nginx.conf`）
  - 记录常见问题排查方法（如查看 `C:\nginx\logs\error.log`）

## 10. （可选）性能优化和监控

- [ ] 10.1 调整 Nginx 配置（`nginx.conf`）：
  - 设置 `worker_processes auto;`
  - 设置 `worker_connections 1024;`
  - 启用 Gzip 压缩：`gzip on; gzip_types text/plain text/css application/json application/javascript;`
- [ ] 10.2 配置静态资源缓存：
  ```nginx
  location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
      expires 1y;
      add_header Cache-Control "public, immutable";
  }
  ```
- [ ] 10.3 监控 Nginx 日志：
  - 定期查看 `C:\nginx\logs\access.log` 分析访问情况
  - 查看 `C:\nginx\logs\error.log` 排查错误
- [ ] 10.4 （可选）配置 log rotation，避免日志文件过大
