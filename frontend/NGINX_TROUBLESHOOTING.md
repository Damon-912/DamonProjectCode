# Nginx 代理配置 404 错误排查指南

## 🔍 问题分析
你收到的错误：
- **状态码**: 404 Not Found
- **服务器**: nginx/1.14.2
- **请求 URL**: http://111.229.137.113/iris-api/invoke

**原因**: Nginx 没有正确加载 `/iris-api/` 的代理配置，导致请求无法转发到后端。

---

## ✅ 解决步骤（在服务器上操作）

### 步骤 1: 检查 Nginx 配置文件

1. **查看当前 Nginx 配置文件**
   ```cmd
   cd C:\nginx\conf
   notepad nginx.conf
   ```

2. **确认配置文件中是否有 `/iris-api/` 的代理配置**
   
   应该看到类似这样的配置：
   ```nginx
   location /iris-api/ {
       proxy_pass http://111.229.137.113:52773/csp/drg/sysInternalMutiple;
       proxy_set_header Host $host;
       ...
   }
   ```
   
   **如果没有这个配置，说明配置文件没有正确替换！**

---

### 步骤 2: 备份并替换配置文件

1. **备份原配置**
   ```cmd
   cd C:\nginx\conf
   copy nginx.conf nginx.conf.bak
   ```

2. **用正确的配置替换**
   
   选项 A - 手动复制（推荐）：
   - 打开我提供的 `frontend/nginx.conf` 文件
   - 全选复制内容
   - 粘贴到 `C:\nginx\conf\nginx.conf` 并保存
   
   选项 B - 使用命令行（如果文件已上传）：
   ```cmd
   cd C:\nginx\conf
   copy /Y C:\path\to\uploaded\nginx.conf nginx.conf
   ```

---

### 步骤 3: 验证 Nginx 配置

1. **测试配置文件语法**
   ```cmd
   cd C:\nginx
   nginx -t
   ```
   
   **期望输出**:
   ```
   nginx: the configuration file C:\nginx/conf/nginx.conf syntax is ok
   nginx: configuration file C:\nginx/conf/nginx.conf test is successful
   ```
   
   **如果有错误，检查配置文件语法！**

2. **查看 Nginx 错误日志**
   ```cmd
   notepad C:\nginx\logs\error.log
   ```
   
   查看是否有配置文件加载错误。

---

### 步骤 4: 重新加载 Nginx 配置

1. **重新加载配置**（不中断服务）
   ```cmd
   cd C:\nginx
   nginx -s reload
   ```
   
   **如果报错，先停止再启动**:
   ```cmd
   nginx -s stop
   start nginx
   ```

2. **确认 Nginx 正在运行**
   ```cmd
   tasklist | findstr nginx
   ```
   
   **期望输出**:
   ```
   nginx.exe                      xxxx Console                    1      7,000 K
   nginx.exe                      yyyy Console                    1      8,000 K
   ```

---

### 步骤 5: 测试代理配置

1. **使用 curl 测试**（在服务器上）
   ```cmd
   curl http://localhost/iris-api/invoke -v
   ```
   
   **如果返回 404**: 配置仍未生效
   **如果返回其他错误（如 502）**: 代理配置生效，但后端可能不可达

2. **检查后端服务是否可访问**
   ```cmd
   curl http://111.229.137.113:52773/csp/drg/sysInternalMutiple -v
   ```

---

## 🔧 简化版 Nginx 配置（如果问题持续）

如果配置复杂导致问题，使用这个最小化配置：

```nginx
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        root   html/dist;
        index  index.html index.htm;

        # API 代理 - 最重要的一步
        location /iris-api/ {
            proxy_pass http://111.229.137.113:52773/csp/drg/sysInternalMutiple;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # React Router 支持
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
```

**保存后，务必执行 `nginx -s reload`！**

---

## 📋 快速检查清单

- [ ] Nginx 配置文件已替换为包含 `/iris-api/` 代理的版本
- [ ] 执行了 `nginx -t` 验证配置语法（无错误）
- [ ] 执行了 `nginx -s reload` 重新加载配置
- [ ] 后端服务 `111.229.137.113:52773` 正在运行
- [ ] Windows 防火墙已开放端口 52773（如果后端在另一台服务器）

---

## 🆘 如果还是 404

1. **检查 Nginx 是否加载了正确的配置文件**
   ```cmd
   nginx -V 2>&1 | findstr "configure"
   ```
   
   查看 `--conf-path=` 参数，确认配置文件路径。

2. **完全重启 Nginx**
   ```cmd
   cd C:\nginx
   nginx -s stop
   taskkill /F /IM nginx.exe
   start nginx
   ```

3. **检查是否有多个 Nginx 实例**
   ```cmd
   tasklist | findstr nginx
   ```
   
   如果有两个进程，杀掉所有进程重新启动。

---

## 📞 收集错误信息

如果问题仍未解决，请提供以下信息：
1. `nginx -t` 的输出
2. `C:\nginx\logs\error.log` 的内容
3. 当前 `C:\nginx\conf\nginx.conf` 的内容
4. `tasklist | findstr nginx` 的输出

---

**最后更新**: 2026-06-10
