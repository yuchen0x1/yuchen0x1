# 更新记录

## [0.2.0] - 2026-11-26

### 新增

- 索引新增 `github-project-health-inspector`（WorkBuddy Skill，v1.0.0），同步主页、仓库索引与横幅计数。
- 校验脚本新增 README 叙述计数、`repo-descriptions.md` 语言/状态一致性和 GitHub 主要语言核验；新增仓库或语言变化会让 CI 给出明确错误。

### 修复

- 更正 PROJECT NEXUS 为正式版（v2.0.0 起，当前 v2.1.1），不再标注开发预览。
- 更正 AI-QQ-Bot 仅接入 QQ 开放平台官方机器人，删除不存在的 OneBot 通道描述。
- 更正 ApkStart 同时支持 Windows 与 Linux。
- 更正 Short-Video-Analysis 为覆盖 12 个平台，提供 PHP 网页版、Windows 客户端与版本化 HTTP API。
- 更正 LUMORA Camera 为 v2.1.8 正式签名稳定版，并同步索引中的签名状态。
- 同步 aa-browser 与 arco-design 的 GitHub 主要语言。
- 修复 2026-11-23 定时校验因新仓库未收录而失败的问题。

### 维护

- 更新公开仓库索引快照与维护基线：34 个个人公开仓库、3 个组织归档仓库，共 37 个索引仓库、36 个项目。
- 为横幅图片增加 `?v=0.2.0` 缓存参数，避免已访问用户继续看到 36/35 的旧计数。
- 校验脚本改为显式枚举 JSON 数组，避免不同 PowerShell 版本的行为差异；脚本以 UTF-8 BOM 保存，保证中文状态标签正确解析。

## [0.1.1] - 2026-11-23

### 文档

- 补充真实核对的 UI 生态证据与取舍，明确静态 Profile README 不引入 Web 组件运行时或第三方动态卡片。

## [0.1.0] - 2026-11-23

### 修复

- 修复个人仓库迁移到 `Indifference-Project` 后，README 在线覆盖校验仍使用旧账号 URL 导致 CI 失败的问题。
- 更正主页仓库总数、项目数、Fork 数、归档状态和横幅数字，使其与 GitHub 公开 API 一致。
- 收紧极客工具箱和 LUMORA Camera 的公开描述，避免把开发预览或历史调试包写成当前产品形态。

### 新增

- 增加组织迁移项目的可追溯索引，保留 `Qzone-Archive`、`Codex-Remote-Bridge` 和 `themes` 的公开归档入口。
- 增加 `scripts/sync-public-index.py` 和月度公开仓库元数据快照工作流；脚本只读取公开元数据，不覆盖人工文案。
- 增加安全政策、索引维护说明和当前公开事实快照。

### 维护

- 为验证、竞品扫描和公开索引快照工作流增加并发收敛，避免重复运行消耗 Actions 配额。
- 将校验脚本扩展为同时核验个人账号与明确追踪的组织仓库。
