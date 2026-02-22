#!/bin/bash
# VPS 价值计算器 V3.6.7 绝对系统路径修复版
set -e

# 1. 基础配置
INSTALL_DIR="/root/vps-calc-v2"
BASE_URL="https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main"

echo "========================================"
echo "    NEURAL-LINK VPS 计算器安装程序"
echo "========================================"

# 2. 依赖检查与目录初始化
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if ! command -v node > /dev/null; then
    echo "正在安装 Node.js..."
    if command -v apt > /dev/null; then apt update && apt install -y nodejs
    elif command -v yum > /dev/null; then yum install -y nodejs
    fi
fi

# 3. 下载文件
echo "正在获取核心组件..."
curl -fsSL "$BASE_URL/server.js" -o server.js
curl -fsSL "$BASE_URL/index.html" -o index.html

# 4. 端口设置
echo -n "请输入运行端口 [默认 8030]: "
read USER_PORT
PORT=${USER_PORT:-8030}

# 5. 关键修复：创建软链接，这种方式在 Linux 下最可靠
echo "正在配置系统管理命令..."
# 先删除可能存在的旧文件
rm -f /usr/bin/syjz /usr/local/bin/syjz /bin/syjz

# 创建管理脚本本体
cat << 'EOF' > /root/vps-calc-v2/manage.sh
#!/bin/bash
INSTALL_DIR="/root/vps-calc-v2"
BASE_URL="https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main"
case "$1" in
    "update")
        echo "正在更新代码..."
        cd $INSTALL_DIR
        curl -fsSL "$BASE_URL/server.js" -o server.js
        curl -fsSL "$BASE_URL/index.html" -o index.html
        CURR_PORT=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $NF}' | head -n 1)
        PORT=${CURR_PORT:-8030}
        PID=$(lsof -t -i:$PORT 2>/dev/null || true)
        [ -n "$PID" ] && kill -9 "$PID"
        nohup node server.js "$PORT" > app.log 2>&1 &
        echo "更新成功，端口: $PORT"
        ;;
    "uninstall")
        read -p "确定卸载吗？(y/n): " confirm
        if [ "$confirm" == "y" ]; then
            CURR_PORT=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $NF}' | head -n 1)
            [ -n "$CURR_PORT" ] && kill -9 $(lsof -t -i:$CURR_PORT) 2>/dev/null || true
            rm -rf $INSTALL_DIR /usr/bin/syjz
            echo "已彻底移除。"
        fi
        ;;
    *)
        echo "用法: syjz update (更新) / syjz uninstall (卸载)"
        ;;
esac
EOF

chmod +x /root/vps-calc-v2/manage.sh
# 创建到 /usr/bin 的直接软链接
ln -sf /root/vps-calc-v2/manage.sh /usr/bin/syjz

# 6. 启动服务
echo "正在启动服务..."
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
[ -n "$PID" ] && kill -9 "$PID" || true
nohup node server.js "$PORT" > app.log 2>&1 &
sleep 2

# 7. 最终显示
IP=$(curl -4 -s ifconfig.me || echo "IP")
echo "----------------------------------------"
echo "安装成功！"
echo "访问地址: http://${IP}:${PORT}"
echo "管理命令: syjz (若提示找不到, 请重新打开终端或输入 source /etc/profile)"
echo "----------------------------------------"
