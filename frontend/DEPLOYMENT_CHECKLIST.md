# DRG系统前端部署检查清单

## ✅ 已完成的配置修改

### 1. API配置文件已更新
- ✅ `src/containers/config/httpConfig.js` - 已更新为使用 Nginx 代理
- ✅ `nginx.conf` - 已添加 API 代理配置

### 2. 配置说明
- **开发环境**: 使用 Vite 代理 (`vite.config.ts`)
- **生产环境**: 使用 Nginx 代理 (`nginx.conf`)

---

## 📋 部署前检查清单

### 1. 后端服务检查
- [ ] 确认云服务器 `111.229.137.113:52773` 的 IRIS 服务正在运行
- [ ] 确认 API 端点 `/csp/drg/sysInternalMutiple` 可以访问
- [ ] 测试 API 连接：
  ```bash
  curl -X POST http://111.229.137.113:52773/csp/drg/sysInternalMutiple \
    -H "Content-Type: application/json" \
    -H "Authorization: Basic cHJoaXA6cHJoaXBAMjAyMA==" \
    -d '{"code":"01040073","params":[]}'
  ```

### 2. 前端构建检查
- [ ] 重新构建前端项目：
  ```bash
  cd "d:/AI开发/CodeBuddy/DRG医保控费预警系统开发项目/frontend"
  npm run build
  ```
- [ ] 确认 `dist` 目录生成成功
- [ ] 检查 `dist/index.html` 是否存在

### 3. 文件上传准备
需要上传到服务器的文件：
- [ ] `frontend/dist/` 目录（整个目录）
- [ ] `frontend/nginx.conf` 配置文件

---

## 🚀 服务器端部署步骤

### 步骤 1: 安装 Nginx
1. 下载 Nginx for Windows: http://nginx.org/en/download.html
2. 解压到 `C:\nginx`

### 步骤 2: 部署前端文件
```cmd
mkdir C:\nginx\html\dist
xcopy /E /Y \path\to\dist\* C:\nginx\html\dist\
```

### 步骤 3: 配置 Nginx
1. 备份原配置：`copy C:\nginx\conf\nginx.conf C:\nginx\conf\nginx.conf.bak`
2. 用提供的 `nginx.conf` 替换 `C:\nginx\conf\nginx.conf`

### 步骤 4: 启动 Nginx
```cmd
cd C:\nginx
start nginx
nginx -s reload
```

### 步骤 5: 配置防火墙
1. 开放端口 80（HTTP）
2. 确认端口 52773（IRIS）对已部署的前端可访问

---

## 🔍 部署后验证

### 1. 基本访问测试
- [ ] 浏览器访问：http://111.229.137.113
- [ ] 确认登录页面正常显示

### 2. API 代理测试
- [ ] 打开浏览器开发者工具（F12）
- [ ] 尝试登录，观察 Network 标签
- [ ] 确认 API 请求 `/iris-api/invoke` 返回正常（状态码 200）

### 3. 常见问题排查
如果遇到问题：
1. **页面无法访问**
   - 检查 Nginx 是否运行：`tasklist | findstr nginx`
   - 查看 Nginx 日志：`C:\nginx\logs\error.log`

2. **API 请求失败**
   - 检查 IRIS 服务是否运行
   - 检查 Nginx 代理配置
   - 查看浏览器控制台错误信息

3. **CORS 错误**
   - 确认 Nginx 配置中的 CORS headers 正确
   - 检查 IRIS 服务的 CORS 配置

---

## 📝 配置文件说明

### 已修改的配置文件
1. **`src/containers/config/httpConfig.js`**
   - `ipDeault`: 生产环境设为空（使用相对路径）
   - `urlAddress`: 改为 `/iris-api/invoke`

2. **`nginx.conf`**
   - 添加 `/iris-api/` 路径的代理配置
   - 代理到 `http://111.229.137.113:52773/csp/drg/sysInternalMutiple`

### 未修改的配置文件
- **`vite.config.ts`** - 仅用于开发环境，无需修改
- **`src/api/request.ts`** - 已正确配置 `baseURL: '/iris-api'`

---

## 📞 技术支持

如遇到部署问题，请检查：
1. Nginx 错误日志：`C:\nginx\logs\error.log`
2. 浏览器控制台错误
3. 网络请求状态（F12 -> Network）

---

**最后更新**: 2026-06-10
