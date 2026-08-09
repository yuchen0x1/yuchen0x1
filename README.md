<div align="center">

  <a href="https://github.com/yuchen0x1">
    <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=25&pause=1200&color=0969DA&center=true&vCenter=true&width=680&lines=%E4%BD%A0%E5%A5%BD%EF%BC%8C%E6%88%91%E6%98%AF%E8%B1%AB%E6%99%A8;%E8%B7%AF%E7%94%B1%E5%99%A8%E6%8A%98%E8%85%BE+%C2%B7+AI+%E5%B7%A5%E5%85%B7%E9%93%BE+%C2%B7+%E5%BC%80%E6%BA%90%E5%AE%9E%E8%B7%B5;%E6%8A%8A%E9%97%AE%E9%A2%98%E5%81%9A%E6%88%90%E5%8F%AF%E5%A4%8D%E7%8E%B0%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88" alt="豫晨" />
  </a>

  <p><strong>冷漠不是神</strong> · 独立开发者 · 家庭网络与 AI 工具链实践者</p>

  <p>
    <a href="https://github.com/yuchen0x1">GitHub</a>
    ·
    <a href="https://gitee.com/yuchen0x1">Gitee</a>
    ·
    <a href="https://github.com/yuchen0x1?tab=repositories">全部项目</a>
    ·
    <a href="https://github.com/yuchen0x1/yuchen0x1/issues">交流与反馈</a>
    ·
    <a href="https://t.me/lenmoC">Telegram</a>
  </p>

  <p>
    <img src="https://img.shields.io/badge/OpenWrt-00A3E0?style=flat-square&logo=openwrt&logoColor=white" alt="OpenWrt" />
    <img src="https://img.shields.io/badge/AI%20Tooling-0969DA?style=flat-square&logo=openai&logoColor=white" alt="AI Tooling" />
    <img src="https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white" alt="TypeScript" />
    <img src="https://img.shields.io/badge/Go-00ADD8?style=flat-square&logo=go&logoColor=white" alt="Go" />
    <img src="https://img.shields.io/badge/Vue.js-42B883?style=flat-square&logo=vuedotjs&logoColor=white" alt="Vue.js" />
    <img src="https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white" alt="Docker" />
  </p>

  <p>
    <img src="https://img.shields.io/badge/QQ交流群-1016190748-12B7F5?style=flat-square&logo=tencentqq&logoColor=white" alt="QQ 交流群 1016190748" />
    <a href="https://t.me/lenmoC"><img src="https://img.shields.io/badge/Telegram-@lenmoC-26A5E4?style=flat-square&logo=telegram&logoColor=white" alt="Telegram @lenmoC" /></a>
  </p>

</div>

<p align="center">
  <em>把踩过的坑整理成文档，把重复的工作做成工具，把能复现的方案分享给需要的人。</em>
</p>

<br />

## 目录

- [现在在做什么](#现在在做什么)
- [精选项目](#精选项目)
- [技术栈](#技术栈)
- [工程原则](#工程原则)
- [项目来源与归属](#项目来源与归属)
- [近期记录](#近期记录)
- [参与方式](#参与方式)

## 现在在做什么

| 方向 | 当前重点 | 交付形式 |
| --- | --- | --- |
| 家庭网络 | OpenWrt、ImmortalWrt、Xray、Reality、旁路由与长期稳定性 | 可复现教程、配置经验、维护分支 |
| AI 工具链 | API 用量、视觉能力补齐、模型中转、Codex 工作流 | 本地工具、MCP、桌面端与网关 |
| 自动化平台 | 多账号托管、任务调度、告警、审计与备份 | Web 控制台、Worker、Docker 部署 |
| 二次开发 | 在成熟开源项目上修复真实问题，补齐安全边界与用户体验 | Fork、补丁、文档与可回滚升级 |

## 精选项目

这些项目代表了目前最完整的产品化实践。每个项目都优先解决真实使用中的痛点，并尽量提供清晰的部署、升级和故障排查路径。

### 工具与基础设施

| 项目 | 解决的问题 | 技术与特点 |
| --- | --- | --- |
| [Usage Atlas](https://github.com/yuchen0x1/usage-atlas) | 统一查看多个模型平台的官方用量、费用、限额与余额 | React / TypeScript；实时更新、玻璃风格控制台、自定义兼容平台与严格密钥边界 |
| [Auto Vision Bridge](https://github.com/yuchen0x1/vision-adapter-bridge) | 为不支持视觉的模型自动补齐看图能力 | Node.js；技能模式、透明代理、一键卸载、本地视觉后端、三类图片通道与 20+ 免费视觉模型 |
| [豫晨 Gitee Codex 插件市场](https://github.com/yuchen0x1/codex-gitee-marketplace) | 让 Codex 通过本地 MCP 服务完成 Gitee 仓库工作流 | 插件 / MCP；安全上传预览、敏感文件拦截、AI 一键安装与 Pull Request 流程 |
| [Codex Remote Bridge](https://github.com/yuchen0x1/chatgpt-win) | 将 Windows 上的 Codex Desktop 安全地桥接到手机 | Android / WPF / CDP；全文检索、定时任务时区、P50/P95 延迟、线程 TTL 与局域网直连 |

### 自动化与运营

| 项目 | 解决的问题 | 技术与特点 |
| --- | --- | --- |
| [QQ Farm Bot](https://github.com/yuchen0x1/qq-farm-bot) | 多账号农场自动托管、任务调度和运行告警 | Vue 3 / Node.js；独立 Worker、19 类告警、日报/周报/对比报告、登录安全加固与 Docker 部署 |
| [Online Testing Account](https://github.com/yuchen0x1/online-testing-account) | 检查账号存活状态与 Codex 周期额度 | TypeScript / Windows / Android；2.0 桌面端、安卓局域网 API、上游轮询容错、模型发现与真实连接测试 |
| [去水印解析](https://github.com/yuchen0x1/short-video-no-watermark-downloader) | 统一处理短视频解析、批量任务与媒体地址获取 | PHP；多平台解析、历史记录、批量停止/重试、版本化 API、限流与媒体代理 |

### 网络与二次开发

| 项目 | 解决的问题 | 技术与特点 |
| --- | --- | --- |
| [3X-UI Fork](https://github.com/yuchen0x1/3x-ui) | 修复面板真实使用中的配置问题并提升操作效率 | Go / Vue；玻璃 UI 主题、Reality 表单修复、默认值标记、配置校验与快捷复制 |
| [JDCloud RE-CP-02 OpenWrt Guide](https://github.com/yuchen0x1/jdcloud-re-cp-02-openwrt-guide) | 降低刷机、救砖、扩容和家庭网络配置的试错成本 | OpenWrt；刷机前校验、设备风险说明、全局访问备份流程与常见问题 |

## 技术栈

<table>
  <tr>
    <td width="50%" valign="top">
      <h3>产品与前端</h3>
      <p>React · Vue 3 · TypeScript · JavaScript · Vite · Next.js · Ant Design</p>
      <p>重视信息层级、键盘操作、移动端适配、空状态、错误恢复和可观测反馈。</p>
    </td>
    <td width="50%" valign="top">
      <h3>服务与数据</h3>
      <p>Go · Node.js · Python · PHP · Shell · PostgreSQL · Redis</p>
      <p>偏好清晰的边界、可回滚的变更、最小权限和适合长期运行的任务模型。</p>
    </td>
  </tr>
  <tr>
    <td width="50%" valign="top">
      <h3>网络与运维</h3>
      <p>OpenWrt · ImmortalWrt · Xray-core · Reality · Docker · systemd</p>
      <p>围绕家庭网络、VPS、代理节点、备份、日志和故障排查建立可复现流程。</p>
    </td>
    <td width="50%" valign="top">
      <h3>AI 与自动化</h3>
      <p>OpenAI · Anthropic · OpenRouter · DeepSeek · MCP · CDP</p>
      <p>优先使用官方接口，清楚标注数据来源，避免把密钥、隐私和不可逆操作带入自动化。</p>
    </td>
  </tr>
</table>

## 工程原则

1. **先可复现，再谈炫技**：部署步骤、环境要求和失败路径都应当能被别人验证。
2. **默认保护数据**：密钥不进仓库，敏感文件有拦截，远程写操作先预览再确认。
3. **功能必须可恢复**：操作有状态反馈，任务有日志，数据有备份，升级有回滚路径。
4. **界面服务于工作**：减少装饰性层级，把重点放在扫描、比较、批量操作和错误恢复。
5. **二次开发要尊重上游**：保留许可证与来源说明，尽量让改动独立、清晰、可合并。

## 项目来源与归属

以下项目是在上游开源项目基础上的二次开发或重写，使用、分发和再次修改时请同时遵守对应许可证，并保留原作者信息。

| 项目 | 上游项目 | 原作者 | 说明 |
| --- | --- | --- | --- |
| [3X-UI Fork](https://github.com/yuchen0x1/3x-ui) | [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui)；最初源自 [FranzKafkaYu/x-ui](https://github.com/FranzKafkaYu/x-ui) | MHSanaei；Franz Kafka Yu | GPL-3.0 维护分支，持续进行 UI、Reality 和配置体验改进 |
| [QQ Farm Bot](https://github.com/yuchen0x1/qq-farm-bot) | [cxw521/qq-farm-automation-bot](https://github.com/cxw521/qq-farm-automation-bot) | cxw521 | 在上游代码基础上进行产品化重构与功能扩展，许可证以双方仓库实际声明为准 |
| [去水印解析](https://github.com/yuchen0x1/short-video-no-watermark-downloader) | [5ime/video_spider](https://github.com/5ime/video_spider) | 5ime | AGPL-3.0 项目基础上的多平台解析、批量任务和 API 二次开发 |
| [Codex Remote Bridge](https://github.com/yuchen0x1/chatgpt-win) | [CoimgRain/Codex-Mini](https://github.com/CoimgRain/Codex-Mini) | CoimgRain | 参考上游本地桥接思路，重写 Windows 控制层并新增 Android 客户端 |

Usage Atlas、Auto Vision Bridge、豫晨 Gitee Codex 插件市场、Online Testing Account 和 JDCloud RE-CP-02 OpenWrt Guide 为本账号自主开发项目；其中使用到的第三方依赖、协议和数据源仍以各自许可证及官方条款为准。

## 近期记录

| 时间 | 进展 |
| --- | --- |
| 2026-08 | 重构个人主页信息架构，统一项目入口与技术方向说明 |
| 2026-08 | 多个项目连续升级：玻璃 UI、真实连接测试、报告系统、视觉技能模式与远程桥接能力持续完善 |
| 2026-08 | 发布 Gitee Codex 插件市场，补齐仓库、上传与 Pull Request 工作流 |
| 2026-08 | 发布 Usage Atlas，聚合多个平台的官方 API 用量与费用数据 |
| 2026-08 | 完善 Auto Vision Bridge，加入缓存、配置向导与视觉 MCP 配置 |
| 2026-07 | 推进 QQ Farm Bot 多账号托管、Web 看板与多渠道告警 |
| 2026-07 | 维护 3X-UI Fork，处理 Reality 配置校验和 UI 使用体验问题 |
| 2026-07 | 完成 ChatGPT Win 的手机远程控制、任务同步与局域网连接 |
| 2026-06 | 整理 RE-CP-02 救砖、OpenWrt 刷机与 eMMC 扩容流程 |

## 参与方式

- 想了解项目：从上面的精选项目进入对应仓库，优先阅读项目 README 和部署说明。
- 发现问题：提交 [Issue](https://github.com/yuchen0x1/yuchen0x1/issues)，附上系统、版本、复现步骤和日志片段。
- 想贡献代码：先在对应项目创建 Issue 说明方案，再提交范围清晰的 Pull Request。
- 需要 Gitee 镜像：访问 [Gitee 主页](https://gitee.com/yuchen0x1) 查看同步仓库。
- QQ 交流群：`1016190748`
- Telegram：[https://t.me/lenmoC](https://t.me/lenmoC)
- 加群或私聊反馈时，请备注：项目名称、问题摘要、原项目地址（如属于二次开发项目）以及当前版本。

涉及账号、网络、代理或自动化的项目，请遵守所在地法律法规、平台服务条款和上游项目许可证。示例配置中的密钥、Cookie、Token 和个人数据均不应直接复用。

<div align="center">
  <br />
  <sub>Build clearly. Operate carefully. Share what works.</sub>
</div>
