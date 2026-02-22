const http = require('http');
const fs = require('fs');
const path = require('path');

const ADMIN_USER = 'cshaizhihao';
const ADMIN_PASS = 'a5139801';
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

    res.writeHead(404);
    res.end('Not Found');
});

server.listen(port, () => {
    console.log(`\n========================================`);
    console.log(`  NEURAL-LINK VPS CALCULATOR ONLINE  `);
    console.log(`  PORT: ${port}                          `);
    console.log(`  URL: http://localhost:${port}          `);
    console.log(`========================================\n`);
});
