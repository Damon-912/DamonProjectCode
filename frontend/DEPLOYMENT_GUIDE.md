# DRG医保控费预警系统 - Windows Server 部署指南

## 服务器信息
- **操作系统**: Windows Server 2019
- **服务器IP**: 111.229.137.113
- **Web服务器**: Nginx
- **SSH端口**: 22
- **账号**: administrator

---

## 部署步骤

### 步骤 1: 下载 Nginx for Windows（需手动操作）

1. 访问 Nginx 官网下载页面：http://nginx.org/en/download.html
2. 下载 **nginx/Windows-1.24.x** 稳定版本（例如：nginx-1.24.0.zip）
3. 下载完成后，将 zip 文件上传到服务器

**需要你手动操作**：下载并上传 Nginx 安装包到服务器

---

### 步骤 2: 上传前端构建文件（需手动操作）

将本地的 `frontend/dist` 目录上传到服务器。

**本地路径**: `d:/AI开发/CodeBuddy/DRG医保控费预警系统开发项目/frontend/dist`

**上传方式**（任选一种）：
- 使用远程桌面（RDP）直接复制粘贴
- 使用 WinSCP 或 FileZilla 通过 SFTP 上传
- 使用 SCP 命令（如果你有 SSH 访问权限）

**需要你手动操作**：将 dist 目录上传到服务器

---

### 步骤 3: 安装和配置 Nginx（需手动操作）

1. **解压 Nginx**
   - 在服务器上，将下载的 `nginx-1.24.0.zip` 解压到 `C:\nginx`

2. **创建前端目录**
   ```cmd
   mkdir C:\nginx\html\dist
   ```

3. **复制前端文件**
   - 将上传的 `dist` 目录中的所有文件复制到 `C:\nginx\html\dist\`

4. **配置 Nginx**
   - 用记事本打开 `C:\nginx\conf\nginx.conf`
   - 将本项目的 `nginx.conf` 文件内容复制并替换原内容
   - 保存文件

**需要你手动操作**：解压、配置 Nginx

---

### 步骤 4: 启动 Nginx（需手动操作）

1. **打开命令提示符（管理员权限）**
   ```cmd
   cd C:\nginx
   ```

2. **启动 Nginx**
   ```cmd
   start nginx
   ```

3. **检查 Nginx 是否运行**
   - 打开浏览器访问：http://localhost
   - 或访问：http://111.229.137.113

4. **常用 Nginx 命令**
   ```cmd
   nginx -s reload   # 重新加载配置
   nginx -s stop     # 快速停止
   nginx -s quit     # 优雅停止
   ```

**需要你手动操作**：启动 Nginx 服务

---

### 步骤 5: 配置 Windows 防火墙（需手动操作）

如果无法从外部访问，需要开放端口 80：

1. 打开 **Windows Defender 防火墙**
2. 点击 **高级设置**
3. 点击 **入站规则** -> **新建规则**
4. 选择 **端口** -> **TCP** -> **特定本地端口**：`80`
5. 允许连接 -> 完成

**需要你手动操作**：配置防火墙规则

---

## 验证部署

部署完成后，在浏览器中访问：
- **本地访问**: http://localhost
- **外网访问**: http://111.229.137.113

应该能看到 DRG 医保控费预警系统的登录页面。

---

## 常见问题

### 1. Nginx 启动失败
- 检查 80 端口是否被占用：`netstat -ano | findstr :80`
- 如果占用，修改 `nginx.conf` 中的 `listen 80` 为其他端口（如 8080）

### 2. 页面显示 403 Forbidden
- 检查 `C:\nginx\html\dist` 目录是否存在
- 检查 `index.html` 是否在 dist 目录中

### 3. 刷新页面显示 404
- 确认 `nginx.conf` 中已配置 `try_files $uri $uri/ /index.html;`

---

## 项目构建命令（本地执行）

如果需要重新构建前端：

```bash
cd "d:/AI开发/CodeBuddy/DRG医保控费预警系统开发项目/frontend"
npm run build
```

构建完成后，新的 `dist` 目录会生成，需要重新上传到服务器。

---

## 联系人

如有问题，请联系系统管理员。
