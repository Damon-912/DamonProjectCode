const http = require('http');
const httpProxy = require('http-proxy');
const fs = require('fs');
const path = require('path');
const url = require('url');

const proxy = httpProxy.createProxyServer({});
const PORT = 8090;
const STATIC_DIR = 'C:\\inetpub\\wwwroot\\DRG';

const server = http.createServer((req, res) => {
    // 设置 CORS 头
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }
    
    console.log('Request:', req.url);
    
    // API proxy - 处理 /iris-api/invoke
    if (req.url.startsWith('/iris-api/')) {
        const targetUrl = 'http://111.229.137.113:52773/csp/drg/sysInternalMutiple' + req.url.substring('/iris-api'.length);
        console.log('Proxying to:', targetUrl);
        
        proxy.web(req, res, { 
            target: 'http://111.229.137.113:52773',
            changeOrigin: true,
            pathRewrite: {
                '^/iris-api': '/csp/drg/sysInternalMutiple'
            }
        }, (err) => {
            console.error('Proxy error:', err);
            res.writeHead(500);
            res.end(JSON.stringify({ errorCode: '-1', errorMessage: '代理错误: ' + err.message }));
        });
        return;
    }
    
    // Static files
    let filePath = path.join(STATIC_DIR, req.url === '/' ? 'index.html' : req.url);
    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
        filePath = path.join(STATIC_DIR, 'index.html');
    }
    
    const ext = path.extname(filePath);
    const contentType = {
        '.html': 'text/html',
        '.js': 'application/javascript',
        '.css': 'text/css',
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.svg': 'image/svg+xml'
    }[ext] || 'application/octet-stream';
    
    fs.readFile(filePath, (err, data) => {
        if (err) {
            console.error('File error:', err);
            res.writeHead(404);
            res.end('Not found');
            return;
        }
        res.setHeader('Content-Type', contentType);
        res.writeHead(200);
        res.end(data);
    });
});

proxy.on('error', (err, req, res) => {
    console.error('Proxy error:', err);
    res.writeHead(500);
    res.end(JSON.stringify({ errorCode: '-1', errorMessage: '代理错误' }));
});

server.listen(PORT, '0.0.0.0', () => {
    console.log('Server running on http://0.0.0.0:' + PORT);
    console.log('Static dir:', STATIC_DIR);
});
