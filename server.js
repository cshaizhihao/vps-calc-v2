const http = require('http');
const fs = require('fs');
const path = require('path');

// 初始默认凭据
let ADMIN_USER = 'admin';
let ADMIN_PASS = 'admin';
const DEFAULT_PORT = 8030;

const port = process.argv[2] || DEFAULT_PORT;

const MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.js': 'text/javascript; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
};

const server = http.createServer((req, res) => {
    // 处理 API 接口
    if (req.method === 'POST') {
        let body = '';
        req.on('data', chunk => { body += chunk.toString(); });
        req.on('end', () => {
            if (req.url === '/api/login') {
                try {
                    const { user, pass } = JSON.parse(body);
                    if (user === ADMIN_USER && pass === ADMIN_PASS) {
                        res.writeHead(200);
                        res.end('OK');
                    } else {
                        res.writeHead(401);
                        res.end('Unauthorized');
                    }
                } catch (e) { res.writeHead(400); res.end('Bad Request'); }
                return;
            }

            if (req.url === '/api/update-auth') {
                try {
                    const { newUser, newPass, user, pass } = JSON.parse(body);
                    if (user === ADMIN_USER && pass === ADMIN_PASS) {
                        ADMIN_USER = newUser;
                        ADMIN_PASS = newPass;
                        res.writeHead(200);
                        res.end('AUTH UPDATED');
                    } else { res.writeHead(401); res.end('Unauthorized'); }
                } catch (e) { res.writeHead(400); res.end('Bad Request'); }
                return;
            }
        });
        return;
    }

    // 静态文件服务
    let filePath = req.url === '/' ? './index.html' : '.' + req.url;
    filePath = path.join(__dirname, filePath);
    
    // 防止路径穿越
    if (!filePath.startsWith(__dirname)) {
        res.writeHead(403);
        res.end('Forbidden');
        return;
    }

    const extname = path.extname(filePath);
    const contentType = MIME_TYPES[extname] || 'application/octet-stream';

    fs.readFile(filePath, (error, content) => {
        if (error) {
            if (error.code === 'ENOENT') {
                res.writeHead(404);
                res.end('404 Not Found');
            } else {
                res.writeHead(500);
                res.end(`Server Error: ${error.code}`);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        }
    });
});

// 强制绑定到 IPv4 (0.0.0.0) 舍弃 IPv6
server.listen(port, '0.0.0.0', () => {
    console.log(`\n========================================`);
    console.log(`  VPS CALCULATOR V3.2 (CYBERPUNK) ONLINE`);
    console.log(`  IPV4 ONLY: http://0.0.0.0:${port}      `);
    console.log(`  DEFAULT AUTH: admin / admin           `);
    console.log(`========================================\n`);
});
