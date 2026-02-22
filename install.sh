#!/bin/bash
# VPS 价值计算器 V3.6.3 交互逻辑彻底修复版
set -e

echo "========================================"
echo "    NEURAL-LINK VPS 计算器安装程序"
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
echo "正在从 GitHub 获取最新组件..."
curl -fsSL "$BASE_URL/server.js" -o server.js
curl -fsSL "$BASE_URL/index.html" -o index.html

# 4. 端口设置 (彻底修复交互逻辑)
# 强制开启标准输入关联
exec < /dev/tty 2>/dev/null || exec < /dev/stdin

PORT=8030
echo -n "请输入您想使用的运行端口 [默认 8030]: "
read USER_PORT

if [ -n "$USER_PORT" ]; then
    if [[ "$USER_PORT" =~ ^[0-9]+$ ]]; then
        PORT=$USER_PORT
    else
        echo "检测到非数字，使用默认值 8030"
    fi
fi

# 5. 启动服务
echo "正在启动服务，监听端口: $PORT ..."
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then kill -9 "$PID" || true; fi

nohup node server.js "$PORT" > app.log 2>&1 &
sleep 2

# 6. 完成
IP=$(curl -4 -s ifconfig.me || echo "服务器IP")
echo "----------------------------------------"
echo "安装圆满成功！"
echo "访问地址: http://${IP}:${PORT}"
echo "默认管理账号: admin"
echo "默认管理密码: admin"
echo "----------------------------------------"
