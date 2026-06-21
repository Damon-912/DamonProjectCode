## ADDED Requirements

### Requirement: Install Nginx on Windows Server
系统 SHALL 提供在腾讯云 Windows Server 2019 上安装 Nginx 的步骤。

#### Scenario: Download and extract Nginx
- **WHEN** 从 https://nginx.org/en/download.html 下载 Windows 稳定版本
- **THEN** 将压缩包解压到 `C:\nginx` 目录
- **AND** 目录结构包含 `nginx.exe`、`conf\`、`logs\`、`temp\` 等

#### Scenario: Verify Nginx runs successfully
- **WHEN** 运行 `C:\nginx\start nginx.exe`
- **THEN** 打开浏览器访问 `http://localhost`
- **AND** 看到 "Welcome to nginx!" 页面，确认安装成功

### Requirement: Configure Windows Firewall rules
系统 SHALL 配置 Windows 防火墙，开放 HTTP 端口（80）。

#### Scenario: Configure Windows Firewall using GUI
- **WHEN** 打开"Windows Defender 防火墙" → "高级设置" → "入站规则" → "新建规则"
- **THEN** 选择"端口" → TCP → 特定本地端口：80 → "允许连接"
- **AND** 命名规则为 "Nginx HTTP"，完成配置

#### Scenario: Configure Windows Firewall using command line
- **WHEN** 以管理员身份运行命令提示符
- **THEN** 执行 `netsh advfirewall firewall add rule name="Nginx HTTP" dir=in action=allow protocol=TCP localport=80`
- **AND** 执行 `netsh advfirewall firewall add rule name="Nginx HTTP Outbound" dir=out action=allow protocol=TCP localport=80`

#### Scenario: Verify firewall rules
- **WHEN** 运行 `netsh advfirewall firewall show rule name="Nginx HTTP"`
- **THEN** 显示规则详细信息，确认规则已生效

### Requirement: Configure Tencent Cloud security group
系统 SHALL 配置腾讯云安全组规则，允许外网访问 HTTP 端口（80）。

#### Scenario: Add inbound rule in Tencent Cloud console
- **WHEN** 登录腾讯云控制台，找到实例 `lhins-djbbo9ac`
- **THEN** 进入"安全组" → "添加规则"
- **AND** 配置：协议 TCP，端口 80，源地址 0.0.0.0/0，策略允许

#### Scenario: Verify external access
- **WHEN** 安全组规则配置完成
- **THEN** 从外网访问 `http://111.229.137.113`
- **AND** 浏览器成功加载 Nginx 默认页面或前端应用

### Requirement: Create deployment directory on Windows
系统 SHALL 在 Windows Server 上创建用于存放前端构建产物的目录，并设置正确的权限。

#### Scenario: Create directory using GUI
- **WHEN** 打开"文件资源管理器"
- **THEN** 创建目录 `C:\www\drg-frontend`
- **AND** 右键 → "属性" → "安全"，确保 IIS_IUSRS 或 Everyone 有读取权限

#### Scenario: Create directory using command line
- **WHEN** 以管理员身份运行命令提示符
- **THEN** 执行 `mkdir C:\www\drg-frontend`
- **AND** 执行 `icacls C:\www\drg-frontend /grant Everyone:(OI)(CI)RX` 赋予读取权限

### Requirement: Verify deployment on Windows
系统 SHALL 提供验证部署成功的方法，包括本地测试和外部访问测试。

#### Scenario: Local test on server
- **WHEN** 在服务器浏览器访问 `http://localhost`
- **THEN** 返回 `index.html` 的内容
- **AND** HTTP 状态码为 200

#### Scenario: External access test
- **WHEN** 从外部网络访问 `http://111.229.137.113`
- **THEN** 浏览器成功加载前端应用
- **AND** 控制台无 404 或网络错误

#### Scenario: API proxy test
- **WHEN** 前端应用调用 `/api/health` 端点
- **THEN** 请求通过 Nginx 反向代理成功到达后端 API
- **AND** 返回正确的 JSON 响应

### Requirement: View Nginx logs on Windows
系统 SHALL 提供查看 Nginx 访问日志和错误日志的方法，以便排查问题。

#### Scenario: View error log
- **WHEN** Nginx 启动失败或运行异常
- **THEN** 查看 `C:\nginx\logs\error.log`
- **AND** 根据错误信息排查问题（如端口占用、配置错误）

#### Scenario: View access log
- **WHEN** 需要分析访问情况
- **THEN** 查看 `C:\nginx\logs\access.log`
- **AND** 可以看到每个请求的访问记录（IP、时间、请求路径、状态码等）

### Requirement: Backup and rollback on Windows
系统 SHALL 支持备份当前部署版本，并在出现问题时快速回滚。

#### Scenario: Backup current deployment
- **WHEN** 部署新版本前
- **THEN** 运行 `xcopy /E /I C:\www\drg-frontend C:\www\backup\drg-frontend.backup.%date:~0,4%%date:~5,2%%date:~8,2%`
- **AND** 备份完成后部署新版本

#### Scenario: Rollback to previous version
- **WHEN** 新版本出现问题需要回滚
- **THEN** 停止 Nginx：`C:\nginx\nginx.exe -s stop`
- **AND** 运行 `rmdir /S /Q C:\www\drg-frontend && move C:\www\backup\drg-frontend.backup.YYYYMMDD C:\www\drg-frontend`
- **AND** 重启 Nginx：`C:\nginx\start nginx.exe`

### Requirement: Register Nginx as Windows service (optional)
系统 SHALL 提供将 Nginx 注册为 Windows 服务的方法，实现开机自启动（使用 nssm 工具）。

#### Scenario: Download and use nssm
- **WHEN** 下载 nssm 工具（https://nssm.cc/download）
- **THEN** 以管理员身份运行 `nssm install nginx C:\nginx\nginx.exe`
- **AND** 在"服务"管理器中可以看到 nginx 服务

#### Scenario: Start and enable auto-start
- **WHEN** 运行 `sc start nginx`
- **THEN** Nginx 服务启动
- **AND** 运行 `sc config nginx start= auto` 设置开机自启动
