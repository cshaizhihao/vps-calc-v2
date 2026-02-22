const http = require('http');
const fs = require('fs');
const path = require('path');

// 初始默认凭据
let ADMIN_USER = 'admin';
let ADMIN_PASS = 'admin';
const DEFAULT_PORT = 8030;

const port = process.argv[2] || DEFAULT_PORT;

const server = http.createServer((req, res) => {
    // 静态文件服务
    if (req.url === '/' || req.url === '/index.html') {
        fs.readFile(path.join(__dirname, 'index.html'), (err, data) => {
            res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
            res.end(data);
        });
        return;
    }

    // 后台登录接口
    if (req.url === '/api/login' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => { body += chunk.toString(); });
        req.on('end', () => {
            try {
                const { user, pass } = JSON.parse(body);
                if (user === ADMIN_USER && pass === ADMIN_PASS) {
                    res.writeHead(200);
                    res.end('OK');
                } else {
                    res.writeHead(401);
                    res.end('Unauthorized');
                }
            } catch (e) {
                res.writeHead(400);
                res.end('Bad Request');
            }
        });
        return;
    }

    // 修改凭据接口
    if (req.url === '/api/update-auth' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => { body += chunk.toString(); });
        req.on('end', () => {
            try {
                const { newUser, newPass, user, pass } = JSON.parse(body);
                // 验证当前权限
                if (user === ADMIN_USER && pass === ADMIN_PASS) {
                    ADMIN_USER = newUser;
                    ADMIN_PASS = newPass;
                    res.writeHead(200);
                    res.end('AUTH UPDATED');
                } else {
                    res.writeHead(401);
                    res.end('Unauthorized');
                }
            } catch (e) {
                res.writeHead(400);
                res.end('Bad Request');
            }
        });
        return;
    }

    res.writeHead(404);
    res.end('Not Found');
});

// 强制绑定到 IPv4 (0.0.0.0) 舍弃 IPv6
server.listen(port, '0.0.0.0', () => {
    console.log(`\n========================================`);
    console.log(`  NEURAL-LINK VPS CALCULATOR ONLINE  `);
    console.log(`  IPV4 ONLY: http://0.0.0.0:${port}      `);
    console.log(`  DEFAULT AUTH: admin / admin           `);
    console.log(`========================================\n`);
});
