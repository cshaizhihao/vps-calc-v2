#!/bin/bash
# VPS 价值计算器 V3.6.8 自定义端口 & 管理命令终极修复版
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

# 4. 端口设置 (完全修复自定义端口逻辑)
PORT=8030
echo -n "请输入运行端口 [直接回车使用预览默认 8030]: "
read USER_PORT
if [ ! -z "$USER_PORT" ]; then
    if [[ "$USER_PORT" =~ ^[0-9]+$ ]]; then
        PORT=$USER_PORT
    else
        echo "输入无效，降级使用默认端口 8030"
    fi
fi

# 5. 关键修复：将端口持久化写入管理脚本
echo "正在配置系统管理命令 syjz ..."
rm -f /usr/bin/syjz

cat << EOF > "$INSTALL_DIR/manage.sh"
#!/bin/bash
INSTALL_DIR="$INSTALL_DIR"
BASE_URL="$BASE_URL"
PORT=$PORT
case "\$1" in
    "update")
        echo "正在更新代码至最新版本..."
        cd \$INSTALL_DIR
        curl -fsSL "\$BASE_URL/server.js" -o server.js
        curl -fsSL "\$BASE_URL/index.html" -o index.html
        PID=\$(lsof -t -i:\$PORT 2>/dev/null || true)
        [ -n "\$PID" ] && kill -9 "\$PID"
        nohup node server.js "\$PORT" > app.log 2>&1 &
        echo "更新成功，当前运行端口: \$PORT"
        ;;
    "uninstall")
        read -p "确定卸载吗？(y/n): " confirm
        if [ "\$confirm" == "y" ]; then
            PID=\$(lsof -t -i:\$PORT 2>/dev/null || true)
            [ -n "\$PID" ] && kill -9 "\$PID" 2>/dev/null || true
            rm -rf \$INSTALL_DIR /usr/bin/syjz
            echo "已彻底移除。"
        fi
        ;;
    *)
        echo "用法: syjz update (更新) / syjz uninstall (卸载)"
        ;;
esac
EOF

chmod +x "$INSTALL_DIR/manage.sh"
# 创建全局软链接
ln -sf "$INSTALL_DIR/manage.sh" /usr/bin/syjz

# 6. 启动服务
echo "正在启动服务，端口: $PORT ..."
PID=$(lsof -t -i:"$PORT" 2>/dev/null || true)
[ -n "$PID" ] && kill -9 "$PID" || true
nohup node server.js "$PORT" > app.log 2>&1 &
sleep 2

# 7. 最终显示
IP=$(curl -4 -s ifconfig.me || echo "IP")
echo "----------------------------------------"
echo "安装圆满成功！"
echo "访问地址: http://${IP}:${PORT}"
echo "快捷管理: syjz"
echo " - 更新代码: syjz update"
echo " - 彻底卸载: syjz uninstall"
echo "----------------------------------------"
