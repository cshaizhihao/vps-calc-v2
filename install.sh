#!/bin/bash
# VPS 价值计算器 V3.6.6 系统集成修复版
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    NEURAL-LINK VPS 计算器安装程序      ${NC}"
echo -e "${CYAN}========================================${NC}"

INSTALL_DIR="/root/vps-calc-v2"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if ! command -v node > /dev/null; then
    echo "正在安装 Node.js..."
    if command -v apt > /dev/null; then apt update && apt install -y nodejs
    elif command -v yum > /dev/null; then yum install -y nodejs
    fi
fi

BASE_URL="https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main"
echo "正在从 GitHub 获取最新组件..."
curl -fsSL "$BASE_URL/server.js" -o server.js
curl -fsSL "$BASE_URL/index.html" -o index.html

PORT=8030
echo -n "请输入运行端口 [默认 8030]: "
read USER_PORT
if [ -z "$USER_PORT" ]; then PORT=8030; else PORT=$USER_PORT; fi

# --- 核心修复：生成 /usr/bin/syjz 并强制刷新 ---
cat << 'EOF' > /usr/bin/syjz
#!/bin/bash
INSTALL_DIR="/root/vps-calc-v2"
BASE_URL="https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main"
case "$1" in
    "update"|"更新")
        echo "正在同步最新代码..."
        cd $INSTALL_DIR
        curl -fsSL "$BASE_URL/server.js" -o server.js
        curl -fsSL "$BASE_URL/index.html" -o index.html
        # 获取当前运行的端口
        CURRENT_PORT=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $NF}' | head -n 1)
        PORT=${CURRENT_PORT:-8030}
        PID=$(lsof -t -i:$PORT 2>/dev/null || true)
        if [ -n "$PID" ]; then kill -9 "$PID"; fi
        nohup node server.js "$PORT" > app.log 2>&1 &
        echo "更新完成！端口: $PORT"
        ;;
    "uninstall"|"卸载")
        read -p "确定要卸载吗？(y/n): " confirm
        if [ "$confirm" == "y" ]; then
            CURRENT_PORT=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $NF}' | head -n 1)
            [ -n "$CURRENT_PORT" ] && kill -9 $(lsof -t -i:$CURRENT_PORT) 2>/dev/null || true
            rm -rf $INSTALL_DIR
            rm /usr/bin/syjz
            echo "卸载成功。"
        fi
        ;;
    *)
        echo "VPS计算器管理命令 syjz"
        echo "用法: syjz [update|uninstall]"
        ;;
esac
EOF

chmod +x /usr/bin/syjz
# 强制让 bash 重新哈希命令路径，确保 syjz 立即生效
hash -r 2>/dev/null || true

echo "正在启动服务..."
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then kill -9 "$PID" || true; fi

nohup node server.js "$PORT" > app.log 2>&1 &
sleep 2

IP=$(curl -4 -s ifconfig.me || echo "服务器IP")
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${GREEN}安装圆满成功！${NC}"
echo -e "访问地址: ${CYAN}http://${IP}:${PORT}${NC}"
echo -e "管理命令: ${GREEN}syjz${NC}"
echo -e "${CYAN}----------------------------------------${NC}"
