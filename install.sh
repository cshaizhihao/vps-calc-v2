#!/bin/bash
# VPS CALCULATOR V3.2 极速安装脚本
set -e

echo "========================================"
echo "   NEURAL-LINK VPS CALC INSTALLER"
echo "========================================"

# 1. 环境准备
INSTALL_DIR="/root/vps-calc-v2"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# 2. 依赖检查
if ! command -v node > /dev/null; then
    echo "正在安装 Node.js..."
    if command -v apt > /dev/null; then apt update && apt install -y nodejs
    elif command -v yum > /dev/null; then yum install -y nodejs
    fi
fi

# 3. 下载文件
BASE_URL="https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main"
curl -fsSL "$BASE_URL/server.js" -o server.js
curl -fsSL "$BASE_URL/index.html" -o index.html

# 4. 端口设置 (针对 FinalShell 优化)
read -t 10 -p "请输入端口 [默认 8030]: " PORT || PORT=8030
PORT=${PORT:-8030}

# 5. 启动
echo "正在启动..."
# 尝试杀死旧进程
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then kill -9 "$PID"; fi

nohup node server.js "$PORT" > app.log 2>&1 &

# 6. 完成
IP=$(curl -4 -s ifconfig.me || echo "你的IP")
echo "----------------------------------------"
echo "安装成功！"
echo "访问地址: http://$IP:$PORT"
echo "默认账号: admin"
echo "默认密码: admin"
echo "----------------------------------------"
