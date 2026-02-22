#!/bin/bash
# VPS CALCULATOR V3.4 脚本变量修复版
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

# 4. 端口设置 (修复交互变量漏读问题)
# 强制先声明一个默认值
PORT=8030
echo "请输入端口 [直接回车使用预览默认 8030]: "
# read 在某些环境下即使超时也会清空已有的默认变量，所以需要使用临时变量备份
if read -t 10 TEMP_PORT; then
    if [ ! -z "$TEMP_PORT" ]; then
        PORT=$TEMP_PORT
    fi
fi

# 5. 启动
echo "正在启动，监听端口: $PORT ..."
# 确保端口未被占用
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then 
    echo "正在关闭占用端口 $PORT 的进程..."
    kill -9 "$PID" || true
fi

# 核心：启动脚本
nohup node server.js "$PORT" > app.log 2>&1 &
sleep 2

# 6. 完成
# 这里必须直接使用 $PORT 变量
IP=$(curl -4 -s ifconfig.me || echo "你的IP")
echo "----------------------------------------"
echo "安装成功！"
echo "访问地址: http://${IP}:${PORT}"
echo "默认账号: admin"
echo "默认密码: admin"
echo "----------------------------------------"
