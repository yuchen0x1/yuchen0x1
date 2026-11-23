# 主页维护状态

更新于 2026-11-23。本仓库是 GitHub 个人主页 README 与公开项目索引，源文件为 `README.md`、`repo-descriptions.md` 和 `assets/`；没有应用运行时、数据库、安装包、自动更新客户端或软件版本号。GitHub 托管 Markdown 与 SVG，浏览器在桌面和移动端展示同一份内容。

## 当前基线

| 项目 | 状态 | 依据 |
|---|---|---|
| 公开仓库覆盖 | 36 个索引仓库（33 个个人账号仓库含本主页，3 个组织归档仓库），35 个项目，2 个个人 Fork + 1 个组织归档 Fork | 2026-11-23 GitHub 用户/组织仓库 API 与 `-CheckLinks` 校验 |
| 本地结构校验 | 通过 | `pwsh -NoProfile -File scripts/validate-readme.ps1` |
| 在线覆盖校验 | 通过 | `pwsh -NoProfile -File scripts/validate-readme.ps1 -CheckLinks`（含组织迁移仓库） |
| 远程 CI | 上次失败原因已修复 | 2026-11-19 失败由迁移后的 `themes` 仍指向个人账号造成；需观察本次推送后的运行 |
| 定期监测 | 已配置 | 每周一 03:17 UTC 检查公开仓库覆盖、状态、索引与横幅 |
| 竞品元数据扫描 | 已配置 | 每月 1 日 04:43 UTC 保存 30 个相关仓库的公开元数据为 Actions artifact；人工评估后再改动产品 |
| 公开索引快照 | 已配置 | 每月 1 日 04:47 UTC 保存个人账号与组织归档仓库的公开元数据；脚本不会覆盖人工文案 |
| Release / 更新客户端 | 不适用 | GitHub Profile README 直接随默认分支更新，无可安装产品 |
| 依赖 / 漏洞 | 无应用依赖 | 校验使用 PowerShell 和 GitHub API；仓库启用 secret scanning 和 Dependabot security updates，后者暂无依赖可更新 |
| 分支保护 | 未启用 | 2026-11-18 GitHub API 返回 main 未受保护 |
| 许可证 | 未声明 | 本仓库无 LICENSE 文件；新增内容不要假定开放源码许可 |

## 更新步骤

1. 从 GitHub 公开仓库列表和各仓库 README、Release 核对新增、迁移和归档状态。描述只写已公开证实的功能；调试版须注明。
2. 同步 `README.md` 与 `repo-descriptions.md`。调整 `assets/profile-banner.svg` 的仓库、项目、语言与 Fork 数字及描述文本。
3. 运行 `pwsh -NoProfile -File scripts/validate-readme.ps1 -CheckLinks`。此命令依赖 GitHub API；无网络或限流时另行运行不带 `-CheckLinks` 的结构校验，并将在线覆盖标为未验证。
4. 提交与推送后检查 Actions 实际结论以及 GitHub 个人主页渲染。每周定时任务失败时按日志补充公开证据后人工修订，不自动覆盖编辑过的项目描述。项目迁移到组织时，将其加入校验脚本追踪清单并在 README 使用组织 URL。

竞品扫描脚本 `python scripts/research-profiles.py` 只读取 GitHub 公开信息并输出 JSON 快照，不复制第三方 README 原文，也不更新主页。公开索引脚本 `python scripts/sync-public-index.py` 只记录个人账号和明确追踪的组织归档仓库。两个脚本都不更新主页，`GITHUB_TOKEN` 仅在进程环境中使用。参考清单与取舍见 `docs/profile-research.md`，索引维护边界见 `docs/public-index.md`。

GitHub 的定时工作流只在默认分支触发，可能延迟；公开仓库 60 天无活动时可能被停用。可用 `workflow_dispatch` 手动重跑。这里不以 Actions 失败自动改写 README，避免错误元数据进入主页。

## 平台适用性

| 候选 | 结论 | 理由 |
|---|---|---|
| 桌面 Web、移动 Web、响应式 Web | A：继续支持 | GitHub 托管的同一 README 可在浏览器阅读；需在实际 GitHub 页面检查窄屏与 SVG。 |
| Windows 10/11、Linux（Ubuntu/Debian/Fedora/Arch）、macOS Intel/Apple Silicon | C：不单独开发 | 这些系统通过浏览器访问主页，没有可独立移植的业务逻辑。 |
| Android、Android 平板、折叠屏、iOS、iPadOS | C：不单独开发 | 移动浏览器可访问；原生客户端没有额外用户价值。 |
| PWA、Chrome/Edge/Firefox 扩展 | C：不开发 | 主页信息由 GitHub 实时展示，离线安装或浏览器权限无实际用途。 |
| Docker、NAS、私有化、云服务器、CLI | C：不开发 | GitHub 已提供公开托管；仅本地 PowerShell CLI 用于维护校验。 |

## 已知限制与后续工作

- 旧的 `Codex-Remote-Bridge`、`Qzone-Archive` 个人账户 URL 目前返回 404，已从当前公开仓库清单移除。若确认新的公开归档地址，再另列历史项目，不计入个人账户仓库数。
- 公开仓库随时变化，文档日期是快照，定期检查只能发现不同步，项目介绍仍需人工判断。
- GitHub Profile 的第三方项目和发布信息在各自仓库维护。本仓库不会替它们创建跨平台安装包或更新通道。
