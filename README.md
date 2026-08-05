<div align="center">

  <a href="https://github.com/nhzhongguo">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=25&pause=1200&color=0969DA&center=true&vCenter=true&width=600&lines=%E4%BD%A0%E5%A5%BD%EF%BC%8C%E6%88%91%E6%98%AF%E5%86%B7%E6%BC%A0%E4%B8%8D%E6%98%AF%E7%A5%9E+%F0%9F%91%8B;%E8%B7%AF%E7%94%B1%E5%99%A8%E6%8A%98%E8%85%BE+%C2%B7+%E5%AE%B6%E5%BA%AD%E7%BD%91%E7%BB%9C+%C2%B7+OpenWrt;%E5%BC%80%E5%8F%91+%C2%B7+AI+%E5%B7%A5%E5%85%B7%E9%93%BE+%C2%B7+MCP" alt="冷漠不是神" />
  </a>

  <p>冷漠的秘密仓库，记录每一次折腾，也分享每一个答案。</p>

  <a href="https://openwrt.org/"><img src="https://img.shields.io/badge/OpenWrt-00A3E0?style=flat-square&logo=openwrt&logoColor=white" alt="OpenWrt" /></a>
  <img src="https://img.shields.io/badge/%E5%AE%B6%E5%BA%AD%E7%BD%91%E7%BB%9C-0969DA?style=flat-square" alt="家庭网络" />
  <img src="https://img.shields.io/badge/%E8%B7%AF%E7%94%B1%E5%99%A8%E6%8A%98%E8%85%BE-238636?style=flat-square" alt="路由器折腾" />
  <img src="https://img.shields.io/badge/3X--UI-FF6C37?style=flat-square&logo=x" alt="3X-UI" />
  <img src="https://img.shields.io/badge/Xray-00AEFF?style=flat-square&logo=x" alt="Xray" />
  <img src="https://img.shields.io/badge/VPS-B72CFF?style=flat-square&logo=ubuntu&logoColor=white" alt="VPS" />
  <img src="https://img.shields.io/badge/PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white" alt="PowerShell" />
  <img src="https://img.shields.io/badge/AI%20Vision-6F42C1?style=flat-square&logo=openai&logoColor=white" alt="AI Vision" />
  <img src="https://img.shields.io/badge/MCP-000000?style=flat-square" alt="MCP" />
  <img src="https://img.shields.io/badge/Gitee-C71D23?style=flat-square&logo=gitee&logoColor=white" alt="Gitee" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white" alt="Docker" />
  <img src="https://img.shields.io/badge/Vue.js-42B883?style=flat-square&logo=vuedotjs&logoColor=white" alt="Vue.js" />
  <img src="https://img.shields.io/badge/PHP-777BB4?style=flat-square&logo=php&logoColor=white" alt="PHP" />

</div>

<br />

## 🔥 正在折腾

- 🔧 OpenWrt 刷机、设备救砖和 eMMC 扩容
- 🌐 家庭网络配置、排错和长期使用记录
- 🚀 VLESS+Reality 节点搭建与优化（CN2 线路 + BBR）
- 🛠️ 3X-UI 面板二次开发：Bug 修复、UI 升级、Reality 增强
- 🤖 给不支持视觉的大模型装上眼睛：Auto Vision Bridge + 免费视觉 MCP
- 📱 手机远程控制 Windows 上的 Codex（ChatGPT Win）
- 🧩 为 Codex 补齐 Gitee 仓库、项目上传与 Pull Request 工作流
- 📊 聚合 OpenAI / Anthropic / OpenRouter / DeepSeek 的官方用量数据
- 🌾 多账号 QQ 农场自动托管、可视化看板与 19 渠道告警
- 🎬 短视频无水印解析、批量任务与版本化 API
- 📝 把踩过的坑写成别人也能照着做的教程

<table>
  <tr>
    <td width="50%" valign="top">
      <h3>🎯 设备与方向</h3>
      <pre><code>路由器    京东云鲁班二代（RE-CP-02）
固件      ImmortalWrt 23.05.4
服务器    Ubuntu 24.04 × 洛杉矶 CN2
关注      稳定、清晰、可复现</code></pre>
    </td>
    <td width="50%" valign="top">
      <h3>💻 技术栈</h3>
      <pre><code>路由      OpenWrt / ImmortalWrt
代理      Xray-core / Reality / Vision
面板      3X-UI 3.5.0
AI/中转   Auto Vision Bridge / MCP
跨端      Android / WPF / CDP
插件      Codex Plugin / Gitee MCP
后端      Go / Python / PHP / Shell / Node.js
前端      React / Vue / TypeScript / Ant Design
运维      Docker / systemd / ufw / iptables</code></pre>
    </td>
  </tr>
</table>

## 📚 作品

<a href="https://github.com/nhzhongguo/codex-gitee-marketplace">
  <img align="right" width="170" src="https://img.shields.io/badge/Codex%20Gitee-Plugin-C71D23?style=for-the-badge&logo=gitee&logoColor=white" alt="Codex Gitee Plugin" />
</a>

### [豫晨 Gitee Codex 插件市场 🆕](https://github.com/nhzhongguo/codex-gitee-marketplace)

让 Codex 通过本地 MCP 服务操作 Gitee：查看和创建仓库、管理分支、预览并上传本地项目，以及创建 Pull Request。访问令牌仅从本机环境变量读取；远程写操作必须先预览确认，上传前会拦截敏感文件，同时支持 Gitee / GitHub 双源安装。

<a href="https://github.com/nhzhongguo/usage-atlas">
  <img align="right" width="170" src="https://img.shields.io/badge/Usage%20Atlas-Token%20Dashboard-009688?style=for-the-badge&logo=chartdotjs&logoColor=white" alt="Usage Atlas" />
</a>

### [Usage Atlas — 多平台 Token 账本 🆕](https://github.com/nhzhongguo/usage-atlas)

本地优先的 API 用量仪表盘，通过官方接口汇总 OpenAI、Anthropic、OpenRouter、DeepSeek 与自定义兼容平台的 Token、请求、费用、限额或余额。明确区分官方数据、本地预算和平台未开放指标，密钥不落盘，并为自定义平台请求设置严格的 SSRF 防护边界。

<a href="https://github.com/nhzhongguo/qushuiyin-jiexi">
  <img align="right" width="170" src="https://img.shields.io/badge/Video%20Parser-PHP-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="Video Parser" />
</a>

### [去水印解析 — 短视频无水印工具 🆕](https://github.com/nhzhongguo/qushuiyin-jiexi)

基于 5ime/video_spider 二次开发，覆盖抖音、快手、B 站、小红书、视频号等主流平台。重做网页视觉与交互，补齐单个 / 批量解析、历史记录、版本化 API 和 OpenAPI 文档，并加入请求限流、媒体代理、可选 API 鉴权及输入校验。

<a href="https://github.com/nhzhongguo/qq-farm-bot">
  <img align="right" width="170" src="https://img.shields.io/badge/QQ%20Farm-Automation-42B883?style=for-the-badge&logo=vuedotjs&logoColor=white" alt="QQ Farm Bot" />
</a>

### [QQ Farm Bot — 多账号自动化托管平台](https://github.com/nhzhongguo/qq-farm-bot)

面向长期挂机场景的自托管系统：每个农场账号由独立 Worker 驱动，提供自动农活、好友互动、收益趋势、任务调度和移动端适配的 Vue 3 面板。支持 19 种告警渠道、原子写入与自动备份、诊断和审计脱敏，并提供 Docker 部署与完整测试链路。

<a href="https://github.com/nhzhongguo/auto-vision-bridge">
  <img align="right" width="170" src="https://img.shields.io/badge/Auto%20Vision%20Bridge-AI%20Vision-6F42C1?style=for-the-badge&logo=openai&logoColor=white" alt="Auto Vision Bridge" />
</a>

### [Auto Vision Bridge — 给不会看图的 AI 装上眼睛 🆕](https://github.com/nhzhongguo/auto-vision-bridge)

给 DeepSeek / Kimi / 文心等不支持视觉的大模型自动补上看图能力：支持视觉的模型原样透传，不支持的自动调视觉模型识别成文字。零依赖中转层（Node.js ≥ 18，免安装即跑）、同图 LRU 缓存省钱省时、交互式配置向导，附赠 7 家免费视觉模型 MCP 配置。

<a href="https://github.com/nhzhongguo/3x-ui">
  <img align="right" width="170" src="https://img.shields.io/badge/3X--UI-Fork-FF6C37?style=for-the-badge&logo=x" alt="3X-UI Fork" />
</a>

### [3X-UI Fork — 二次开发版](https://github.com/nhzhongguo/3x-ui)

基于 MHSanaei/3x-ui 的维护分支。修复 Reality 空 shortId、pbk URL 编码、UUID 大小写等 5 类 Bug，全面升级 UI 布局，增强 Reality 默认值（Cloudflare dest / randomized fingerprint），新增一键复制链接、后端配置校验等功能。

<a href="https://github.com/nhzhongguo/chatgpt-win">
  <img align="right" width="170" src="https://img.shields.io/badge/ChatGPT%20Win-Phone%20Remote-10A37F?style=for-the-badge&logo=android&logoColor=white" alt="ChatGPT Win" />
</a>

### [ChatGPT Win — 手机远程控制 Windows 上的 Codex](https://github.com/nhzhongguo/chatgpt-win)

把 Windows 上的 Codex Desktop 桥接到手机：扫码即连、任务列表与聊天同步、发送图片、停止响应、新建线程、完成通知。电脑端 CDP 无感控制 + GUI/剪贴板回退，内置 token 鉴权与限流，局域网直连不经过任何第三方服务器。

<a href="https://github.com/nhzhongguo/online-testing-account">
  <img align="right" width="170" src="https://img.shields.io/badge/Online%20Testing%20Account-Account%20Health-3178C6?style=for-the-badge&logo=typescript&logoColor=white" alt="Online Testing Account" />
</a>

### [Online Testing Account — 账号存活与额度检测](https://github.com/nhzhongguo/online-testing-account)

双语 Windows / Android 账号健康检查器：串行验证账号不依赖过期时间猜状态，实时显示 Codex 5 小时 / 周期额度与剩余百分比，支持递归导入与批量清理 401。还能把 Android 手机变成带配对密钥的 OpenAI 兼容局域网 API 网关（多账号轮询）。

<a href="https://github.com/nhzhongguo/jdcloud-re-cp-02-openwrt-guide">
  <img align="right" width="170" src="https://img.shields.io/badge/OpenWrt-RE--CP--02-00A3E0?style=for-the-badge&logo=openwrt&logoColor=white" alt="RE-CP-02 OpenWrt" />
</a>

### [JDCloud RE-CP-02 OpenWrt Guide](https://github.com/nhzhongguo/jdcloud-re-cp-02-openwrt-guide)

京东云 RE-CP-02 鲁班二代的 OpenWrt 刷机与家庭网络配置教程，包含准备、刷机包校验、来源致谢和常见问题。

<br clear="right" />

## 🛠️ 折腾日志

| 时间 | 事件 |
|------|------|
| 2026-08 | 豫晨 Gitee Codex 插件市场开源：仓库、分支、上传与 PR 工作流 |
| 2026-08 | Usage Atlas 开源：多平台官方 API 用量、费用与余额仪表盘 |
| 2026-08 | 去水印解析二次开发：多平台批量解析 + 版本化 API |
| 2026-08 | Auto Vision Bridge 开源：零依赖视觉中转层 + 7 家免费视觉模型 MCP |
| 2026-07 | QQ Farm Bot：多账号自动托管 + Web 看板 + 19 渠道告警 |
| 2026-07 | ChatGPT Win：手机远程控制 Windows 上的 Codex（CDP + Android） |
| 2026-07 | Online Testing Account：账号存活与 Codex 额度检测 |
| 2026-07 | VLESS+Reality 节点搭建，服务器与路由器联动 |
| 2026-07 | 3X-UI 面板二次开发：Bug 修复 + UI 升级 + Reality 增强 |
| 2026-07 | ImmortalWrt 刷机 + overlay 迁移到 eMMC 大存储 |
| 2026-07 | PassWall / AdGuardHome / 多插件部署 |
| 2026-06 | RE-CP-02 救砖 + OpenWrt 固件编译 |

---

<div align="center">

  <sub>Build. Break. Learn. 🔨</sub>

</div>
