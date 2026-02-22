# VPS 剩余价值计算器 (Cyberpunk 2077 Edition)

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-3.0-fcee0a.svg)

基于赛博朋克 2077 视觉元素打造的轻量级 VPS 交易计算工具。

## 核心功能
- **精确计算**：支持多种付款周期，精确到天的剩余价值计算。
- **视觉风格**：沉浸式赛博朋克 UI。
- **AAC 后台**：内置 Icebreaker 登录系统，支持通过 HTML、Markdown 和 CSS 实时美化和自定义网页。
- **零依赖运行**：仅需 Node.js 即可在全球任意服务器部署。

## 常用信息
- **默认账号**：`admin`
- **默认密码**：`admin`
- **后台入口**：点击页面右下角 `[ROOT_ACCESS]` (登录后可修改凭据)

---

## 一键安装脚本 (推荐)

在你的服务器上执行以下命令即可快速启动：

```bash
curl -fsSL https://raw.githubusercontent.com/cshaizhihao/vps-calc-v2/main/install.sh | bash
```

---

## 手动本地安装方式

1. 克隆代码：
   ```bash
   git clone https://github.com/cshaizhihao/vps-calc-v2.git
   cd vps-calc-v2
   ```

2. 运行：
   ```bash
   node server.js [端口号]
   ```

---
*Created by Neural-Link System*
