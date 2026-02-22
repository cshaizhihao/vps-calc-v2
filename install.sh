#!/bin/bash
# VPS 价值计算器 V3.6.5 汉化版安装与管理脚本
set -e

# 颜色定义
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}    NEURAL-LINK VPS 计算器安装程序      ${NC}"
echo -e "${CYAN}========================================${NC}"

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

# 4. 端口设置 (安全交互)
PORT=8030
echo -n "请输入运行端口 [默认 8030]: "
read USER_PORT
if [ -z "$USER_PORT" ]; then
    PORT=8030
else
    PORT=$USER_PORT
fi

# 5. 生成管理命令 syjz
cat << EOF > /usr/local/bin/syjz
#!/bin/bash
case "\$1" in
    "update"|"更新")
        echo "正在同步最新代码..."
        cd $INSTALL_DIR
        curl -fsSL "$BASE_URL/server.js" -o server.js
        curl -fsSL "$BASE_URL/index.html" -o index.html
        PID=\$(lsof -t -i:$PORT 2>/dev/null || true)
        if [ -n "\$PID" ]; then kill -9 "\$PID"; fi
        nohup node server.js "$PORT" > app.log 2>&1 &
        echo "更新完成！"
        ;;
    "uninstall"|"卸载")
        read -p "确定要卸载吗？(y/n): " confirm
        if [ "\$confirm" == "y" ]; then
            PID=\$(lsof -t -i:$PORT 2>/dev/null || true)
            if [ -n "\$PID" ]; then kill -9 "\$PID"; fi
            rm -rf $INSTALL_DIR
            rm /usr/local/bin/syjz
            echo "卸载成功。"
        fi
        ;;
    *)
        echo "VPS计算器管理命令 syjz"
        echo "用法: syjz [update|uninstall]"
        echo "      syjz 更新"
        echo "      syjz 卸载"
        ;;
esac
EOF
chmod +x /usr/local/bin/syjz

# 6. 启动服务
echo "正在启动服务，监听端口: $PORT ..."
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
if [ -n "$PID" ]; then kill -9 "$PID" || true; fi

nohup node server.js "$PORT" > app.log 2>&1 &
sleep 2

# 7. 完成
IP=$(curl -4 -s ifconfig.me || echo "服务器IP")
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "${GREEN}安装圆满成功！${NC}"
echo -e "访问地址: ${CYAN}http://${IP}:${PORT}${NC}"
echo -e "默认账号: ${GREEN}admin${NC}  密码: ${GREEN}admin${NC}"
echo -e "${CYAN}----------------------------------------${NC}"
echo -e "快捷管理命令: ${GREEN}syjz${NC}"
echo -e " - 输入 ${CYAN}syjz update${NC}    进行代码更新"
echo -e " - 输入 ${CYAN}syjz uninstall${NC} 进行程序卸载"
echo -e "${CYAN}----------------------------------------${NC}"
