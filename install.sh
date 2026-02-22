#!/bin/bash
# VPS 价值计算器 V3.6.2 强交互安装脚本
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
    echo "正在安装 Node.js (JavaScript 运行环境)..."
    if command -v apt > /dev/null; then 
        apt update && apt install -y nodejs
    elif command -v yum > /dev/null; then 
        yum install -y nodejs
    fi
fi

# 3. 下载文件
BASE_URL="https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main"
echo "正在从 GitHub 获取最新中文组件..."
curl -fsSL "$BASE_URL/server.js" -o server.js
curl -fsSL "$BASE_URL/index.html" -o index.html

# 4. 端口设置 (修复交互逻辑)
PORT=8030
echo "请输入您想使用的运行端口 (例: 8080):"
echo "提示: 直接按回车将使用默认端口 8030"

# 使用 read 进行阻塞式交互，除非在非交互式环境或用户手动超时
# 之前的脚本可能因为 read 逻辑在某些 shell 环境下对空输入的处理导致自动跳过
# 现在改为明确读取
read USER_PORT

if [ ! -z "$USER_PORT" ]; then
    if [[ "$USER_PORT" =~ ^[0-9]+$ ]]; then
        PORT=$USER_PORT
    else
        echo "检测到非数字输入，将降级使用默认端口 8030"
        PORT=8030
    fi
fi

# 5. 启动服务
echo "正在启动服务，监听端口: $PORT ..."
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then 
    echo "正在关闭占用端口 $PORT 的旧程序..."
    kill -9 "$PID" || true
fi

# 核心启动
nohup node server.js "$PORT" > app.log 2>&1 &
sleep 2

# 6. 完成并输出汉化信息
IP=$(curl -4 -s ifconfig.me || echo "您的服务器IP")
echo "----------------------------------------"
echo "安装圆满成功！"
echo "访问地址: http://${IP}:${PORT}"
echo "默认管理账号: admin"
echo "默认管理密码: admin"
echo "----------------------------------------"
