const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const PORT = 8090;

// 代理 API 请求
app.use('/iris-api', createProxyMiddleware({
    target: 'http://111.229.137.113:52773/csp/drg/sysInternalMutiple',
    changeOrigin: true,
    pathRewrite: {
        '^/iris-api': ''
    },
    onProxyRes: function(proxyRes, req, res) {
        proxyRes.headers['Access-Control-Allow-Origin'] = '*';
    },
    onError: function(err, req, res) {
        console.error('Proxy error:', err);
        res.status(500).json({ errorCode: '-1', errorMessage: '代理错误' });
    }
}));

// 静态文件
app.use(express.static('C:\\inetpub\\wwwroot\\DRG'));

// SPA 回退 - 使用正则表达式匹配所有路径
app.use((req, res) => {
    res.sendFile(path.join('C:\\inetpub\\wwwroot\\DRG', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
    console.log('Server running on http://0.0.0.0:' + PORT);
});
