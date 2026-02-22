#!/bin/bash

# ====================================================
# VPS 剩余价值计算器 V3.0 一键安装脚本
# ====================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    NEURAL-LINK VPS CALC INSTALLER      ${NC}"
echo -e "${CYAN}========================================${NC}"

# 1. 环境检查与目录创建
echo -e "${YELLOW}[1/4]${NC} 正在初始化目录..."
INSTALL_DIR="/root/vps-calc-v2"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit

# 2. 检查并安装 Node.js
if ! command -v node > /dev/null; then
    echo -e "${YELLOW}[2/4]${NC} 正在安装 Node.js 运行环境..."
    if command -v apt > /dev/null; then
        apt update && apt install -y nodejs
    elif command -v yum > /dev/null; then
        yum install -y nodejs
    else
        echo -e "${RED}错误: 无法确定包管理器，请手动安装 Node.js${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}[OK]${NC} Node.js 已安装: $(node -v)"
fi

# 3. 下载源码文件
echo -e "${YELLOW}[3/4]${NC} 正在从 GitHub 同步最新核心文件..."
curl -fsSL https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main/server.js -o server.js
curl -fsSL https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main/index.html -o index.html

if [ ! -f "server.js" ]; then
    echo -e "${RED}同步失败，请检查网络连接${NC}"
    exit 1
fi

# 4. 启动服务
echo -e "${YELLOW}[4/4]${NC} 配置端口并启动..."
# FinalShell 适配：增加超时处理防止 read 阻塞
read -t 10 -p "请输入运行端口 [默认 8030]: " PORT
PORT=${PORT:-8030}

# 杀死占用该端口的旧进程
PID=$(lsof -t -i:"$PORT" 2>/dev/null)
if [ -n "$PID" ]; then
    kill -9 "$PID"
fi

nohup node server.js "$PORT" > app.log 2>&1 &

echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${GREEN}安装成功！系统已进入后台运行。${NC}"
echo -e "${YELLOW}访问地址: http://$(curl -4 -s ifconfig.me):$PORT${NC}"
echo -e "日志路径: $INSTALL_DIR/app.log"
echo -e "${CYAN}----------------------------------------${NC}"
