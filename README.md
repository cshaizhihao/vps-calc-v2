# VPS 剩余价值计算器 (Cyberpunk 2077 // Neural-Link Edition)

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-3.6-fcee0a.svg)

基于赛博朋克 2077 视觉元素打造的深度沉浸式 VPS 交易计算工具。

## 🚀 核心功能
- **精确价值计算**：支持月/季/半年/年/两年等周期，结合实时汇率精准计算。
- **沉浸式赛博 UI**：玻璃拟态材质、霓虹呼吸灯、数字滚动动效、故障艺术风格。
- **多币种自动汇率**：内置 CNY、USD、EUR、JPY、HKD、GBP 实时汇率转换。
- **AAC 核心后台**：支持通过 HTML/Markdown/CSS 注入实时美化网页。
- **自定义视觉**：管理后台可一键更换全局动态/静态背景。
- **中英双语**：全界面中西双语标注，安装程序全汉化。
- **IPv4 锁定**：强制 IPv4 监听，完美解决双栈服务器连接难题。

## 🔐 常用信息 (初始化)
- **默认账号**：`admin`
- **默认密码**：`admin`
- **后台入口**：点击页面右下角极小字样 `[系统覆盖 // SYSTEM_OVERRIDE]`
- **安全提示**：登录后请务必在后台修改默认凭据。

---

## 🛠️ 一键安装脚本 (推荐)

在你的 Linux 服务器上执行以下命令即可全自动安装（支持 root/sudo）：

```bash
curl -fsSL https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main/install.sh | bash
```

---

## 📦 手动本地安装

1. 克隆代码：
   ```bash
   git clone https://github.com/cshaizhihao/vps-calc-v2.git
   cd vps-calc-v2
   ```

2. 运行环境要求：
   - 包含 Node.js 环境（脚本会自动尝试安装，如失败请手动安装 `apt install nodejs -y`）

3. 启动：
   ```bash
   node server.js [自定义端口]
   ```

---
*Created by Neural-Link System v3.6*
